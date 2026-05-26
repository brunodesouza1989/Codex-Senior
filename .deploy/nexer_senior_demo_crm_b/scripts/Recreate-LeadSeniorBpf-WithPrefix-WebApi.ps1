param(
    [string]$Url = "https://nexereabrpresales.crm.dynamics.com",
    [string]$SolutionUniqueName = "nexer_senior_demo_crm_b",
    [string]$SourceWorkflowId = "f3e1f376-5d69-4dff-bd4b-9cb6a41ce6e4",
    [string]$DisplayName = "Lead Senior",
    [string]$TechnicalName = "nexer_bpf_leadsenior"
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
        return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Body ($Body | ConvertTo-Json -Depth 40)
    }
    return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers
}

$script:AccessToken = Get-PacDataverseToken -ResourceUrl $Url

foreach ($name in @($DisplayName, $TechnicalName)) {
    $encodedName = $name.Replace("'", "''")
    $existing = Invoke-Dv -Method Get -Path ("workflows?`$select=name,workflowid,uniquename,statecode,statuscode&`$filter=name eq '$encodedName'")
    foreach ($workflow in @($existing.value)) {
        if ([int]$workflow.statecode -eq 0) {
            Write-Host ("Deleting draft BPF {0} / {1} / {2}" -f $workflow.name, $workflow.uniquename, $workflow.workflowid)
            Invoke-Dv -Method Delete -Path "workflows($($workflow.workflowid))" | Out-Null
        } else {
            Write-Host ("Keeping non-draft BPF {0} / {1} / {2}" -f $workflow.name, $workflow.uniquename, $workflow.workflowid)
        }
    }
}

$created = Invoke-Dv -Method Post -Path "workflows($SourceWorkflowId)/Microsoft.Dynamics.CRM.CreateWorkflowFromTemplate" -Body @{ WorkflowName = $TechnicalName } -Prefer "return=representation"
$workflowId = $created.workflowid
Write-Host ("Created BPF from template: {0} / {1}" -f $TechnicalName, $workflowId)

Invoke-Dv -Method Patch -Path "workflows($workflowId)" -Body @{
    name = $DisplayName
    processorder = 1
} | Out-Null

Invoke-Dv -Method Post -Path "AddSolutionComponent" -Body @{
    ComponentType = 29
    ComponentId = $workflowId
    SolutionUniqueName = $SolutionUniqueName
    AddRequiredComponents = $false
} | Out-Null

$confirm = Invoke-Dv -Method Get -Path "workflows($workflowId)?`$select=name,workflowid,uniquename,statecode,statuscode"
Write-Host ("DONE workflowid={0} name={1} uniquename={2} state={3} status={4}" -f $confirm.workflowid, $confirm.name, $confirm.uniquename, $confirm.statecode, $confirm.statuscode)
