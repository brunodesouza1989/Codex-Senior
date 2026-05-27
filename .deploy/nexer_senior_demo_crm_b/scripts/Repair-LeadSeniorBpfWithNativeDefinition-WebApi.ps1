param(
    [string]$Url = "https://nexereabrpresales.crm.dynamics.com",
    [string]$WorkflowName = "Lead Senior",
    [string]$NativeWorkflowId = "919e14d1-6489-4852-abd0-a63a6ecaac5d"
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
    param([string]$Method, [string]$Path, [object]$Body = $null)
    $headers = @{
        Authorization = "Bearer $script:AccessToken"
        Accept = "application/json"
        "OData-MaxVersion" = "4.0"
        "OData-Version" = "4.0"
    }
    $uri = "$Url/api/data/v9.2/$Path"
    Write-Host "DV $Method $Path"
    if ($Body -ne $null) {
        return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Body ($Body | ConvertTo-Json -Depth 100)
    }
    return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers
}

$script:AccessToken = Get-PacDataverseToken -ResourceUrl $Url
$encodedName = $WorkflowName.Replace("'", "''")
$result = Invoke-Dv -Method Get -Path ("workflows?`$select=name,workflowid,statecode,statuscode&`$filter=name eq '$encodedName'")
if (@($result.value).Count -lt 1) {
    throw "Workflow '$WorkflowName' not found."
}

$workflow = $result.value[0]
$workflowId = $workflow.workflowid
$compact = $workflowId -replace "-", ""

$definitionsFolder = "C:\codex\senior\.deploy\nexer_senior_demo_crm_b\bpf-definitions"
$nativeDefinitionPath = Get-ChildItem -LiteralPath $definitionsFolder -Filter "*$NativeWorkflowId.workflow.json" | Select-Object -First 1 -ExpandProperty FullName
if (-not $nativeDefinitionPath) {
    throw "Native definition file not found for workflow $NativeWorkflowId."
}

$native = Get-Content -Raw -LiteralPath $nativeDefinitionPath | ConvertFrom-Json
$clientDataObject = $native.clientdata | ConvertFrom-Json
$clientDataObject.title = $WorkflowName
$clientDataObject.workflowEntityId = $workflowId
$clientDataObject.description = "Temporary repaired definition for safe cleanup."
$clientData = $clientDataObject | ConvertTo-Json -Depth 100 -Compress

$xaml = $native.xaml
$xaml = $xaml -replace "XrmWorkflow[0-9a-fA-F]{32}", "XrmWorkflow$compact"

Invoke-Dv -Method Patch -Path "workflows($workflowId)" -Body @{
    clientdata = $clientData
    xaml = $xaml
    description = "Temporary repaired definition for safe cleanup."
} | Out-Null

Write-Host ("Repaired workflow definition for {0}" -f $workflowId)
