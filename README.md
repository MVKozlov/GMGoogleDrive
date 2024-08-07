# GMGoogleDrive

Google Drive REST Api module for Powershell
with Google Sheets API support

## Table of Contents

- [GoogleDrive Setup](#googledrive-setup)
- [Usage](#usage)
- [Error Handling](#error-handling)
- [Automate things](#automate-things)
- [Using a service account](#using-a-service-account)

---

### GoogleDrive Setup

Google Drive is a free service for file storage files. In order to use this storage you need a Google (or Google Apps) user which will own the files, and a Google API client.

 1. Go to the [Google Developers console](https://console.developers.google.com/project) and create a new project.
    - Now you should be on the [Project Dashboard](https://console.cloud.google.com/home/dashboard)
 2. Go to **APIs & Services** > **APIs** and enable **Drive API** and **Sheets API**.

#### Using Web client OAuth 2.0

 1. Click **Credentials**
 2. Create **OAuth Client ID** Credentials
 3. Select **Web Application** as product type
 4. Configure the **Authorized Redirect URI** to https://developers.google.com/oauthplayground _must not have a ending “/” in the URI_
 5. Save your **Client ID** and **Secret** or full OAuth string
 6. Now you will have a `Client ID`, `Client Secret`, and `Redirect URL`.
 7. You can convert oauth string to oauth `PSObject` for future use

    ``` powershell
    $oauth_json = '{"web":{"client_id":"10649365436h34234f34hhqd423478fsdfdo.apps.googleusercontent.com",
      "client_secret":"h78H78h7*H78h87",
      "redirect_uris":["https://developers.google.com/oauthplayground"]}}' | ConvertFrom-Json
    ```

 8. Request Authroization Code  

      - by powershell

      ``` powershell
      $code = Request-GDriveAuthorizationCode -ClientID $oauth_json.web.client_id `
        -ClientSecret $oauth_json.web.client_secret
      ```

      - or manually
        1. Browse to https://developers.google.com/oauthplayground
        2. Click the gear in the right-hand corner and select “_Use your own OAuth credentials_"
        3. Fill in OAuth Client ID and OAuth Client secret
        4. Authorize the API scopes
            - https://www.googleapis.com/auth/drive
            - https://www.googleapis.com/auth/drive.file
            - https://www.googleapis.com/auth/spreadsheets
        5. Save `Authorization Code` or directly **Exchange authorization code** for tokens
        6. Save `Refresh token`, it can not be requested again without new Authorization code
 9. Get refresh Token

      - by powershell

      ``` powershell
      $refresh = Request-GDriveRefreshToken -ClientID $oauth_json.web.client_id `
        -ClientSecret $oauth_json.web.client_secret `
        -AuthorizationCode $code
      ```

      - manually

        you already have it if you do **8.5** + **8.6**

 10. `Authentication Token` - mandatory parameter for almost every `GDrive` cmdlets, and it need to be refreshed every hour, so you should get it (and can refresh it) at the beginning of your actual work with google drive

      ``` powershell
      $access = Get-GDriveAccessToken -ClientID $oauth_json.web.client_id `
        -ClientSecret $oauth_json.web.client_secret `
        -RefreshToken $refresh.refresh_token
      ```

#### Using a service account

Using a service account allows you to upload data to folders that are shared with the service account.

In Google Workspace enterprise environments, it is also possible to grant impersonation rights to the service account. With these rights, the service account can act as a user (without OAuth consent screen).

Please check the Google documentation:

- [Create a service account](https://developers.google.com/workspace/guides/create-credentials#create_a_service_account)
- [Assign impersonation rights (domain-wide delegation)](https://developers.google.com/workspace/guides/create-credentials#optional_set_up_domain-wide_delegation_for_a_service_account)

Google offers two types of service user files .json and .p12. Both types are implemented in this module.

``` PowerShell
Get-GDriveAccessToken `
  -Path D:\service_account.json -JsonServiceAccount `
  -ImpersonationUser "user@domain.com"
```

``` PowerShell
$keyData = Get-Content -AsByteStream -Path D:\service_account.p12
Get-GDriveAccessToken `
  -KeyData $KeyData `
  -KeyId 'd41d8cd98f0b24e980998ecf8427e' `
  -ServiceAccountMail test-account@980998ecf8427e.iam.gserviceaccount.com `
  -ImpersonationUser "user@domain.com"
```

### Usage

``` powershell
# Upload new file
Add-GDriveItem -AccessToken $access.access_token -InFile D:\SomeDocument.doc -Name SomeDocument.doc
# Search existing file
Find-GDriveItem -AccessToken $access.access_token -Query 'name="test.txt"'
# Update existing file contents
Set-GDriveItemContent -AccessToken $access.access_token -ID $file.id -StringContent 'test file'
# Get ParentFolderID and Modified Time for file
Get-GDriveItemProperty -AccessToken $access.access_token -ID $file.id -Property parents, modifiedTime
# and so on :)
```

### Error Handling

Cmdlets exiting at the first error, but, for example if Metadata Upload succeded but content upload failed, _UploadID_ as **ResumeID** returned for resume operations later

If Error catched, error record can be decoded by Get-GDriveError

``` powershell
 # save error to variable
 try { Get-GDriveItemProperty -AccessToken 'error token' -id 'error id' } catch { $err = $_ }
 # decode error
 Get-GDriveError $err
```

### Automate things

For automatic usage (for example from task scheduler) you must save your credentials secure way.

For this task you can use these functions (if you do not need something even more secure):

``` powershell
function Protect-String {
<#
  .SYNOPSIS
    Convert String to textual form of SecureString
  .PARAMETER String
    String to convert
  .OUTPUTS
    String
  .NOTES
    Author: MVKozlov
#>
param(
  [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
  [string]$String
)
PROCESS {
  $String | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString
}
}

function Unprotect-String {
<#
  .SYNOPSIS
    Convert SecureString to string
  .PARAMETER String
    String to convert (textual form of SecureString)
  .PARAMETER SecureString
    SecureString to convert
  .OUTPUTS
    String
  .NOTES
    Author: MVKozlov
#>
[CmdletBinding(DefaultParameterSetName='s')]
param(
  [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0, ParameterSetName='s')]
  [string]$String,
  [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0, ParameterSetName='ss')]
  [SecureString]$SecureString
)
PROCESS {
  if ($String) {
    $SecureString = $String | ConvertTo-SecureString
  }
  if ($SecureString) {
    (New-Object System.Net.NetworkCredential '', ($SecureString)).Password
  }
}
}
```

First you manually launch powershell on machine that will run you script and under needed user.
Then you construct your GDrive credentials object and save it securely:

``` powershell
[PSCustomObject]@{
  ClientID = 'clientid'
  ClientSecret = 'clientsecret'
  RefreshToken = 'refreshtoken'
} | ConvertTo-Json | Protect-String | Set-Content -Path C:\Path\somefile
```

And in your automatic script you get saved data, decode it and use:

``` powershell
$Credentials = Get-Content -Path C:\path\somefile | Unprotect-String | ConvertFrom-JSon

try {
  Write-Host "Getting Access token"
  $Token = Get-GDriveAccessToken -ClientID $Credentials.ClientID `
  -ClientSecret $Credentials.ClientSecret -RefreshToken $Credentials.RefreshToken
  Write-Host "Token expires at $([DateTime]::Now.AddSeconds($Token.expires_in))"
}
catch {
  Write-Warning "Error getting Access token $_"
  Get-GDriveError $_
}
if ($Token) {
  $Summary = Get-GDriveSummary -AccessToken $Token.access_token -ErrorAction Stop
  # [...]
}
```
