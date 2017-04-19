<#
.SYNOPSIS
    Revoke Access or Refresh Token
.DESCRIPTION
    Revoke Access or Refresh Token
    If Revoke Refresh Token, Access Token also revoked
.PARAMETER Token
    Token to Revoke
.EXAMPLE
    Revoke-GDriveToken -Token $access_token
.OUTPUTS
    None
.NOTES
    Author: Max Kozlov
.LINK
    Request-GDriveAccessToken
    Request-GDriveRefreshToken
    https://developers.google.com/identity/protocols/OAuth2
    https://developers.google.com/identity/protocols/OAuth2InstalledApp
    https://developers.google.com/identity/protocols/OAuth2WebServer
#>
function Revoke-GDriveToken {
[CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=0)]
        [string]$Token
    )

    $Uri = '{0}/revoke?token={1}' -f $GDriveAccountsTokenUri, $Token
    Invoke-RestMethod -Method Get -Uri $Uri @GDriveProxySettings
}
