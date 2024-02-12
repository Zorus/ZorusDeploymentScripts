#!/bin/zsh

# The token below is optional, and just ensures the script can pull down the latest installer which requires authentication from an endpoint.
# If there is no token specified, the script will attempt to read the deployment token from your local endpoint's configuration.
ZORUS_DEPLOYMENT_TOKEN=""

# Do not change these values
ZORUS_WEB_DOWNLOAD_HOST="portal.zorustech.com"
ZORUS_APP_DATA_BASE_DIR="/Library/Application Support/Zorus, Inc"
ZORUS_SETTINGS_DIR="$ZORUS_APP_DATA_BASE_DIR/Settings"
ZORUS_CREDENTIALS_FILE="$ZORUS_SETTINGS_DIR/credentials.json"

echo "        ___           ___           ___           ___           ___      "
echo "       /\  \         /\  \         /\  \         /\__\         /\  \     "
echo "       \:\  \       /::\  \       /::\  \       /:/  /        /::\  \    "
echo "        \:\  \     /:/\:\  \     /:/\:\  \     /:/  /        /:/\ \  \   "
echo "         \:\  \   /:/  \:\  \   /::\~\:\  \   /:/  /  ___   _\:\~\ \  \  "
echo "   _______\:\__\ /:/__/ \:\__\ /:/\:\ \:\__\ /:/__/  /\__\ /\ \:\ \ \__\ "
echo "   \::::::::/__/ \:\  \ /:/  / \/_|::\/:/  / \:\  \ /:/  / \:\ \:\ \/__/ "
echo "    \:\~~\~~      \:\  /:/  /     |:|::/  /   \:\  /:/  /   \:\ \:\__\   "
echo "     \:\  \        \:\/:/  /      |:|\/__/     \:\/:/  /     \:\/:/  /   "
echo "      \:\__\        \::/  /       |:|  |        \::/  /       \::/  /    "
echo "       \/__/         \/__/         \|__|         \/__/         \/__/     "
echo "                                                                         "
echo "                     Generic macOS Forced Reinstaller                    "
echo "                                                                         "

# Firstly uninstall all current applications
if [[ -d /Applications/MSP-Maintenance.app ]]
then
	echo "Detected existing Maintenance installation. Uninstalling."
        /Applications/MSP-Maintenance.app/Contents/Resources/uninstaller.sh
fi

if [[ -d /Applications/MSP-Filtering.app ]]
then
	echo "Detected existing Filtering installation. Uninstalling."
	/Applications/MSP-Filtering.app/Contents/Resources/uninstaller.sh
fi

# Secondly check if we have an available deployment token from the current endpoint.
if [[ -z $ZORUS_DEPLOYMENT_TOKEN ]]
then
    if [[ -f $ZORUS_CREDENTIALS_FILE ]]
    then
        CREDENTIAL_FILE_DATA=$(cat $ZORUS_CREDENTIALS_FILE)
        read -r -d '' JXA <<EOF
        function run() {
            var credentialJson = JSON.parse(\`$CREDENTIAL_FILE_DATA\`);
            return credentialJson.CredentialSettings.DeploymentKey;
        }
        EOF
        ZORUS_DEPLOYMENT_TOKEN=$(osascript -l 'JavaScript' <<< "${JXA}")
        echo "Found Zorus Deployment Token $ZORUS_DEPLOYMENT_TOKEN."
    fi
fi

# Thirdly pull the latest installer
ZORUS_WEB_DOWNLOAD_URL="https://$ZORUS_WEB_DOWNLOAD_HOST/product-downloads/agent"
 
if [[ $(sysctl -n machdep.cpu.brand_string) =~ "Apple" ]]
then
    echo "Detected Apple Silicon Processor."
    ZORUS_WEB_DOWNLOAD_URL+="?platformType=2&architectureType=2"
else
    echo "Detected Intel Processor."
    ZORUS_WEB_DOWNLOAD_URL+="?platformType=2&architectureType=1"
fi

echo "Creating Temporary Directory."
ZORUS_TEMP_DIR=$(mktemp -d)
cd "$ZORUS_TEMP_DIR"
echo "Created Temporary Directory $ZORUS_TEMP_DIR."

echo "Downloading Installer from $ZORUS_WEB_DOWNLOAD_URL."
curl -f -s -S --connect-timeout 30 --retry 5 --retry-delay 60 -L -o ZorusFilteringInstaller.pkg -H "X-Deployment-Token: $ZORUS_DEPLOYMENT_TOKEN" "$ZORUS_WEB_DOWNLOAD_URL"
echo "Downloaded Installer to $ZORUS_TEMP_DIR/ZorusFilteringInstaller.pkg."

echo "Installing Filtering."
installer -pkg "$ZORUS_TEMP_DIR/ZorusFilteringInstaller.pkg" -target /Applications
echo "Filtering Installed."