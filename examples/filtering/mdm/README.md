# Zorus Filtering MDM Configurations

These files are provided as an example of how to whitelist all of the necessary components of Zorus Filtering on macOS. Some of these configuration profiles can be applied directly to an endpoint, while others _require_ the use of an MDM server and a supervised device. There's sadly no way around this as it is an Apple restriction.

All configuration files provided are intended as examples only. Your MDM Solution or your own MDM implementation may require changes to the profiles provided and no support is provided or available through Zorus for **ANY** MDM solution.

If you have suggestions or proposed changes, feel free to make a PR and it will be reviewed by a Zorus Engineer.

## Profile Descriptions

| Profile Name | Description | Comments |
| -- | -- | -- |
| MSP Filtering (System Extensions) | Allows applications signed with a Zorus Team Certificate to install and remove System Extensions from an endpoint. | N/A |
| MSP Filtering (DNS) | Allows the deployment of a DNS proxy at the operating system level as long as it comes from an application or extension signed by a Zorus Team Certificate. | N/A |
| MSP Filtering (TP) | Allows the deployment of a Transparent Proxy at the operating system as long as it comes from an application or extension signed by a Zorus Team Certificate. | This profile is only available on macOS 14 and higher (Sonoma - 2023). |
| MSP Filtering (Login Items) | Allows applications signed by a Zorus Team Certificate to add or remove startup items (also known as launch daemons). |  This must be applied at an MDM level. This can't be applied directly to an endpoint and the endpoint must be suprervised for this to work. |
| MSP Filtering (Chrome) | Configures Chrome to disable DNS-over-HTTPS or DNS-over-TLS in order to work with Zorus Filtering and disables user configuration of the setting. | N/A |
| MSP Filtering (Firefox) | Configures Chrome to disable DNS-over-HTTPS or DNS-over-TLS and enables the importing of enterprise roots (local endpoint trusted root certificates) in order to work with Zorus Filtering. Additionally prevents the user from making any changes. | N/A |
| -- | -- | -- |