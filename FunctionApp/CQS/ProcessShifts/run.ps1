##PURPOSE: This is the timer job that wakes up periodically and checks for any scheduling operations (add/remove of agents) to be executed. This done by checking the SPO list.
##Performs those operations and thus achieve the goal of managing agents without manual intervention
##Currently this function is configured to run schedules against only one call queue that is hardcoded in line#24. You must update it for it to work.
##To support multiple call queues, the code must be either updated or make a copy of this into a new function and set the call queue id
# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format.
#$currentUTCtime = Get-Date # (Get-Date).ToUniversalTime()

$currentUTCtime = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId((Get-Date), 'Pacific Standard Time').ToString('MM/dd/yyyy HH:mm')

$AuthentionModuleLocation = ".\Modules\GetAuthenticationToken\GetAuthenticationToken.psd1"
$GetSchedules = ".\Modules\GetSchedulesManifest\GetSchedulesByTime.psd1"
$UpdateSchedules = ".\Modules\UpdateSchedulesManifest\UpdateScheduleEntry.psd1"
Import-Module $AuthentionModuleLocation
Import-Module $GetSchedules
Import-Module $UpdateSchedules
$authHeader = Get-AuthenticationToken

#"https://graph.microsoft.com/v1.0/sites/contoso.sharepoint.com,4d5a27d4-5891-420f-8822-e29376ca4eed,b2648eb8-4d00-4bc3-b3bb-f5c96ec3ad7d/lists/ade46535-7cd3-4418-b872-5b752c830dfa/items?expand=fields(select=Id, Title, AgentShiftDate, Time, AgentEmail, AgentUserId, ActionType, IsComplete)&`$filter=fields/AgentShiftDate eq '$Date' and fields/Time eq '$Time' and fields/IsComplete eq 0 and fields/Removed eq 0"

## TODO: REPLACE WITH YOUR CALL QUEUE ID
$CQid= "fc66a46c-fb4d-4e97-9931-ae52a8f47594"
$SPOSiteId = $ENV:ShiftsMgrSPOSiteId
$ManifestListId = $ENV:ShiftsMgrManifestListId
$ChangeLogListId = $ENV:ShiftsMgrChangeLogListId
$IsCompleted = "true"
$Date=$currentUTCtime.split(" ")[0]
$Time=$currentUTCtime.split(" ")[1]
$ListUrl = "https://graph.microsoft.com/v1.0/sites/$SPOSiteId/lists/$ManifestListId/items?expand=fields(select=Id, Title, AgentShiftDate, Time, AgentEmail, AgentUserId, ActionType, IsComplete)&`$filter=fields/AgentShiftDate eq '$Date' and fields/Time eq '$Time' and fields/IsComplete eq 0 and fields/Removed eq 0 and fields/CallQueue eq '$CQid'"
$SchedulesInfoObject = Get-SchedulesByTime -Token $authHeader -ListUrlWithFilter $ListUrl #-Date $Date -Time $Time -ListUrl 
$agentsToAdd = @()
$agentsToRemvoe = @()
$agentsUPNToAdd = @()
$agentsUPNToRemvoe = @()
$SchedulesInfoObject.value | %{
    if($_.fields.ActionType -eq 'Add') {
        $agentsToAdd += $_.fields.AgentUserId
        $agentsUPNToAdd += $_.fields.AgentEmail
    }
    elseif($_.fields.ActionType -eq 'Remove') {
        $agentsToRemvoe += $_.fields.AgentUserId
        $agentsUPNToRemvoe += $_.fields.AgentEmail
    }
}

# Check if any agents must be added or removed.
if ($agentsToAdd.Length + $agentsToRemvoe.Length -gt 0)
{
    $secpasswd = ConvertTo-SecureString -String $ENV:ShiftsMgrSvcAccountPwd -AsPlainText -Force 
    $mycreds = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $ENV:ShiftsMgrSvcAccountId, $secpasswd
    Connect-MicrosoftTeams -Credential $mycreds | Out-Null
    $cqAgentsResult = Get-CsCallQueue  -Identity $CQid | Select Agents
    $newAgents = @()
    $currentAgents = @()
    if($cqAgentsResult.Agents.Length -gt 0)
    {
        Write-output "Consolidating with existing agents"
        $cqAgentsResult.Agents | % { $currentAgents += $_.ObjectId }
        $agentsContinuing = $currentAgents | ?{$_ -notin $agentsToRemvoe}
        #If agentsContinuing is empty, it means all existing agents to be removed. So just return the agentsToAdd.
        $newAgents =  $agentsContinuing.Length -eq 0 ? $agentsToAdd : (Compare-Object $agentsContinuing $agentsToAdd -PassThru -IncludeEqual)
    }
    else
    {
        Write-output "No existing agents"
        $newAgents = $agentsToAdd
    }

    $agentsChangLog = [PSCustomObject]@{
        CurrentAgents = $currentAgents
        AgentsToAdd = $agentsToAdd
        AgentsToRemove = $agentsToRemvoe
        NewAgents = $newAgents
    }
    Write-output $agentsChangLog
    $body = Set-CsCallQueue -Users $newAgents -Identity $CQid | Select Name, Identity, Agents | ConvertTo-Json
    Disconnect-MicrosoftTeams

    # SET THE ISCOMPELTE TO TRUE FOR THE PROCESSED ITEMS
    $SchedulesInfoObject.value | %{ Update-ScheduleEntry -Token $authHeader -Id $_.fields.id -IsComplete $IsCompleted -SPOSiteid $SPOSiteId -ManifestListId $ManifestListId}
    #Add-ShiftsChangeLog -Token $authHeader -Date $Date -Time $Time -ChangeBy "Service Account" -AgentsBeforeChange $agentsChangLog.CurrentAgents -AgentsToAdd $agentsChangLog.AgentsToAdd -AgentsToRemove $agentsChangLog.AgentsToRemove -AgentsAfterChange $agentsChangLog.NewAgents
    Add-ShiftsChangeLog -Token $authHeader -DateStr $Date -TimeStr $Time -ChangeBy "Service Account" -AgentsBeforeChange ($agentsChangLog.CurrentAgents -join ", ") -AgentsToAdd ($agentsChangLog.AgentsToAdd -join ", ") -AgentsToRemove ($agentsChangLog.AgentsToRemove -join ", ") -AgentsAfterChange ($agentsChangLog.NewAgents -join ", ") -SPOSiteid $SPOSiteId -ChangeLogListId $ChangeLogListId -CallQueueId $CQid
}
else
{
    Write-output "No shifts entries found for the provided date time ($Date $Time) criteria. No action taken."
}

# The 'IsPastDue' property is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"
