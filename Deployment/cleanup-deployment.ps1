Param (
    [parameter(mandatory = $true)] [string]$displayName,   # Display name for your application registered in Azure AD 
    [parameter(mandatory = $true)] [ValidateLength(3, 24)] [string]$rgName    # Name of the resource group for Azure
)

Connect-AzAccount -DeviceCode

Remove-AzResourceGroup -Name $rgName -Force

Remove-AzADApplication -DisplayName $displayName 

$CustomConnectorAADappName = "$displayName-customconnector"
Remove-AzADApplication -DisplayName $CustomConnectorAADappName
