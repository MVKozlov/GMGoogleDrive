﻿$GDriveUri = "https://www.googleapis.com/drive/v3/files/"
$GDriveUploadUri = "https://www.googleapis.com/upload/drive/v3/files/"
$GDriveOAuth2TokenUri = "https://www.googleapis.com/oauth2/v4/token"
$GDriveAccountsTokenUri = "https://accounts.google.com/o/oauth2/v2/auth"
$GDriveRevokeTokenUri = "https://accounts.google.com/o/oauth2/revoke"
$GDriveAboutURI = "https://www.googleapis.com/drive/v2/about"
$GDriveTrashUri = "https://www.googleapis.com/drive/v3/files/trash"
$GDriveSheetsUri = "https://sheets.googleapis.com/v4/spreadsheets"

$GDriveAuthScope = "https://www.googleapis.com/auth/drive"

$GDriveOAuth2Audience = "https://oauth2.googleapis.com/token"

#TODO: https://developers.google.com/drive/api/v3/batch (may be?)

$GDriveProxySettings = @{}

#region Load Private Functions
Try {
    Get-ChildItem "$PSScriptRoot\Private\*.ps1" -Exclude *.tests.ps1, *profile.ps1 | ForEach-Object {
        #$Function = $_.Name
        . $_.FullName
    }
} Catch {
    Write-Warning ("{0}: {1}" -f $Function,$_.Exception.Message)
    Continue
}
#endregion Load Private Functions

#region Load Public Functions
Try {
    Get-ChildItem "$PSScriptRoot\Public\*.ps1" -Exclude *.tests.ps1, *profile.ps1 -Recurse | ForEach-Object {
        #$Function = $_.Name
        . $_.FullName
    }
} Catch {
    Write-Warning ("{0}: {1}" -f $Function,$_.Exception.Message)
    Continue
}
#endregion Load Public Functions
