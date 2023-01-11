Param (
    [parameter(mandatory = $true)] [string]$SPOSiteTitle,  # Title of the SharePoint site to be created
    [parameter(mandatory = $true)] [string]$AzFunctionMID # Azure Function Managed Identity ID
)

Import-Module Microsoft.Graph.Sites
Connect-MgGraph -Scope Sites.FullControl.All, User.Read.All, Group.ReadWrite.All -DeviceCode

#Sample MID used for testing
#$AzureFunctionMID = "5938d428-1311-4d66-8727-057b906ae7fc"

$uri = "https://graph.microsoft.com/v1.0/me"
$userId = (Invoke-MgGraphRequest -Method Get -Uri $uri).id

#Create M365 group using Microsoft Graph PowerShell
$Owner = "https://graph.microsoft.com/v1.0/users/" + $userId
$params = @{
	Description = "SPO site used as backend for the Call Queue Scheduler app"
	DisplayName = $SPOSiteTitle
	GroupTypes = @(
        "Unified"
	)
	MailEnabled = $false
	MailNickname = $SPOSiteTitle
	SecurityEnabled = $true
	"Owners@odata.bind" = @(
		$Owner
	)
}
$group = New-MgGroup -BodyParameter $params
$groupId = $group.Id
$Uri= "https://graph.microsoft.com/v1.0/groups/$groupId/sites/root"
$siteInfo = $null
Do {
    # Pause for 5 seconds per loop
    Start-Sleep -s 5
    # Check if the site has been created
    try
    {
        $siteInfo = Invoke-MgGraphRequest -Method Get -Uri $Uri
        Write-Host "SPO site created."
    }
    catch
    {
        $siteInfo = $null
        Write-Host "SPO site is still provisioning. Retry in 5 seconds..."
    }
}
while ($siteInfo -eq $null)

Write-Host "Granting write permissions to the Azure Function Managed Identity using Site.Selected scope"
$application = @{
    id = $AzFunctionMID
    displayName = "cqs-azfunction-mid"
}
$appRole = "write"
New-MgSitePermission -SiteId $siteInfo.id -Roles $appRole -GrantedToIdentities @{ Application = $application }

Write-Host "SPO Site Url: "+ $siteInfo.webUrl
Write-Host "SPO Site ID: "+ $siteInfo.Id

# Deploy the site template
Write-Host "Deploying site template to create the required lists and libraries"
Connect-PnPOnline -Url $siteInfo.webUrl -DeviceLogin
Invoke-PnPSiteTemplate -Path ..\Pkgs\shift-manager-site-lists.xml -Verbose -IgnoreDuplicateDataRowErrors -Handlers Lists

Get-MgSiteList -SiteId $siteInfo.Id | ?{$_.Name -like "Shifts*"} | Select DisplayName, Id, WebUrl