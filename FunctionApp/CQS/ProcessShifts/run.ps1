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

## TODO: MAKE THIS CONFIGURABLE
$CQid= $ENV:ShiftMgrCallQueueId #"a072605c-0130-4792-80cf-d379f518358d"
$IsCompleted = "true"
$Date=$currentUTCtime.split(" ")[0]
$Time=$currentUTCtime.split(" ")[1]
$SchedulesInfoObject = Get-SchedulesByTime -Token $authHeader -Date $Date -Time $Time
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
    $SchedulesInfoObject.value | %{ Update-ScheduleEntry -Token $authHeader -Id $_.fields.id -IsComplete $IsCompleted }
    #Add-ShiftsChangeLog -Token $authHeader -Date $Date -Time $Time -ChangeBy "Service Account" -AgentsBeforeChange $agentsChangLog.CurrentAgents -AgentsToAdd $agentsChangLog.AgentsToAdd -AgentsToRemove $agentsChangLog.AgentsToRemove -AgentsAfterChange $agentsChangLog.NewAgents
    Add-ShiftsChangeLog -Token $authHeader -DateStr $Date -TimeStr $Time -ChangeBy "Service Account" -AgentsBeforeChange ($agentsChangLog.CurrentAgents -join ", ") -AgentsToAdd ($agentsChangLog.AgentsToAdd -join ", ") -AgentsToRemove ($agentsChangLog.AgentsToRemove -join ", ") -AgentsAfterChange ($agentsChangLog.NewAgents -join ", ")
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
