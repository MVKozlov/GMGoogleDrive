<#
.SYNOPSIS
    Update GoogleDrive Item comment
.DESCRIPTION
    Updates a comment
.PARAMETER ID
    The ID of the file
.PARAMETER CommentID
    The ID of the comment
.PARAMETER Comment
    The plain text content of the comment.
    This field is used for setting the content, while htmlContent should be displayed.
.PARAMETER JsonProperty
    Json-formatted string with all needed comment resource properties
    "content" property are mandatory
    other properties can be "anchor" and "quotedFileContent.value"
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    Set-GDriveItemComment -AccessToken $access_token -ID '0BAjkl4cBDNVpVbB5nGhKQ195aU0' -CommentID 'AAAAjfW3VhQ' -Comment 'test comment changed'
.EXAMPLE
    $anchor = @{anchor=@{r='head';a=@(@{line=@{n=2;l=2}})}} | ConvertTo-Json -Compress -Depth 10
    Set-GDriveItemComment -AccessToken $access_token -ID '0BAjkl4cBDNVpVbB5nGhKQ195aU0' -CommentID 'AAAAjfW3VhQ' -JsonProperty (@{anchor=$anchor; content='test comment changed'} | ConvertTo-Json -Compress -Depth 10)
.OUTPUTS
    Json with comment as PSObject
.NOTES
    Author: Max Kozlov
.LINK
    Add-GDriveItemComment
    Get-GDriveItemComment
    Get-GDriveItemCommentList
    Remove-GDriveItemComment
    https://developers.google.com/drive/api/guides/manage-comments
    https://developers.google.com/drive/api/v3/reference/comments/update
    https://developers.google.com/drive/api/v3/reference/comments#resource
#>
function Set-GDriveItemComment {
[CmdletBinding(DefaultParameterSetName='Add')]
param(
    [Parameter(Mandatory, Position=0)]
    [string]$ID,

    [Parameter(Mandatory, Position=1)]
    [string]$CommentID,

    [Parameter(Mandatory, Position=2, ParameterSetName='comment')]
    [Alias('Text', 'Content')]
    [string]$Comment,

    [Parameter(Mandatory, Position=2, ParameterSetName='json')]
    [Alias('Metadata')]
    [string]$JsonProperty,

    [Parameter(Mandatory)]
    [string]$AccessToken
)
    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }
    $Params = New-Object System.Collections.ArrayList
    # Always return all properties.
    [void]$Params.Add('fields=*')
    $Uri = '{0}{1}/comments/{2}?supportsAllDrives=true&{3}' -f $GDriveUri, $ID, $CommentID, ($Params -join '&')
    Write-Verbose "URI: $Uri"
    if ($PSCmdlet.ParameterSetName -eq 'comment') {
        $Body = @{
            content = $Comment
        }
        $JsonProperty = ConvertTo-Json $Body -Compress
    }
    Write-Verbose "RequestBody: $JsonProperty"
    $requestParams = @{
        Uri = $Uri
        Headers = $Headers
        ContentType = "application/json; charset=utf-8"
    }
    Invoke-RestMethod @requestParams -Method Patch -Body $JsonProperty @GDriveProxySettings
}
