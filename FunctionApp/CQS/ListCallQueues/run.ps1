## Connect to MS Teams and get all the call queue's along with agents info
using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

$secpasswd = ConvertTo-SecureString -String $ENV:ShiftsMgrSvcAccountPwd -AsPlainText -Force 
$mycreds = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $ENV:ShiftsMgrSvcAccountId, $secpasswd

<#
#Use this block to test with hard coded credentials
$SvcAcctPwd = "***"
$SvcAcctId = "shiftmgr@contoso.onmicrosoft.com"
$secpasswd = ConvertTo-SecureString -String $SvcAcctPwd -AsPlainText -Force 
$mycreds = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $SvcAcctId, $secpasswd
#>

Connect-MicrosoftTeams -Credential $mycreds | Out-Null
$body = Get-CsCallQueue | Select Name, Identity, Agents | ConvertTo-Json
#$body = $ENV:ShiftMgrCallQueueId
Write-output "PS Result>"
Write-output `n$body
Disconnect-MicrosoftTeams


# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})