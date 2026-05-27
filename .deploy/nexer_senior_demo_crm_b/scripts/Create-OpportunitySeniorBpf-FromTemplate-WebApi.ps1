param(
    [string]$Url = "https://nexereabrpresales.crm.dynamics.com",
    [string]$SolutionUniqueName = "nexer_senior_demo_crm_b",
    [string]$SourceWorkflowId = "138acd55-4a5b-4fe8-9af7-abbe5b94745a",
    [string]$TargetName = "Oportunidade Senior Privado"
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
        Where-Object { $_.target -like "$ResourceUrl/*" -and $_.secret -and [int64]$_.expires_on -gt ($now + 60) } |
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
        return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Body ($Body | ConvertTo-Json -Depth 40)
    }
    return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers
}

$script:AccessToken = Get-PacDataverseToken -ResourceUrl $Url

$existing = Invoke-Dv -Method Get -Path ("workflows?`$select=name,workflowid,statecode,statuscode&`$filter=name eq '$TargetName'")
if (@($existing.value).Count -gt 0) {
    $workflowId = $existing.value[0].workflowid
    Write-Host "Target BPF already exists: $TargetName / $workflowId"
} else {
    $result = Invoke-Dv -Method Post -Path "workflows($SourceWorkflowId)/Microsoft.Dynamics.CRM.CreateWorkflowFromTemplate" -Body @{ WorkflowName = $TargetName } -Prefer "return=representation"
    $workflowId = $result.workflowid
    Write-Host "Created BPF from template/action: $TargetName / $workflowId"
}

$addBody = @{
    ComponentType = 29
    ComponentId = $workflowId
    SolutionUniqueName = $SolutionUniqueName
    AddRequiredComponents = $false
}
Invoke-Dv -Method Post -Path "AddSolutionComponent" -Body $addBody | Out-Null
Write-Host "Added BPF workflow to solution: $SolutionUniqueName"

$publishBody = @{
    ParameterXml = "<importexportxml><workflows><workflow>{$workflowId}</workflow></workflows></importexportxml>"
}
try {
    Invoke-Dv -Method Post -Path "PublishXml" -Body $publishBody | Out-Null
} catch {
    Invoke-Dv -Method Post -Path "PublishAllXml" -Body @{} | Out-Null
}

$confirm = Invoke-Dv -Method Get -Path "workflows($workflowId)?`$select=name,workflowid,primaryentity,category,type,statecode,statuscode"
Write-Host ("DONE workflowid={0} state={1} status={2}" -f $confirm.workflowid, $confirm.statecode, $confirm.statuscode)
