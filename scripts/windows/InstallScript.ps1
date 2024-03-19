$Token = "";
$Password = "";
$trayIcon = 0; # default is 0
$addRemove = 0; # default is 0

$originalProtocol = [System.Net.ServicePointManager]::SecurityProtocol
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::'SystemDefault'

# Determine whether or not the agent is already installed
$InstalledSoftware = Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
foreach($obj in $InstalledSoftware)
{
    if ($obj.GetValue('DisplayName') -match "Archon")
    {
        Write-Host "Zorus Deployment Agent is already installed. Exiting."
        Exit
    }
}

if ([string]::IsNullOrEmpty($Token))
{
    # Token must be set
    Write-Host "Deployment token not provided. Exiting."
    Exit
}

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
    Write-Host "Failed to download installer. Exiting."
    Exit
}

if ([string]::IsNullOrEmpty($Password))
{
    Write-Host "Installing Zorus Deployment Agent..."
    Start-Process -FilePath $destination -ArgumentList "/qn", "ARCHON_TOKEN=$Token", "HIDE_TRAY_ICON=$trayIcon", "HIDE_ADD_REMOVE=$addRemove" -Wait
}
else
{
    Write-Host "Installing Zorus Deployment Agent with password..."
    Start-Process -FilePath $destination -ArgumentList "/qn", "ARCHON_TOKEN=$Token", "HIDE_TRAY_ICON=$trayIcon", "HIDE_ADD_REMOVE=$addRemove", "UNINSTALL_PASSWORD=$Password" -Wait
}

Write-Host "Removing temporary files..."
Remove-Item -recurse $destination
Write-Host "Installation complete."

[System.Net.ServicePointManager]::SecurityProtocol = $originalProtocol
