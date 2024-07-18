<#
.SYNOPSIS
    Get GoogleDrive Item comment reply
.DESCRIPTION
    Gets a reply by ID
.PARAMETER ID
    The ID of the file
.PARAMETER CommentID
    The ID of the comment
.PARAMETER ReplyID
    The ID of the reply
.PARAMETER IncludeDeleted
    Whether to return deleted replies.
    Deleted replies will not include their original content.
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    Get-GDriveItemReply -AccessToken $access_token -ID '0BAjkl4cBDNVpVbB5nGhKQ195aU0' -CommentID 'AAAAjfW3VhQ' -ReplyID 'AAAAkQjn-5E'
.OUTPUTS
    Json with item reply as PSObject
.NOTES
    Author: Max Kozlov
.LINK
    Add-GDriveItemReply
    Get-GDriveItemReplyList
    Set-GDriveItemReply
    Remove-GDriveItemReply
    https://developers.google.com/drive/api/v3/reference/replies/get
    https://developers.google.com/drive/api/v3/reference/replies#resource
#>
function Get-GDriveItemReply {
[CmdletBinding(DefaultParameterSetName='Next')]
param(
    [Parameter(Mandatory, Position=0)]
    [string]$ID,

    [Parameter(Mandatory, Position=1)]
    [string]$CommentID,

    [Parameter(Mandatory, Position=2)]
    [string]$ReplyID,

    [switch]$IncludeDeleted,

    [Parameter(Mandatory)]
    [string]$AccessToken
)
    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }
    $Params = New-Object System.Collections.ArrayList
    # Always return all properties.
    [void]$Params.Add('fields=*')
    if ($IncludeDeleted) {
        [void]$Params.Add('includeDeleted=true')
    }
    $Uri = '{0}{1}/comments/{2}/replies/{3}?supportsAllDrives=true&{4}' -f $GDriveUri, $ID, $CommentID, $ReplyID, ($Params -join '&')
    Write-Verbose "URI: $Uri"
    $requestParams = @{
        Uri = $Uri
        Headers = $Headers
        ContentType = "application/json; charset=utf-8"
    }
    Invoke-RestMethod @requestParams -Method Get @GDriveProxySettings
}
