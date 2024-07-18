<#
.SYNOPSIS
    Remove GoogleDrive Item comment
.DESCRIPTION
    Deletes a comment
.PARAMETER ID
    The ID of the file
.PARAMETER CommentID
    The ID of the comment
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    Remove-GDriveItemComment -AccessToken $access_token -ID '0BAjkl4cBDNVpVbB5nGhKQ195aU0' -CommentID 'AAAAjfW3VhQ'
.OUTPUTS
    None
.NOTES
    Author: Max Kozlov
.LINK
    Add-GDriveItemComment
    Get-GDriveItemComment
    Get-GDriveItemCommentList
    Set-GDriveItemComment
    https://developers.google.com/drive/api/v3/reference/comments/delete
#>
function Remove-GDriveItemComment {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
param(
    [Parameter(Mandatory, Position=0)]
    [string]$ID,

    [Parameter(Mandatory, Position=1)]
    [string]$CommentID,

    [Parameter(Mandatory)]
    [string]$AccessToken
)
    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }
    $Uri = '{0}{1}/comments/{2}?supportsAllDrives=true' -f $GDriveUri, $ID, $CommentID
    Write-Verbose "URI: $Uri"
    if ($PSCmdlet.ShouldProcess($ID, "Remove Item Comment")) {
        $requestParams = @{
            Uri = $Uri
            Headers = $Headers
            ContentType = "application/json; charset=utf-8"
        }
        Invoke-RestMethod @requestParams -Method Delete @GDriveProxySettings
    }
}
