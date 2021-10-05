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
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
param(
    [Parameter(Mandatory)]
    [string]$AccessToken
)
    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }
    $requestParams = @{
        Uri = $GDriveTrashUri
        Headers = $Headers
        ContentType = "application/json; charset=utf-8"
    }
    if ($PSCmdlet.ShouldProcess("Trash", "Clear")) {
       Invoke-RestMethod @requestParams -Method Delete @GDriveProxySettings
    }
}
