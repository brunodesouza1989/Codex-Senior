param(
    [string]$Url = "https://nexereabrpresales.crm.dynamics.com",
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
    param([string]$Method, [string]$Path, [object]$Body = $null)
    $headers = @{
        Authorization = "Bearer $script:AccessToken"
        Accept = "application/json"
        "OData-MaxVersion" = "4.0"
        "OData-Version" = "4.0"
    }
    $uri = "$Url/api/data/v9.2/$Path"
    if ($Body -ne $null) {
        return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Body ($Body | ConvertTo-Json -Depth 40)
    }
    return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers
}

function Get-StepFields {
    param([object]$Step)
    $fields = @()
    foreach ($child in @($Step.steps.list)) {
        if ($child.PSObject.Properties.Name -contains "dataFieldName") {
            $fields += $child.dataFieldName
        }
        if ($child.PSObject.Properties.Name -contains "steps") {
            $fields += Get-StepFields -Step $child
        }
    }
    return $fields
}

$script:AccessToken = Get-PacDataverseToken -ResourceUrl $Url

$encodedName = $WorkflowName.Replace("'", "''")
$result = Invoke-Dv -Method Get -Path ("workflows?`$select=name,workflowid,uniquename,primaryentity,category,type,statecode,statuscode,clientdata&`$filter=name eq '$encodedName'")
if (@($result.value).Count -lt 1) {
    throw "Workflow '$WorkflowName' not found."
}

$workflow = $result.value[0]
$clientData = $workflow.clientdata | ConvertFrom-Json
$entityStep = $clientData.steps.list[0]

Write-Host ("Name: {0}" -f $workflow.name)
Write-Host ("WorkflowId: {0}" -f $workflow.workflowid)
Write-Host ("UniqueName: {0}" -f $workflow.uniquename)
Write-Host ("PrimaryEntity: {0}" -f $workflow.primaryentity)
Write-Host ("State/Status: {0}/{1}" -f $workflow.statecode, $workflow.statuscode)
Write-Host "Stages:"

foreach ($stage in @($entityStep.steps.list)) {
    $label = $stage.stepLabels.list[0].description
    $fields = Get-StepFields -Step $stage
    Write-Host ("- {0}: {1}" -f $label, ($fields -join ", "))
}
