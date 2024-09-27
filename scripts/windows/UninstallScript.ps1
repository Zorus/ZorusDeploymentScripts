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
    Exit 1
}

if ([string]::IsNullOrEmpty($Password))
{
    Write-Host "Uninstalling Zorus Deployment Agent..."
    $Process = Start-Process -FilePath $destination -ArgumentList "-s" -Wait -NoNewWindow -PassThru
}
else
{
    Write-Host "Uninstalling Zorus Deployment Agent with password..."
    $Process = Start-Process -FilePath $destination -ArgumentList "-s", "-p $Password" -Wait -NoNewWindow -PassThru
}

Write-Host "Removing temporary files..."
Remove-Item -recurse $destination
Write-Host "Removal complete."

Exit $Process.ExitCode