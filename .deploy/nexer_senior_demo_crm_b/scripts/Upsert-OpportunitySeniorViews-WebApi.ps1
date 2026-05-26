param(
    [string]$Url = "https://nexereabrpresales.crm.dynamics.com",
    [string]$SolutionUniqueName = "nexer_senior_demo_crm_b"
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

function New-LayoutXml {
    return @"
<grid name="resultset" object="3" jump="name" select="1" icon="1" preview="1">
  <row name="result" id="opportunityid">
    <cell name="name" width="260" />
    <cell name="customerid" width="170" />
    <cell name="salesstagecode" width="140" />
    <cell name="estimatedvalue" width="120" />
    <cell name="closeprobability" width="110" />
    <cell name="estimatedclosedate" width="130" />
    <cell name="discountpercentage" width="110" />
    <cell name="ownerid" width="160" />
    <cell name="statuscode" width="140" />
    <cell name="modifiedon" width="140" />
  </row>
</grid>
"@
}

function New-FetchXml {
    param([string]$FilterName)
    $filter = switch ($FilterName) {
        "open" {
@"
      <condition attribute="statecode" operator="eq" value="0" />
"@
        }
        "mine" {
@"
      <condition attribute="statecode" operator="eq" value="0" />
      <condition attribute="ownerid" operator="eq-userid" />
"@
        }
        "proposal" {
@"
      <condition attribute="statecode" operator="eq" value="0" />
      <filter type="or">
        <condition attribute="proposedsolution" operator="not-null" />
        <condition attribute="developproposal" operator="eq" value="1" />
        <condition attribute="presentproposal" operator="eq" value="1" />
      </filter>
"@
        }
        "discount" {
@"
      <condition attribute="statecode" operator="eq" value="0" />
      <filter type="or">
        <condition attribute="discountpercentage" operator="gt" value="0" />
        <condition attribute="discountamount" operator="gt" value="0" />
        <condition attribute="totaldiscountamount" operator="gt" value="0" />
      </filter>
"@
        }
        "closing" {
@"
      <condition attribute="statecode" operator="eq" value="0" />
      <condition attribute="estimatedclosedate" operator="next-x-days" value="30" />
"@
        }
        "won" {
@"
      <condition attribute="statecode" operator="eq" value="1" />
"@
        }
    }

    $valueOrder = if ($FilterName -eq "won") { "actualvalue" } else { "estimatedvalue" }
    return @"
<fetch version="1.0" mapping="logical" distinct="false">
  <entity name="opportunity">
    <attribute name="name" />
    <attribute name="customerid" />
    <attribute name="salesstagecode" />
    <attribute name="estimatedvalue" />
    <attribute name="actualvalue" />
    <attribute name="closeprobability" />
    <attribute name="estimatedclosedate" />
    <attribute name="actualclosedate" />
    <attribute name="discountpercentage" />
    <attribute name="discountamount" />
    <attribute name="totaldiscountamount" />
    <attribute name="ownerid" />
    <attribute name="statuscode" />
    <attribute name="modifiedon" />
    <attribute name="opportunityid" />
    <filter type="and">
$filter
    </filter>
    <order attribute="$valueOrder" descending="true" />
    <order attribute="estimatedclosedate" descending="false" />
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

$views = @(
    @{ Name = "Senior 360 | Oportunidades - Pipeline aberto"; Filter = "open"; Description = "Oportunidades abertas do pipeline Senior." },
    @{ Name = "Senior 360 | Oportunidades - Minha carteira"; Filter = "mine"; Description = "Oportunidades abertas do usuario atual." },
    @{ Name = "Senior 360 | Oportunidades - Proposta e CPQ/GPS"; Filter = "proposal"; Description = "Oportunidades com proposta ou solucao registrada." },
    @{ Name = "Senior 360 | Oportunidades - Desconto e aprovacao"; Filter = "discount"; Description = "Oportunidades abertas com desconto informado para acompanhamento de aprovacao." },
    @{ Name = "Senior 360 | Oportunidades - Fechamento 30 dias"; Filter = "closing"; Description = "Oportunidades abertas com fechamento previsto nos proximos 30 dias." },
    @{ Name = "Senior 360 | Oportunidades - Ganhas"; Filter = "won"; Description = "Oportunidades ganhas para narrativa de fechamento e integracao." }
)

foreach ($view in $views) {
    $viewNameEscaped = $view.Name.Replace("'", "''")
    $body = @{
        name = $view.Name
        returnedtypecode = "opportunity"
        querytype = 0
        fetchxml = (New-FetchXml -FilterName $view.Filter)
        layoutxml = (New-LayoutXml)
        description = $view.Description
        isdefault = $false
    }

    $existing = Invoke-Dv -Method Get -Path ("savedqueries?`$select=savedqueryid,name&`$filter=returnedtypecode eq 'opportunity' and querytype eq 0 and name eq '$viewNameEscaped'")
    if (@($existing.value).Count -gt 0) {
        $viewId = $existing.value[0].savedqueryid
        Invoke-Dv -Method Patch -Path "savedqueries($viewId)" -Body $body | Out-Null
        Write-Host "Updated view: $($view.Name) ($viewId)"
    } else {
        $created = Invoke-Dv -Method Post -Path "savedqueries" -Body $body -Prefer "return=representation"
        $viewId = $created.savedqueryid
        Write-Host "Created view: $($view.Name) ($viewId)"
    }

    Add-SolutionComponent -ComponentId $viewId
}

Invoke-Dv -Method Post -Path "PublishXml" -Body @{
    ParameterXml = "<importexportxml><entities><entity>opportunity</entity></entities></importexportxml>"
} | Out-Null
Write-Host "Published Opportunity views."
