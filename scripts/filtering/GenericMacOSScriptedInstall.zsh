#!/bin/zsh
 
set -e

# Change these values
ZORUS_DEPLOYMENT_TOKEN="YourDeploymentTokenHere" # This should be ideally unique per each of your customer. Obtain this value from https://portal.zorustech.com.
ZORUS_SET_DEPLOYMENT_TOKEN=true # Set this to false if you have an MDM that will deploy the deployment token with another approach.

# Do not change these values
ZORUS_WEB_DOWNLOAD_HOST="portal.zorustech.com"
ZORUS_APP_DATA_BASE_DIR="/Library/Application Support/Zorus, Inc"
ZORUS_SETTINGS_DIR="$ZORUS_APP_DATA_BASE_DIR/Settings" 

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
echo "                      Generic macOS Scripted Install                     "
echo "                                                                         "
 
if [[ -d /Applications/MSP-Filtering.app ]]
then
    echo "Detected existing installation. Skipping installation."
    exit 0
fi

# Change below when we release.
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

if [[ $ZORUS_SET_DEPLOYMENT_TOKEN ]]
then
	echo "Creating Credentials File."
	if [ ! -f "$ZORUS_SETTINGS_DIR/credentials.json" ]
	then
		mkdir -p "$ZORUS_SETTINGS_DIR"
		cat <<-EOF > "$ZORUS_SETTINGS_DIR/credentials.json"
		{
		    "CredentialSettings": {
		        "DeploymentKey": "$ZORUS_DEPLOYMENT_TOKEN"
		    }
		}
		EOF
	fi
	echo "Created Credentials File."
else
	echo "Skipped Creating Credentials File."
fi

echo "Installing Filtering."
installer -pkg "$ZORUS_TEMP_DIR/ZorusFilteringInstaller.pkg" -target /Applications
echo "Filtering Installed."
