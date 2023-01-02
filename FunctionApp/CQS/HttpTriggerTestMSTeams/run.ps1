using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

$AuthentionModuleLocation = ".\Modules\GetAuthenticationToken\GetAuthenticationToken.psd1"
$UpdateSchedules = ".\Modules\UpdateSchedulesManifest\UpdateScheduleEntry.psd1"
Import-Module $AuthentionModuleLocation
Import-Module $UpdateSchedules
$authHeader = Get-AuthenticationToken

$upn = $Request.Headers['X-MS-CLIENT-PRINCIPAL-NAME']
$userid = $Request.Headers['X-MS-CLIENT-PRINCIPAL-ID']
$body = $upn + " | " + $userid #$Request | ConvertTo-Json

<#
#Take csv file base64 string, parse and create items in SPO list
$fc = "QXNzaWdubWVudCw4LzMxLzIwMjIsOS8xLzIwMjIsOS8yLzIwMjIsOS8zLzIwMjIsOS80LzIwMjIsOS81LzIwMjIsOS82LzIwMjIsOS83LzIwMjIsOS84LzIwMjIsOS85LzIwMjIsOS8xMC8yMDIyLDkvMTEvMjAyMiw5LzEyLzIwMjIsOS8xMy8yMDIyLDkvMTQvMjAyMiw5LzE1LzIwMjIsOS8xNi8yMDIyLDkvMTcvMjAyMiw5LzE4LzIwMjIsOS8xOS8yMDIyLDkvMjAvMjAyMiw5LzIxLzIwMjIsOS8yMi8yMDIyLDkvMjMvMjAyMiw5LzI0LzIwMjIsOS8yNS8yMDIyLDkvMjYvMjAyMiw5LzI3LzIwMjIsOS8yOC8yMDIyLDkvMjkvMjAyMiw5LzMwLzIwMjINCk5DQUwgVFMgM2EtN2EsLCwsLEp1ZHkgUmV5ZXMsLCwsLCxQZXJyeSBDb3gsSnVkeSBSZXllcywsLCwsLCxKdWR5IFJleWVzLCwsLCwsUGVycnkgQ294LEp1ZHkgUmV5ZXMsLCwsLA0KTkNBTCBUUyA3YS0xMWEsLEpvaG4gRG9yaWFuLCwsLCwsLFNhcmFoIENoYWxrZSwsLCwsLCxMYXZlcm5lIFJvYmVydHMsLCwsLCwsU2FyYWggQ2hhbGtlLCwsLCwsLE1pY2hhZWwgTW9zbGV5LA0KTkNBTCBUUyAxMWEtMzozMHAsLEVsbGlvdCBSZWlkLCwsLCwsLEVsbGlvdCBSZWlkLCwsLCwsLEVsbGlvdCBSZWlkLCwsLCwsLEVsbGlvdCBSZWlkLCwsLCwsLEVsbGlvdCBSZWlkLA0KTkNBTCBUUyA3YS0zOjMwcCwsLENocmlzdG9waGVyIFR1cmssRHJldyBTdWZmaW4sRGF2ZSBGcmFuY28sRWxsaW90IFJlaWQsQ2hyaXN0b3BoZXIgVHVyayxEYXZlIEZyYW5jbywsTHVjeSBCZW5uZXR0LEtlbiBKZW5raW5zLERhdmUgRnJhbmNvLEtlbm5ldGggRm94LFBlcnJ5IENveCxEYXZlIEZyYW5jbywsTHVjeSBCZW5uZXR0LERyZXcgU3VmZmluLExhdmVybmUgUm9iZXJ0cyxLZW5uZXRoIEZveCxUZWQgQnVja2xhbmQsRGF2ZSBGcmFuY28sLERvbmFsIEZhaXNvbixSb2JlcnQgS2Vsc28sRGF2ZSBGcmFuY28sTGF2ZXJuZSBSb2JlcnRzLFBlcnJ5IENveCxEYXZlIEZyYW5jbywsTHVjeSBCZW5uZXR0DQpOQ0FMIFRTIDdhLTM6MzBwLCwsLCwsS2VubmV0aCBGb3gsRWxpemEgQ291cGUsLCwsLCwsLCwsLCwsLCwsLFNhcmFoIENoYWxrZSwsLFNhcmFoIENoYWxrZSwsLCwNCk5DQUwgVFMgN2EtMzozMHAsLCwsLCxUb2RkIFF1aW5pYW4sLCwsLCwsLCwsLCwsLCwsLCxFbGl6YSBDb3VwZSwsLCwsLCwNCk5DQUwgVFMgN2EtMzozMHAsLCwsLCxDaHJpc3RvcGhlciBUdXJrLCwsLCwsLCwsLCwsLCwsLCwsLCwsLCwsLA0KTkNBTCBUUyAxMGEtMnAsLFJvYmVydCBLZWxzbyxEcmV3IFN1ZmZpbixDYXJsYSBFc3Bpbm9zYSxFbGxpb3QgUmVpZCxDaHJpc3RvcGhlciBUdXJrLERvbmFsIEZhaXNvbixTYXJhaCBDaGFsa2UsRG9uYWwgRmFpc29uLERlbmlzZSBNYWhvbmV5LERvbmFsIEZhaXNvbixNaWNoYWVsIE1vc2xleSxDaHJpc3RvcGhlciBUdXJrLENocmlzdG9waGVyIFR1cmssS2VubmV0aCBGb3gsRG9uYWwgRmFpc29uLERyZXcgU3VmZmluLENhcmxhIEVzcGlub3NhLEVsbGlvdCBSZWlkLFNhcmFoIENoYWxrZSxEb25hbCBGYWlzb24sU2FyYWggQ2hhbGtlLERvbmFsIEZhaXNvbixEZW5pc2UgTWFob25leSxLZW4gSmVua2lucyxNaWNoYWVsIE1vc2xleSxMYXZlcm5lIFJvYmVydHMsTGF2ZXJuZSBSb2JlcnRzLEtlbm5ldGggRm94LFJvYmVydCBLZWxzbyxEcmV3IFN1ZmZpbg0KTkNBTCBUUyAxMGEtMnAsLCwsLCxPUEVOLCwsLCwsLCwsLCwsLCwsLCwsLCwsLCwsLA0KTkNBTCBUUyAycC02cCwsUm9iZXJ0IEtlbHNvLERyZXcgU3VmZmluLENhcmxhIEVzcGlub3NhLEVsbGlvdCBSZWlkLEVsaXphIENvdXBlLENocmlzdG9waGVyIFR1cmssTWljaGFlbCBNb3NsZXksRG9uYWwgRmFpc29uLERlbmlzZSBNYWhvbmV5LEVsaXphIENvdXBlLEVsaXphIENvdXBlLEx1Y3kgQmVubmV0dCxDaHJpc3RvcGhlciBUdXJrLEtlbm5ldGggRm94LERvbmFsIEZhaXNvbixEcmV3IFN1ZmZpbixDYXJsYSBFc3Bpbm9zYSxFbGxpb3QgUmVpZCxUZWQgQnVja2xhbmQsTGF2ZXJuZSBSb2JlcnRzLE1pY2hhZWwgTW9zbGV5LERvbmFsIEZhaXNvbixEZW5pc2UgTWFob25leSxFbGl6YSBDb3VwZSxFbGl6YSBDb3VwZSxMdWN5IEJlbm5ldHQsTGF2ZXJuZSBSb2JlcnRzLEtlbm5ldGggRm94LFJvYmVydCBLZWxzbyxEcmV3IFN1ZmZpbg0KTkNBTCBUUyA2cC0xMHAsLFBlcnJ5IENveCxMdWN5IEJlbm5ldHQsWmFjaCBCcmFmZixEcmV3IFN1ZmZpbixDaHJpc3RvcGhlciBUdXJrLEx1Y3kgQmVubmV0dCxSb2JlcnQgS2Vsc28sTHVjeSBCZW5uZXR0LEx1Y3kgQmVubmV0dCxSb2JlcnQgS2Vsc28sQ2hyaXN0b3BoZXIgVHVyayxSb2JlcnQgS2Vsc28sTHVjeSBCZW5uZXR0LFJvYmVydCBLZWxzbyxQZXJyeSBDb3gsTHVjeSBCZW5uZXR0LEtlbiBKZW5raW5zLERyZXcgU3VmZmluLFJvYmVydCBLZWxzbyxMdWN5IEJlbm5ldHQsS2VuIEplbmtpbnMsTHVjeSBCZW5uZXR0LEx1Y3kgQmVubmV0dCxSb2JlcnQgS2Vsc28sTGF2ZXJuZSBSb2JlcnRzLFJvYmVydCBLZWxzbyxMdWN5IEJlbm5ldHQsUm9iZXJ0IEtlbHNvLFBlcnJ5IENveCxEb25hbCBGYWlzb24NCk5DQUwgVFMgMzozMHAtMTJhLENhcmxhIEVzcGlub3NhLCxFbGxpb3QgUmVpZCxEb25hbCBGYWlzb24sS2VuIEplbmtpbnMsRG9uYWwgRmFpc29uLERhdmUgRnJhbmNvLERvbmFsIEZhaXNvbiwsRG9uYWwgRmFpc29uLERhdmUgRnJhbmNvLFJvYmVydCBLZWxzbyxFbGl6YSBDb3VwZSxEYXZlIEZyYW5jbyxDYXJsYSBFc3Bpbm9zYSwsRWxsaW90IFJlaWQsUm9iZXJ0IEtlbHNvLFJvYmVydCBLZWxzbyxTYXJhaCBDaGFsa2UsRGF2ZSBGcmFuY28sUm9iZXJ0IEtlbHNvLCxEYXZlIEZyYW5jbyxEYXZlIEZyYW5jbyxSb2JlcnQgS2Vsc28sRWxpemEgQ291cGUsRGF2ZSBGcmFuY28sQ2FybGEgRXNwaW5vc2EsLEVsbGlvdCBSZWlkDQpOQ0FMIFRTIDM6MzBwLTEyYSwsLCwsLCwsLCxFbGl6YSBDb3VwZSwsLCwsLCwsLCwsLCwsLCwsLCwsLA0KTkNBTCBUUyAxMDozMHAtN2EsTmVpbCBGbHlubixEZW5pc2UgTWFob25leSxKdWR5IFJleWVzLCxOZWlsIEZseW5uLE5laWwgRmx5bm4sVG9kZCBRdWluaWFuLE5laWwgRmx5bm4sS2VuIEplbmtpbnMsLCxOZWlsIEZseW5uLE5laWwgRmx5bm4sVG9kZCBRdWluaWFuLE5laWwgRmx5bm4sRGVuaXNlIE1haG9uZXksSnVkeSBSZXllcywsTmVpbCBGbHlubixOZWlsIEZseW5uLFRvZGQgUXVpbmlhbixOZWlsIEZseW5uLEtlbiBKZW5raW5zLCwsTmVpbCBGbHlubixOZWlsIEZseW5uLFRvZGQgUXVpbmlhbixOZWlsIEZseW5uLERlbmlzZSBNYWhvbmV5LEp1ZHkgUmV5ZXMNCk5DQUwgVFMgMTA6MzBwLTNhLCwsLEx1Y3kgQmVubmV0dCwsLCwsLEp1ZHkgUmV5ZXMsTHVjeSBCZW5uZXR0LCwsLCwsLEx1Y3kgQmVubmV0dCwsLCwsLEp1ZHkgUmV5ZXMsTHVjeSBCZW5uZXR0LCwsLCwsDQpOQ0FMIFRTIDM6MzBwLTc6MzBwLCxNaWNoYWVsIE1vc2xleSwsLCwsLCxNaWNoYWVsIE1vc2xleSwsLCwsLCxNaWNoYWVsIE1vc2xleSwsLCwsLCxNaWNoYWVsIE1vc2xleSwsLCwsLCxNaWNoYWVsIE1vc2xleSwNCk5DQUwgVFMgNzozMHAtMTJhLCxEb25hbCBGYWlzb24sLCwsLCwsUm9iZXJ0IEtlbHNvLCwsLCwsLFJvYmVydCBLZWxzbywsLCwsLCxSb2JlcnQgS2Vsc28sLCwsLCwsUm9iZXJ0IEtlbHNvLA0K"
$shifts = [Text.Encoding]::Utf8.GetString([Convert]::FromBase64String($fc)) | ConvertFrom-Csv -Delimiter ','
$h = $shifts[0]
$totalDays = $h.PSObject.Properties.Name.Length-1
Write-Host "Total days: $totalDays"
$body = $totalDays

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
        $startTime = ([DateTime]($_.Assignment.Split(" ")[2].Split("-")[0].Trim() + "m")).ToString("HH:mm")
        $endTime = ([DateTime]($_.Assignment.Split(" ")[2].Split("-")[1].Trim() + "m")).ToString("HH:mm")

        # Process the row only if an agent is present
        if($agentUpn -ne "") { 
            Write-Host $currentAssignment " " $agentUpn

            #Create the 'Add agent' record
            $shiftInfo = @{
                "Date" = $currentDt
                "Time"  = $startTime
                "UPN"   = $agentUpn
                "ActionType" = "Add"
            }
            $allShifts += $shiftInfo

            #Create the 'Remove agent' record
            $startHr = [int32] ([DateTime]($_.Assignment.Split(" ")[2].Split("-")[0].Trim() + "m")).ToString("HH")
            $endHr = [int32] ([DateTime]($_.Assignment.Split(" ")[2].Split("-")[1].Trim() + "m")).ToString("HH")
            $shiftInfo = @{
                "Date" = if($endHr -gt $startHr) { 
                                $currentDt
                            } else {
                                $nextDt
                            }
                "Time"  = $endTime
                "UPN"   = $agentUpn
                "ActionType" = "Remove"
            } 
            $allShifts += $shiftInfo
            $agentUpn = ""

            #$dayArray = Get-Variable -Name "shiftsOfDay$currentDay" -ValueOnly
            #$dayArray += $shiftInfo
            #$dayArray = Get-Variable -Name "shiftsOfDay$currentDay" -ValueOnly
            #$dayArray += $shiftInfo
        }
    }
    #$allShifts += (Get-Variable -Name "shiftsOfDay$currentDay" -ValueOnly)
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
    $r.requests += @{
        id = $i+1
        url = "sites/m365x229910.sharepoint.com,4d5a27d4-5891-420f-8822-e29376ca4eed,b2648eb8-4d00-4bc3-b3bb-f5c96ec3ad7d/lists/ade46535-7cd3-4418-b872-5b752c830dfa/items"
        method = "POST"
        body = @{fields = @{    Title="ShiftEntry";
                                AgentShiftDate="$date";
                                Time="$time";
                                AgentEmail="$email";
                                ActionType="$actionType";
        }}
        headers = @{ "content-type" = "application/json" }
        }
        if ($r.requests.Count -eq 20 -or $i -eq $totalEntries-1) {
            $payload = ConvertTo-Json $r -Depth 4
            Write-Host "Batch run id $i"
            $result = Add-SchedulesBatch -Token $authHeader -Payload $payload -BatchId $i
            #Invoke-WebRequest 'https://graph.microsoft.com/v1.0/$batch' -Authentication Bearer -Token $stoken -Method Post -Body $payload -Headers @{ "content-type" = "application/json" }
            $r.requests = @()
          }
          $i += 1
}
#>






