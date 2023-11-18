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
.PARAMETER PathServiceAccountFile
    Path to the P12 Certificate
.PARAMETER CertificatePassword
    SercueString with the certificate password
.PARAMETER ServiceAccountMail
    mail address of the serviceaccount
.PARAMETER SessionDuration
    Time in seconds till the session expires
.PARAMETER ImpersonationUser
    Username of the user you want to impersonate
.EXAMPLE
    $refresh = Request-GDriveRefreshToken -ClientID $oauth_json.web.client_id -ClientSecret $oauth_json.web.client_secret -AuthorizationCode $code
    Request-GDriveAccessToken -ClientID $oauth_json.web.client_id -ClientSecret $oauth_json.web.client_secret -RefreshToken $refresh.refresh_token
    Get-GDriveAccessToken -PathServiceAccountFile "C:\temp\certificate.p12" -ServiceAccountMail "account@xxx.iam.gserviceaccount.com" -ImpersonationUser "user@domain.com"
    Get-GDriveAccessToken -PathServiceAccountFile "C:\temp\ServiceAccount.json" -ImpersonationUser "user@domain.com"
.OUTPUTS
    Json with Access Codes and its lifetime and type as PSObject
.NOTES
    Author: Max Kozlov
.LINK
    Request-GDriveRefreshToken
    Request-GDriveAuthorizationCode
    Revoke-GDriveToken
    https://developers.google.com/drive/api/v3/about-auth
    https://developers.google.com/identity/protocols/OAuth2
    https://developers.google.com/identity/protocols/OAuth2InstalledApp
    https://developers.google.com/identity/protocols/OAuth2WebServer
    https://developers.google.com/identity/protocols/oauth2/service-account
#>
function Get-GDriveAccessToken {
[CmdletBinding()]
    param(
        [Parameter(ParameterSetName='ClientID', Mandatory, Position=0, ValueFromPipelineByPropertyName)]
        [string]$ClientID,

        [Parameter(ParameterSetName='ClientID', Mandatory, Position=1, ValueFromPipelineByPropertyName)]
        [string]$ClientSecret,

        [Parameter(ParameterSetName='ClientID', Mandatory, Position=2, ValueFromPipelineByPropertyName)]
        [string]$RefreshToken,

        [Parameter(ParameterSetName='P12ServiceAccount', Mandatory, ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName='JSONServiceAccount', Mandatory, ValueFromPipelineByPropertyName)]
        [string]$PathServiceAccountFile,

        [Parameter(ParameterSetName='P12ServiceAccount', ValueFromPipelineByPropertyName)]
        #[SecureString]$CertificatePassword = (ConvertTo-SecureString "notasecret" -AsPlainText -Force),
        [SecureString]$CertificatePassword = ("76492d1116743f0423413b16050a5345MgB8AHMATABiADIAWABNAFcAQgBWAEwAdwAwADAAUQBCAEUAcAAzAEYAVwBXAEEAPQA9AHwAMwBmAGUANwA4AGYAYQAzAGIAZgBlAGMAMAA3ADgANAA3ADUANwBmADkANQA3AGUAZABhAGYAOAA0AGIAYQBlAGMAZgA5ADAAYgBlADQAMABiADMAZgA2ADQAMABmADQAZQBkADUAMgAzADkAYwBkADgANwA1AGMANQAwAGMANQA=" |
            ConvertTo-SecureString -Key (1..16)),

        [Parameter(ParameterSetName='P12ServiceAccount', Mandatory, ValueFromPipelineByPropertyName)]
        [string]$ServiceAccountMail,

        [Parameter(ParameterSetName='P12ServiceAccount', ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName='JSONServiceAccount', ValueFromPipelineByPropertyName)]
        [ValidateRange(1,3600)]
        [int]$SessionDuration = 3600,

        [Parameter(ParameterSetName='P12ServiceAccount', ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName='JSONServiceAccount', ValueFromPipelineByPropertyName)]
        [string]$ImpersonationUser
    )
    BEGIN {
        $Uri = $GDriveOAuth2TokenUri
    }
    PROCESS {

        if ($PSCmdlet.ParameterSetName -in 'ClientID') {

            $Body = @{
                grant_type = 'refresh_token'
                client_id = $ClientID
                client_secret = $ClientSecret
                refresh_token = $RefreshToken
            }
            Write-Debug (($Body | Out-String) -replace "`r`n")
        
            Invoke-RestMethod -Method Post -Uri $Uri -Body $Body -ContentType "application/x-www-form-urlencoded" @GDriveProxySettings

        } elseif ($PSCmdlet.ParameterSetName -in 'P12ServiceAccount','JSONServiceAccount') {
            
            if($PSCmdlet.ParameterSetName -in 'P12ServiceAccount') {

                if($PSVersionTable.PSVersion -lt "6.1") {
                    # PowerShell 5
                    $Certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
                    $Certificate.Import($PathServiceAccountFile, $CertificatePassword, 'DefaultKeySet')
                } else {
                    # PowerShell 6.1 or higher
                    $Certificate = Get-PfxCertificate -FilePath $PathServiceAccountFile -Password $CertificatePassword
                }
                $RSA = ImportX509AsRSA -key $Certificate

                $Token = Get-JWTToken `
                    -Issuer $ServiceAccountMail `
                    -RSA $RSA `
                    -ImpersonationUser $ImpersonationUser `
                    -ExpirationSec $SessionDuration
            
            } elseif($PSCmdlet.ParameterSetName -in 'JSONServiceAccount') {

                $ServiceAccountJson = Get-Content $PathServiceAccountFile | ConvertFrom-Json

                $PrivateKey = [convert]::FromBase64String($ServiceAccountJson.private_key -replace "-{5}(BEGIN|END) PRIVATE KEY-{5}")
                if($PSVersionTable.PSVersion -lt "7.0") {
                    # PowerShell 5
                    $RSA = Import5AsRSA -private_bytes $PrivateKey
                } else {
                    # PowerShell 7
                    $RSA = Import7AsRSA -private_bytes $PrivateKey
                }

                $Token = Get-JWTToken `
                    -Issuer $ServiceAccountJson.client_email `
                    -RSA $RSA `
                    -KeyId $ServiceAccountJson.private_key_id `
                    -ImpersonationUser $ImpersonationUser `
                    -ExpirationSec $SessionDuration

            }

            Write-Verbose "Token: $Token"

            $WebRequestParams = @{
                Method = "POST"
                Uri = $Uri
                ContentType = "application/x-www-form-urlencoded"
                Body = "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=$Token"
            }

            Invoke-RestMethod @WebRequestParams

        }
    }
}
