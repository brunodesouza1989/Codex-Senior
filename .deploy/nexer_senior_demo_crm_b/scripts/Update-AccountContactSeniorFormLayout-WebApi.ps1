param(
    [string]$Url = "https://nexereabrpresales.crm.dynamics.com",
    [Parameter(Mandatory = $true)]
    [ValidateSet("account", "contact", "opportunity")]
    [string]$TableLogicalName,
    [Parameter(Mandatory = $true)]
    [string]$FormId,
    [Parameter(Mandatory = $true)]
    [string]$FormName
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
        return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Body ($Body | ConvertTo-Json -Depth 80)
    }
    return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers
}

function New-Id { return "{" + ([guid]::NewGuid().ToString()) + "}" }

function New-LabelsXml {
    param([string]$Pt, [string]$En = $null, [string]$Es = $null)
    if (-not $En) { $En = $Pt }
    if (-not $Es) { $Es = $Pt }
    return @"
<labels>
  <label description="$En" languagecode="1033" />
  <label description="$Pt" languagecode="1046" />
  <label description="$Es" languagecode="3082" />
</labels>
"@
}

function Get-ClassId {
    param([string]$Kind)
    switch ($Kind) {
        "picklist" { return "{3EF39988-22BB-4f0b-BBBE-64B5A3748AEE}" }
        "lookup" { return "{270BD3DB-D9AF-4782-9025-509E298DEC0A}" }
        "money" { return "{533B9E00-756B-4312-95A0-DC888637AC78}" }
        "integer" { return "{C6D124CA-7EDA-4a60-AEA9-7FB8D318B68F}" }
        "memo" { return "{E0DECE4B-6FC8-4a8f-A065-082708572369}" }
        "email" { return "{ADA2203E-B4CD-49be-9DDF-234642B43B52}" }
        "url" { return "{71716B6C-711E-476c-8AB8-5D11542BFB47}" }
        "datetime" { return "{5B773807-9FB2-42DB-97C3-7A91EFF8ADFF}" }
        "decimal" { return "{C3EFE0C3-0EC6-42be-8349-CBD9079DFD8E}" }
        "boolean" { return "{67FAC785-CD58-4f9f-ABB3-4B7DDC6ED5ED}" }
        default { return "{4273EDBD-AC1D-40d3-9FB2-095C621B552D}" }
    }
}

function New-CellXml {
    param([string]$Field, [string]$LabelPt, [string]$Kind = "text")
    $cellId = New-Id
    $labelId = New-Id
    $classId = Get-ClassId -Kind $Kind
    $controlId = "senior_$Field"
    return @"
<row>
  <cell id="$cellId" showlabel="true" locklevel="0" labelid="$labelId">
    $(New-LabelsXml -Pt $LabelPt)
    <control id="$controlId" classid="$classId" datafieldname="$Field" disabled="false" />
  </cell>
</row>
"@
}

function New-TimelineCellXml {
    $cellId = New-Id
    $labelId = New-Id
    return @"
<row>
  <cell id="$cellId" showlabel="false" rowspan="10" colspan="1" auto="false" labelid="$labelId">
    $(New-LabelsXml -Pt "Timeline" -En "Timeline" -Es "Timeline")
    <control id="senior_timeline_$TableLogicalName" classid="{E7A81278-8635-4d9e-8D4D-59480B391C5B}" />
  </cell>
</row>
"@
}

function New-SectionXml {
    param([string]$Name, [string]$Label, [string[]]$Rows)
    $sectionId = New-Id
    $labelId = New-Id
    $rowXml = $Rows -join "`n"
    return @"
<section name="$Name" showlabel="true" showbar="false" id="$sectionId" IsUserDefined="1" columns="1" locklevel="0" labelwidth="115" celllabelposition="Left" labelid="$labelId">
  $(New-LabelsXml -Pt $Label)
  <rows>
    $rowXml
  </rows>
</section>
"@
}

