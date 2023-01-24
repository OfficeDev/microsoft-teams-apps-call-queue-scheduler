##PURPOSE: This functions gets called from flow when user uploads a CSV file. This functions get the CSV file content. Parses it, generates a manifest of operations (add and remove) for agents schedule.
##The schedules are added to SPO site.
using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)
$AuthentionModuleLocation = ".\Modules\GetAuthenticationToken\GetAuthenticationToken.psd1"
$UpdateSchedules = ".\Modules\UpdateSchedulesManifest\UpdateScheduleEntry.psd1"
Import-Module $AuthentionModuleLocation
Import-Module $UpdateSchedules
$authHeader = Get-AuthenticationToken
Write-Host $authHeader.Authorization
$runasUserUpn = $Request.Headers['X-MS-CLIENT-PRINCIPAL-NAME']
$userid = $Request.Headers['X-MS-CLIENT-PRINCIPAL-ID']

$SPOSiteId = $ENV:ShiftsMgrSPOSiteId
$ManifestListId = $ENV:ShiftsMgrManifestListId
$ChangeLogListId = $ENV:ShiftsMgrChangeLogListId

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."


$filename = $Request.Body.filename
$filecontent = $Request.Body.filecontent
$body = "Filename: $filename. Content: $filecontent"
$shifts = $filecontent | ConvertFrom-Csv -Delimiter ','
#[Text.Encoding]::Utf8.GetString([Convert]::FromBase64String($fc.Trim())) | ConvertFrom-Csv -Delimiter ','
$h = $shifts[0]
$totalDays = $h.PSObject.Properties.Name.Length-1
Write-Host "Total days: $totalDays"


$allShifts = @()
1..$totalDays | % {
    Write-Host "Day $_ >>>  $(([DateTime] $h.PSObject.Properties.Name[$_]).ToString("MM/dd/yyyy"))"
    $currentDay = $_
    #New-Variable -Name "shiftsOfDay$currentDay" -Value @() -Force

    $shifts | %{ 
        $currentAssignment = $_.Assignment
        $agentUpn = $_.$($h.PSObject.Properties.Name[$currentDay])
        $currentDt = ([DateTime] $h.PSObject.Properties.Name[$currentDay]).ToString("MM/dd/yyyy")   
        $nextDt = ([DateTime] $h.PSObject.Properties.Name[$currentDay]).AddDays(1).ToString("MM/dd/yyyy")
        <#
        $startTime = ([DateTime]($_.Assignment.Split(" ")[2].Split("-")[0].Trim() + "m")).ToString("HH:mm")
        $endTime = ([DateTime]($_.Assignment.Split(" ")[2].Split("-")[1].Trim() + "m")).ToString("HH:mm")
        $startHr = [int32] ([DateTime]($_.Assignment.Split(" ")[2].Split("-")[0].Trim() + "m")).ToString("HH")
        $endHr = [int32] ([DateTime]($_.Assignment.Split(" ")[2].Split("-")[1].Trim() + "m")).ToString("HH")
        #>
        $startTime = ([DateTime]($_.Assignment.Split("-")[0].Trim())).ToString("HH:mm")
        $endTime = ([DateTime]($_.Assignment.Split("-")[1].Trim())).ToString("HH:mm")
        $startHr = [int32] ([DateTime]($_.Assignment.Split("-")[0].Trim())).ToString("HH")
        $endHr = [int32] ([DateTime]($_.Assignment.Split("-")[1].Trim())).ToString("HH")
        $endDt = if(($endHr -gt $startHr) -or ($endHr -eq $startHr)) { 
                                $currentDt
                            } else {
                                $nextDt
                            }
        # Process the row only if an agent is present
        if($agentUpn -ne "") { 
            Write-Host $currentAssignment " " $agentUpn
            $shiftLinkGuid = (New-Guid).Guid #This is to associate add and remove entries

            #Create the 'Add agent' record
            $shiftInfo = @{
                "Date" = $currentDt
                "Time"  = $startTime
                "UPN"   = $agentUpn
                "ActionType" = "Add"
                "EndDate" = $endDt
                "EndTime" = $endTime
                "StartHour" = $startHr
                "EndHour" = $endHr
                "ShiftLink" = $shiftLinkGuid
            }
            $allShifts += $shiftInfo

            #Create the 'Remove agent' record
            $shiftInfo = @{
                "Date" = $endDt
                "Time"  = $endTime
                "UPN"   = $agentUpn
                "ActionType" = "Remove"
                "EndDate" = $endDt
                "EndTime" = $endTime
                "StartHour" = $startHr
                "EndHour" = $endHr
                "ShiftLink" = $shiftLinkGuid           
            } 
            $allShifts += $shiftInfo
            $agentUpn = ""
        }
    }
}

$r = @{ requests = @() }
$i = 0
$totalEntries = $allShifts.Length
Write-Host "Total rows $totalEntries"
$allShifts | %{
    #Write-Host "Iteration $i"
    $date = $_.Date
    $time = $_.Time
    $email = $_.UPN
    $actionType = $_.ActionType
    $endDate = $_.EndDate
    $endTime = $_.EndTime
    $startHour = $_.StartHour
    $endHour = $_.EndHour
    $shiftLink = $_.ShiftLink

    $r.requests += @{
        id = $i+1
        #url = "sites/m365x229910.sharepoint.com,4d5a27d4-5891-420f-8822-e29376ca4eed,b2648eb8-4d00-4bc3-b3bb-f5c96ec3ad7d/lists/ade46535-7cd3-4418-b872-5b752c830dfa/items"
        url = "sites/$SPOSiteId/lists/$ManifestListId/items"
        method = "POST"
        body = @{fields = @{    Title="ShiftEntry";
                                AgentShiftDate="$date";
                                Time="$time";
                                AgentEmail="$email";
                                ActionType="$actionType";
                                EndDate="$endDate";
                                EndTime="$endTime";
                                StartHour="$startHour";
                                EndHour="$endHour";
                                AddedVia="$filename";
                                AddModBy="$runasUserUpn";
                                ShiftLink="$shiftLink"
        }}
        headers = @{ "content-type" = "application/json" }
        }
        if ($r.requests.Count -eq 20 -or $i -eq $totalEntries-1) {
            $payload = ConvertTo-Json $r -Depth 4
            Write-Host "Batch run id $i"
            Write-Host $payload
            $result = Add-SchedulesBatch -Token $authHeader -Payload $payload -BatchId $i
            Write-Host $result.StatusCode
            Write-Host $result.Content
            $r.requests = @()
          }
          $i += 1
}


# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})
