$Password = ""

if ([Enum]::GetNames([System.Net.SecurityProtocolType]) -contains 'Tls12')
{
	[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
}
else
{
	[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls
}

$source = "http://static.zorustech.com.s3.amazonaws.com/downloads/ZorusAgentRemovalTool.exe";
$destination = "$env:TEMP\ZorusAgentRemovalTool.exe";

Write-Host "Downloading Zorus Agent Removal Tool..."
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile($source, $destination)

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
