<#
.SYNOPSIS
    Remove GoogleDrive Item reply
.DESCRIPTION
    Deletes a reply
.PARAMETER ID
    The ID of the file
.PARAMETER CommentID
    The ID of the comment
.PARAMETER ReplyID
    The ID of the reply
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    Remove-GDriveItemReply -AccessToken $access_token -ID '0BAjkl4cBDNVpVbB5nGhKQ195aU0' -CommentID 'AAAAjfW3VhQ' -ReplyID 'AAAAkQjn-5E'
.OUTPUTS
    None
.NOTES
    Author: Max Kozlov
.LINK
    Add-GDriveItemReply
    Get-GDriveItemReply
    Get-GDriveItemReplyList
    Set-GDriveItemReply
    https://developers.google.com/drive/api/v3/reference/replies/delete
#>
function Remove-GDriveItemReply {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
param(
    [Parameter(Mandatory, Position=0)]
    [string]$ID,

    [Parameter(Mandatory, Position=1)]
    [string]$CommentID,

    [Parameter(Mandatory, Position=2)]
    [string]$ReplyID,

    [Parameter(Mandatory)]
    [string]$AccessToken
)
    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }
    $Uri = '{0}{1}/comments/{2}/replies/{3}?supportsAllDrives=true' -f $GDriveUri, $ID, $CommentID, $ReplyID
    Write-Verbose "URI: $Uri"
    if ($PSCmdlet.ShouldProcess($ID, "Remove Item Reply")) {
        $requestParams = @{
            Uri = $Uri
            Headers = $Headers
            ContentType = "application/json; charset=utf-8"
        }
        Invoke-RestMethod @requestParams -Method Delete @GDriveProxySettings
    }
}
