# Use this script if you need to generate a new ZIP package
$rootfolder = "$PSScriptRoot\..\..\"

# Make sure you update and save the MicrosofttTeams module as Azure Function custom modules
<#
Write-Host "Check if Microsoft Teams PowerShell module is installed and up-to-date"
$TeamsPSModuleVersion = $(Find-Module -Name MicrosoftTeams).Version
$TeamsPSModuleInstalled = $(Get-ChildItem -Path $($rootfolder + "FunctionApp\Modules\MicrosoftTeams"))

If($TeamsPSModuleInstalled.Name -ne $TeamsPSModuleVersion -And $TeamsPSModuleInstalled -ne $null)
{
    Write-Host "New Microsoft Teams PowerShell module found, download started"
    Remove-Item $TeamsPSModuleInstalled -Force -Con
    Save-Module -Path $($rootfolder + "FunctionApp\Modules") -Name MicrosoftTeams -Repository PSGallery -MinimumVersion 4.0.0
}
ElseIf($TeamsPSModuleInstalled -eq $null)
{
    Write-Host "Downloading Microsoft Teams PowerShell module"
    Save-Module -Path $($rootfolder + "FunctionApp\Modules") -Name MicrosoftTeams -Repository PSGallery -MinimumVersion 4.0.0
}
#>

# List in the ZIP package all the function app you need to deploy
$packageFiles = @(
    "$($rootfolder)FunctionApp\CQS\CsvInputParser",
    "$($rootfolder)FunctionApp\CQS\GetCallQueueById",
    "$($rootfolder)FunctionApp\CQS\GetCallQueues",
    "$($rootfolder)FunctionApp\CQS\HttpTriggerTestMSTeams",
    "$($rootfolder)FunctionApp\CQS\ListCallQueues",
    "$($rootfolder)FunctionApp\CQS\ParseSchedulesCSV",
    "$($rootfolder)FunctionApp\CQS\ProcessShifts",
    "$($rootfolder)FunctionApp\CQS\TestAzFunction",
    "$($rootfolder)FunctionApp\CQS\UpdateCallQueueAgents",
    "$($rootfolder)FunctionApp\CQS\Modules",
    "$($rootfolder)FunctionApp\CQS\host.json",
    "$($rootfolder)FunctionApp\CQS\profile.ps1",
    "$($rootfolder)FunctionApp\CQS\requirements.psd1"
)
$destinationPath = $rootfolder + "Packages\Azure\cqs-function-artifact.zip"

Write-Host "Creating Azure artifact"
Compress-Archive -Path $packageFiles -DestinationPath $destinationPath -CompressionLevel optimal -Force

Write-Host "Completed creating new deployment package"