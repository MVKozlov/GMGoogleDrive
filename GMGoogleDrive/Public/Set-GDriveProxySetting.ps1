<#
.SYNOPSIS
    Set Proxy Settings for use in GDrive functions
.DESCRIPTION
    Set Proxy Settings for use in GDrive functions
    Request-GDriveAuthorizationCode does not use this settings because it IE based
.EXAMPLE
    # Set Proxy
    Set-GDriveProxySettings -Proxy http://mycorpproxy.mydomain
.EXAMPLE
    # Remove Proxy
    Set-GDriveProxySettings -Proxy ''
.OUTPUTS
    None
.NOTES
    Author: Max Kozlov
.LINK
    Get-GDriveProxySetting
#>
function Set-GDriveProxySetting {
[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Parameter(ValueFromPipelineByPropertyName)]
    [Uri]$Proxy,
    [Parameter(ValueFromPipelineByPropertyName)]
    [PSCredential]$ProxyCredential,
    [Parameter(ValueFromPipelineByPropertyName)]
    [switch]$ProxyUseDefaultCredentials
)
    BEGIN {
    }
    PROCESS {
    }
    END {
        if ($PSCmdlet.ShouldProcess("Set New Proxy settings")) {
            if ($Proxy -and $Proxy.IsAbsoluteUri) {
                $GDriveProxySettings.Proxy = $Proxy
            }
            else {
                if ($Proxy.OriginalString) {
                       Write-Error 'Invalid proxy URI, may be you forget http:// prefix ?'
                }
                else {
                    $GDriveProxySettings.Remove('Proxy')
                }
            }
            if ($ProxyCredential) {
                $GDriveProxySettings.ProxyCredential = $ProxyCredential
            }
            else {
                $GDriveProxySettings.Remove('ProxyCredential')
            }
            if ($ProxyUseDefaultCredentials) {
                $GDriveProxySettings.ProxyUseDefaultCredentials = $ProxyUseDefaultCredentials
            }
            else {
                $GDriveProxySettings.Remove('ProxyUseDefaultCredentials')
            }
        }
    }
}
