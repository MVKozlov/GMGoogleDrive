<#
.SYNOPSIS
    Set Proxy Settings for use in GDrive functions
.DESCRIPTION
    Set Proxy Settings for use in GDrive functions
.OUTPUTS
    Proxy settings as PSObject
.NOTES
    Author: Max Kozlov
.LINK
    Set-GDriveProxySetting
#>
function Get-GDriveProxySetting {
[CmdletBinding()]
param(
)
    [PSCustomObject]@{
        Proxy = if ($GDriveProxySettings.Proxy) { $GDriveProxySettings.Proxy } else { $null }
        ProxyCredential = if ($GDriveProxySettings.ProxyCredential) { $GDriveProxySettings.ProxyCredential } else { $null }
        ProxyUseDefaultCredentials = if ($GDriveProxySettings.ProxyUseDefaultCredentials) { $GDriveProxySettings.ProxyUseDefaultCredentials } else { $null }
    }
}
