<#
.SYNOPSIS
    Update GoogleDrive Item reply
.DESCRIPTION
    Updates a reply
.PARAMETER ID
    The ID of the file
.PARAMETER CommentID
    The ID of the comment
.PARAMETER ReplyID
    The ID of the reply
.PARAMETER Reply
    The plain text content of the reply.
    This field is used for setting the content, while htmlContent should be displayed.
    This is required on creates if no action is specified.
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    Set-GDriveItemReply -AccessToken $access_token -ID '0BAjkl4cBDNVpVbB5nGhKQ195aU0' -CommentID 'AAAAjfW3VhQ' -Comment 'test comment changed'
.EXAMPLE
    Set-GDriveItemReply -AccessToken $access_token -ID '0BAjkl4cBDNVpVbB5nGhKQ195aU0' -CommentID 'AAAAjfW3VhQ' -JsonProperty (@{content='2nd comment changed too'; resolved=$true} | ConvertTo-Json)
.OUTPUTS
    Json with reply as PSObject
.NOTES
    Author: Max Kozlov
.LINK
    Add-GDriveItemReply
    Get-GDriveItemReply
    Get-GDriveItemReplyList
    Remove-GDriveItemReply
    https://developers.google.com/drive/api/v3/reference/replies/update
    https://developers.google.com/drive/api/v3/reference/replies#resource
#>
function Set-GDriveItemReply {
[CmdletBinding(DefaultParameterSetName='Add')]
param(
    [Parameter(Mandatory, Position=0)]
    [string]$ID,

    [Parameter(Mandatory, Position=1)]
    [string]$CommentID,

    [Parameter(Mandatory, Position=2)]
    [string]$ReplyID,

    [Parameter(Mandatory, Position=2)]
    [Alias('Text', 'Content')]
    [string]$Reply,

    [Parameter(Mandatory)]
    [string]$AccessToken
)
    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }
    $Params = New-Object System.Collections.ArrayList
    # Always return all properties.
    [void]$Params.Add('fields=*')
    $Uri = '{0}{1}/comments/{2}/replies/{3}?supportsAllDrives=true&{4}' -f $GDriveUri, $ID, $CommentID, $ReplyID, ($Params -join '&')
    Write-Verbose "URI: $Uri"
    $Body = @{
        content = $Reply
    }
    $JsonProperty = ConvertTo-Json $Body -Compress
    Write-Verbose "RequestBody: $JsonProperty"
    $requestParams = @{
        Uri = $Uri
        Headers = $Headers
        ContentType = "application/json; charset=utf-8"
    }
    Invoke-RestMethod @requestParams -Method Patch -Body $JsonProperty @GDriveProxySettings
}
