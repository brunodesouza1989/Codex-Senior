param(
    [string]$Url = "https://nexereabrpresales.crm.dynamics.com",
    [string]$FormId = "c8e4eb26-8558-f111-bec7-7c1e526b609d",
    [string]$FormName = "Cliente Potencial Senior"
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
        $jsonBody = $Body | ConvertTo-Json -Depth 60
        return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Body $jsonBody
    }

    return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers
}

function New-Id {
    return "{" + ([guid]::NewGuid().ToString()) + "}"
}

function New-LabelsXml {
    param(
        [string]$Pt,
        [string]$En = $null,
        [string]$Es = $null
    )

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
        default { return "{4273EDBD-AC1D-40d3-9FB2-095C621B552D}" }
    }
}

function New-CellXml {
    param(
        [string]$Field,
        [string]$LabelPt,
        [string]$Kind = "text"
    )

    $cellId = New-Id
    $labelId = New-Id
    $classId = Get-ClassId -Kind $Kind
    $controlId = "senior_$Field"
    $labels = New-LabelsXml -Pt $LabelPt

    return @"
<row>
  <cell id="$cellId" showlabel="true" locklevel="0" labelid="$labelId">
    $labels
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
  <cell id="$cellId" showlabel="false" rowspan="8" colspan="1" auto="false" labelid="$labelId">
    $(New-LabelsXml -Pt "Timeline" -En "Timeline" -Es "Timeline")
    <control id="senior_timeline" classid="{E7A81278-8635-4d9e-8D4D-59480B391C5B}" />
  </cell>
</row>
"@
}

function New-SectionXml {
    param(
        [string]$Name,
        [string]$Label,
        [string[]]$Rows
    )

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

function New-SeniorTabXml {
    $tabId = New-Id
    $labelId = New-Id

    $identificacao = New-SectionXml -Name "senior_identificacao" -Label "Identificação" -Rows @(
        (New-CellXml -Field "subject" -LabelPt "Tópico"),
        (New-CellXml -Field "firstname" -LabelPt "Nome"),
        (New-CellXml -Field "lastname" -LabelPt "Sobrenome"),
        (New-CellXml -Field "companyname" -LabelPt "Empresa"),
        (New-CellXml -Field "jobtitle" -LabelPt "Cargo")
    )

    $contato = New-SectionXml -Name "senior_contato" -Label "Contato" -Rows @(
        (New-CellXml -Field "emailaddress1" -LabelPt "Email" -Kind "email"),
        (New-CellXml -Field "telephone1" -LabelPt "Telefone"),
        (New-CellXml -Field "mobilephone" -LabelPt "Celular")
    )

    $qualificacao = New-SectionXml -Name "senior_qualificacao_comercial" -Label "Qualificação Comercial" -Rows @(
        (New-CellXml -Field "leadsourcecode" -LabelPt "Origem" -Kind "picklist"),
        (New-CellXml -Field "industrycode" -LabelPt "Segmento" -Kind "picklist"),
        (New-CellXml -Field "revenue" -LabelPt "Potencial Financeiro" -Kind "money"),
        (New-CellXml -Field "numberofemployees" -LabelPt "Porte" -Kind "integer"),
        (New-CellXml -Field "budgetamount" -LabelPt "Orçamento" -Kind "money"),
        (New-CellXml -Field "budgetstatus" -LabelPt "Status Do Orçamento" -Kind "picklist"),
        (New-CellXml -Field "prioritycode" -LabelPt "Prioridade" -Kind "picklist"),
        (New-CellXml -Field "leadqualitycode" -LabelPt "Aderência Senior" -Kind "picklist")
    )

    $checklist = New-SectionXml -Name "senior_checklist_qualificacao" -Label "Checklist De Qualificação" -Rows @(
        (New-CellXml -Field "nexer_interessedocliente" -LabelPt "Linha Senior" -Kind "picklist"),
        (New-CellXml -Field "purchaseprocess" -LabelPt "Decisor/Comitê" -Kind "picklist"),
        (New-CellXml -Field "purchasetimeframe" -LabelPt "Prazo" -Kind "picklist"),
        (New-CellXml -Field "qualificationcomments" -LabelPt "Dor e Necessidade" -Kind "memo")
    )

    $timeline = New-SectionXml -Name "senior_proxima_acao" -Label "Próxima Ação" -Rows @(
        (New-TimelineCellXml)
    )

    return @"
<tab name="senior_summary" verticallayout="true" id="$tabId" IsUserDefined="1" locklevel="0" expanded="true" showlabel="true" labelid="$labelId">
  $(New-LabelsXml -Pt "Resumo Senior" -En "Senior Summary" -Es "Resumen Senior")
  <columns>
    <column width="33%">
      <sections>
        $identificacao
        $contato
      </sections>
    </column>
    <column width="34%">
      <sections>
        $qualificacao
        $checklist
      </sections>
    </column>
    <column width="33%">
      <sections>
        $timeline
      </sections>
    </column>
  </columns>
</tab>
"@
}

$script:AccessToken = Get-PacDataverseToken -ResourceUrl $Url
Write-Host "Using PAC Dataverse token from local cache"

$form = Invoke-Dv -Method Get -Path "systemforms($FormId)?`$select=name,formid,formxml"
if ($form.name -ne $FormName) {
    throw "Unexpected form. Expected '$FormName', got '$($form.name)'."
}

[xml]$xml = $form.formxml
$tabs = $xml.form.tabs
if (-not $tabs) {
    throw "Form XML does not contain tabs."
}

$existingSeniorTab = $tabs.tab | Where-Object { $_.name -eq "senior_summary" } | Select-Object -First 1
if ($existingSeniorTab) {
    [void]$tabs.RemoveChild($existingSeniorTab)
}

$seniorTabXml = New-SeniorTabXml
$fragment = $xml.CreateDocumentFragment()
$fragment.InnerXml = $seniorTabXml
[void]$tabs.InsertBefore($fragment, $tabs.FirstChild)

$body = @{
    formxml = $xml.form.OuterXml
}
Invoke-Dv -Method Patch -Path "systemforms($FormId)" -Body $body | Out-Null
Write-Host "Updated form XML layout for $FormName"

$publishBody = @{
    ParameterXml = "<importexportxml><entities><entity>lead</entity></entities></importexportxml>"
}
Invoke-Dv -Method Post -Path "PublishXml" -Body $publishBody | Out-Null
Write-Host "Published Lead customizations"

Write-Host "DONE formid=$FormId"
