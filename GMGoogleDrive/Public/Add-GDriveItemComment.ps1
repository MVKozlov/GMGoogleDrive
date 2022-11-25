<#
.SYNOPSIS
    Add GoogleDrive Item comment
.DESCRIPTION
    Creates a new comment on a file
.PARAMETER ID
    The ID of the file
.PARAMETER Comment
    The plain text content of the comment.
    This field is used for setting the content, while htmlContent should be displayed.
.PARAMETER Ancor
    A region of the document represented as a JSON string.
    For details on defining anchor properties, refer to 'manage-comments#define' link or example
.PARAMETER QuotedContent
    The quoted content itself.
    This is interpreted as plain text if set through the API.
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    Add-GDriveItemComment -AccessToken $access_token -ID '0BAjkl4cBDNVpVbB5nGhKQ195aU0' -Comment 'test comment'
.EXAMPLE
    $ancor = @{r='head'; a=@{line=@{n=12;l=3}},@{line=@{n=18;l=1}}} | ConvertTo-Json -Depth 10 -Compress
    Add-GDriveItemComment -AccessToken $access_token -ID '0BAjkl4cBDNVpVbB5nGhKQ195aU0' -Comment 'test comment' -Ancor $ancor
.OUTPUTS
    Json with item comment as PSObject
.NOTES
    Author: Max Kozlov
    TODO: Note: Authorization optional?
.LINK
    Get-GDriveItemComment
    Get-GDriveItemCommentList
    Set-GDriveItemComment
    Remove-GDriveItemComment
    https://developers.google.com/drive/api/guides/manage-comments
    https://developers.google.com/drive/api/v3/reference/comments/create
    https://developers.google.com/drive/api/v3/reference/comments#resource
#>
function Add-GDriveItemComment {
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position=0)]
    [string]$ID,

    [Parameter(Mandatory, Position=1)]
    [Alias('Text', 'Content')]
    [string]$Comment,

    [Parameter()]
    [string]$Ancor,

    [Parameter()]
    [string]$QuotedContent,

    [Parameter(Mandatory)]
    [string]$AccessToken
)
    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }
    $Params = New-Object System.Collections.ArrayList
    # Always return all properties.
    [void]$Params.Add('fields=*')
    $Uri = '{0}{1}/comments?supportsAllDrives=true&{2}' -f $GDriveUri, $ID, ($Params -join '&')
    Write-Verbose "URI: $Uri"
    $Body = @{
        content = $Comment
        ancor = $Ancor
        "quotedFileContent.value" = $QuotedContent
    }
    $JsonProperty = ConvertTo-Json $Body -Compress
    Write-Verbose "RequestBody: $JsonProperty"
    $requestParams = @{
        Uri = $Uri
        Headers = $Headers
        ContentType = "application/json; charset=utf-8"
    }
    Invoke-RestMethod @requestParams -Method Post -Body $JsonProperty @GDriveProxySettings
}
