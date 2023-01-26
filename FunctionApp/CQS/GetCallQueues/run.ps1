##PURPOSE: This function does below things:
##1. Get list of Call Queue ID's that the current user (invoking this function) owns or manages. This is stored in the SPO list called CallQueueOwners.
##2. Then it connects to MS Teams, get all the call queue's along with agents. Filters the list based on #1 and returns it as JSON
using namespace System.Net
# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

$AuthentionModuleLocation = ".\Modules\GetAuthenticationToken\GetAuthenticationToken.psd1"
$CallQueuesModule = ".\Modules\GetCallQueues\GetCallQueues.psd1"
Import-Module $AuthentionModuleLocation
Import-Module $CallQueuesModule
$authHeader = Get-AuthenticationToken
$runasUserUpn = $Request.Headers['X-MS-CLIENT-PRINCIPAL-NAME']
$userid = $Request.Headers['X-MS-CLIENT-PRINCIPAL-ID']
Write-output $runasUserUpn

$SPOSiteId = $ENV:ShiftsMgrSPOSiteId
$CallQueueOwnersListId = $ENV:ShiftsMgrCallQueueOwnersListId
#https://graph.microsoft.com/v1.0/sites/{siteid}/lists/{listid}/items?expand=fields(select=OwnerEmail,CallQueueId)&$filter=fields/OwnerEmail eq 'admin@contoso.OnMicrosoft.com'
$ListUrl = "https://graph.microsoft.com/v1.0/sites/$SPOSiteId/lists/$CallQueueOwnersListId/items?expand=fields(select=OwnerEmail,CallQueueId)&`$filter=fields/OwnerEmail eq '$runasUserUpn'"
Write-output $ListUrl
#Get list of call queues the current user must manage
$GetUsersCallQueues = Get-CallQueues -Token $authHeader -ListUrlWithFilter $ListUrl
$callqueueIds = @()
$GetUsersCallQueues.value | %{
    $callqueueIds += $_.fields.CallQueueId
}
Write-output "# of call queues this user manages " $callqueueIds.length
$secpasswd = ConvertTo-SecureString -String $ENV:ShiftsMgrSvcAccountPwd -AsPlainText -Force 
$mycreds = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $ENV:ShiftsMgrSvcAccountId, $secpasswd
Connect-MicrosoftTeams -Credential $mycreds | Out-Null
#$body = Get-CsCallQueue | Select Name, Identity, Agents | ?{$_.Identity -in $callqueueIds} | ConvertTo-Json
if($callqueueIds.length -le 1) 
{
    $body = Get-CsCallQueue | Select Name, Identity, Agents | ?{$_.Identity -in $callqueueIds} 
    $body = ConvertTo-Json -InputObject @($body)
}
else
{
    $body = Get-CsCallQueue | Select Name, Identity, Agents | ?{$_.Identity -in $callqueueIds} | ConvertTo-Json   
}
$result = $body.Replace(", OptIn","")
Write-output "PS Result>"
Write-output `n$result
Disconnect-MicrosoftTeams

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $result
})
