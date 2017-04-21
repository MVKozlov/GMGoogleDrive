<#
.SYNOPSIS
    Exchange Authorization Code to Access and Refresh Tokens
.DESCRIPTION
    Exchange Authorization Code to Access and Refresh Tokens

    NOT intended for use in scripts! Only cmdline with UI and real user behind the keyboard

.PARAMETER ClientID
    OAuth2 Client ID
.PARAMETER ClientSecret
    OAuth2 Client Secret
.PARAMETER AuthorizationCode
    OAuth2 Authorization Code
.PARAMETER RedirectUri
    OAuth2 RedirectUri
.EXAMPLE
    $oauth_json = $oauth | ConvertFrom-Json
    $code = Request-GDriveAuthorizationCode -ClientID $oauth_json.web.client_id -ClientSecret $oauth_json.web.client_secret
    Request-GDriveRefreshToken -ClientID $oauth_json.web.client_id -ClientSecret $oauth_json.web.client_secret -AuthorizationCode $code
.OUTPUTS
    Json with Refresh and Access Codes and its lifetime and type as PSObject
.NOTES
    Author: Max Kozlov
.LINK
    Get-GDriveAccessToken
    Request-GDriveAuthorizationCode
    Revoke-GDriveToken
    https://developers.google.com/identity/protocols/OAuth2
    https://developers.google.com/identity/protocols/OAuth2InstalledApp
    https://developers.google.com/identity/protocols/OAuth2WebServer
#>
function Request-GDriveRefreshToken {
[CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=0)]
        [string]$ClientID,

        [Parameter(Mandatory, Position=1)]
        [string]$ClientSecret,

        [Parameter(Mandatory, Position=2)]
        [string]$AuthorizationCode,

        [string]$RedirectUri = 'https://developers.google.com/oauthplayground'
    )

    $Uri = $GDriveOAuth2TokenUri
    $Body = @{
        grant_type = 'authorization_code'
        client_id = $ClientID
        client_secret = $ClientSecret
        code = $AuthorizationCode
        redirect_uri = $RedirectUri
        scope = ''
    }
    Write-Debug (($Body | Out-String) -replace "`r`n")

    Invoke-RestMethod -Method Post -Uri $Uri -Body $Body -ContentType "application/x-www-form-urlencoded" @GDriveProxySettings
}
