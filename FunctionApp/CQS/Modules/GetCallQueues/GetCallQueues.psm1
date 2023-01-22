function Get-CallQueues
{
    #param ($Token,$Date,$Time)
    param ($Token, $ListUrlWithFilter)
    
	    #Write-Host "Getting schedules on $Date at $Time"
	    #$uri = "https://graph.microsoft.com/v1.0/sites/m365x229910.sharepoint.com,4d5a27d4-5891-420f-8822-e29376ca4eed,b2648eb8-4d00-4bc3-b3bb-f5c96ec3ad7d/lists/ade46535-7cd3-4418-b872-5b752c830dfa/items?expand=fields(select=Id, Title, AgentShiftDate, Time, AgentEmail, AgentUserId, ActionType, IsComplete)&`$filter=fields/AgentShiftDate eq '$Date' and fields/Time eq '$Time' and fields/IsComplete eq 0 and fields/Removed eq 0"

        
        $Token.add('Prefer', 'HonorNonIndexedQueriesWarningMayFailRandomly')
	    $CallQueuesInfo = Invoke-RestMethod -Uri $ListUrlWithFilter -Headers $Token -Method Get

	    Return $CallQueuesInfo
}

<#
function Get-CallQueues
{
    param ($Token,$Id,$IsComplete,$SPOSiteId,$ManifestListId)
    
	    Write-Host "Update the item setting the IsComplete column"
	    #$uri = "https://graph.microsoft.com/v1.0/sites/m365x229910.sharepoint.com,4d5a27d4-5891-420f-8822-e29376ca4eed,b2648eb8-4d00-4bc3-b3bb-f5c96ec3ad7d/lists/ade46535-7cd3-4418-b872-5b752c830dfa/items/$Id/fields"
	    $uri = "https://graph.microsoft.com/v1.0/sites/$SPOSiteId/lists/$ManifestListId/items/$Id/fields"
		$postBody =@"
		{
			"IsComplete": $IsComplete
		}
"@

	    $SchedulesInfo = Invoke-RestMethod -Uri $uri -Headers $Token -Method Patch -Body $postBody

	    Return $SchedulesInfo
}
#>