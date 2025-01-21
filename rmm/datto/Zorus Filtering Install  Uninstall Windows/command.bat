# Zorus Deployment Script for Datto RMM
# Zorus Filtering Install / Uninstall Component
# 
# Special thanks to Datto + Stan Lee for providing examples and guidance for components and ComStore support.

function script:Get-WebClientWithProxy() {
    [System.Net.WebRequest]::DefaultWebProxy = [System.Net.WebRequest]::GetSystemWebProxy()
    [System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
    return New-Object System.Net.WebClient
}

function script:Enable-Tls12Support() {
    if (([Net.ServicePointManager]::SecurityProtocol -band 3072) -ne 3072) {
        Write-Host "Current Security Protocol does not support TLS 1.2, will attempt to set it."
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072
            return $true
        } catch {
            Write-Host "Failed to set Security Protocol to support TLS 1.2. You may be on an unsupported version of Windows."
            return $false
        }
    }
    Write-Host "Current Security Protocol supports TLS 1.2"
    return $false
}

function script:Disable-Tls12Support() {
    Write-Host "Removing TLS 1.2 Support."
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -band (-bnot 3072)
}

function script:Test-DownloadedZorusFile([String]$FilePath) {
    Write-Host "Verifying downloaded file $($FilePath)."
    # We first verify that Windows trusts the application. If an attacker can compromise the CA Store in Windows, the endpoint has already been compromised.
    $SignatureResult = Get-AuthenticodeSignature -FilePath $FilePath
    if ($SignatureResult.Status -ne 'Valid') {
        throw "Failed to verify downloaded file $($FilePath) signature due to $($SignatureResult.Status): $($SignatureResult.StatusMessage)"
    }
    # Secondly we verify that the signing certificate contains the word Zorus in it.
    # This is done so that we don't target a specific code signing certificate as these may change over time.
    if (!$SignatureResult.SignerCertificate.Subject.Contains("Zorus")) {
        throw "Failed to verify downloaded file $($FilePath) as signature does not contain a leaf certificate that presents itself as Zorus: $($SignatureResult.SignerCertificate.SubjectName)"
    }
    # Thirdly, we verify that no part of the certificate chain has been revoked, as Get-AuthenticodeSignature does not validate revocation status.
    $X509Chain = New-Object System.Security.Cryptography.X509Certificates.X509Chain
    $X509Chain.ChainPolicy.RevocationFlag = [System.Security.Cryptography.X509Certificates.X509RevocationFlag]::EntireChain
    $X509Chain.ChainPolicy.RevocationMode = [System.Security.Cryptography.X509Certificates.X509RevocationMode]::Online
    # Ignore Time Validity, as that is verified by Get-AuthenticodeSignature, since it uses Counter-Signatures to get by Certificate Expiry times.
    $X509Chain.ChainPolicy.VerificationFlags = [System.Security.Cryptography.X509Certificates.X509VerificationFlags]::IgnoreNotTimeValid
    $X509Chain.ChainPolicy.UrlRetrievalTimeout = New-Object System.TimeSpan(0, 1, 0)
    if (!$X509Chain.Build($SignatureResult.SignerCertificate)) {
        $ChainElementId = 0
        foreach ($ChainElement in $X509Chain.ChainElements) {
            Write-Host "Chain $($ChainElementId): $($ChainElement.Certificate.Subject) $($ChainElement.Information)"
            foreach ($ChainElementStatus in $ChainElement.ChainElementStatus) {
                Write-Host "Chain $($ChainElementId): $($ChainElementStatus.StatusInformation)"
            }
            $ChainElementId += 1
        }
        throw "Failed to verify downloaded file $(FilePath) as code signing certificate chain appears invalid: $($SignatureResult.SignerCertificate.SubjectName)"
    }
    Write-Host "Successfully verified $($FilePath)"
}

