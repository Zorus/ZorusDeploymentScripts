$Token = "";

if ([string]::IsNullOrEmpty($Token))
{
    Write-Host "Deployment token not provided. Exiting."
    Exit
}

$hklm = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Registry32)
$key =  $hklm.OpenSubKey("SOFTWARE\Zorus Inc.\Archon Agent")

# get stored deployment token value
$previousToken = $key.GetValue("deploymentKey")

# get installation path
$path = $key.GetValue("Path")
if (!$path)
{
    Write-Host "Custom installation path not found, using default location."
    $path = "C:\Program Files\Zorus Inc\Archon Agent"
}
else
{
    $path = $path.TrimEnd("\")
}

Start-Process -FilePath "$path\Zorus Deployment Agent\ZorusDeploymentAgent.exe" -ArgumentList "--token=$Token" -Wait

# get stored deployment token value
$updatedToken = $key.GetValue("deploymentKey")
if ($previousToken -eq $updatedToken)
{
    Write-Host "Failed to update deployment token. Check your token and try again."
    Exit
}

Write-Host "Deployment token updated successfully."
