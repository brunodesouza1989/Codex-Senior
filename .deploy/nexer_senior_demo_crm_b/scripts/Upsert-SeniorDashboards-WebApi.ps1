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
        return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Body ($Body | ConvertTo-Json -Depth 80)
    }
    return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers
}

function Escape-ODataString([string]$Value) {
    return $Value.Replace("'", "''")
}

function Get-ViewId {
    param([string]$Name)
    $escaped = Escape-ODataString $Name
    $result = Invoke-Dv -Method Get -Path "savedqueries?`$select=savedqueryid,name&`$filter=returnedtypecode eq 'opportunity' and name eq '$escaped'"
    if (@($result.value).Count -lt 1) { throw "View not found: $Name" }
    return $result.value[0].savedqueryid
}

function Get-ChartId {
    param([string]$Name)
    $escaped = Escape-ODataString $Name
    $result = Invoke-Dv -Method Get -Path "savedqueryvisualizations?`$select=savedqueryvisualizationid,name&`$filter=primaryentitytypecode eq 'opportunity' and name eq '$escaped'"
    if (@($result.value).Count -lt 1) { throw "Chart not found: $Name" }
    return $result.value[0].savedqueryvisualizationid
}

function New-GuidText {
    return ([guid]::NewGuid()).ToString("B")
}

function New-ChartCellXml {
    param(
        [string]$Label,
        [string]$ViewId,
        [string]$ChartId,
        [int]$ColSpan = 2,
        [int]$RowSpan = 12
    )
    $cellId = New-GuidText
    $controlId = "Component$(([guid]::NewGuid()).ToString('N').Substring(0,8))"
    return @"
<cell colspan="$ColSpan" rowspan="$RowSpan" showlabel="false" id="$cellId" auto="false">
  <labels><label description="$Label" languagecode="1046" /></labels>
  <control id="$controlId" classid="{E7A81278-8635-4d9e-8D4D-59480B391C5B}">
    <parameters>
      <TargetEntityType>opportunity</TargetEntityType>
      <ChartGridMode>Chart</ChartGridMode>
      <EnableQuickFind>false</EnableQuickFind>
      <EnableViewPicker>true</EnableViewPicker>
      <EnableJumpBar>false</EnableJumpBar>
      <RecordsPerPage>12</RecordsPerPage>
      <ViewId>{$ViewId}</ViewId>
      <IsUserView>false</IsUserView>
      <ViewIds>{$ViewId}</ViewIds>
      <AutoExpand>Fixed</AutoExpand>
      <VisualizationId>{$ChartId}</VisualizationId>
      <IsUserChart>false</IsUserChart>
      <EnableChartPicker>true</EnableChartPicker>
      <RelationshipName />
    </parameters>
  </control>
</cell>
"@
}

function New-GridCellXml {
    param(
        [string]$Label,
        [string]$ViewId,
        [int]$ColSpan = 2,
        [int]$RowSpan = 12
    )
    $cellId = New-GuidText
    $controlId = "Component$(([guid]::NewGuid()).ToString('N').Substring(0,8))"
    return @"
<cell colspan="$ColSpan" rowspan="$RowSpan" showlabel="false" id="$cellId" auto="false">
  <labels><label description="$Label" languagecode="1046" /></labels>
  <control id="$controlId" classid="{E7A81278-8635-4d9e-8D4D-59480B391C5B}">
    <parameters>
      <TargetEntityType>opportunity</TargetEntityType>
      <ChartGridMode>Grid</ChartGridMode>
      <EnableQuickFind>true</EnableQuickFind>
      <EnableViewPicker>true</EnableViewPicker>
      <EnableJumpBar>false</EnableJumpBar>
      <RecordsPerPage>8</RecordsPerPage>
      <ViewId>{$ViewId}</ViewId>
      <IsUserView>false</IsUserView>
      <ViewIds>{$ViewId}</ViewIds>
      <AutoExpand>Fixed</AutoExpand>
      <RelationshipName />
    </parameters>
  </control>
</cell>
"@
}

function New-DashboardXml {
    param([string]$FirstRow, [string]$SecondRow)
    $tabId = New-GuidText
    $sectionId = New-GuidText
    return @"
<form>
  <tabs>
    <tab showlabel="false" verticallayout="true" id="$tabId">
      <labels><label description="" languagecode="1046" /></labels>
      <columns>
        <column width="100%">
          <sections>
            <section showlabel="false" showbar="false" columns="1111" id="$sectionId">
              <labels><label description="" languagecode="1046" /></labels>
              <rows>
                <row>
$FirstRow
                </row>
                <row />
                <row />
                <row />
                <row />
                <row />
                <row />
                <row />
                <row />
                <row />
                <row />
                <row />
                <row>
$SecondRow
                </row>
                <row />
                <row />
                <row />
                <row />
                <row />
                <row />
                <row />
                <row />
                <row />
                <row />
                <row />
              </rows>
            </section>
          </sections>
        </column>
      </columns>
    </tab>
  </tabs>
</form>
"@
}

