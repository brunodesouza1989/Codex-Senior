param(
    [string]$Url = "https://nexereabrpresales.crm.dynamics.com",
    [string]$SolutionUniqueName = "nexer_senior_demo_crm_b",
    [Parameter(Mandatory = $true)]
    [string]$TableLogicalName,
    [Parameter(Mandatory = $true)]
    [string]$SourceFormName,
    [Parameter(Mandatory = $true)]
    [string]$TargetFormName,
    [string]$Description = "Formulario Senior Demo baseado em formulario existente."
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
        return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Body ($Body | ConvertTo-Json -Depth 80)
    }
    return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers
}

$script:AccessToken = Get-PacDataverseToken -ResourceUrl $Url

$sourceName = $SourceFormName.Replace("'", "''")
$targetName = $TargetFormName.Replace("'", "''")
$sourceResult = Invoke-Dv -Method Get -Path ("systemforms?`$select=name,formid,formxml,type,formactivationstate,formpresentation,objecttypecode&`$filter=name eq '$sourceName' and objecttypecode eq '$TableLogicalName' and type eq 2")
if (@($sourceResult.value).Count -lt 1) {
    throw "Source form '$SourceFormName' for '$TableLogicalName' was not found."
}
$sourceForm = $sourceResult.value[0]

$existingResult = Invoke-Dv -Method Get -Path ("systemforms?`$select=name,formid,objecttypecode&`$filter=name eq '$targetName' and objecttypecode eq '$TableLogicalName' and type eq 2")
if (@($existingResult.value).Count -gt 0) {
    $targetId = $existingResult.value[0].formid
    Write-Host "Target form already exists: $TargetFormName / $targetId"
} else {
    $created = Invoke-Dv -Method Post -Path "systemforms" -Prefer "return=representation" -Body @{
        name = $TargetFormName
        description = $Description
        objecttypecode = $TableLogicalName
        type = 2
        formactivationstate = 1
        formpresentation = 1
        formxml = [string]$sourceForm.formxml
    }
    $targetId = $created.formid
    Write-Host "Created target form: $TargetFormName / $targetId"
}

Invoke-Dv -Method Post -Path "AddSolutionComponent" -Body @{
    ComponentType = 60
    ComponentId = $targetId
    SolutionUniqueName = $SolutionUniqueName
    AddRequiredComponents = $false
} | Out-Null
Write-Host "Added form to solution: $SolutionUniqueName"

Invoke-Dv -Method Post -Path "PublishXml" -Body @{
    ParameterXml = "<importexportxml><entities><entity>$TableLogicalName</entity></entities></importexportxml>"
} | Out-Null
Write-Host "Published $TableLogicalName customizations"

Write-Host "DONE table=$TableLogicalName formid=$targetId"