function New-AccountTabXml {
    $tabId = New-Id
    $labelId = New-Id
    $perfil = New-SectionXml -Name "senior_radar_perfil" -Label "Perfil Da Conta" -Rows @(
        (New-CellXml -Field "name" -LabelPt "Conta"),
        (New-CellXml -Field "accountnumber" -LabelPt "Identificador/CNPJ"),
        (New-CellXml -Field "websiteurl" -LabelPt "Site" -Kind "url"),
        (New-CellXml -Field "telephone1" -LabelPt "Telefone")
    )
    $comercial = New-SectionXml -Name "senior_radar_comercial" -Label "Radar Comercial" -Rows @(
        (New-CellXml -Field "industrycode" -LabelPt "Setor" -Kind "picklist"),
        (New-CellXml -Field "revenue" -LabelPt "Receita Anual" -Kind "money"),
        (New-CellXml -Field "numberofemployees" -LabelPt "Colaboradores" -Kind "integer"),
        (New-CellXml -Field "accountclassificationcode" -LabelPt "Classificação" -Kind "picklist"),
        (New-CellXml -Field "accountratingcode" -LabelPt "Rating" -Kind "picklist")
    )
    $relacionamento = New-SectionXml -Name "senior_radar_relacionamento" -Label "Relacionamento" -Rows @(
        (New-CellXml -Field "primarycontactid" -LabelPt "Contato Principal" -Kind "lookup"),
        (New-CellXml -Field "parentaccountid" -LabelPt "Conta Pai" -Kind "lookup"),
        (New-CellXml -Field "ownerid" -LabelPt "Proprietário" -Kind "lookup"),
        (New-CellXml -Field "description" -LabelPt "Próxima Ação / Observações" -Kind "memo")
    )
    $timeline = New-SectionXml -Name "senior_radar_proxima_acao" -Label "Pendências E Interações" -Rows @((New-TimelineCellXml))
    return @"
<tab name="senior_account_radar" verticallayout="true" id="$tabId" IsUserDefined="1" locklevel="0" expanded="true" showlabel="true" labelid="$labelId">
  $(New-LabelsXml -Pt "Radar Da Conta" -En "Account Radar" -Es "Radar De Cuenta")
  <columns>
    <column width="33%"><sections>$perfil</sections></column>
    <column width="34%"><sections>$comercial</sections></column>
    <column width="33%"><sections>$relacionamento $timeline</sections></column>
  </columns>
</tab>
"@
}

function New-ContactTabXml {
    $tabId = New-Id
    $labelId = New-Id
    $perfil = New-SectionXml -Name "senior_contact_perfil" -Label "Perfil Do Contato" -Rows @(
        (New-CellXml -Field "fullname" -LabelPt "Nome Completo"),
        (New-CellXml -Field "jobtitle" -LabelPt "Cargo"),
        (New-CellXml -Field "parentcustomerid" -LabelPt "Conta" -Kind "lookup"),
        (New-CellXml -Field "ownerid" -LabelPt "Proprietário" -Kind "lookup")
    )
    $influencia = New-SectionXml -Name "senior_contact_influencia" -Label "Papel E Influência" -Rows @(
        (New-CellXml -Field "accountrolecode" -LabelPt "Papel Na Conta" -Kind "picklist"),
        (New-CellXml -Field "preferredcontactmethodcode" -LabelPt "Canal Preferido" -Kind "picklist"),
        (New-CellXml -Field "preferredsystemuserid" -LabelPt "Responsavel Preferencial" -Kind "lookup"),
        (New-CellXml -Field "description" -LabelPt "Contexto / Influência" -Kind "memo")
    )
    $contato = New-SectionXml -Name "senior_contact_canais" -Label "Canais" -Rows @(
        (New-CellXml -Field "emailaddress1" -LabelPt "Email" -Kind "email"),
        (New-CellXml -Field "telephone1" -LabelPt "Telefone"),
        (New-CellXml -Field "mobilephone" -LabelPt "Celular")
    )
    $timeline = New-SectionXml -Name "senior_contact_interacoes" -Label "Última Interação E Próxima Ação" -Rows @((New-TimelineCellXml))
    return @"
<tab name="senior_contact_context" verticallayout="true" id="$tabId" IsUserDefined="1" locklevel="0" expanded="true" showlabel="true" labelid="$labelId">
  $(New-LabelsXml -Pt "Contexto Senior" -En "Senior Context" -Es "Contexto Senior")
  <columns>
    <column width="33%"><sections>$perfil</sections></column>
    <column width="34%"><sections>$influencia $contato</sections></column>
    <column width="33%"><sections>$timeline</sections></column>
  </columns>
</tab>
"@
}