function Add-SolutionComponent {
    param([string]$ComponentId)
    try {
        Invoke-Dv -Method Post -Path "AddSolutionComponent" -Body @{
            ComponentType = 60
            ComponentId = $ComponentId
            SolutionUniqueName = $SolutionUniqueName
            AddRequiredComponents = $true
        } | Out-Null
        Write-Host "Added dashboard to solution: $ComponentId"
    } catch {
        Write-Host "AddSolutionComponent skipped/failed for $ComponentId"
        Write-Host $_.Exception.Message
    }
}

function Upsert-Dashboard {
    param([string]$Name, [string]$Description, [string]$FormXml)
    $escaped = Escape-ODataString $Name
    $existing = Invoke-Dv -Method Get -Path "systemforms?`$select=formid,name,type&`$filter=name eq '$escaped' and type eq 0"
    $body = @{
        name = $Name
        description = $Description
        formxml = $FormXml
        type = 0
        objecttypecode = "none"
        isdefault = $false
        formactivationstate = 1
    }
    if (@($existing.value).Count -gt 0) {
        $id = $existing.value[0].formid
        Invoke-Dv -Method Patch -Path "systemforms($id)" -Body $body | Out-Null
        Write-Host "Updated dashboard: $Name ($id)"
    } else {
        $created = Invoke-Dv -Method Post -Path "systemforms" -Body $body -Prefer "return=representation"
        $id = $created.formid
        Write-Host "Created dashboard: $Name ($id)"
    }
    Add-SolutionComponent -ComponentId $id
    return $id
}

function Publish-AllWithRetry {
    param([int]$Retries = 5, [int]$DelaySeconds = 45)
    for ($attempt = 1; $attempt -le $Retries; $attempt++) {
        try {
            Invoke-Dv -Method Post -Path "PublishAllXml" -Body @{} | Out-Null
            Write-Host "Published all customizations."
            return
        } catch {
            if ($attempt -eq $Retries) { throw }
            Write-Host ("PublishAllXml busy; retrying in {0}s ({1}/{2})." -f $DelaySeconds, $attempt, $Retries)
            Start-Sleep -Seconds $DelaySeconds
        }
    }
}

$script:AccessToken = Get-PacDataverseToken -ResourceUrl $Url

$viewPipeline = Get-ViewId "Senior 360 | Oportunidades - Pipeline aberto"
$viewDiscount = Get-ViewId "Senior 360 | Oportunidades - Desconto e Aprovação"
$viewClosing = Get-ViewId "Senior 360 | Oportunidades - Fechamento 30 dias"
$viewWon = Get-ViewId "Senior 360 | Oportunidades - Ganhas"

$chartMonth = Get-ChartId "Mês de Fechamento"
$chartBusinessUnit = Get-ChartId "Pipeline x Unidade de Negócio"
$chartStage = Get-ChartId "Oportunidades por Fase de Pipeline"
$chartStatus = Get-ChartId "Oportunidade por Status"

$operationalRow1 = @(
    (New-ChartCellXml -Label "Pipeline por etapa" -ViewId $viewPipeline -ChartId $chartStage),
    (New-ChartCellXml -Label "Status das oportunidades" -ViewId $viewPipeline -ChartId $chartStatus)
) -join "`r`n"
$operationalRow2 = @(
    (New-GridCellXml -Label "Pipeline aberto" -ViewId $viewPipeline),
    (New-GridCellXml -Label "Desconto e aprovação" -ViewId $viewDiscount)
) -join "`r`n"

$executiveRow1 = @(
    (New-ChartCellXml -Label "Forecast por mês" -ViewId $viewPipeline -ChartId $chartMonth),
    (New-ChartCellXml -Label "Pipeline por unidade de negócio" -ViewId $viewPipeline -ChartId $chartBusinessUnit)
) -join "`r`n"
$executiveRow2 = @(
    (New-GridCellXml -Label "Fechamento em 30 dias" -ViewId $viewClosing),
    (New-GridCellXml -Label "Oportunidades ganhas" -ViewId $viewWon)
) -join "`r`n"

Upsert-Dashboard -Name "Senior 360 | Operacional Presales" -Description "Dashboard operacional Senior para pré-vendas, Sales Ops e governança de pipeline." -FormXml (New-DashboardXml -FirstRow $operationalRow1 -SecondRow $operationalRow2) | Out-Null
Upsert-Dashboard -Name "Senior 360 | Executivo Pipeline" -Description "Dashboard executivo Senior para forecast, pipeline e fechamento." -FormXml (New-DashboardXml -FirstRow $executiveRow1 -SecondRow $executiveRow2) | Out-Null

Publish-AllWithRetry
Write-Host "Senior dashboards upserted and published."
