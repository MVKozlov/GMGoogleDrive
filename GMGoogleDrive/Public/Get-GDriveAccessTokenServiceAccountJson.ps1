<#
.SYNOPSIS
    Request a Access Token for a service account to work with GoogleDrive
.DESCRIPTION
    Request a Access Token for a service account to work with GoogleDrive
.PARAMETER PathJsonFile
    Path to the .json file
.PARAMETER PathOpenSSL
    Path to OpenSSL
.PARAMETER SessionDuration
    Time in minutes till the session expires
.PARAMETER ImpersonationUser
    Username of the user you want to impersonate
.PARAMETER TempPathCertificates
    Path to temporary store the certificates to change the certificate format
.EXAMPLE
    Get-GDriveAccessTokenServiceAccountJson
.OUTPUTS
    Accesstoken
.NOTES
    Author: Jan Elhaus
.LINK
    https://developers.google.com/identity/protocols/oauth2/service-account
#>
function Get-GDriveAccessTokenServiceAccountJson {
[CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=0, ValueFromPipelineByPropertyName)]
        [string]$PathJsonFile,

        [Parameter(Mandatory, Position=1, ValueFromPipelineByPropertyName)]
        [string]$PathOpenSSL,

        [Parameter(Position=2, ValueFromPipelineByPropertyName)]
        [ValidateRange(1,60)]
        [int]$SessionDuration = 60,

        [Parameter(Position=3, ValueFromPipelineByPropertyName)]
        [string]$ImpersonationUser,

        [Parameter(Position=4)]
        [string]$TempPathCertificates = (Get-Location).Path
    )
    BEGIN {

    }
    PROCESS {

        # Loading service account data
        $service_account_cred = Get-Content $PathJsonFile | ConvertFrom-Json


        $privte_key = $service_account_cred.private_key
        $public_key = (Invoke-RestMethod $service_account_cred.client_x509_cert_url @GDriveProxySettings).($service_account_cred.private_key_id)
        $privte_key | Out-File "$TempPathCertificates\private.key"
        $public_key | Out-File "$TempPathCertificates\public.cer"

        # Transform the private and public kyey to a p12 file, so PowerShell is able to Import
        .$PathOpenSSL pkcs12 -export -in "$($TempPathCertificates)\public.cer" -inkey "$($TempPathCertificates)\private.key" -out "$($TempPathCertificates)\pfx.p12" -password pass:notasecret

        Remove-Item "$($TempPathCertificates)\private.key"
        Remove-Item "$($TempPathCertificates)\public.cer"

        $accesstoken = Get-GDriveAccessTokenServiceAccountP12 `
            -PathP12Certificate "$($TempPathCertificates)\pfx.p12" `
            -ServiceAccountMail $service_account_cred.client_email `
            -CertificatePassword (ConvertTo-SecureString "notasecret" -AsPlainText -Force) `
            -SessionDuration $SessionDuration `
            -ImpersonationUser $ImpersonationUser
        
        Remove-Item "$($TempPathCertificates)\pfx.p12"

        return $accesstoken

    }
}
