param(
    [string]$Url = "https://nexereabrpresales.crm.dynamics.com",
    [string]$WorkflowName = "Lead Senior",
    [ValidateSet("Active", "Draft")]
    [string]$State = "Draft"
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
        return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Body ($Body | ConvertTo-Json -Depth 40)
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
Write-Host ("Before: workflowid={0} state={1} status={2}" -f $workflowId, $workflow.statecode, $workflow.statuscode)

if ($State -eq "Active") {
    $targetState = 1
    $targetStatus = 2
} else {
    $targetState = 0
    $targetStatus = 1
}

$attempts = @(
    @{ Method = "Patch"; Path = "workflows($workflowId)"; Body = @{ statecode = $targetState; statuscode = $targetStatus } },
    @{ Method = "Post"; Path = "workflows($workflowId)/Microsoft.Dynamics.CRM.SetState"; Body = @{ State = $targetState; Status = $targetStatus } },
    @{ Method = "Post"; Path = "SetState"; Body = @{ EntityMoniker = @{ "@odata.type" = "Microsoft.Dynamics.CRM.workflow"; workflowid = $workflowId }; State = $targetState; Status = $targetStatus } },
    @{ Method = "Post"; Path = "Microsoft.Dynamics.CRM.SetState"; Body = @{ EntityMoniker = @{ "@odata.type" = "Microsoft.Dynamics.CRM.workflow"; workflowid = $workflowId }; State = $targetState; Status = $targetStatus } }
)

$changed = $false
foreach ($attempt in $attempts) {
    try {
        Invoke-Dv -Method $attempt.Method -Path $attempt.Path -Body $attempt.Body | Out-Null
        $changed = $true
        break
    } catch {
        Write-Host ("SetState attempt failed via {0} {1}: {2}" -f $attempt.Method, $attempt.Path, $_.Exception.Message)
    }
}
if (-not $changed) {
    throw "Unable to set workflow state to $State."
}

$confirm = Invoke-Dv -Method Get -Path "workflows($workflowId)?`$select=name,workflowid,statecode,statuscode"
Write-Host ("After: workflowid={0} state={1} status={2}" -f $confirm.workflowid, $confirm.statecode, $confirm.statuscode)
