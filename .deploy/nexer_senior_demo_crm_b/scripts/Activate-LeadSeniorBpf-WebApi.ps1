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

function Get-ResponseBody {
    param([System.Management.Automation.ErrorRecord]$ErrorRecord)
    if (-not $ErrorRecord.Exception.Response) { return $ErrorRecord.Exception.Message }
    $stream = $ErrorRecord.Exception.Response.GetResponseStream()
    if (-not $stream) { return $ErrorRecord.Exception.Message }
    $reader = New-Object IO.StreamReader($stream)
    return $reader.ReadToEnd()
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
Write-Host ("Before: state={0} status={1}" -f $workflow.statecode, $workflow.statuscode)

$attempts = @(
    @{ Method = "Patch"; Path = "workflows($workflowId)"; Body = @{ statecode = 1; statuscode = 2 } },
    @{ Method = "Post"; Path = "workflows($workflowId)/Microsoft.Dynamics.CRM.SetState"; Body = @{ State = 1; Status = 2 } },
    @{ Method = "Post"; Path = "SetState"; Body = @{ EntityMoniker = @{ "@odata.type" = "Microsoft.Dynamics.CRM.workflow"; workflowid = $workflowId }; State = 1; Status = 2 } },
    @{ Method = "Post"; Path = "Microsoft.Dynamics.CRM.SetState"; Body = @{ EntityMoniker = @{ "@odata.type" = "Microsoft.Dynamics.CRM.workflow"; workflowid = $workflowId }; State = 1; Status = 2 } }
)

foreach ($attempt in $attempts) {
    try {
        Invoke-Dv -Method $attempt.Method -Path $attempt.Path -Body $attempt.Body | Out-Null
        Write-Host ("Activation succeeded via {0} {1}" -f $attempt.Method, $attempt.Path)
        break
    } catch {
        Write-Host ("Activation attempt failed via {0} {1}" -f $attempt.Method, $attempt.Path)
        Write-Host (Get-ResponseBody -ErrorRecord $_)
    }
}

try {
    Invoke-Dv -Method Post -Path "PublishXml" -Body @{ ParameterXml = "<importexportxml><workflows><workflow>{$workflowId}</workflow></workflows></importexportxml>" } | Out-Null
} catch {
    Write-Host "Targeted publish failed; using PublishAllXml."
    Invoke-Dv -Method Post -Path "PublishAllXml" -Body @{} | Out-Null
}

$confirm = Invoke-Dv -Method Get -Path "workflows($workflowId)?`$select=name,workflowid,statecode,statuscode"
Write-Host ("After: state={0} status={1}" -f $confirm.statecode, $confirm.statuscode)
