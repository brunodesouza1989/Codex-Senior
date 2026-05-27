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

function Escape-ODataString {
    param([string]$Value)
    return $Value.Replace("'", "''")
}

function Get-FirstRecord {
    param([string]$EntitySet, [string]$Select, [string]$Filter)
    $path = "$EntitySet`?`$select=$Select&`$filter=$Filter&`$top=1"
    $result = Invoke-Dv -Method Get -Path $path
    return @($result.value) | Select-Object -First 1
}

function Ensure-Account {
    $name = "Indústrias Modelo Sul"
    $existing = Get-FirstRecord -EntitySet "accounts" -Select "accountid,name" -Filter "name eq '$(Escape-ODataString $name)'"
    if ($existing) { return $existing.accountid }
    $created = Invoke-Dv -Method Post -Path "accounts" -Prefer "return=representation" -Body @{
        name = $name
        websiteurl = "https://www.industriasmodelosul.example"
        telephone1 = "+55 47 3333-0100"
        revenue = 185000000
        numberofemployees = 4200
        description = "Conta estratégica fictícia para demonstrar Radar da Conta Senior: HCM, ERP, Logística, ETN, CPQ/GPS e ERP Sapiens."
    }
    return $created.accountid
}

function Ensure-Contact {
    param(
        [string]$FirstName,
        [string]$LastName,
        [string]$JobTitle,
        [string]$Email,
        [string]$Mobile,
        [string]$AccountId,
        [string]$Description
    )
    $existing = Get-FirstRecord -EntitySet "contacts" -Select "contactid,emailaddress1" -Filter "emailaddress1 eq '$(Escape-ODataString $Email)'"
    if ($existing) { return $existing.contactid }
    $created = Invoke-Dv -Method Post -Path "contacts" -Prefer "return=representation" -Body @{
        firstname = $FirstName
        lastname = $LastName
        jobtitle = $JobTitle
        emailaddress1 = $Email
        mobilephone = $Mobile
        description = $Description
        "parentcustomerid_account@odata.bind" = "/accounts($AccountId)"
    }
    return $created.contactid
}

function Ensure-Lead {
    $subject = "Smart Lead - Evento HCM Senior - Indústrias Modelo Sul"
    $existing = Get-FirstRecord -EntitySet "leads" -Select "leadid,subject" -Filter "subject eq '$(Escape-ODataString $subject)'"
    if ($existing) { return $existing.leadid }
    $created = Invoke-Dv -Method Post -Path "leads" -Prefer "return=representation" -Body @{
        subject = $subject
        firstname = "Marina"
        lastname = "Klein"
        companyname = "Indústrias Modelo Sul"
        jobtitle = "Diretora de Pessoas"
        emailaddress1 = "marina.klein@industriasmodelosul.example"
        telephone1 = "+55 47 3333-0101"
        revenue = 1250000
        budgetamount = 980000
        qualificationcomments = "Dor principal: consolidar HCM e integrar dados operacionais com ERP Sapiens. Lead fictício gerado por Smart Lead para demo Senior."
        description = "Próxima ação: validar escopo HCM + ERP com sponsor e preparar ETN."
    }
    return $created.leadid
}

function Ensure-Opportunity {
    param([string]$AccountId)
    $name = "Projeto HCM Senior - Rollout Nacional"
    $existing = Get-FirstRecord -EntitySet "opportunities" -Select "opportunityid,name" -Filter "name eq '$(Escape-ODataString $name)'"
    if ($existing) { return $existing.opportunityid }
    $created = Invoke-Dv -Method Post -Path "opportunities" -Prefer "return=representation" -Body @{
        name = $name
        "customerid_account@odata.bind" = "/accounts($AccountId)"
        estimatedvalue = 1250000
        closeprobability = 72
        estimatedclosedate = (Get-Date).AddDays(28).ToString("yyyy-MM-dd")
        customerneed = "Unificar processos de HCM, folha e jornada em operação nacional."
        proposedsolution = "HCM Senior + integração ERP Sapiens + governança comercial."
        currentsituation = "Sponsor engajado; risco principal é aprovação de desconto e validação técnica ETN."
        description = "Próxima ação: simular CPQ/GPS, revisar desconto e avançar para contrato."
        discountpercentage = 8
        nexer_statusetn = 253360003
        nexer_statuscpqgps = 253360003
        nexer_statuserpsapiens = 253360001
        nexer_statusaprovacaodesconto = 253360002
        nexer_justificativadesconto = "Desconto fictício aprovado para demonstrar alçada e fechamento da jornada privada."
        nexer_dataaprovacaodesconto = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    }
    return $created.opportunityid
}

function Ensure-Task {
    param([string]$OpportunityId)
    $subject = "Preparar proposta CPQ/GPS e validação ETN - Demo Senior"
    $existing = Get-FirstRecord -EntitySet "tasks" -Select "activityid,subject" -Filter "subject eq '$(Escape-ODataString $subject)'"
    if ($existing) { return $existing.activityid }
    $created = Invoke-Dv -Method Post -Path "tasks" -Prefer "return=representation" -Body @{
        subject = $subject
        description = "Atividade fictícia para sustentar a próxima ação na oportunidade Senior."
        scheduledend = (Get-Date).AddDays(2).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        "regardingobjectid_opportunity@odata.bind" = "/opportunities($OpportunityId)"
    }
    return $created.activityid
}

$script:AccessToken = Get-PacDataverseToken -ResourceUrl $Url

$accountId = Ensure-Account
$decisionMakerId = Ensure-Contact -FirstName "Marina" -LastName "Klein" -JobTitle "Diretora de Pessoas" -Email "marina.klein@industriasmodelosul.example" -Mobile "+55 47 99900-0101" -AccountId $accountId -Description "Decisora e sponsor da jornada HCM Senior."
$influencerId = Ensure-Contact -FirstName "Rafael" -LastName "Borges" -JobTitle "Gerente de TI" -Email "rafael.borges@industriasmodelosul.example" -Mobile "+55 47 99900-0102" -AccountId $accountId -Description "Influenciador técnico; acompanha ETN e integração ERP Sapiens."
$leadId = Ensure-Lead
$opportunityId = Ensure-Opportunity -AccountId $accountId
$taskId = Ensure-Task -OpportunityId $opportunityId

Write-Host "DONE account=$accountId decisionMaker=$decisionMakerId influencer=$influencerId lead=$leadId opportunity=$opportunityId task=$taskId"
