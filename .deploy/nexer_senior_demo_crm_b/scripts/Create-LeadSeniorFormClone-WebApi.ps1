param(
    [string]$Url = "https://nexereabrpresales.crm.dynamics.com",
    [string]$SolutionUniqueName = "nexer_senior_demo_crm_b",
    [string]$SourceFormName = "Sales Insights",
    [string]$TargetFormName = "Cliente Potencial Senior"
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

function Invoke-Dv {
    param(
        [string]$Method,
        [string]$Path,
        [object]$Body = $null,
        [string]$Prefer = $null
    )

    $headers = @{
        Authorization = "Bearer $script:AccessToken"
        Accept = "application/json"
        "OData-MaxVersion" = "4.0"
        "OData-Version" = "4.0"
    }

    if ($Prefer) {
        $headers["Prefer"] = $Prefer
    }

    $uri = "$Url/api/data/v9.2/$Path"
    if ($Body -ne $null) {
        $jsonBody = $Body | ConvertTo-Json -Depth 50
        return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Body $jsonBody
    }

    return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers
}

$script:AccessToken = Get-PacDataverseToken -ResourceUrl $Url
Write-Host "Using PAC Dataverse token from local cache"

$encodedSourceName = $SourceFormName.Replace("'", "''")
$sourceResult = Invoke-Dv -Method Get -Path ("systemforms?`$select=name,formid,formxml,type,formactivationstate,formpresentation,objecttypecode&`$filter=name eq '$encodedSourceName'")
$sourceForms = @($sourceResult.value | Where-Object { $_.objecttypecode -eq "lead" -or $_.objecttypecode -eq 4 -or $_.objecttypecode -eq "4" })

if ($sourceForms.Count -lt 1) {
    throw "Source form '$SourceFormName' for Lead was not found."
}

$sourceForm = $sourceForms[0]

$encodedTargetName = $TargetFormName.Replace("'", "''")
$existingResult = Invoke-Dv -Method Get -Path ("systemforms?`$select=name,formid,objecttypecode&`$filter=name eq '$encodedTargetName'")
$existingForms = @($existingResult.value | Where-Object { $_.objecttypecode -eq "lead" -or $_.objecttypecode -eq 4 -or $_.objecttypecode -eq "4" })

if ($existingForms.Count -gt 0) {
    $targetId = $existingForms[0].formid
    Write-Host "Target form already exists: $TargetFormName / $targetId"
} else {
    $createBody = @{
        name = $TargetFormName
        description = "Formulario de Cliente Potencial para a demo Senior, baseado em Sales Insights."
        objecttypecode = "lead"
        type = 2
        formactivationstate = 1
        formpresentation = 1
        formxml = [string]$sourceForm.formxml
    }

    $createResult = Invoke-Dv -Method Post -Path "systemforms" -Body $createBody -Prefer "return=representation"
    $targetId = $createResult.formid
    Write-Host "Created target form: $TargetFormName / $targetId"
}

$addBody = @{
    ComponentType = 60
    ComponentId = $targetId
    SolutionUniqueName = $SolutionUniqueName
    AddRequiredComponents = $false
}
Invoke-Dv -Method Post -Path "AddSolutionComponent" -Body $addBody | Out-Null
Write-Host "Added form to solution: $SolutionUniqueName"

$publishBody = @{
    ParameterXml = "<importexportxml><entities><entity>lead</entity></entities></importexportxml>"
}
Invoke-Dv -Method Post -Path "PublishXml" -Body $publishBody | Out-Null
Write-Host "Published Lead customizations"

$confirm = Invoke-Dv -Method Get -Path ("systemforms?`$select=name,formid,objecttypecode&`$filter=formid eq $targetId")
if (@($confirm.value).Count -lt 1) {
    throw "Form creation could not be confirmed."
}

Write-Host "DONE formid=$targetId"
