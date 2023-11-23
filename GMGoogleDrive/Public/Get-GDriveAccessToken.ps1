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
.PARAMETER JsonServiceAccount
    Use path/content input as json service account data
.PARAMETER Path
    Path to input p12/json file
.PARAMETER Content
    Content of json service file or private key in pem(pksc8) format
.PARAMETER KeyData
    Private key in binary form (imported from pkcs12)
.PARAMETER Certificate
    X509Certificate with private key
.PARAMETER Password
    SecureString with the private key password (Google default password: notasecret )
.PARAMETER ServiceAccountMail
    Mail address of the service account
.PARAMETER KeyId
    Service account key id
.PARAMETER ImpersonationUser
    Username of the user you want to impersonate
.PARAMETER SessionDuration
    Time in seconds till the session expires
.EXAMPLE
    $refresh = Request-GDriveRefreshToken -ClientID $oauth_json.web.client_id -ClientSecret $oauth_json.web.client_secret -AuthorizationCode $code
    $token = Request-GDriveAccessToken -ClientID $oauth_json.web.client_id -ClientSecret $oauth_json.web.client_secret -RefreshToken $refresh.refresh_token
.EXAMPLE
    $token = Get-Content D:\service_account.json | ConvertFrom-Json | Get-GDriveAccessToken
.EXAMPLE
    $token = Get-GDriveAccessToken -Path D:\service_account.json -JsonServiceAccount
.EXAMPLE
    $token = Get-GDriveAccessToken -Content (Get-Content D:\service_account.json) -JsonServiceAccount
.EXAMPLE
    $keyData = Get-Content -AsByteStream -Path service_account.p12
    $token = Get-GDriveAccessToken -KeyData $KeyData -KeyId 'd41d8cd98f0b24e980998ecf8427e' -ServiceAccountMail test-account@980998ecf8427e.iam.gserviceaccount.com
.EXAMPLE
    $Content = Get-Content -Path service_account.pem
    $token = Get-GDriveAccessToken -Content $Content -KeyId 'd41d8cd98f0b24e980998ecf8427e' -ServiceAccountMail test-account@980998ecf8427e.iam.gserviceaccount.com
