function Get-UserInfo
{
    param ($Token,$UserId)
    
    If($UserId -ne $null)
    {
	    Write-Host "Getting userid: $UserId"
	    $uri = "https://graph.microsoft.com/v1.0/users/$UserId"
	    $UserInfo = Invoke-RestMethod -Uri $uri -Headers $Token -Method Get

	    Return $UserInfo
    }
}