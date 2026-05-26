param(
    [string]$Url = "https://nexereabrpresales.crm.dynamics.com",
    [string]$SolutionUniqueName = "nexer_senior_demo_crm_b",
    [string]$SourceWorkflowId = "f3e1f376-5d69-4dff-bd4b-9cb6a41ce6e4",
    [string]$TargetName = "Lead Senior",
    [string]$TargetUniqueName = "nexer_bpf_leadsenior"
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
    $tokens = $json.AccessToken.PSObject.Properties | ForEach-Object { $_.Value }
    $token = $tokens |
        Where-Object {
            $_.target -like "$ResourceUrl/*" -and
            $_.secret -and
            [int64]$_.expires_on -gt ($now + 60)
        } |
        Sort-Object { [int64]$_.expires_on } -Descending |
        Select-Object -First 1

    if (-not $token) {
        throw "No valid PAC Dataverse token found for $ResourceUrl"
    }

    return $token.secret
}

function Invoke-Dv {
    param(
        [string]$Method,
        [string]$Path,
        [object]$Body = $null,
        [string]$Prefer = $null
    )

    $headers = @{
        Authorization = "Bearer $script:AccessToken"
        Accept = "application/json"
        "OData-MaxVersion" = "4.0"
        "OData-Version" = "4.0"
    }

    if ($Prefer) {
        $headers["Prefer"] = $Prefer
    }

    $uri = "$Url/api/data/v9.2/$Path"
    Write-Host "DV $Method $Path"
    if ($Body -ne $null) {
        $jsonBody = $Body | ConvertTo-Json -Depth 80
        return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Body $jsonBody
    }

    return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers
}

function New-GuidString {
    return [guid]::NewGuid().ToString()
}

function Replace-WorkflowIdentity {
    param(
        [string]$Text,
        [string]$OldWorkflowId,
        [string]$NewWorkflowId
    )

    $oldCompact = $OldWorkflowId -replace "-", ""
    $newCompact = $NewWorkflowId -replace "-", ""
    $result = $Text.Replace($OldWorkflowId, $NewWorkflowId)
    $result = $result.Replace($OldWorkflowId.ToUpperInvariant(), $NewWorkflowId.ToUpperInvariant())
    $result = $result.Replace($oldCompact, $newCompact)
    $result = $result.Replace($oldCompact.ToUpperInvariant(), $newCompact.ToUpperInvariant())
    return $result
}

$script:AccessToken = Get-PacDataverseToken -ResourceUrl $Url
Write-Host "Using PAC Dataverse token from local cache"

$existingByUniqueName = Invoke-Dv -Method Get -Path ("workflows?`$select=name,workflowid,uniquename,statecode,statuscode&`$filter=uniquename eq '$TargetUniqueName'")
$existingByName = Invoke-Dv -Method Get -Path ("workflows?`$select=name,workflowid,uniquename,statecode,statuscode&`$filter=name eq '$TargetName'")
$existingValues = @($existingByUniqueName.value) + @($existingByName.value)
if ($existingValues.Count -gt 0) {
    $targetWorkflowId = $existingValues[0].workflowid
    Write-Host "Target BPF already exists: $TargetName / $targetWorkflowId"
} else {
    $source = Invoke-Dv -Method Get -Path "workflows($SourceWorkflowId)?`$select=name,workflowid,uniquename,primaryentity,category,type,mode,xaml,clientdata"
    $targetWorkflowId = New-GuidString
    $targetCompact = $targetWorkflowId -replace "-", ""

    $xaml = Replace-WorkflowIdentity -Text ([string]$source.xaml) -OldWorkflowId $SourceWorkflowId -NewWorkflowId $targetWorkflowId
    $clientData = Replace-WorkflowIdentity -Text ([string]$source.clientdata) -OldWorkflowId $SourceWorkflowId -NewWorkflowId $targetWorkflowId

    $clientData = $clientData.Replace('"title":"Weg - Cliente Potencial até a Oportunidade"', ('"title":"' + $TargetName + '"'))
    $clientData = $clientData.Replace('"title":"Processo de Vendas do Cliente Potencial até a Oportunidade"', ('"title":"' + $TargetName + '"'))

    $createBody = @{
        workflowid = $targetWorkflowId
        name = $TargetName
        uniquename = $TargetUniqueName
        primaryentity = "lead"
        category = 4
        type = 1
        mode = 0
        businessprocesstype = 0
        description = "BPF Senior para qualificacao de Cliente Potencial: Entrada, Filtro 1, Filtro 2, Agendado e Qualificado."
        xaml = $xaml
        clientdata = $clientData
    }

    $created = Invoke-Dv -Method Post -Path "workflows" -Body $createBody -Prefer "return=representation"
    $targetWorkflowId = $created.workflowid
    Write-Host "Created BPF draft: $TargetName / $targetWorkflowId"
}

$addBody = @{
    ComponentType = 29
    ComponentId = $targetWorkflowId
    SolutionUniqueName = $SolutionUniqueName
    AddRequiredComponents = $false
}
Invoke-Dv -Method Post -Path "AddSolutionComponent" -Body $addBody | Out-Null
Write-Host "Added BPF workflow to solution: $SolutionUniqueName"

try {
    $activateBody = @{
        EntityMoniker = @{
            "@odata.type" = "Microsoft.Dynamics.CRM.workflow"
            workflowid = $targetWorkflowId
        }
        State = 1
        Status = 2
    }
    Invoke-Dv -Method Post -Path "SetState" -Body $activateBody | Out-Null
    Write-Host "Activated BPF"
} catch {
    Write-Host "Activation failed, leaving BPF as draft. Error follows:"
    Write-Host $_.Exception.Message
}

$publishBody = @{
    ParameterXml = "<importexportxml><workflows><workflow>{$targetWorkflowId}</workflow></workflows></importexportxml>"
}
try {
    Invoke-Dv -Method Post -Path "PublishXml" -Body $publishBody | Out-Null
    Write-Host "Published BPF customization"
} catch {
    Write-Host "Workflow-specific publish failed; falling back to publish all customizations."
    Invoke-Dv -Method Post -Path "PublishAllXml" -Body @{} | Out-Null
    Write-Host "Published all customizations"
}

$confirm = Invoke-Dv -Method Get -Path "workflows($targetWorkflowId)?`$select=name,workflowid,uniquename,primaryentity,category,type,statecode,statuscode"
Write-Host ("DONE workflowid={0} state={1} status={2}" -f $confirm.workflowid, $confirm.statecode, $confirm.statuscode)
