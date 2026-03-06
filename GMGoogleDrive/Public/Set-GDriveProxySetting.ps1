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
.EXAMPLE
    # Set default system Proxy
    Set-GDriveProxySettings -UseDefaultSystemProxy
.OUTPUTS
    None
.NOTES
    Author: Max Kozlov
.LINK
    Get-GDriveProxySetting
#>
function Set-GDriveProxySetting {
[CmdletBinding(SupportsShouldProcess=$true, DefaultParameterSetName='plain')]
param(
    [Parameter(ValueFromPipelineByPropertyName, ParameterSetName='plain')]
    [Uri]$Proxy,
    [Parameter(ValueFromPipelineByPropertyName, ParameterSetName='plain')]
    [PSCredential]$ProxyCredential,
    [Parameter(ValueFromPipelineByPropertyName, ParameterSetName='plain')]
    [switch]$ProxyUseDefaultCredentials,
    [Parameter(ParameterSetName='default')]
    [bool]$UseDefaultSystemProxy
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
                    [void]$GDriveProxySettings.Remove('Proxy')
                }
            }
            if ($ProxyCredential) {
                $GDriveProxySettings.ProxyCredential = $ProxyCredential
            }
            else {
                [void]$GDriveProxySettings.Remove('ProxyCredential')
            }
            if ($ProxyUseDefaultCredentials) {
                $GDriveProxySettings.ProxyUseDefaultCredentials = $ProxyUseDefaultCredentials
            }
            else {
                [void]$GDriveProxySettings.Remove('ProxyUseDefaultCredentials')
            }
            if ($PSCmdlet.ParameterSetName -eq 'default') {
                if ($UseDefaultSystemProxy) {
                    if ($PSVersionTable.PSVersion.Major -gt 5) {
                        [System.Net.Http.HttpClient]::DefaultProxy = $GDriveDefaultSystemProxy
                    }
                    else {
                        [System.Net.WebRequest]::DefaultWebProxy = $GDriveDefaultSystemProxy
                    }
                }
                else {
                    if ($PSVersionTable.PSVersion.Major -gt 5) {
                        [System.Net.Http.HttpClient]::DefaultProxy = $GDriveEmptySystemProxy
                    }
                    else {
                        [System.Net.WebRequest]::DefaultWebProxy = $GDriveEmptySystemProxy
                    }
                }
            }
        }
    }
}
