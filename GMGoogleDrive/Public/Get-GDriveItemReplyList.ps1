<#
.SYNOPSIS
    Get GoogleDrive Item comment's replies
.DESCRIPTION
    Lists a comment's replies
.PARAMETER ID
    The ID of the file
.PARAMETER CommentID
    The ID of the comment
.PARAMETER IncludeDeleted
    Whether to include deleted replies.
    Deleted replies will not include their original content. (Default: false)
.PARAMETER AllResults
    Collect all results in one output
.PARAMETER NextPageToken
    Supply NextPage Token from Previous paged search
.PARAMETER PageSize
    Set Page Size for paged search
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    Get-GDriveItemReplyList -AccessToken $access_token -ID '0BAjkl4cBDNVpVbB5nGhKQ195aU0' -CommentID 'AAAAjfW3VhQ'
.OUTPUTS
    Json with replies list as PSObject
.NOTES
    Author: Max Kozlov
.LINK
    Add-GDriveItemReply
    Get-GDriveItemReply
    Set-GDriveItemReply
    Remove-GDriveItemReply
    https://developers.google.com/drive/api/v3/reference/replies/list
#>
function Get-GDriveItemReplyList {
[CmdletBinding(DefaultParameterSetName='Next')]
param(
    [Parameter(Mandatory, Position=0)]
    [string]$ID,

    [Parameter(Mandatory, Position=1)]
    [string]$CommentID,

    [switch]$IncludeDeleted,

    [Parameter(ParameterSetName='All')]
    [switch]$AllResults,

    [Parameter(ParameterSetName='Next')]
    [string]$NextPageToken,

    [ValidateRange(1,100)]
    [int]$PageSize = 100,

    [Parameter(Mandatory)]
    [string]$AccessToken
)
    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }
    if ($AllResults) {
        [void]$PSBoundParameters.Remove('AllResults')
        $replies = New-Object System.Collections.ArrayList
        $baselist = $null
        do {
            $PSBoundParameters['NextPageToken'] = $NextPageToken
            $list = Get-GDriveItemReplyList @PSBoundParameters
            if ($null -eq $list) { break }
            $baselist = $list
            $NextPageToken = $list.nextPageToken
            $replies.AddRange($list.replies)
        } while ($NextPageToken)
        if ($null -ne $baselist) {
            $baselist.replies=$replies.ToArray()
            $baselist
        }
    }
    else {
        $Params = New-Object System.Collections.ArrayList
        [void]$Params.Add('pageSize=' + $PageSize)
        # Always return all properties.
        [void]$Params.Add('fields=*')
        if ($IncludeDeleted) {
            [void]$Params.Add('includeDeleted=true')
        }
        if ($NextPageToken) {
            [void]$Params.Add('pageToken=' + $NextPageToken)
        }
        $Uri = '{0}{1}/comments/{2}/replies?supportsAllDrives=true&{3}' -f $GDriveUri, $ID, $CommentID, ($Params -join '&')
        Write-Verbose "URI: $Uri"
        $requestParams = @{
            Uri = $Uri
            Headers = $Headers
            ContentType = "application/json; charset=utf-8"
        }
        Invoke-RestMethod @requestParams -Method Get @GDriveProxySettings
    }
}
