# Although this runs the installer, it is actually the update script.
# Please do NOT use this for fresh installs as it doesn't allow input for
# deployment tokens and other necessary first time install variables.

$originalProtocol = [System.Net.ServicePointManager]::SecurityProtocol
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::'SystemDefault'

$source = "https://static.zorustech.com/downloads/ZorusInstaller.exe"
$destination = "$env:TEMP\ZorusInstaller.exe"

Write-Host "Downloading Zorus Deployment Agent..."
try
{
    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile($source, $destination)
}
catch
{
    Write-Host "Failed to download update. Exiting."
    Exit
}

Write-Host "Updating Zorus Deployment Agent..."
Start-Process -FilePath $destination -ArgumentList @('/exenoui /qn ALLUSERS="1" AUTO_UPGRADE="1" /L*V "C:\Windows\Temp\ZorusInstaller.log"') -Wait

Write-Host "Removing temporary files..."
Remove-Item -recurse $destination
Write-Host "Update complete."

[System.Net.ServicePointManager]::SecurityProtocol = $originalProtocol
