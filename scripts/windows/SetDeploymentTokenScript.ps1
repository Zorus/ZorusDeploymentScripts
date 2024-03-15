$Token = "";

if ([string]::IsNullOrEmpty($Token))
{
    Write-Host "Deployment token not provided. Exiting."
    Exit
}

$zorusRegistry = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Zorus Inc.\Archon Agent"

# get stored deployment token value
$previousToken = Get-ItemProperty -Path $zorusRegistry -Name deploymentKey 2>$null | Select-Object -ExpandProperty deploymentKey

# get installation path
$path = Get-ItemProperty -Path $zorusRegistry -Name Path 2>$null | Select-Object -ExpandProperty Path

if (!$path)
{
    Write-Host "Custom installation path not found, using default location."
    $path = "C:\Program Files\Zorus Inc\Archon Agent\"
}

Start-Process -FilePath "$path\Zorus Deployment Agent\ZorusDeploymentAgent.exe" -ArgumentList "--token=$Token" -Wait

# get stored deployment token value
$updatedToken = Get-ItemProperty -Path $zorusRegistry -Name deploymentKey 2>$null | Select-Object -ExpandProperty deploymentKey

if ($previousToken -eq $updatedToken)
{
    Write-Host "Failed to update deployment token. Check your token and try again."
    Exit
}

Write-Host "Deployment token updated successfully."

