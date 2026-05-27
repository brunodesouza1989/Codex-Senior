$ErrorActionPreference = 'Stop'

$toolPath = (Resolve-Path '.tools\pac-msi\pkg\tools').Path
$sdkDepDlls = Get-ChildItem '.tools\sdk-deps' -Recurse -Filter '*.dll' |
  Where-Object { $_.FullName -match '\\lib\\(net461|net472|netstandard2\.0)\\' } |
  Group-Object BaseName -AsHashTable -AsString
Write-Host "ToolPath=$toolPath"
Write-Host "Loading Microsoft.Extensions.Logging.Abstractions 3.1.8"
foreach ($depName in $sdkDepDlls.Keys) {
  Write-Host "Preloading $depName"
  [System.Reflection.Assembly]::LoadFrom($sdkDepDlls[$depName][0].FullName) | Out-Null
}

[AppDomain]::CurrentDomain.add_AssemblyResolve({
  param($sender, $args)
  $name = New-Object System.Reflection.AssemblyName($args.Name)
  if ($sdkDepDlls.ContainsKey($name.Name)) {
    return [System.Reflection.Assembly]::LoadFrom($sdkDepDlls[$name.Name][0].FullName)
  }
  $candidate = Join-Path $toolPath ($name.Name + '.dll')
  if (Test-Path $candidate) {
    return [System.Reflection.Assembly]::LoadFrom($candidate)
  }
  return $null
})

foreach ($dll in @(
  'Microsoft.Xrm.Sdk.dll',
  'Microsoft.Crm.Sdk.Proxy.dll',
  'Microsoft.PowerPlatform.Dataverse.Client.dll'
)) {
  $path = Join-Path $toolPath $dll
  Write-Host "Loading $dll"
  [System.Reflection.Assembly]::LoadFrom($path) | Out-Null
}

Write-Host "Creating ServiceClient"
$conn = 'AuthType=OAuth;Url=https://nexereabrpresales.crm.dynamics.com;ClientId=51f81489-12ee-4a9e-aaae-a2591f45987d;RedirectUri=app://58145B91-0C36-4500-8554-080854F2AC97;LoginPrompt=Auto'
$svc = [Microsoft.PowerPlatform.Dataverse.Client.ServiceClient]::new($conn)
Write-Host "IsReady=$($svc.IsReady)"
if (-not $svc.IsReady) {
  Write-Host "LastError=$($svc.LastError)"
  Write-Host "LastException=$($svc.LastException)"
  exit 2
}

Write-Host "Executing WhoAmI"
$req = [Microsoft.Crm.Sdk.Messages.WhoAmIRequest]::new()
$res = $svc.Execute($req)
[pscustomobject]@{
  IsReady = $svc.IsReady
  UserId = $res.UserId
  OrgId = $res.OrganizationId
  ConnectedOrg = $svc.ConnectedOrgFriendlyName
} | ConvertTo-Json
