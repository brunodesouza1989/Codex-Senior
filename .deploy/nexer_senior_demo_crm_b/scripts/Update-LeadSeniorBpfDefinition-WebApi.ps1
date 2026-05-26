param(
    [string]$Url = "https://nexereabrpresales.crm.dynamics.com",
    [string]$WorkflowName = "Lead Senior"
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

function New-Guid { return [guid]::NewGuid().ToString() }

function XmlEscape([string]$value) {
    return [System.Security.SecurityElement]::Escape($value)
}

function ClassIdFor([string]$kind) {
    switch ($kind) {
        "picklist" { return "3EF39988-22BB-4f0b-BBBE-64B5A3748AEE" }
        "lookup" { return "270BD3DB-D9AF-4782-9025-509E298DEC0A" }
        "money" { return "533B9E00-756B-4312-95A0-DC888637AC78" }
        "memo" { return "E0DECE4B-6FC8-4a8f-A065-082708572369" }
        default { return "4273EDBD-AC1D-40d3-9FB2-095C621B552D" }
    }
}

function New-ControlStepObject {
    param([int]$Index, [string]$Field, [string]$Label, [string]$Kind, [bool]$Required = $false)
    $stepId = New-Guid
    $controlId = "ControlStep$($Index)"
    $stepName = "Step_$($Index)"
    return [ordered]@{
        "__class" = "StepStep:#Microsoft.Crm.Workflow.ObjectModel"
        id = "StepStep$($Index)"
        description = $Field
        name = $stepName
        stepLabels = @{ list = @(@{ labelId = $stepId; languageCode = 1046; description = $Label }) }
        steps = @{ list = @([ordered]@{
            "__class" = "ControlStep:#Microsoft.Crm.Workflow.ObjectModel"
            id = $controlId
            description = ""
            name = "Step_$($Index + 1)"
            stepLabels = @{ list = @() }
            controlId = $Field
            classId = (ClassIdFor $Kind)
            dataFieldName = $Field
            systemStepType = "IdentifyContact"
            isSystemControl = $false
            parameters = ""
            controlDisplayName = $Field
            isUnbound = $false
            controlType = "0"
        }) }
        stepStepId = $stepId
        isProcessRequired = $Required
        isHidden = $false
    }
}

function New-StageObject {
    param([int]$Index, [string]$Name, [string]$StageId, [string]$NextStageId, [object[]]$Steps)
    return [ordered]@{
        "__class" = "StageStep:#Microsoft.Crm.Workflow.ObjectModel"
        id = "StageStep$Index"
        description = $Name
        name = "Step_$Index"
        stepLabels = @{ list = @(@{ labelId = $StageId; languageCode = 1046; description = $Name }) }
        steps = @{ list = $Steps }
        stageId = $StageId
        nextStageId = $NextStageId
        stageCategory = "0"
    }
}

function New-ControlStepXaml {
    param([object]$Step)
    $stepLabel = $Step.stepLabels.list[0]
    $control = $Step.steps.list[0]
    $displayName = XmlEscape $Step.description
    $label = XmlEscape $stepLabel.description
    return @"
                <mxswa:ActivityReference AssemblyQualifiedName="Microsoft.Crm.Workflow.Activities.StepComposite, Microsoft.Crm.Workflow, Version=9.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" DisplayName="$($Step.id): $displayName">
                  <mxswa:ActivityReference.Properties>
                    <sco:Collection x:TypeArguments="Variable" x:Key="Variables" />
                    <sco:Collection x:TypeArguments="Activity" x:Key="Activities">
                      <Sequence DisplayName="$($control.id)">
                        <mcwb:Control ClassId="$($control.classId)" ControlDisplayName="$($control.controlDisplayName)" ControlId="$($control.controlId)" DataFieldName="$($control.dataFieldName)" IsSystemControl="False" IsUnbound="False" SystemStepType="0">
                          <mcwb:Control.Parameters>
                            <InArgument x:TypeArguments="x:String">
                              <Literal x:TypeArguments="x:String" Value="" />
                            </InArgument>
                          </mcwb:Control.Parameters>
                        </mcwb:Control>
                      </Sequence>
                    </sco:Collection>
                    <sco:Collection x:TypeArguments="mcwo:StepLabel" x:Key="StepLabels">
                      <mcwo:StepLabel Description="$label" LabelId="$($stepLabel.labelId)" LanguageCode="1046" />
                    </sco:Collection>
                    <x:String x:Key="ProcessStepId">$($Step.stepStepId)</x:String>
                    <x:Boolean x:Key="IsProcessRequired">$($Step.isProcessRequired)</x:Boolean>
                  </mxswa:ActivityReference.Properties>
                </mxswa:ActivityReference>
"@
}

function New-StageXaml {
    param([object]$Stage)
    $stepsXml = ($Stage.steps.list | ForEach-Object { New-ControlStepXaml $_ }) -join "`r`n"
    $label = XmlEscape $Stage.stepLabels.list[0].description
    $nextXml = if ($Stage.nextStageId) { "<x:String x:Key=""NextStageId"">$($Stage.nextStageId)</x:String>" } else { "<x:Null x:Key=""NextStageId"" />" }
    return @"
          <mxswa:ActivityReference AssemblyQualifiedName="Microsoft.Crm.Workflow.Activities.StageComposite, Microsoft.Crm.Workflow, Version=9.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" DisplayName="$($Stage.id): $label">
            <mxswa:ActivityReference.Properties>
              <sco:Collection x:TypeArguments="Variable" x:Key="Variables" />
              <sco:Collection x:TypeArguments="Activity" x:Key="Activities">
$stepsXml
              </sco:Collection>
              <sco:Collection x:TypeArguments="mcwo:StepLabel" x:Key="StepLabels">
                <mcwo:StepLabel Description="$label" LabelId="$($Stage.stageId)" LanguageCode="1046" />
              </sco:Collection>
              <x:String x:Key="StageId">$($Stage.stageId)</x:String>
              <x:String x:Key="StageCategory">$($Stage.stageCategory)</x:String>
              $nextXml
            </mxswa:ActivityReference.Properties>
          </mxswa:ActivityReference>
"@
}

function New-BpfXaml {
    param([string]$WorkflowId, [object[]]$Stages)
    $compact = $WorkflowId -replace "-", ""
    $stagesXml = ($Stages | ForEach-Object { New-StageXaml $_ }) -join "`r`n"
    return @"
<Activity x:Class="XrmWorkflow$compact" xmlns="http://schemas.microsoft.com/netfx/2009/xaml/activities" xmlns:mcwb="clr-namespace:Microsoft.Crm.Workflow.BusinessProcessFlowActivities;assembly=Microsoft.Crm.Workflow, Version=9.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" xmlns:mcwo="clr-namespace:Microsoft.Crm.Workflow.ObjectModel;assembly=Microsoft.Crm, Version=9.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" xmlns:mva="clr-namespace:Microsoft.VisualBasic.Activities;assembly=System.Activities, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" xmlns:mxs="clr-namespace:Microsoft.Xrm.Sdk;assembly=Microsoft.Xrm.Sdk, Version=9.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" xmlns:mxswa="clr-namespace:Microsoft.Xrm.Sdk.Workflow.Activities;assembly=Microsoft.Xrm.Sdk.Workflow, Version=9.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" xmlns:scg="clr-namespace:System.Collections.Generic;assembly=mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" xmlns:sco="clr-namespace:System.Collections.ObjectModel;assembly=mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" xmlns:srs="clr-namespace:System.Runtime.Serialization;assembly=System.Runtime.Serialization, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" xmlns:this="clr-namespace:" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml">
  <x:Members>
    <x:Property Name="InputEntities" Type="InArgument(scg:IDictionary(x:String, mxs:Entity))" />
    <x:Property Name="CreatedEntities" Type="InArgument(scg:IDictionary(x:String, mxs:Entity))" />
  </x:Members>
  <this:XrmWorkflow$compact.InputEntities>
    <InArgument x:TypeArguments="scg:IDictionary(x:String, mxs:Entity)" />
  </this:XrmWorkflow$compact.InputEntities>
  <this:XrmWorkflow$compact.CreatedEntities>
    <InArgument x:TypeArguments="scg:IDictionary(x:String, mxs:Entity)" />
  </this:XrmWorkflow$compact.CreatedEntities>
  <mva:VisualBasic.Settings>Assembly references and imported namespaces for internal implementation</mva:VisualBasic.Settings>
  <mxswa:Workflow>
    <mxswa:ActivityReference AssemblyQualifiedName="Microsoft.Crm.Workflow.Activities.EntityComposite, Microsoft.Crm.Workflow, Version=9.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" DisplayName="EntityStep1: lead">
      <mxswa:ActivityReference.Properties>
        <sco:Collection x:TypeArguments="Variable" x:Key="Variables" />
        <sco:Collection x:TypeArguments="Activity" x:Key="Activities">
$stagesXml
        </sco:Collection>
        <x:Null x:Key="RelationshipName" />
        <x:Null x:Key="AttributeName" />
        <x:Boolean x:Key="IsClosedLoop">False</x:Boolean>
      </mxswa:ActivityReference.Properties>
    </mxswa:ActivityReference>
  </mxswa:Workflow>
</Activity>
"@
}

function Get-StageClientData {
    param([object]$Stage)
    $items = @()
    foreach ($step in @($Stage.steps.list)) {
        foreach ($control in @($step.steps.list)) {
            if ($control.PSObject.Properties.Name -contains "dataFieldName") {
                $label = if (@($step.stepLabels.list).Count -gt 0) { $step.stepLabels.list[0].description } else { $control.dataFieldName }
                $labelId = if (@($step.stepLabels.list).Count -gt 0) { $step.stepLabels.list[0].labelId } else { [guid]::NewGuid().ToString() }
                $items += [ordered]@{
                    DisplayName = $label
                    DisplayLabelId = $labelId
                    Type = "Field"
                    Field = @{
                        AttributeName = $control.dataFieldName
                        IsRequired = [bool]$step.isProcessRequired
                    }
                }
            }
        }
    }
    return ,($items | ConvertTo-Json -Depth 20 -Compress)
}

function Ensure-ProcessStage {
    param([object]$Stage, [string]$WorkflowId, [string]$PrimaryEntity)
    $stageId = $Stage.stageId
    $stageName = if (@($Stage.stepLabels.list).Count -gt 0) { $Stage.stepLabels.list[0].description } else { $Stage.description }
    $stageBody = @{
        stagename = $stageName
        stagecategory = [int]$Stage.stageCategory
        clientdata = [string](Get-StageClientData -Stage $Stage)
    }
    $stageExists = $false
    try {
        Invoke-Dv -Method Get -Path "processstages($stageId)?`$select=processstageid" | Out-Null
        $stageExists = $true
    } catch {
        Write-Host "Creating processstage: $stageId"
    }
    if ($stageExists) {
        Write-Host "Reusing existing processstage: $stageId for $stageName"
        return
    }

    $stageBody["processstageid"] = $stageId
    $stageBody["primaryentitytypecode"] = $PrimaryEntity
    $stageBody["processid@odata.bind"] = "/workflows($WorkflowId)"
    Invoke-Dv -Method Post -Path "processstages" -Body @{
        processstageid = $stageBody.processstageid
        stagename = $stageBody.stagename
        primaryentitytypecode = $stageBody.primaryentitytypecode
        stagecategory = $stageBody.stagecategory
        clientdata = $stageBody.clientdata
        "processid@odata.bind" = $stageBody["processid@odata.bind"]
    } | Out-Null
}

$script:AccessToken = Get-PacDataverseToken -ResourceUrl $Url

$existing = Invoke-Dv -Method Get -Path ("workflows?`$select=name,workflowid,statecode,statuscode&`$filter=name eq '$WorkflowName'")
if (@($existing.value).Count -lt 1) {
    throw "Workflow '$WorkflowName' not found."
}
$workflow = $existing.value[0]
$workflowId = $workflow.workflowid

if ([int]$workflow.statecode -ne 0) {
    throw "Workflow '$WorkflowName' must be draft/inactive before definition update. Current state=$($workflow.statecode)."
}

$stageNames = @("Entrada", "Filtro 1", "Filtro 2", "Agendado", "Qualificado")
$templateStageOrder = @("Qualify", "Qualificar", "Desenvolver", "Proposta", "Revisão Da Cotação", "Revisao Da Cotacao", "Close")
$stageLookup = @{}
$existingStages = Invoke-Dv -Method Get -Path ("processstages?`$select=processstageid,stagename,_processid_value&`$filter=_processid_value eq $workflowId")
foreach ($existingStage in @($existingStages.value)) {
    $stageLookup[$existingStage.stagename] = $existingStage.processstageid
}
$orderedExistingStageIds = @()
foreach ($templateStageName in $templateStageOrder) {
    if ($stageLookup.ContainsKey($templateStageName)) {
        $orderedExistingStageIds += $stageLookup[$templateStageName]
    }
}
$stageIds = for ($i = 0; $i -lt $stageNames.Count; $i++) {
    $stageName = $stageNames[$i]
    if ($stageLookup.ContainsKey($stageName)) {
        $stageLookup[$stageName]
    } elseif ($i -lt $orderedExistingStageIds.Count) {
        $orderedExistingStageIds[$i]
    } else {
        New-Guid
    }
}
$stepIndex = 2
$stages = @()

$entradaSteps = @(
    (New-ControlStepObject -Index ($stepIndex++) -Field "leadsourcecode" -Label "Origem" -Kind "picklist" -Required $true),
    (New-ControlStepObject -Index ($stepIndex++) -Field "companyname" -Label "Empresa" -Kind "text" -Required $true),
    (New-ControlStepObject -Index ($stepIndex++) -Field "firstname" -Label "Nome" -Kind "text"),
    (New-ControlStepObject -Index ($stepIndex++) -Field "lastname" -Label "Sobrenome" -Kind "text"),
    (New-ControlStepObject -Index ($stepIndex++) -Field "emailaddress1" -Label "Email" -Kind "text"),
    (New-ControlStepObject -Index ($stepIndex++) -Field "telephone1" -Label "Telefone" -Kind "text")
)
$stages += New-StageObject -Index 2 -Name "Entrada" -StageId $stageIds[0] -NextStageId $stageIds[1] -Steps $entradaSteps

$filtro1Steps = @(
    (New-ControlStepObject -Index ($stepIndex++) -Field "industrycode" -Label "Segmento" -Kind "picklist" -Required $true),
    (New-ControlStepObject -Index ($stepIndex++) -Field "nexer_interessedocliente" -Label "Linha Senior" -Kind "picklist"),
    (New-ControlStepObject -Index ($stepIndex++) -Field "leadqualitycode" -Label "Aderencia Senior" -Kind "picklist")
)
$stages += New-StageObject -Index 3 -Name "Filtro 1" -StageId $stageIds[1] -NextStageId $stageIds[2] -Steps $filtro1Steps

$filtro2Steps = @(
    (New-ControlStepObject -Index ($stepIndex++) -Field "qualificationcomments" -Label "Dor e Necessidade" -Kind "memo" -Required $true),
    (New-ControlStepObject -Index ($stepIndex++) -Field "budgetstatus" -Label "Status Do Orcamento" -Kind "picklist"),
    (New-ControlStepObject -Index ($stepIndex++) -Field "budgetamount" -Label "Orcamento" -Kind "money"),
    (New-ControlStepObject -Index ($stepIndex++) -Field "purchasetimeframe" -Label "Prazo" -Kind "picklist")
)
$stages += New-StageObject -Index 4 -Name "Filtro 2" -StageId $stageIds[2] -NextStageId $stageIds[3] -Steps $filtro2Steps

$agendadoSteps = @(
    (New-ControlStepObject -Index ($stepIndex++) -Field "ownerid" -Label "Responsavel" -Kind "lookup"),
    (New-ControlStepObject -Index ($stepIndex++) -Field "description" -Label "Proxima Acao" -Kind "memo")
)
$stages += New-StageObject -Index 5 -Name "Agendado" -StageId $stageIds[3] -NextStageId $stageIds[4] -Steps $agendadoSteps

$qualificadoSteps = @(
    (New-ControlStepObject -Index ($stepIndex++) -Field "purchaseprocess" -Label "Processo De Compra" -Kind "picklist"),
    (New-ControlStepObject -Index ($stepIndex++) -Field "revenue" -Label "Potencial Financeiro" -Kind "money"),
    (New-ControlStepObject -Index ($stepIndex++) -Field "leadqualitycode" -Label "Aderencia Final" -Kind "picklist")
)
$stages += New-StageObject -Index 6 -Name "Qualificado" -StageId $stageIds[4] -NextStageId $null -Steps $qualificadoSteps

$clientData = [ordered]@{
    "__class" = "WorkflowStep:#Microsoft.Crm.Workflow.ObjectModel"
    id = "WorkflowStep0"
    description = "BPF Senior para qualificacao de Cliente Potencial."
    name = "Step_0"
    stepLabels = @{ list = @() }
    steps = @{ list = @([ordered]@{
        "__class" = "EntityStep:#Microsoft.Crm.Workflow.ObjectModel"
        id = "EntityStep1"
        description = "lead"
        name = "Step_1"
        stepLabels = @{ list = @() }
        steps = @{ list = $stages }
        relationshipName = $null
        attributeName = $null
        isClosedLoop = $false
    }) }
    primaryEntityName = "lead"
    nextStepIndex = [string]($stepIndex + 1)
    isCrmUIWorkflow = $true
    category = "4"
    businessProcessType = "0"
    mode = "0"
    title = $WorkflowName
    workflowEntityId = $workflowId
    formId = $null
    argumentsArray = @()
    variables = @()
    inputs = @()
} | ConvertTo-Json -Depth 100 -Compress

$xaml = New-BpfXaml -WorkflowId $workflowId -Stages $stages

foreach ($stage in $stages) {
    Ensure-ProcessStage -Stage $stage -WorkflowId $workflowId -PrimaryEntity "lead"
}

Invoke-Dv -Method Patch -Path "workflows($workflowId)" -Body @{
    clientdata = $clientData
    xaml = $xaml
    description = "BPF Senior para qualificacao de Cliente Potencial: Entrada, Filtro 1, Filtro 2, Agendado e Qualificado."
} | Out-Null
Write-Host "Updated Lead Senior BPF definition"

try {
    Invoke-Dv -Method Patch -Path "workflows($workflowId)" -Body @{ statecode = 1; statuscode = 2 } | Out-Null
    Write-Host "Activated Lead Senior BPF"
} catch {
    Write-Host "Activation failed:"
    Write-Host $_.Exception.Message
}

Invoke-Dv -Method Post -Path "PublishAllXml" -Body @{} | Out-Null
Write-Host "Published customizations"

$confirm = Invoke-Dv -Method Get -Path "workflows($workflowId)?`$select=name,workflowid,statecode,statuscode,clientdata"
Write-Host ("DONE workflowid={0} state={1} status={2}" -f $confirm.workflowid, $confirm.statecode, $confirm.statuscode)