function global:Install-ZorusFiltering([String]$DeploymentToken, 
                                       [String]$UninstallPassword = $null, 
                                       [Boolean]$HideFromAddRemovePrograms = $false,
                                       [Boolean]$VerifyDownload = $true,
                                       [String]$DownloadUrl = "https://static.zorustech.com/downloads/ZorusInstaller.exe",
                                       [String]$TempDownloadPath = "$ENV:TEMP\ZorusInstaller.exe",
                                       [String]$LogLocation = "$ENV:TEMP\ZorusInstallLog.log") {
    $InstalledSoftware = Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall"

    foreach($obj in $InstalledSoftware) {
        if ($obj.GetValue('DisplayName') -match "Archon") {
            throw "Zorus Deployment Agent is already installed. Exiting."
        }
    }

    if ([string]::IsNullOrEmpty($DeploymentToken)) {
        throw "Deployment token not provided. Exiting."
    }

    $AddedTls12Support = Enable-Tls12Support

    Write-Host "Downloading Zorus Deployment Agent from $DownloadUrl to $TempDownloadPath..."
    try {
        $WebClient = Get-WebClientWithProxy
        $WebClient.DownloadFile($DownloadUrl, $TempDownloadPath)
    } catch {
        throw "Failed to download installer. Exiting."
    }

    if ($AddedTls12Support) {
        Disable-Tls12Support
    }

    if ($VerifyDownload) {
        Test-DownloadedZorusFile -FilePath $TempDownloadPath
    }

    $InstallerArguments = "/exenoui", "/qn", "ARCHON_TOKEN=$DeploymentToken", "/norestart", "ALLUSERS=1"

    if (![string]::IsNullOrWhiteSpace($UninstallPassword)) {
        $InstallerArguments += "UNINSTALL_PASSWORD=$UninstallPassword"
    }

    if (![String]::IsNullOrWhiteSpace($LogLocation)) {
        $InstallerArguments += "/L*V `"$LogLocation`""
    }

    $InstallerArguments += "HIDE_ADD_REMOVE=$(If ($HideFromAddRemovePrograms) { "1" } Else { "0"} )"

    $OutputValue = "Installing Zorus Deployment Agent with Arguments $TempDownloadPath $([string]::Join(" ", $InstallerArguments))"
    $OutputValue = $OutputValue.Replace($DeploymentToken, (New-Object System.String('*', $DeploymentToken.Length)))
    if (![string]::IsNullOrWhiteSpace($UninstallPassword)) {
        $OutputValue = $OutputValue.Replace($UninstallPassword, (New-Object System.String('*', $UninstallPassword.Length)))
    }

    Write-Host $OutputValue
    $InstallProcess = Start-Process -FilePath $TempDownloadPath -ArgumentList $InstallerArguments -Wait -NoNewWindow -PassThru
    switch ($InstallProcess.ExitCode) {
        0 {
            Write-Host "Successfully Installed Zorus Filtering."
        }
        3010 {
            Write-Host "Successfully Installed Zorus Filtering. A restart is required."
        }
        default {
            throw "Failed to install Zorus Filtering due to a non-zero exit code: $($InstallProcess.ExitCode)"
        }
    }
}

function global:Uninstall-ZorusFiltering([String]$UninstallPassword = $null,
                                         [Boolean]$VerifyDownload = $true,
                                         [String]$DownloadUrl = "http://static.zorustech.com.s3.amazonaws.com/downloads/ZorusAgentRemovalTool.exe",
                                         [String]$TempDownloadPath = "$ENV:TEMP\ZorusAgentRemovalTool.exe") {
    $AddedTls12Support = Enable-Tls12Support

    Write-Host "Downloading Zorus Deployment Agent Removal Tool from $DownloadUrl to $TempDownloadPath..."
    try {
        $WebClient = Get-WebClientWithProxy
        $WebClient.DownloadFile($DownloadUrl, $TempDownloadPath)
    } catch {
        throw "Failed to download removal tool. Exiting."
    }

    if ($AddedTls12Support) {
        Disable-Tls12Support
    }

    if ($VerifyDownload) {
        Test-DownloadedZorusFile -FilePath $TempDownloadPath
    }

    $RemovalArguments = @("-s")

    if (![String]::IsNullOrWhiteSpace($UninstallPassword)) {
        $RemovalArguments += "-p $UninstallPassword"
    }

    $OutputValue = "Removing Zorus Deployment Agent with Arguments $TempDownloadPath $([string]::Join(" ", $RemovalArguments))"
    if (![string]::IsNullOrWhiteSpace($UninstallPassword)) {
        $OutputValue = $OutputValue.Replace($UninstallPassword, (New-Object System.String('*', $UninstallPassword.Length)))
    }

    Write-Host $OutputValue
    $UninstallProcess = Start-Process -FilePath $TempDownloadPath -ArgumentList $RemovalArguments -Wait -NoNewWindow -PassThru

    switch ($UninstallProcess.ExitCode) {
        0 {
            Write-Host "Successfully Uninstalled Zorus Filtering."
        }
        default {
            throw "Failed to uninstall Zorus Filtering due to a non-zero exit code: $($UninstallProcess.ExitCode)"
        }
    }
}

$isDotSourced = $MyInvocation.InvocationName -eq '.' -or $MyInvocation.Line -eq ''

if (!$isDotSourced) {
    $FunctionArgs = @{
        UninstallPassword = $ENV:Password
        VerifyDownload = $ENV:VerifyZorusDownloads -eq 'true'
    }

    if (![String]::IsNullOrWhiteSpace($ENV:ZorusDeploymentToken)) {
        $FunctionArgs["DeploymentToken"] = $ENV:ZorusDeploymentToken
    } elseif (![String]::IsNullOrWhiteSpace($ENV:SiteZorusDeploymentToken)) {
        $FunctionArgs["DeploymentToken"] = $ENV:SiteZorusDeploymentToken
    }

    if ($ENV:HideAddRemove -eq 'true') {
        $FunctionArgs["HideFromAddRemovePrograms"] = $true
    }

    if ($env:Install -ne 'true') {
        $FunctionToInvoke = "Uninstall-ZorusFiltering"
    } else {
        $FunctionToInvoke = "Install-ZorusFiltering"
    }

    & $FunctionToInvoke @FunctionArgs
} else {
    Write-Host "You have sourced the Zorus Install Utilities. You may install or uninstall Zorus by invoking the Install-ZorusFiltering and Uninstall-ZorusFiltering functions."
}