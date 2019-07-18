<#
.SYNOPSIS
    Clear GDrive Trash
.DESCRIPTION
    Clear GDrive Trash
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    Clear-GDriveTrash -AccessToken $access_token
.OUTPUTS
    If successful, this method returns an empty response body.
.NOTES
    Author: Harmandeep Saggu
.LINK
    https://developers.google.com/drive/api/v3/reference/files/emptyTrash
#>
function Clear-GDriveTrash {
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$AccessToken
)
    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-type"  = "application/json"
    }
    Invoke-RestMethod -Uri $GDriveTrashUri -Method Delete -Headers $Headers @GDriveProxySettings
}
