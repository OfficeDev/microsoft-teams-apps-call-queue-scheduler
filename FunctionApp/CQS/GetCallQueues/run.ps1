##DO NOT USE THIS FUNCTION
using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

#$SvcAcctId = $ENV:CC-ServiceAccountId
#$SvcAcctPwd = $ENV:CC-ServiceAccountPwd

Write-output "From KV"
$body = $ENV:CCServiceAccountPwd #ServiceAccountEmail


$secpasswd = ConvertTo-SecureString -String $ENV:CCServiceAccountPwd -AsPlainText -Force 
$mycreds = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $ENV:CCServiceAccountId, $secpasswd

#$secpasswd = ConvertTo-SecureString -String $SvcAcctPwd -AsPlainText -Force 
#$mycreds = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $SvcAcctId, $secpasswd

Connect-MicrosoftTeams -Credential $mycreds | Out-Null
$body = Get-CsCallQueue | Select Name | ConvertTo-Json
Write-output "PS Result>"
Write-output `n$body
Disconnect-MicrosoftTeams



# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})