.EXAMPLE
    $Certificate = Get-ChildItem Cert:\CurrentUser\My\D41D8CD98F0B24E980998ECF8427E6732C711FB0
    $token = Get-GDriveAccessToken -Certificate $Certificate -KeyId 'd41d8cd98f0b24e980998ecf8427e' -ServiceAccountMail test-account@980998ecf8427e.iam.gserviceaccount.com
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
        [Parameter(Mandatory, Position=0, ValueFromPipelineByPropertyName, ParameterSetName='clientid')]
        [string]$ClientID,

        [Parameter(Mandatory, Position=1, ValueFromPipelineByPropertyName, ParameterSetName='clientid')]
        [string]$ClientSecret,

        [Parameter(Mandatory, Position=2, ValueFromPipelineByPropertyName, ParameterSetName='clientid')]
        [string]$RefreshToken,

        [Parameter(ParameterSetName='json_path')]
        [Parameter(ParameterSetName='json_content')]
        [switch]$JsonServiceAccount,
        [Parameter(ParameterSetName='json_path')]
        [Parameter(ParameterSetName='p12')]
        [string]$Path,
        [Parameter(ParameterSetName='json_content')]
        [Parameter(ParameterSetName='p8', ValueFromPipelineByPropertyName)]
        [Alias("private_key")]
        [string[]]$Content,
        [Parameter(ParameterSetName='p12d')]
        [byte[]]$KeyData,
        [Parameter(ParameterSetName='cert')]
        [System.Security.Cryptography..X509Certificate2]$Certificate,

        [Parameter(ParameterSetName='p12')]
        [Parameter(ParameterSetName='p12d')]
       #[SecureString]$Password = (ConvertTo-SecureString "notasecret" -AsPlainText -Force),
        [SecureString]$Password = ("76492d1116743f0423413b16050a5345MgB8AHMATABiADIAWABNAFcAQgBWAEwAdwAwADAAUQBCAEUAcAAzAEYAVwBXAEEAPQA9AHwAMwBmAGUANwA4AGYAYQAzAGIAZgBlAGMAMAA3ADgANAA3ADUANwBmADkANQA3AGUAZABhAGYAOAA0AGIAYQBlAGMAZgA5ADAAYgBlADQAMABiADMAZgA2ADQAMABmADQAZQBkADUAMgAzADkAYwBkADgANwA1AGMANQAwAGMANQA=" |
        ConvertTo-SecureString -Key (1..16)),

        [Parameter(ParameterSetName='p12', Mandatory=$true)]
        [Parameter(ParameterSetName='p12d', Mandatory=$true)]
        [Parameter(ParameterSetName='p8', Mandatory=$true, ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName='cert', Mandatory=$true)]
        [Alias("client_email")]
        [string]$ServiceAccountMail,
        [Parameter(ParameterSetName='p12', Mandatory=$true)]
        [Parameter(ParameterSetName='p12d', Mandatory=$true)]
        [Parameter(ParameterSetName='p8', Mandatory=$true, ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName='cert', Mandatory=$true)]
        [Alias("private_key_id")]
        [string]$KeyId,

        [Parameter(ParameterSetName='json_path')]
        [Parameter(ParameterSetName='json_content')]
        [Parameter(ParameterSetName='p12', Mandatory=$true)]
        [Parameter(ParameterSetName='p12d', Mandatory=$true)]
        [Parameter(ParameterSetName='p8', Mandatory=$true, ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName='cert', Mandatory=$true)]
        [string]$ImpersonationUser,

        [Parameter(ParameterSetName='json_path')]
        [Parameter(ParameterSetName='json_content')]
        [Parameter(ParameterSetName='p12')]
        [Parameter(ParameterSetName='p12d')]
        [Parameter(ParameterSetName='p8')]
        [Parameter(ParameterSetName='cert')]
        [ValidateRange(1,3600)]
        [int]$SessionDuration = 3600
    )
    BEGIN {
        $Uri = $GDriveOAuth2TokenUri
    }
    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq 'clientid') {
            Write-Verbose "Use ClientID"
            $Body = @{
                grant_type = 'refresh_token'
                client_id = $ClientID
                client_secret = $ClientSecret
                refresh_token = $RefreshToken
            }
        }
        else {
            $RSA = $null
            if ($PSCmdlet.ParameterSetName.StartsWith('json')) {
                try {
                    if ($Path) {
                        Write-Verbose "Use Json file"
                        $js = Get-Content $Path | ConvertFrom-Json
                    }
                    else {
                        Write-Verbose "Use Json content"
                        $js = $Content | ConvertFrom-Json
                    }
                    ($js.client_email -and $js.private_key -and $js.private_key_id) -or $(throw 'invalid json format') | Out-Null
                    $ServiceAccountMail = $js.client_email
                    $KeyId = $js.private_key_id
                    $Content = $js.private_key
                }
                catch
                {
                    Write-Error $_.Exception
                    return
                }
            }
            elseif ($PSCmdlet.ParameterSetName -eq 'p12') {
                Write-Verbose "Use p12 file"
                $Certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $Path, $Password
            }
            elseif ($PSCmdlet.ParameterSetName -eq 'p12d') {
                Write-Verbose "Use p12 data"
                $Certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $KeyData, $Password
            }
            try {
                # cert/p12/p12d use $Certificate
                if ($Certificate) {
                    Write-Verbose "Aquire certificate"
                    $RSA = ImportX509AsRSA -Key $Certificate
                }
                # json/p8 use $Content
                if (-not $RSA) {
                    Write-Verbose "Aquire private key"
                        $PrivateKey = [convert]::FromBase64String(($Content -replace "-{5}(BEGIN|END) (RSA )?PRIVATE KEY-{5}") -join "`n")
                        if ($PSVersionTable.PSVersion.Major -lt 7) {
                            # PowerShell 5
                            $RSA = Import5AsRSA -private_bytes $PrivateKey
                        } else {
                            # PowerShell 7
                            $RSA = Import7AsRSA -private_bytes $PrivateKey
                        }
                }
            }
            catch {
                Write-Error $_.Exception
                return
            }
            $tokenparams = @{
                Issuer = $ServiceAccountMail
                RSA = $RSA
                KeyId = $KeyId
                ImpersonationUser = $ImpersonationUser
                ExpirationSec = $SessionDuration
            }
            $Token = Get-JWTToken @tokenparams
            $Body = @{
                grant_type = 'urn:ietf:params:oauth:grant-type:jwt-bearer'
                assertion = $Token
            }
        }

        Write-Debug (($Body | Out-String) -replace "`r`n")

        Invoke-RestMethod -Method Post -Uri $Uri -Body $Body -ContentType "application/x-www-form-urlencoded" @GDriveProxySettings
    }
}
