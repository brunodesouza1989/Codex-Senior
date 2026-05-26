param(
    [string]$Url = "https://nexereabrpresales.crm.dynamics.com",
    [string]$SolutionUniqueName = "nexer_senior_demo_crm_b"
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
        return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Body ($Body | ConvertTo-Json -Depth 100)
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

function New-RequiredLevel {
    return @{
        Value = "None"
        CanBeChanged = $true
        ManagedPropertyLogicalName = "canmodifyrequirementlevelsettings"
    }
}

function New-Option {
    param([int]$Value, [string]$Label)
    return @{
        Value = $Value
        Label = (New-Label -Text $Label)
    }
}

function Get-AttributeMetadata {
    param([string]$LogicalName)
    try {
        return Invoke-Dv -Method Get -Path "EntityDefinitions(LogicalName='opportunity')/Attributes(LogicalName='$LogicalName')?`$select=MetadataId,LogicalName"
    } catch {
        return $null
    }
}

function Add-AttributeToSolution {
    param([string]$AttributeId)
    try {
        Invoke-Dv -Method Post -Path "AddSolutionComponent" -Body @{
            ComponentId = $AttributeId
            ComponentType = 2
            SolutionUniqueName = $SolutionUniqueName
            AddRequiredComponents = $false
            IncludedComponentSettingsValues = $null
        } | Out-Null
        Write-Host "Added attribute to solution: $AttributeId"
    } catch {
        Write-Host "AddSolutionComponent skipped/failed for ${AttributeId}: $($_.Exception.Message)"
    }
}

function Ensure-Picklist {
    param([string]$SchemaName, [string]$DisplayName, [object[]]$Options)
    $logicalName = $SchemaName.ToLower()
    $existing = Get-AttributeMetadata -LogicalName $logicalName
    if ($existing) {
        Write-Host "Attribute exists: $logicalName"
        Add-AttributeToSolution -AttributeId $existing.MetadataId
        return
    }

    $created = Invoke-Dv -Method Post -Path "EntityDefinitions(LogicalName='opportunity')/Attributes" -Prefer "return=representation" -Body @{
        "@odata.type" = "Microsoft.Dynamics.CRM.PicklistAttributeMetadata"
        SchemaName = $SchemaName
        DisplayName = (New-Label -Text $DisplayName)
        RequiredLevel = (New-RequiredLevel)
        OptionSet = @{
            OptionSetType = "Picklist"
            IsGlobal = $false
            Options = $Options
        }
    }
    Write-Host "Created picklist: $logicalName ($($created.MetadataId))"
    Add-AttributeToSolution -AttributeId $created.MetadataId
}

function Ensure-Memo {
    param([string]$SchemaName, [string]$DisplayName)
    $logicalName = $SchemaName.ToLower()
    $existing = Get-AttributeMetadata -LogicalName $logicalName
    if ($existing) {
        Write-Host "Attribute exists: $logicalName"
        Add-AttributeToSolution -AttributeId $existing.MetadataId
        return
    }

    $created = Invoke-Dv -Method Post -Path "EntityDefinitions(LogicalName='opportunity')/Attributes" -Prefer "return=representation" -Body @{
        "@odata.type" = "Microsoft.Dynamics.CRM.MemoAttributeMetadata"
        SchemaName = $SchemaName
        DisplayName = (New-Label -Text $DisplayName)
        RequiredLevel = (New-RequiredLevel)
        MaxLength = 2000
        Format = "TextArea"
    }
    Write-Host "Created memo: $logicalName ($($created.MetadataId))"
    Add-AttributeToSolution -AttributeId $created.MetadataId
}

function Ensure-DateTime {
    param([string]$SchemaName, [string]$DisplayName)
    $logicalName = $SchemaName.ToLower()
    $existing = Get-AttributeMetadata -LogicalName $logicalName
    if ($existing) {
        Write-Host "Attribute exists: $logicalName"
        Add-AttributeToSolution -AttributeId $existing.MetadataId
        return
    }

    $created = Invoke-Dv -Method Post -Path "EntityDefinitions(LogicalName='opportunity')/Attributes" -Prefer "return=representation" -Body @{
        "@odata.type" = "Microsoft.Dynamics.CRM.DateTimeAttributeMetadata"
        SchemaName = $SchemaName
        DisplayName = (New-Label -Text $DisplayName)
        RequiredLevel = (New-RequiredLevel)
        Format = "DateAndTime"
    }
    Write-Host "Created datetime: $logicalName ($($created.MetadataId))"
    Add-AttributeToSolution -AttributeId $created.MetadataId
}

$script:AccessToken = Get-PacDataverseToken -ResourceUrl $Url

$approvalOptions = @(
    (New-Option -Value 253360000 -Label "Nao Solicitada"),
    (New-Option -Value 253360001 -Label "Pendente"),
    (New-Option -Value 253360002 -Label "Aprovada"),
    (New-Option -Value 253360003 -Label "Rejeitada"),
    (New-Option -Value 253360004 -Label "Escalada")
)
$integrationOptions = @(
    (New-Option -Value 253360000 -Label "Nao Iniciado"),
    (New-Option -Value 253360001 -Label "Enviado"),
    (New-Option -Value 253360002 -Label "Processando"),
    (New-Option -Value 253360003 -Label "Concluido"),
    (New-Option -Value 253360004 -Label "Erro Simulado")
)
$etnOptions = @(
    (New-Option -Value 253360000 -Label "Nao Acionada"),
    (New-Option -Value 253360001 -Label "Pendente"),
    (New-Option -Value 253360002 -Label "Em Atendimento"),
    (New-Option -Value 253360003 -Label "Concluida")
)

Ensure-Picklist -SchemaName "nexer_StatusAprovacaoDesconto" -DisplayName "Status Aprovacao Desconto" -Options $approvalOptions
Ensure-Memo -SchemaName "nexer_JustificativaDesconto" -DisplayName "Justificativa Desconto"
Ensure-DateTime -SchemaName "nexer_DataAprovacaoDesconto" -DisplayName "Data Aprovacao Desconto"
Ensure-Picklist -SchemaName "nexer_StatusCPQGPS" -DisplayName "Status CPQ/GPS" -Options $integrationOptions
Ensure-Picklist -SchemaName "nexer_StatusERPSapiens" -DisplayName "Status ERP Sapiens" -Options $integrationOptions
Ensure-Picklist -SchemaName "nexer_StatusETN" -DisplayName "Status ETN" -Options $etnOptions

Invoke-Dv -Method Post -Path "PublishXml" -Body @{
    ParameterXml = "<importexportxml><entities><entity>opportunity</entity></entities></importexportxml>"
} | Out-Null
Write-Host "Published Opportunity metadata."
