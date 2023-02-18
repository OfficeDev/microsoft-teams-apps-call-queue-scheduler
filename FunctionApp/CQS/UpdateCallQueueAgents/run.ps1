##PURPOSE: For the given call queue id and list of agent guid's, the script updates the call queue with the provided agents
using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Interact with query parameters or the body of the request.
$cqid = $Request.Body.CQId
$agents = $Request.Body.AgentsList

$agentsList = If($agents.Trim().Length -eq 0) { $null } else { $agents.Split(", ") }

$secpasswd = ConvertTo-SecureString -String $ENV:ShiftsMgrSvcAccountPwd -AsPlainText -Force 
$mycreds = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $ENV:ShiftsMgrSvcAccountId, $secpasswd

Connect-MicrosoftTeams -Credential $mycreds | Out-Null
try {
    Write-output "Agents List: $agentsList"
    $body = Set-CsCallQueue -Users $agentsList -Identity $cqid | Select Name, Identity, Agents | ConvertTo-Json
}
catch {
    Write-output $_.Exception.Message
    $body = "Duplicate agents list provided"
}

Write-output "PS Result>"
Write-output `n$body
Disconnect-MicrosoftTeams

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})