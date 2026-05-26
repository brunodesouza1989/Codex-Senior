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
        return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Body ($Body | ConvertTo-Json -Depth 20)
    }
    return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers
}

$script:AccessToken = Get-PacDataverseToken -ResourceUrl $Url
$encodedName = $WorkflowName.Replace("'", "''")
$result = Invoke-Dv -Method Get -Path ("workflows?`$select=name,workflowid,uniquename,statecode,statuscode&`$filter=name eq '$encodedName'")

foreach ($workflow in @($result.value)) {
    Write-Host ("Removing BPF from solution: {0} / {1} / {2}" -f $workflow.name, $workflow.uniquename, $workflow.workflowid)
    $solution = Invoke-Dv -Method Get -Path ("solutions?`$select=solutionid&`$filter=uniquename eq '$SolutionUniqueName'")
    $solutionId = $solution.value[0].solutionid
    $components = Invoke-Dv -Method Get -Path ("solutioncomponents?`$select=solutioncomponentid,componenttype,objectid,_solutionid_value&`$filter=objectid eq $($workflow.workflowid) and componenttype eq 29")
    foreach ($component in @($components.value | Where-Object { $_."_solutionid_value" -eq $solutionId })) {
        Invoke-Dv -Method Post -Path "solutioncomponents($($component.solutioncomponentid))/Microsoft.Dynamics.CRM.RemoveSolutionComponent" -Body @{
            ComponentType = 29
            SolutionUniqueName = $SolutionUniqueName
        } | Out-Null
        Write-Host ("Removed solutioncomponent {0}" -f $component.solutioncomponentid)
    }
}
