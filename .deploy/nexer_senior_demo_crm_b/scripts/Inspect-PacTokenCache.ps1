$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Security
$cachePath = "C:\Users\Bruno Andrade\AppData\Local\Microsoft\PowerAppsCli\tokencache_msalv3.dat"
$bytes = [IO.File]::ReadAllBytes($cachePath)
$plain = [Security.Cryptography.ProtectedData]::Unprotect($bytes, $null, [Security.Cryptography.DataProtectionScope]::CurrentUser)
$json = [Text.Encoding]::UTF8.GetString($plain) | ConvertFrom-Json
$now = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()

$resourceUrl = "https://nexereabrpresales.crm.dynamics.com"
$json.AccessToken.PSObject.Properties |
    ForEach-Object { $_.Value } |
    Select-Object @{n = "target"; e = { $_.target } },
        @{n = "expires_on"; e = { $_.expires_on } },
        @{n = "valid_for_sec"; e = { [int64]$_.expires_on - $now } },
        @{n = "single_slash_match"; e = { $_.target -like "$resourceUrl/*" } },
        @{n = "double_slash_match"; e = { $_.target -like "$resourceUrl//*" } },
        @{n = "has_secret"; e = { [bool]$_.secret } } |
    Sort-Object valid_for_sec -Descending |
    Select-Object -First 20
