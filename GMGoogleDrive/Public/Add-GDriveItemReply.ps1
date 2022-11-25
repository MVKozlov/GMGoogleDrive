<#
.SYNOPSIS
    Add GoogleDrive Item comment reply
.DESCRIPTION
    Creates a new reply to a file comment
.PARAMETER ID
    The ID of the file
.PARAMETER CommentID
    The ID of the comment
.PARAMETER Reply
    The plain text content of the reply.
    This field is used for setting the content, while htmlContent should be displayed.
    This is required on creates if no action is specified.
.PARAMETER Action
    The action the reply performed to the parent comment.
    Valid values are:
        resolve
        reopen
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    Add-GDriveItemReply -AccessToken $access_token -ID '0BAjkl4cBDNVpVbB5nGhKQ195aU0' -CommentID 'AAAAjfW3VhQ' -Reply 'test reply'
.EXAMPLE
    $ancor = @{r='head'; a=@{line=@{n=12;l=3}},@{line=@{n=18;l=1}} | ConvertTo-Json -Depth 10 -Compress
    Add-GDriveItemReply -AccessToken $access_token -ID '0BAjkl4cBDNVpVbB5nGhKQ195aU0' -CommentID 'AAAAjfW3VhQ' -Reply 'test reply' -Action resolve
.OUTPUTS
    Json with item reply as PSObject
.NOTES
    Author: Max Kozlov
    TODO: Note: Authorization optional?
.LINK
    Get-GDriveItemReply
    Get-GDriveItemReplyList
    Set-GDriveItemReply
    Remove-GDriveItemReply
    https://developers.google.com/drive/api/v3/reference/replies/create
    https://developers.google.com/drive/api/v3/reference/replies#resource
#>
function Add-GDriveItemReply {
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position=0)]
    [string]$ID,

    [Parameter(Mandatory, Position=1)]
    [string]$CommentID,

    [Parameter(Mandatory, Position=2, ParameterSetName='comment')]
    [Parameter(Position=2, ParameterSetName='action')]
    [Alias('Text', 'Content')]
    [string]$Reply,

    [Parameter(Mandatory, Position=2, ParameterSetName='action')]
    [ValidateSet('resolve','reopen', IgnoreCase=$false)]
    [string]$Action,

    [Parameter(Mandatory)]
    [string]$AccessToken
)
    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }
    $Params = New-Object System.Collections.ArrayList
    # Always return all properties.
    [void]$Params.Add('fields=*')
    $Uri = '{0}{1}/comments/{2}/replies?supportsAllDrives=true&{3}' -f $GDriveUri, $ID, $CommentID, ($Params -join '&')
    Write-Verbose "URI: $Uri"
    if ($PSCmdlet.ParameterSetName -eq 'action') {
        $Body = @{
            action = $Action
        }
        if ($Reply) {
            $Body.content = $Reply
        }
    }
    else {
        $Body = @{
            content = $Reply
        }
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
