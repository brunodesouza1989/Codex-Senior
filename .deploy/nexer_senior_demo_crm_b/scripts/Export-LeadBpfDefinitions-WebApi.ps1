param(
    [string]$Url = "https://nexereabrpresales.crm.dynamics.com",
    [string]$OutputFolder = "C:\codex\senior\.deploy\nexer_senior_demo_crm_b\bpf-definitions"
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

$accessToken = Get-PacDataverseToken -ResourceUrl $Url
$headers = @{
    Authorization = "Bearer $accessToken"
    Accept = "application/json"
    "OData-MaxVersion" = "4.0"
    "OData-Version" = "4.0"
}

New-Item -ItemType Directory -Force -Path $OutputFolder | Out-Null

$query = "workflows?`$select=name,workflowid,uniquename,primaryentity,category,type,mode,statecode,statuscode,xaml,clientdata&`$filter=category eq 4"
$result = Invoke-RestMethod -Method Get -Uri "$Url/api/data/v9.2/$query" -Headers $headers
$leadBpfs = @($result.value | Where-Object { $_.primaryentity -eq "lead" -or $_.name -like "*Cliente Potencial*" })

$summary = @()
foreach ($bpf in $leadBpfs) {
    $safeName = ($bpf.name -replace '[\\/:*?"<>|]', '_')
    $prefix = Join-Path $OutputFolder "$safeName-$($bpf.workflowid)"
    $bpf.clientdata | Set-Content -LiteralPath "$prefix.clientdata.json" -Encoding UTF8
    $bpf.xaml | Set-Content -LiteralPath "$prefix.xaml.xml" -Encoding UTF8
    ($bpf | ConvertTo-Json -Depth 10) | Set-Content -LiteralPath "$prefix.workflow.json" -Encoding UTF8
    $summary += [pscustomobject]@{
        Name = $bpf.name
        WorkflowId = $bpf.workflowid
        UniqueName = $bpf.uniquename
        PrimaryEntity = $bpf.primaryentity
        StateCode = $bpf.statecode
        StatusCode = $bpf.statuscode
    }
}

$summary | Format-Table -AutoSize
