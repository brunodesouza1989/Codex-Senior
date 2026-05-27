param(
    [string]$Url = "https://nexereabrpresales.crm.dynamics.com",
    [Parameter(Mandatory = $true)]
    [string]$Path
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

$accessToken = Get-PacDataverseToken -ResourceUrl $Url
$headers = @{
    Authorization = "Bearer $accessToken"
    Accept = "application/json"
    "OData-MaxVersion" = "4.0"
    "OData-Version" = "4.0"
}

$response = Invoke-RestMethod -Method Get -Uri "$Url/api/data/v9.2/$Path" -Headers $headers
$response | ConvertTo-Json -Depth 100
