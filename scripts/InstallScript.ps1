$Token = "";
$Password = "";
$trayIcon = 0; # default is 0
$addRemove = 0; # default is 0

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls;

# Determine whether or not the agent is already installed
$IsInstalled = $false
$InstalledSoftware = Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
foreach($obj in $InstalledSoftware)
{
    if ($obj.GetValue('DisplayName') -match "Archon")
    {
        $IsInstalled = $true
    }
}

# If it is installed
if ($IsInstalled)
{
    # We skip the install routine
    Write-Host "Zorus Deployment Agent is already installed. Exiting."
    Exit
}

if ([string]::IsNullOrEmpty($Token))
{
    # We skip the install routine
    Write-Host "Deployment token not provided. Exiting."
    Exit
}

$source = "http://static.zorustech.com.s3.amazonaws.com/downloads/ZorusInstaller.exe";
$destination = "$env:TEMP\ZorusInstaller.exe";

Write-Host "Downloading Zorus Deployment Agent..."
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile($source, $destination)

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
