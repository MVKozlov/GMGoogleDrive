<#
.SYNOPSIS
    Request a Access Token for a service account to work with GoogleDrive
.DESCRIPTION
    Request a Access Token for a service account to work with GoogleDrive
.PARAMETER PathP12Certificate
    Path to the P12 Certificate
.PARAMETER CertificatePassword
    SercueString with the certificate password
.PARAMETER ServiceAccountMail
    mail address of the serviceaccount
.PARAMETER SessionDuration
    Time in minutes till the session expires
.PARAMETER ImpersonationUser
    Username of the user you want to impersonate
.EXAMPLE
    Get-GDriveAccessTokenServiceAccountP12
.OUTPUTS
    Accesstoken
.NOTES
    Author: Jan Elhaus
.LINK
    https://developers.google.com/identity/protocols/oauth2/service-account
#>
function Get-GDriveAccessTokenServiceAccountP12 {
[CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=0, ValueFromPipelineByPropertyName)]
        [string]$PathP12Certificate,

        [Parameter(Position=1, ValueFromPipelineByPropertyName)]
        [SecureString]$CertificatePassword = (ConvertTo-SecureString "notasecret" -AsPlainText -Force),

        [Parameter(Mandatory, Position=2, ValueFromPipelineByPropertyName)]
        [string]$ServiceAccountMail,

        [Parameter(Position=3, ValueFromPipelineByPropertyName)]
        [ValidateRange(1,60)]
        [int]$SessionDuration = 60,

        [Parameter(Position=4, ValueFromPipelineByPropertyName)]
        [string]$ImpersonationUser
    )
    BEGIN {
        $Uri = $GDriveOAuth2TokenUri
    }
    PROCESS {

        # Loading the certificate
        $cert = Get-PfxCertificate -FilePath $PathP12Certificate -Password $CertificatePassword
        
        # calculate the validity period
        $now = (Get-Date).ToUniversalTime()
        $createDate = [Math]::Floor([decimal](Get-Date($now) -UFormat "%s"))
        $expiryDate = [Math]::Floor([decimal](Get-Date($now.AddMinutes($SessionDuration)) -UFormat "%s"))

        # Defining the request
        $rawclaims = [Ordered]@{
            iss = $ServiceAccountMail # Your service account
            scope = "https://www.googleapis.com/auth/drive" # Requested permissions
            aud = $Uri
            sub = $ImpersonationUser # The user to impersonate
            iat = $createDate
            exp = $expiryDate
        } | ConvertTo-Json

        # Encoding the JWT claim set
        $jwt = New-Jwt -PayloadJson $rawclaims -Cert $cert

        # Doing the access token request
        $apiendpoint = $Uri

        $splat = @{
            Method = "POST"
            Uri = $apiendpoint
            ContentType = "application/x-www-form-urlencoded"
            Body = "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=$jwt"
        }

        $res = Invoke-RestMethod @splat

        return $res.access_token

    }
}
