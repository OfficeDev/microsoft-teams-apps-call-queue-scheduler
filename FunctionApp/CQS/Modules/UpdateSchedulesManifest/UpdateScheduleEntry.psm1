function Update-ScheduleEntry
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

function Add-ShiftsChangeLog
{
	param ($Token, $DateStr, $TimeStr, $ChangeBy, $AgentsBeforeChange, $AgentsAfterChange, $AgentsToAdd, $AgentsToRemove, $SPOSiteId, $ChangeLogListId, $CallQueueId)
    
	Write-Host "Add new entry to change log: $Date $Time"
	#$uri = "https://graph.microsoft.com/v1.0/sites/m365x229910.sharepoint.com,4d5a27d4-5891-420f-8822-e29376ca4eed,b2648eb8-4d00-4bc3-b3bb-f5c96ec3ad7d/lists/4a41bf5c-41a7-444b-9b0c-1d55d2a62a5e/items"
	$uri = "https://graph.microsoft.com/v1.0/sites/$SPOSiteId/lists/$ChangeLogListId/items"
	$postBody =@"
	{
		"fields": {
			"Title": "Timerjob|$CallQueueId",
			"ChangeRequestedBy": "Service Account",
			"Date": "$DateStr",
			"Time": "$TimeStr",
			"AgentsToAdd": "$AgentsToAdd",
			"AgentsToRemove": "$AgentsToRemove",
			"AgentsBeforeChange": "$AgentsBeforeChange",
			"AgentsAfterChange": "$AgentsAfterChange"
		}
	}
"@

	$NewLogInfo = Invoke-RestMethod -Uri $uri -Headers $Token -Method Post -Body $postBody

	Return $NewLogInfo
}

function Add-SchedulesBatch
{
	param ($Token, $Payload, $BatchId)

	Write-Host "Working on batch id: $BatchId"
	$uri = "https://graph.microsoft.com/v1.0/`$batch"
	$BatchRunResult = Invoke-WebRequest -Uri $uri -Method Post -Body $Payload -Headers $Token
	Return $BatchRunResult
}