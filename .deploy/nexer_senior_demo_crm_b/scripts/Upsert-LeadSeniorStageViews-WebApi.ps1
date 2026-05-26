param(
    [string]$Url = "https://nexereabrpresales.crm.dynamics.com",
    [string]$SolutionUniqueName = "nexer_senior_demo_crm_b",
    [string]$WorkflowName = "Lead Senior"
)

$ErrorActionPreference = "Stop"

function Get-PacDataverseToken {
    param([string]$ResourceUrl)
    Add-Type -AssemblyName System.Security
    $cachePath = "C:\Users\Bruno Andrade\AppData\Local\Microsoft\PowerAppsCli\tokencache_msalv3.dat"
    $bytes = [IO.File]::ReadAllBytes($cachePath)
    $plain = [Security.Cryptography.ProtectedData]::Unprotect($bytes, $null, [Security.Cryptography.DataProtectionScope]::CurrentUser)
    $json = [Text.Encoding]::UTF8.GetString($plain) | ConvertFrom-Json
    $now = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    $token = $json.AccessToken.PSObject.Properties |
        ForEach-Object { $_.Value } |
        Where-Object { ($_.target -like "$ResourceUrl/*") -and $_.secret -and ([int64]$_.expires_on -gt ($now + 60)) } |
        Sort-Object { [int64]$_.expires_on } -Descending |
        Select-Object -First 1
    if (-not $token) { throw "No valid PAC Dataverse token found for $ResourceUrl" }
    return $token.secret
}

function Invoke-Dv {
    param([string]$Method, [string]$Path, [object]$Body = $null, [string]$Prefer = $null)
    $headers = @{
        Authorization = "Bearer $script:AccessToken"
        Accept = "application/json"
        "OData-MaxVersion" = "4.0"
        "OData-Version" = "4.0"
    }
    if ($Prefer) { $headers["Prefer"] = $Prefer }
    $uri = "$Url/api/data/v9.2/$Path"
    Write-Host "DV $Method $Path"
    if ($Body -ne $null) {
        return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Body ($Body | ConvertTo-Json -Depth 80)
    }
    return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers
}

function XmlEscape([string]$Value) {
    return [System.Security.SecurityElement]::Escape($Value)
}

function New-LayoutXml {
    return @"
<grid name="resultset" object="4" jump="fullname" select="1" icon="1" preview="1">
  <row name="result" id="leadid">
    <cell name="fullname" width="180" />
    <cell name="companyname" width="180" />
    <cell name="leadsourcecode" width="130" />
    <cell name="prioritycode" width="120" />
    <cell name="msdyncrm_scores" width="100" />
    <cell name="ownerid" width="160" />
    <cell name="description" width="240" />
    <cell name="nexer_interessedocliente" width="160" />
    <cell name="createdon" width="140" />
  </row>
</grid>
"@
}

function New-FetchXml {
    param([string]$BpfEntityName, [string]$StageId)
    return @"
<fetch version="1.0" mapping="logical" distinct="false">
  <entity name="lead">
    <attribute name="fullname" />
    <attribute name="companyname" />
    <attribute name="leadsourcecode" />
    <attribute name="prioritycode" />
    <attribute name="msdyncrm_scores" />
    <attribute name="ownerid" />
    <attribute name="description" />
    <attribute name="nexer_interessedocliente" />
    <attribute name="createdon" />
    <filter type="and">
      <condition attribute="statecode" operator="eq" value="0" />
    </filter>
    <link-entity name="$BpfEntityName" from="bpf_leadid" to="leadid" link-type="inner" alias="seniorbpf">
      <filter type="and">
        <condition attribute="statecode" operator="eq" value="0" />
        <condition attribute="statuscode" operator="eq" value="1" />
        <condition attribute="activestageid" operator="eq" value="$StageId" />
      </filter>
    </link-entity>
    <order attribute="createdon" descending="true" />
  </entity>
</fetch>
"@
}

function Add-SolutionComponent {
    param([string]$ComponentId)
    try {
        Invoke-Dv -Method Post -Path "AddSolutionComponent" -Body @{
            ComponentId = $ComponentId
            ComponentType = 26
            SolutionUniqueName = $SolutionUniqueName
            AddRequiredComponents = $false
            IncludedComponentSettingsValues = $null
        } | Out-Null
        Write-Host "Added view to solution: $ComponentId"
    } catch {
        Write-Host "AddSolutionComponent skipped/failed for ${ComponentId}: $($_.Exception.Message)"
    }
}

$script:AccessToken = Get-PacDataverseToken -ResourceUrl $Url

$workflowNameEscaped = $WorkflowName.Replace("'", "''")
$workflowResult = Invoke-Dv -Method Get -Path ("workflows?`$select=workflowid,uniquename,statecode,statuscode&`$filter=name eq '$workflowNameEscaped'")
if (@($workflowResult.value).Count -lt 1) {
    throw "Workflow '$WorkflowName' not found."
}
$workflow = $workflowResult.value[0]
$bpfEntityName = $workflow.uniquename
Write-Host "Using BPF entity: $bpfEntityName"

$stageResult = Invoke-Dv -Method Get -Path ("processstages?`$select=processstageid,stagename&`$filter=_processid_value eq $($workflow.workflowid)")
$stageMap = @{}
foreach ($stage in @($stageResult.value)) {
    $stageMap[$stage.stagename] = $stage.processstageid
}

$stageNames = @("Entrada", "Filtro 1", "Filtro 2", "Agendado", "Qualificado")
foreach ($stageName in $stageNames) {
    if (-not $stageMap.ContainsKey($stageName)) {
        throw "Stage '$stageName' not found for workflow '$WorkflowName'."
    }

    $viewName = "Senior 360 | Leads - $stageName"
    $viewNameEscaped = $viewName.Replace("'", "''")
    $fetchXml = New-FetchXml -BpfEntityName $bpfEntityName -StageId $stageMap[$stageName]
    $layoutXml = New-LayoutXml
    $body = @{
        name = $viewName
        returnedtypecode = "lead"
        querytype = 0
        fetchxml = $fetchXml
        layoutxml = $layoutXml
        description = "Leads Senior na etapa $stageName do BPF Lead Senior."
        isdefault = $false
    }

    $existing = Invoke-Dv -Method Get -Path ("savedqueries?`$select=savedqueryid,name&`$filter=returnedtypecode eq 'lead' and querytype eq 0 and name eq '$viewNameEscaped'")
    if (@($existing.value).Count -gt 0) {
        $viewId = $existing.value[0].savedqueryid
        Invoke-Dv -Method Patch -Path "savedqueries($viewId)" -Body $body | Out-Null
        Write-Host "Updated view: $viewName ($viewId)"
    } else {
        $created = Invoke-Dv -Method Post -Path "savedqueries" -Body $body -Prefer "return=representation"
        $viewId = $created.savedqueryid
        Write-Host "Created view: $viewName ($viewId)"
    }

    Add-SolutionComponent -ComponentId $viewId
}

Invoke-Dv -Method Post -Path "PublishXml" -Body @{
    ParameterXml = "<importexportxml><entities><entity>lead</entity></entities></importexportxml>"
} | Out-Null
Write-Host "Published Lead views."
