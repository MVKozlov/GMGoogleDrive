# GMGoogleDrive
Google Drive REST Api module for Powershell

## Table of Contents

- [GoogleDrive Setup](#googledrive-setup)
- [Usage](#usage)
- [Error Handling](#error-handling)
- [Automate things](#automate-things)


### GoogleDrive Setup
Google Drive is a free service for file storage files. In order to use this storage you need a Google (or Google Apps) user which will own the files, and a Google API client.
1. Go to the [Google Developers console](https://console.developers.google.com/project) and create a new project.
2. Go to **APIs & Auth** > **APIs** and enable **Drive API**.
3. Click **Credentials**
4. Create **OAuth Client ID** Credentials
5. Select **Web Application** as product type
6. Configure the **Authorized Redirect URI** to https://developers.google.com/oauthplayground _must not have a ending “/” in the URI_
7. Save your **Client ID** and **Secret** or full OAuth string
8. Now you will have a `Client ID`, `Client Secret`, and `Redirect URL`.
9. You can convert oauth string to oauth `PSObject` for future use
    ``` powershell
    $oauth_json = '{"web":{"client_id":"10649365436h34234f34hhqd423478fsdfdo.apps.googleusercontent.com",
      "client_secret":"h78H78h7*H78h87",
      "redirect_uris":["https://developers.google.com/oauthplayground"]}}' | ConvertFrom-Json
    ```
10. Request Authroization Code  

    by powershell
    ``` powershell
    $code = Request-GDriveAuthorizationCode -ClientID $oauth_json.web.client_id `
      -ClientSecret $oauth_json.web.client_secret
    ```
    or manually
    - Browse to https://developers.google.com/oauthplayground
    - Click the gear in the right-hand corner and select “_Use your own OAuth credentials_"
    - Fill in OAuth Client ID and OAuth Client secret
    - Authorize the https://www.googleapis.com/auth/drive API
    - Save `Authorization Code` or directly **Exchange authorization code** for tokens
    - Save `Refresh token`, it can not be requested again without new Authorization code
11. Get refresh Token

    by powershell
    ``` powershell 
    $refresh = Request-GDriveRefreshToken -ClientID $oauth_json.web.client_id `
      -ClientSecret $oauth_json.web.client_secret `
      -AuthorizationCode $code
    ```
    manually - you already have it if you do **10.5** + **10.6**

12. `Authentication Token` - mandatory parameter for almost every `GDrive` cmdlets, and it need to be refreshed every hour, so you should get it (and can refresh it) at the beginning of your actual work with google drive

    ``` powershell
    $access = Get-GDriveAccessToken -ClientID $oauth_json.web.client_id `
      -ClientSecret $oauth_json.web.client_secret `
      -RefreshToken $refresh.refresh_token
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
Error handling left for self-production :)

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
