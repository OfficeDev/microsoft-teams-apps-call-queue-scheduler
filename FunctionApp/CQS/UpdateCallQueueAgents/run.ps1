using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Interact with query parameters or the body of the request.
$cqid = $Request.Body.CQId
$agents = $Request.Body.AgentsList
<#
if (-not $agents) {
    $agents = $Request.Body.Agents
}
#>

$body = "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response."

if ($agents) {
    $body = $agents
}

$agentsList = $agents.Split(", ");
#$body = $agentsList + "|" + $cqid


$secpasswd = ConvertTo-SecureString -String $ENV:ShiftsMgrSvcAccountPwd -AsPlainText -Force 
$mycreds = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $ENV:ShiftsMgrSvcAccountId, $secpasswd

Connect-MicrosoftTeams -Credential $mycreds | Out-Null
$body = Set-CsCallQueue -Users $agentsList -Identity $cqid | Select Name, Identity, Agents | ConvertTo-Json
Write-output "PS Result>"
Write-output `n$body
Disconnect-MicrosoftTeams


# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})
