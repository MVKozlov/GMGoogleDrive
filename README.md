# GMGoogleDrive
Google Drive REST Api module for Powershell
### GoogleDrive Setup
Google Drive is a free service for file storage files. In order to use this storage you need a Google (or Google Apps) user which will own the files, and a Google API client.
1. Go to the [Google Developers console](https://console.developers.google.com/project) and create a new project.
2. Go to **APIs & Auth** > **APIs** and enable **Drive API**.
3. Click **Credentials**
4. Create **OAuth Client ID** Credentials
5. Select **Web Application** as product type
6. Configure the **Authorized Redirect URI** to https://developers.google.com/oauthplayground _must not have a ending “/” in the URI_
7. Save your **Client ID** and **Secret** or full OAuth string
8. Now you will have a Client ID, Client Secret, and Redirect URL.
9. You can convert oauth string to oauth PSObject for future use
 ``` powershell
$oauth_json = '{"web":{"client_id":"10649365436h34234f34hhqd423478fsdfdo.apps.googleusercontent.com",
  "client_secret":"h78H78h7*H78h87",
  "redirect_uris":["https://developers.google.com/oauthplayground"]}}' | ConvertFrom-Json
 ```
10. Request Authroization Code  
``` powershell
$code = Request-GDriveAuthorizationCode -ClientID $oauth_json.web.client_id `
  -ClientSecret $oauth_json.web.client_secret
```
  or manually  
  - Browse to https://developers.google.com/oauthplayground
  - Click the gear in the right-hand corner and select “Use your own OAuth credentials
  - Fill in OAuth Client ID and OAuth Client secret
  - Authorize the https://www.googleapis.com/auth/drive API
  - Save Authorization Code or directly 2Exchange authorization code for tokens
  - Save Refresh token, it can not be requested again without new Authorization code
11. Get refresh Token
``` powershell 
$refresh = Request-GDriveRefreshToken -ClientID $oauth_json.web.client_id `
  -ClientSecret $oauth_json.web.client_secret `
  -AuthorizationCode $code
```
  manually - see 10.6

12. Authentication Token need to be refreshed every hour, so

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
