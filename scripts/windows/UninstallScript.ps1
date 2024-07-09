$Password = ""

# Set TLS 1.2 in a manner compatible with older .Net installations.
[Net.ServicePointManager]::SecurityProtocol = [Enum]::ToObject([Net.SecurityProtocolType], 3072)

$source = "https://static.zorustech.com/downloads/ZorusAgentRemovalTool.exe";
$destination = "$env:TEMP\ZorusAgentRemovalTool.exe";

Write-Host "Downloading Zorus Agent Removal Tool..."
try
{
    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile($source, $destination)
}
catch
{
    Write-Host "Failed to download removal tool. Exiting."
    Exit
}

if ([string]::IsNullOrEmpty($Password))
{
    Write-Host "Uninstalling Zorus Deployment Agent..."
    Start-Process -FilePath $destination -ArgumentList "-s" -Wait
}
else
{
    Write-Host "Uninstalling Zorus Deployment Agent with password..."
    Start-Process -FilePath $destination -ArgumentList "-s", "-p $Password" -Wait
}

Write-Host "Removing temporary files..."
Remove-Item -recurse $destination
Write-Host "Removal complete."