param(
    [string]$Url = "https://nexereabrpresales.crm.dynamics.com",
    [string]$WorkflowId = "04e47f53-c458-f111-bec6-0022482557cc"
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

function Get-ErrorBody {
    param([System.Management.Automation.ErrorRecord]$ErrorRecord)
    if ($ErrorRecord.ErrorDetails -and $ErrorRecord.ErrorDetails.Message) {
        return $ErrorRecord.ErrorDetails.Message
    }
    if (-not $ErrorRecord.Exception.Response) {
        return $ErrorRecord.Exception.Message
    }
    $stream = $ErrorRecord.Exception.Response.GetResponseStream()
    if (-not $stream) {
        return $ErrorRecord.Exception.Message
    }
    $reader = New-Object IO.StreamReader($stream)
    return $reader.ReadToEnd()
}

$accessToken = Get-PacDataverseToken -ResourceUrl $Url
$headers = @{
    Authorization = "Bearer $accessToken"
    SOAPAction = '"http://schemas.microsoft.com/xrm/2011/Contracts/Services/IOrganizationService/Execute"'
}

$body = @"
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
  <s:Body>
    <Execute xmlns="http://schemas.microsoft.com/xrm/2011/Contracts/Services" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
      <request i:type="b:SetStateRequest" xmlns:a="http://schemas.microsoft.com/xrm/2011/Contracts" xmlns:b="http://schemas.microsoft.com/crm/2011/Contracts">
        <a:Parameters xmlns:c="http://schemas.datacontract.org/2004/07/System.Collections.Generic">
          <a:KeyValuePairOfstringanyType>
            <c:key>EntityMoniker</c:key>
            <c:value i:type="a:EntityReference">
              <a:Id>$WorkflowId</a:Id>
              <a:LogicalName>workflow</a:LogicalName>
              <a:Name i:nil="true" />
            </c:value>
          </a:KeyValuePairOfstringanyType>
          <a:KeyValuePairOfstringanyType>
            <c:key>State</c:key>
            <c:value i:type="a:OptionSetValue">
              <a:Value>1</a:Value>
            </c:value>
          </a:KeyValuePairOfstringanyType>
          <a:KeyValuePairOfstringanyType>
            <c:key>Status</c:key>
            <c:value i:type="a:OptionSetValue">
              <a:Value>2</a:Value>
            </c:value>
          </a:KeyValuePairOfstringanyType>
        </a:Parameters>
        <a:RequestId i:nil="true" />
        <a:RequestName>SetState</a:RequestName>
      </request>
    </Execute>
  </s:Body>
</s:Envelope>
"@

try {
    $response = Invoke-WebRequest -Method Post -Uri "$Url/XRMServices/2011/Organization.svc/web" -Headers $headers -ContentType "text/xml; charset=utf-8" -Body $body
    Write-Host ("SOAP SetState HTTP {0}" -f $response.StatusCode)
} catch {
    Write-Host "SOAP SetState failed"
    Write-Host (Get-ErrorBody -ErrorRecord $_)
    throw
}
