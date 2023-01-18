Param (
    [parameter(mandatory = $true)] [string]$SPOSiteTitle,  # Title of the SharePoint site to be created
    [parameter(mandatory = $true)] [string]$AzFunctionMID, # Azure Function Managed Identity ID
    [parameter(mandatory = $true)] [string]$SPOHostUrl # Host url for the SPO site e.x: "moderncomms996974.sharepoint.com"
)
Connect-PnPOnline -Url $SPOHostUrl -DeviceLogin
<#
$ctx = Get-PnPContext
$ctx.Load($ctx.Web.CurrentUser)
$ctx.ExecuteQuery()
$userEmail = $ctx.Web.CurrentUser.Email
#>

# Creating SPO Site
Write-Host "Provisioning SPO site...";
$site = New-PnPSite -Type TeamSite -Title $SPOSiteTitle -Alias $SPOSiteTitle.Replace(' ','') -Description "SPO site used as backend for the Call Queue Scheduler app" -Wait
Write-Host "SPO site created: $site";
Write-Host ""

# Granting write permissions to the Azure Function Managed Identity using Site.Selected scope
Write-Host "Granting write permissions to the Azure Function Managed Identity using Site.Selected scope"
Grant-PnPAzureADAppSitePermission -AppId $AzFunctionMID -DisplayName "cqs-azfunction-mid" -Permissions Write -Site $site
Write-Host ""

# Deploy the site template
Write-Host "Deploying site template to create the required lists and libraries"
Connect-PnPOnline -Url $site -DeviceLogin
Invoke-PnPSiteTemplate -Path ..\Pkgs\cqs-manager-site-lists.xml -Verbose -IgnoreDuplicateDataRowErrors -Handlers Lists
$RootWeb = Get-PnPSite -Includes ID
$Web = Get-PnPWeb -Includes ID
Write-Host ""

Write-Host -ForegroundColor magenta "Here is the information you'll need to deploy and configure while following the remaining steps"
Write-Host "SPO Site Url: " $site
Write-Host "SPO Site ID: $SPOHostUrl,$($RootWeb.Id),$($Web.Id)"
Get-PnPList | ?{$_.Title -like "Shifts*"} | FT

# Disconnecting session
Disconnect-PnPOnline