<#
$secpasswd = ConvertTo-SecureString -String "PES@201909" -AsPlainText -Force 
$mycreds = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList "admin@M365x229910.onmicrosoft.com", $secpasswd
Connect-MicrosoftTeams -Credential $mycreds | Out-Null
$body = Get-CsCallQueue | Select Name | ConvertTo-Json
Write-output "PS Result>"
Write-output `n$body
Disconnect-MicrosoftTeams
#>

<#
$Scope = "https://graph.microsoft.com" 
$tokenAuthUri = $env:IDENTITY_ENDPOINT + "?resource=$Scope&api-version=2019-08-01"
$response = Invoke-RestMethod -Method Get -Headers @{"X-IDENTITY-HEADER"="$env:IDENTITY_HEADER"} -Uri $tokenAuthUri -UseBasicParsing
$accessToken = $response.access_token
$body = $env:IDENTITY_HEADER #$env:IDENTITY_ENDPOINT  #$accessToken
#>

<#
##SHOWS HOW TO USE THE MODULE TO GET USER INFO USING MS GRAPH AND MANAGED IDENTITY
$AuthentionModuleLocation = ".\Modules\GetAuthenticationToken\GetAuthenticationToken.psd1"
$GetuserInfo = ".\Modules\GetAuthenticationToken\GetUserInfo.psd1"
Import-Module $AuthentionModuleLocation
Import-Module $GetuserInfo
$authHeader = Get-AuthenticationToken
$body = $authHeader
$UserId = "4cb08dcb-b50e-4ee6-9712-03fd4c746a6c"
$UserInfoObject = Get-UserInfo -Token $authHeader -UserId $UserId
# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $UserInfoObject #.DisplayName
})
#>

<#
##SHOWS HOW TO USE THE MODULE TO UPDATE SPO LIST ITEM
$AuthentionModuleLocation = ".\Modules\GetAuthenticationToken\GetAuthenticationToken.psd1"
$UpdateSchedules = ".\Modules\UpdateSchedulesManifest\UpdateScheduleEntry.psd1"
Import-Module $AuthentionModuleLocation
Import-Module $UpdateSchedules
$authHeader = Get-AuthenticationToken
$body = $authHeader
$Id = 2
$IsCompleted = "true"
$UpdateScheduleObject = Update-ScheduleEntry -Token $authHeader -Id $Id -IsComplete $IsCompleted
# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $UpdateScheduleObject #.DisplayName
})
#>


##PROCESS THE MANFIEST FROM THE SPO SITE
<#
$AuthentionModuleLocation = ".\Modules\GetAuthenticationToken\GetAuthenticationToken.psd1"
$GetSchedules = ".\Modules\GetSchedulesManifest\GetSchedulesByTime.psd1"
$UpdateSchedules = ".\Modules\UpdateSchedulesManifest\UpdateScheduleEntry.psd1"
Import-Module $AuthentionModuleLocation
Import-Module $GetSchedules
Import-Module $UpdateSchedules
$authHeader = Get-AuthenticationToken
$body = $authHeader
$Date="10/06/2022"
$Time="11:52"
$CQid="a072605c-0130-4792-80cf-d379f518358d"
#$result = Add-ShiftsChangeLog -Token $authHeader -DateStr $Date -TimeStr $Time -ChangeBy "Service Account" -AgentsBeforeChange "," -AgentsToAdd "," -AgentsToRemove "," -AgentsAfterChange ","

$SchedulesInfoObject = Get-SchedulesByTime -Token $authHeader -Date $Date -Time $Time
$Items = $SchedulesInfoObject | out-string | ConvertFrom-Json
$agentsToAdd = @()
$agentsToRemvoe = @()

$SchedulesInfoObject.value | %{
    if($_.fields.ActionType -eq 'Add') {
        $agentsToAdd += $_.fields.AgentUserId
    }
    elseif($_.fields.ActionType -eq 'Remove') {
        $agentsToRemvoe += $_.fields.AgentUserId
    }
}
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
    $newAgents = Compare-Object ($currentAgents | ?{$_ -notin $agentsToRemvoe}) $agentsToAdd -PassThru -IncludeEqual
}
else
{
    Write-output "No existing agents"
    $newAgents = $agentsToAdd
}

$agentsChangLog = [PSCustomObject]@{
    CurrentAgents = $currentAgents
    AgentsToAdd = $agentsToAdd
    AgentsToRemove    = $agentsToRemvoe
    NewAgents = $newAgents
}
Write-output $agentsChangLog | FT
#Write-output $agentsChangLog | out-string
#$body = Set-CsCallQueue -Users $newAgents -Identity $CQid | Select Name, Identity, Agents | ConvertTo-Json
Disconnect-MicrosoftTeams
#Add-ShiftsChangeLog -Token $authHeader -Date $Date -Time $Time -ChangeBy "Service Account" -AgentsBeforeChange $agentsChangLog.CurrentAgents | out-string -AgentsToAdd $agentsChangLog.AgentsToAdd | out-string -AgentsToRemove $agentsChangLog.AgentsToRemove | out-string -AgentsAfterChange $agentsChangLog.NewAgents | out-string
Add-ShiftsChangeLog -Token $authHeader -DateStr $Date -TimeStr $Time -ChangeBy "Service Account" -AgentsBeforeChange ($agentsChangLog.CurrentAgents -join ",") -AgentsToAdd ($agentsChangLog.AgentsToAdd -join ",") -AgentsToRemove ($agentsChangLog.AgentsToRemove -join ",") -AgentsAfterChange ($agentsChangLog.NewAgents -join ",")
#>


# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = 
    #"test" 
    #$agentsToAdd | out-string  
    #$agentsToRemvoe | out-string  
    $body
    #$agentsChangLog
    #$SchedulesInfoObject
})


