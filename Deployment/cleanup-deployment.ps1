Param (
    [parameter(mandatory = $true)] [string]$displayName,   # Display name for your application registered in Azure AD 
    [parameter(mandatory = $true)] [ValidateLength(3, 24)] [string]$rgName    # Name of the resource group for Azure
)

Connect-AzAccount -DeviceCode

Remove-AzResourceGroup -Name $rgName -Force
Remove-AzADApplication -DisplayName $displayName 

$CustomConnectorAADappName = "$displayName-customconnector"
Remove-AzADApplication -DisplayName $CustomConnectorAADappName

Write-Host "Cleanup completed"
Write-Host "ALERT: The Key Vault is soft deleted. To avoid any conflicts provide a unique name for the parameters for your next deployment" -ForegroundColor Yellow

Disconnect-AzAccount
