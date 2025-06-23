<#
    .NOTES
      Author: Quin Church
      Contact: Tesylate Ltd
      Date: March 2024
    
    .SYNOPSIS
      Uninstalls unneeded installed and provisioned Appx packages.

    .EXAMPLE
      .\AppxConfig.ps1

#>

# START LOGGING

mkdir "C:\Tesylate" -erroraction silentlycontinue
mkdir "C:\Tesylate\Logs" -erroraction silentlycontinue

Start-Transcript -Path "C:\Tesylate\Logs\AppxConfig.log" -Verbose -Force

# Remove specified provisioned apps if they exist
Write-Output "Removing unneeded Appx packages..."

$appname = @(

# Microsoft
"*Microsoft.BingWeather*"
"*Microsoft.BingNews*"
"*Microsoft.BingTranslator*"
"*Microsoft.BingSearch*"
"*Microsoft.YourPhone*"
"*Microsoft.ZuneMusic*"
"*Microsoft.ZuneVideo*"
"*Microsoft.GamingApp*"
"*Microsoft.Getstarted*"
"*Microsoft.PowerAutomateDesktop*"
"*Microsoft.Office.OneNote*"
"*Microsoft.Office.Desktop.Access*"
"*Microsoft.Office.Desktop.Excel*"
"*Microsoft.Office.Desktop.Outlook*"
"*Microsoft.Office.Desktop.PowerPoint*"
"*Microsoft.Office.Desktop.Publisher*"
"*Microsoft.Office.Desktop.Word*"
"*Microsoft.Office.Desktop*"
"*Microsoft.OneConnect*"
"*Microsoft.RemoteDesktop*"
"*Microsoft.Messaging*"
"*Microsoft.Microsoft3DViewer*"
"*Microsoft.MicrosoftOfficeHub*"
"*Microsoft.MicrosoftSolitaireCollection*"
"*Microsoft.MicrosoftStickyNotes*"
"*Microsoft.Paint*"
"*Microsoft.People*"
"*Microsoft.Todos*"
"*Microsoft.MixedReality.Portal*"
"*Microsoft.SkypeApp*"
"*Microsoft.Wallet*"
"*Microsoft.WindowsFeedbackHub*"
"*microsoft.windowscommunicationsapps*"
"*Microsoft.Windows.DevHome*"
"*Microsoft.WindowsSoundRecorder*"
"*Microsoft.Xbox.TCUI*"
"*Microsoft.XboxApp*"
"*Microsoft.XboxGameOverlay*"
"*Microsoft.XboxGamingOverlay*"
"*Microsoft.XboxIdentityProvider*"
"*Microsoft.XboxSpeechToTextOverlay*"
"*Microsoft.OutlookForWindows*"
"*MicrosoftTeams*"
"*Microsoft.MicrosoftJournal*"
"*MicrosoftCorporationII.MicrosoftFamily*"

# Other
"*MirametrixInc.GlancebyMirametrix*"
"*Clipchamp.Clipchamp*"
"*7EE7776C.LinkedInforWindows*"
"*5A894077.McAfeeSecurity*"
"*57540AMZNMobileLLC.AmazonAlexa*"
"*SpotifyAB.SpotifyMusic*"
"*king.com.CandyCrushSaga*"
"*4DF9E0F8.Netflix*"
"*FACEBOOK.317180B0BB486*"
"*E0469640.LenovoUtility*"
"*E046963F.LenovoCompanion*"
"*E0469640.LenovoSmartCommunication*"
)

# Remove Appx Provisioned Packages

ForEach($app in $appname){
Write-Output "Removing $app provisioned package..."
Get-AppxProvisionedPackage -Online | where {$_.PackageName -like $app} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
Write-Output "Successfully removed $app provisioned package."

}

# Remove Appx Packages for all users

ForEach($app in $appname){
Write-Output "Removing $app package for all users..."
Get-AppxPackage -AllUsers | where {$_.PackageFullName -like $app} | Remove-AppxPackage -AllUsers 
Write-Output "Successfully removed $app package for all users."
}

# STOP LOGGING

Stop-Transcript
