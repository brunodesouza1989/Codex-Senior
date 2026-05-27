param(
    [string]$Url = "https://nexereabrpresales.crm.dynamics.com"
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

function New-Label {
    param([string]$Text)
    return @{
        LocalizedLabels = @(@{ Label = $Text; LanguageCode = 1046 })
        UserLocalizedLabel = @{ Label = $Text; LanguageCode = 1046 }
    }
}

function Update-AttributeLabel {
    param(
        [string]$LogicalName,
        [string]$MetadataType,
        [string]$DisplayName
    )
    Invoke-Dv -Method Put -Path "EntityDefinitions(LogicalName='opportunity')/Attributes(LogicalName='$LogicalName')" -Body @{
        "@odata.type" = "Microsoft.Dynamics.CRM.$MetadataType"
        LogicalName = $LogicalName
        DisplayName = (New-Label -Text $DisplayName)
    } | Out-Null
    Write-Host "Updated attribute label: $LogicalName -> $DisplayName"
}

function Update-OptionLabel {
    param(
        [string]$AttributeLogicalName,
        [int]$Value,
        [string]$Label
    )
    Invoke-Dv -Method Post -Path "UpdateOptionValue" -Body @{
        EntityLogicalName = "opportunity"
        AttributeLogicalName = $AttributeLogicalName
        Value = $Value
        Label = (New-Label -Text $Label)
        MergeLabels = $true
    } | Out-Null
    Write-Host "Updated option label: $AttributeLogicalName/$Value -> $Label"
}

$script:AccessToken = Get-PacDataverseToken -ResourceUrl $Url

Update-AttributeLabel -LogicalName "nexer_statusaprovacaodesconto" -MetadataType "PicklistAttributeMetadata" -DisplayName "Status Aprovação Desconto"
Update-AttributeLabel -LogicalName "nexer_justificativadesconto" -MetadataType "MemoAttributeMetadata" -DisplayName "Justificativa Desconto"
Update-AttributeLabel -LogicalName "nexer_dataaprovacaodesconto" -MetadataType "DateTimeAttributeMetadata" -DisplayName "Data Aprovação Desconto"
Update-AttributeLabel -LogicalName "nexer_statuscpqgps" -MetadataType "PicklistAttributeMetadata" -DisplayName "Status CPQ/GPS"
Update-AttributeLabel -LogicalName "nexer_statuserpsapiens" -MetadataType "PicklistAttributeMetadata" -DisplayName "Status ERP Sapiens"
Update-AttributeLabel -LogicalName "nexer_statusetn" -MetadataType "PicklistAttributeMetadata" -DisplayName "Status ETN"

Update-OptionLabel -AttributeLogicalName "nexer_statusaprovacaodesconto" -Value 253360000 -Label "Não Solicitada"
Update-OptionLabel -AttributeLogicalName "nexer_statusaprovacaodesconto" -Value 253360001 -Label "Pendente"
Update-OptionLabel -AttributeLogicalName "nexer_statusaprovacaodesconto" -Value 253360002 -Label "Aprovada"
Update-OptionLabel -AttributeLogicalName "nexer_statusaprovacaodesconto" -Value 253360003 -Label "Rejeitada"
Update-OptionLabel -AttributeLogicalName "nexer_statusaprovacaodesconto" -Value 253360004 -Label "Escalada"

foreach ($field in @("nexer_statuscpqgps", "nexer_statuserpsapiens")) {
    Update-OptionLabel -AttributeLogicalName $field -Value 253360000 -Label "Não Iniciado"
    Update-OptionLabel -AttributeLogicalName $field -Value 253360001 -Label "Enviado"
    Update-OptionLabel -AttributeLogicalName $field -Value 253360002 -Label "Processando"
    Update-OptionLabel -AttributeLogicalName $field -Value 253360003 -Label "Concluído"
    Update-OptionLabel -AttributeLogicalName $field -Value 253360004 -Label "Erro Simulado"
}

Update-OptionLabel -AttributeLogicalName "nexer_statusetn" -Value 253360000 -Label "Não Acionada"
Update-OptionLabel -AttributeLogicalName "nexer_statusetn" -Value 253360001 -Label "Pendente"
Update-OptionLabel -AttributeLogicalName "nexer_statusetn" -Value 253360002 -Label "Em Atendimento"
Update-OptionLabel -AttributeLogicalName "nexer_statusetn" -Value 253360003 -Label "Concluída"

Invoke-Dv -Method Post -Path "PublishXml" -Body @{
    ParameterXml = "<importexportxml><entities><entity>opportunity</entity></entities></importexportxml>"
} | Out-Null
Write-Host "Published Opportunity labels."
