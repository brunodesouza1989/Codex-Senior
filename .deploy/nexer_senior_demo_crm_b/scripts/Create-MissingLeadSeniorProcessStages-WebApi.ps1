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
        return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers -ContentType "application/json; charset=utf-8" -Body ($Body | ConvertTo-Json -Depth 100)
    }
    return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers
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
    return ($items | ConvertTo-Json -Depth 20 -Compress)
}

$script:AccessToken = Get-PacDataverseToken -ResourceUrl $Url
$encodedName = $WorkflowName.Replace("'", "''")
$result = Invoke-Dv -Method Get -Path ("workflows?`$select=name,workflowid,clientdata&`$filter=name eq '$encodedName'")
if (@($result.value).Count -lt 1) { throw "Workflow '$WorkflowName' not found." }
$workflow = $result.value[0]
$workflowId = $workflow.workflowid
$clientData = $workflow.clientdata | ConvertFrom-Json

foreach ($entityStep in @($clientData.steps.list | Where-Object { $_.PSObject.Properties.Name -contains "description" })) {
    $primaryEntity = $entityStep.description
    foreach ($stage in @($entityStep.steps.list)) {
        $stageId = $stage.stageId
        $existing = $null
        try { $existing = Invoke-Dv -Method Get -Path "processstages($stageId)?`$select=processstageid" } catch { $existing = $null }
        if ($existing) {
            Write-Host ("Processstage exists: {0}" -f $stageId)
            continue
        }

        $stageName = if (@($stage.stepLabels.list).Count -gt 0) { $stage.stepLabels.list[0].description } else { $stage.description }
        Write-Host ("Creating processstage {0} / {1} / {2}" -f $stageId, $stageName, $primaryEntity)
        Invoke-Dv -Method Post -Path "processstages" -Body @{
            processstageid = $stageId
            stagename = $stageName
            primaryentitytypecode = $primaryEntity
            stagecategory = [int]$stage.stageCategory
            clientdata = (Get-StageClientData -Stage $stage)
            "processid@odata.bind" = "/workflows($workflowId)"
        } | Out-Null
    }
}
