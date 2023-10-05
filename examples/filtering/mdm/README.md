# Zorus Filtering MDM Configurations

Thank you for exploring our GitHub repository containing Zorus Filtering for macOS configuration files. These files serve as valuable examples for whitelisting essential components required for Zorus Filtering on macOS.

## Example Configurations

The configuration files provided here are intended as informative models. Some profiles can be directly applied to individual endpoints, while others require an MDM server and a supervised device due to Apple's restrictions, which cannot be circumvented.
Please note that these configuration files are provided as templates, and they may require adjustments to align with your individual MDM Solution or self-implemented MDM approach. While we are committed to assisting our users, it's essential to clarify that **Zorus does not provide customization, diagnostics, or support for specific Mobile Device Management (MDM) solutions.**

## Community Contributions

If you have suggestions or proposed changes to enhance these configuration files, we encourage you to contribute by forking our repository and creating a Pull Request (PR). Our team of Zorus Engineers will review your submissions for feasibility and alignment with our objectives.
Your active participation and contributions to this repository are highly valued. Together, we can continue to improve the functionality of Zorus Filtering on macOS. Thank you for being a part of our community.

## Profile Descriptions

| Profile Name | Description | Comments | Minimum Requirements |
| -- | -- | -- |
| MSP Filtering (System Extensions) | Allows applications signed with a Zorus Team Certificate to install and remove System Extensions from an endpoint. | N/A | macOS 10.15 (Catalina) for installation, macOS 12.0 (Monterey) for removals. |
| MSP Filtering (DNS) | Allows the deployment of a DNS proxy at the operating system level as long as it comes from an application or extension signed by a Zorus Team Certificate. | N/A | macOS 10.15 (Catalina) |
| MSP Filtering (TP) | Allows the deployment of a Transparent Proxy at the operating system as long as it comes from an application or extension signed by a Zorus Team Certificate. | N/A | macOS 14.0 (Sonoma) | 
| MSP Filtering (Login Items) | Allows applications signed by a Zorus Team Certificate to add or remove startup items (also known as launch daemons). |  This must be applied at an MDM level. This can't be applied directly to an endpoint and the endpoint must be suprervised for this to work. | macOS 13.0 (Ventura) |
| MSP Filtering (Chrome) | Configures Chrome to disable DNS-over-HTTPS or DNS-over-TLS in order to work with Zorus Filtering and disables user configuration of the setting. Additionally prevents the user from making any changes. | N/A | |
| MSP Filtering (Firefox) | Configures Firefox to disable DNS-over-HTTPS or DNS-over-TLS and enables the importing of enterprise roots (local endpoint trusted root certificates) in order to work with Zorus Filtering. Additionally prevents the user from making any changes. | N/A | | 
| MSP Filtering (Deployment Token) | Deploys a deployment token to the remote endpoint for use by the Filtering Agent. | N/A | macOS 10.7 (Lion) |

## Deployment Token

We have included a deployment token configuration file under `MSP Filtering (DeploymentToken).mobileconfig` as an example. However, the deployment token may be deployed in any approach which writes to the [defaults system](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/UserDefaults/AboutPreferenceDomains/AboutPreferenceDomains.html) with the `com.ZorusTech` domain and the `DeploymentKey` key.

As a scripted example, consider the following:

```bash
defaults write com.ZorusTech DeploymentKey -string "YourDeploymentToken"
```

to be functionally equivalent to the MSP Filtering (Deployment Token).mobileconfig file, however it will require manual removal.