function New-OpportunityTabXml {
    $tabId = New-Id
    $labelId = New-Id
    $resumo = New-SectionXml -Name "senior_opp_resumo" -Label "Resumo Da Oportunidade" -Rows @(
        (New-CellXml -Field "name" -LabelPt "Oportunidade"),
        (New-CellXml -Field "customerid" -LabelPt "Cliente" -Kind "lookup"),
        (New-CellXml -Field "salesstagecode" -LabelPt "Fase" -Kind "picklist"),
        (New-CellXml -Field "ownerid" -LabelPt "Responsável" -Kind "lookup")
    )
    $valor = New-SectionXml -Name "senior_opp_valor" -Label "Valor E Forecast" -Rows @(
        (New-CellXml -Field "estimatedvalue" -LabelPt "Valor Estimado" -Kind "money"),
        (New-CellXml -Field "closeprobability" -LabelPt "Probabilidade" -Kind "integer"),
        (New-CellXml -Field "estimatedclosedate" -LabelPt "Data Prevista" -Kind "datetime"),
        (New-CellXml -Field "discountpercentage" -LabelPt "Desconto (%)" -Kind "decimal"),
        (New-CellXml -Field "discountamount" -LabelPt "Desconto" -Kind "money")
    )
    $solucao = New-SectionXml -Name "senior_opp_solucao" -Label "Solução E Risco" -Rows @(
        (New-CellXml -Field "customerneed" -LabelPt "Necessidade" -Kind "memo"),
        (New-CellXml -Field "proposedsolution" -LabelPt "Produto/Solução" -Kind "memo"),
        (New-CellXml -Field "currentsituation" -LabelPt "Situação Atual / Risco" -Kind "memo"),
        (New-CellXml -Field "description" -LabelPt "Próxima Ação" -Kind "memo")
    )
    $governanca = New-SectionXml -Name "senior_opp_governanca" -Label "Governança E Integrações" -Rows @(
        (New-CellXml -Field "purchaseprocess" -LabelPt "Processo De Compra" -Kind "picklist"),
        (New-CellXml -Field "purchasetimeframe" -LabelPt "Prazo De Compra" -Kind "picklist"),
        (New-CellXml -Field "decisionmaker" -LabelPt "Decisor Identificado" -Kind "boolean"),
        (New-CellXml -Field "pricelevelid" -LabelPt "Lista De Preços / CPQ" -Kind "lookup"),
        (New-CellXml -Field "nexer_statusetn" -LabelPt "Status ETN" -Kind "picklist"),
        (New-CellXml -Field "nexer_statuscpqgps" -LabelPt "Status CPQ/GPS" -Kind "picklist"),
        (New-CellXml -Field "nexer_statuserpsapiens" -LabelPt "Status ERP Sapiens" -Kind "picklist"),
        (New-CellXml -Field "nexer_statusaprovacaodesconto" -LabelPt "Status Aprovação Desconto" -Kind "picklist"),
        (New-CellXml -Field "nexer_justificativadesconto" -LabelPt "Justificativa Desconto" -Kind "memo"),
        (New-CellXml -Field "nexer_dataaprovacaodesconto" -LabelPt "Data Aprovação Desconto" -Kind "datetime")
    )
    $timeline = New-SectionXml -Name "senior_opp_interacoes" -Label "Interações E Pendências" -Rows @((New-TimelineCellXml))
    return @"
<tab name="senior_opportunity_summary" verticallayout="true" id="$tabId" IsUserDefined="1" locklevel="0" expanded="true" showlabel="true" labelid="$labelId">
  $(New-LabelsXml -Pt "Oportunidade Senior" -En "Senior Opportunity" -Es "Oportunidad Senior")
  <columns>
    <column width="33%"><sections>$resumo $valor</sections></column>
    <column width="34%"><sections>$solucao</sections></column>
    <column width="33%"><sections>$governanca $timeline</sections></column>
  </columns>
</tab>
"@
}

$script:AccessToken = Get-PacDataverseToken -ResourceUrl $Url
$form = Invoke-Dv -Method Get -Path "systemforms($FormId)?`$select=name,formid,formxml,objecttypecode"
if ($form.name -ne $FormName -or $form.objecttypecode -ne $TableLogicalName) {
    throw "Unexpected form. Expected $TableLogicalName/$FormName, got $($form.objecttypecode)/$($form.name)."
}

[xml]$xml = $form.formxml
$tabs = $xml.form.tabs
if (-not $tabs) { throw "Form XML does not contain tabs." }

$tabName = switch ($TableLogicalName) {
    "account" { "senior_account_radar" }
    "contact" { "senior_contact_context" }
    "opportunity" { "senior_opportunity_summary" }
}
$existingTab = $tabs.tab | Where-Object { $_.name -eq $tabName } | Select-Object -First 1
if ($existingTab) {
    [void]$tabs.RemoveChild($existingTab)
}

$tabXml = switch ($TableLogicalName) {
    "account" { New-AccountTabXml }
    "contact" { New-ContactTabXml }
    "opportunity" { New-OpportunityTabXml }
}
$fragment = $xml.CreateDocumentFragment()
$fragment.InnerXml = $tabXml
[void]$tabs.InsertBefore($fragment, $tabs.FirstChild)

Invoke-Dv -Method Patch -Path "systemforms($FormId)" -Body @{ formxml = $xml.form.OuterXml } | Out-Null
Write-Host "Updated form XML layout for $FormName"

Invoke-Dv -Method Post -Path "PublishXml" -Body @{
    ParameterXml = "<importexportxml><entities><entity>$TableLogicalName</entity></entities></importexportxml>"
} | Out-Null
Write-Host "Published $TableLogicalName customizations"
Write-Host "DONE table=$TableLogicalName formid=$FormId"
