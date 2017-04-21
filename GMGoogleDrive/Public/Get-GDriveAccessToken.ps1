<#
.SYNOPSIS
    Renew Access Token to work with GoogleDrive
.DESCRIPTION
    Renew Access Token to work with GoogleDrive
.PARAMETER ClientID
    OAuth2 Client ID
.PARAMETER ClientSecret
    OAuth2 Client Secret
.PARAMETER RefreshToken
    OAuth2 RefreshToken
.EXAMPLE
    $refresh = Request-GDriveRefreshToken -ClientID $oauth_json.web.client_id -ClientSecret $oauth_json.web.client_secret -AuthorizationCode $code
    Request-GDriveAccessToken -ClientID $oauth_json.web.client_id -ClientSecret $oauth_json.web.client_secret -RefreshToken $refresh.refresh_token
.OUTPUTS
    Json with Access Codes and its lifetime and type as PSObject
.NOTES
    Author: Max Kozlov
.LINK
    Request-GDriveRefreshToken
    Request-GDriveAuthorizationCode
    Revoke-GDriveToken
    https://developers.google.com/identity/protocols/OAuth2
    https://developers.google.com/identity/protocols/OAuth2InstalledApp
    https://developers.google.com/identity/protocols/OAuth2WebServer
#>
function Get-GDriveAccessToken {
[CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=0)]
        [string]$ClientID,

        [Parameter(Mandatory, Position=1)]
        [string]$ClientSecret,

        [Parameter(Mandatory, Position=2)]
        [string]$RefreshToken
    )

    $Uri = $GDriveOAuth2TokenUri
    $Body = @{
        grant_type = 'refresh_token'
        client_id = $ClientID
        client_secret = $ClientSecret
        refresh_token = $RefreshToken
    }
    Write-Debug (($Body | Out-String) -replace "`r`n")

    Invoke-RestMethod -Method Post -Uri $Uri -Body $Body -ContentType "application/x-www-form-urlencoded" @GDriveProxySettings
}
