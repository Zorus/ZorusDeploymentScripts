# Although this runs the installer, it is actually the update script.
# Please do NOT use this for fresh installs as it doesn't allow input for
# deployment tokens and other necessary first time install variables.

[System.Net.ServicePointManager]::SecurityProtocol = "Tls";

$source = "https://static.zorustech.com/downloads/ZorusInstaller.exe"
$destination = "$env:TEMP\ZorusInstaller.exe"

Write-Host "Downloading Zorus Deployment Agent..."
$client = New-Object System.Net.WebClient
$client.DownloadFile($source, $destination)

Write-Host "Updating Zorus Deployment Agent..."
Start-Process -FilePath $destination -ArgumentList @('/qn ALLUSERS="1" /L*V "C:\Windows\Temp\ZorusInstaller.log"') -Wait

Write-Host "Removing temporary files..."
Remove-Item -recurse $destination
Write-Host "Update complete."
