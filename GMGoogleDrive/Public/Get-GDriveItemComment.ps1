<#
.SYNOPSIS
    Get GoogleDrive Item comment
.DESCRIPTION
    Gets a comment by ID
.PARAMETER ID
    The ID of the file
.PARAMETER CommentID
    The ID of the comment
.PARAMETER IncludeDeleted
    Whether to include deleted comments.
    Deleted comments will not include their original content.
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    Get-GDriveItemComment -AccessToken $access_token -ID '0BAjkl4cBDNVpVbB5nGhKQ195aU0' -CommentID 'AAAAjfW3VhQ'
.OUTPUTS
    Json with item comment as PSObject
.NOTES
    Author: Max Kozlov
.LINK
    Add-GDriveItemComment
    Get-GDriveItemCommentList
    Set-GDriveItemComment
    Remove-GDriveItemComment
    https://developers.google.com/drive/api/v3/reference/comments/get
    https://developers.google.com/drive/api/v3/reference/comments#resource
#>
function Get-GDriveItemComment {
[CmdletBinding(DefaultParameterSetName='Next')]
param(
    [Parameter(Mandatory, Position=0)]
    [string]$ID,

    [Parameter(Mandatory, Position=1)]
    [string]$CommentID,

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
    $Uri = '{0}{1}/comments/{2}?supportsAllDrives=true&{3}' -f $GDriveUri, $ID, $CommentID, ($Params -join '&')
    Write-Verbose "URI: $Uri"
    $requestParams = @{
        Uri = $Uri
        Headers = $Headers
        ContentType = "application/json; charset=utf-8"
    }
    Invoke-RestMethod @requestParams -Method Get @GDriveProxySettings
}
