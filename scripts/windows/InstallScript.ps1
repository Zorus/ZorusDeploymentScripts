$Token = "";
$Password = "";
$addRemove = 0; # default is 0

# Set TLS 1.2 in a manner compatible with older .Net installations.
[Net.ServicePointManager]::SecurityProtocol = [Enum]::ToObject([Net.SecurityProtocolType], 3072)

# Determine whether or not the agent is already installed
$InstalledSoftware = Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
foreach($obj in $InstalledSoftware)
{
    if ($obj.GetValue('DisplayName') -match "Archon")
    {
        Write-Host "Zorus Deployment Agent is already installed. Exiting."
        Exit 0
    }
}

if ([string]::IsNullOrEmpty($Token))
{
    # Token must be set
    Write-Host "Deployment token not provided. Exiting."
    Exit 1
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
    Exit 1
}

if ([string]::IsNullOrEmpty($Password))
{
    Write-Host "Installing Zorus Deployment Agent..."
    $Process = Start-Process -FilePath $destination -ArgumentList "/qn", "ARCHON_TOKEN=$Token", "HIDE_ADD_REMOVE=$addRemove" -Wait -NoNewWindow -PassThru
}
else
{
    Write-Host "Installing Zorus Deployment Agent with password..."
    $Process = Start-Process -FilePath $destination -ArgumentList "/qn", "ARCHON_TOKEN=$Token", "HIDE_ADD_REMOVE=$addRemove", "UNINSTALL_PASSWORD=$Password" -Wait -NoNewWindow -PassThru
}

Write-Host "Removing temporary files..."
Remove-Item -recurse $destination
Write-Host "Installation complete."

Exit $Process.ExitCode