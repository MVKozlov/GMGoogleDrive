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
    https://developers.google.com/identity/protocols/OAuth2InstalledApp
#>
function Revoke-GDriveToken {
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
    param(
        [Parameter(Mandatory, Position=0)]
        [string]$Token
    )

    $Uri = '{0}?token={1}' -f $GDriveRevokeTokenUri, $Token
    if ($PSCmdlet.ShouldProcess('Revoke Token')) {
        Invoke-RestMethod -Method Get -Uri $Uri @GDriveProxySettings
    }
}
