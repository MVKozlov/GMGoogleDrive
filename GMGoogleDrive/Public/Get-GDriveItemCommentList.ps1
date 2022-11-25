<#
.SYNOPSIS
    Get GoogleDrive Item comments
.DESCRIPTION
    Lists a file's comments
.PARAMETER ID
    The ID of the file
.PARAMETER IncludeDeleted
    Whether to include deleted comments.
    Deleted comments will not include their original content.
.PARAMETER StartModifiedTime
    The minimum value of 'modifiedTime' for the result comments
.PARAMETER AllResults
    Collect all results in one output
.PARAMETER NextPageToken
    Supply NextPage Token from Previous paged search
.PARAMETER PageSize
    Set Page Size for paged search
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    Get-GDriveItemCommentList -AccessToken $access_token -ID '0BAjkl4cBDNVpVbB5nGhKQ195aU0'
.EXAMPLE
    Get-GDriveItemCommentList -AccessToken $access_token -ID '0BAjkl4cBDNVpVbB5nGhKQ195aU0' -IncludeDeleted -StartModifiedTime '11:00'
.OUTPUTS
    Json with item comment list as PSObject
.NOTES
    Author: Max Kozlov
.LINK
    Add-GDriveItemComment
    Get-GDriveItemComment
    Set-GDriveItemComment
    Remove-GDriveItemComment
    https://developers.google.com/drive/api/v3/reference/comments/list
#>
function Get-GDriveItemCommentList {
[CmdletBinding(DefaultParameterSetName='Next')]
param(
    [Parameter(Mandatory, Position=0)]
    [string]$ID,

    [switch]$IncludeDeleted,

    [datetime]$StartModifiedTime,

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
        $comments = New-Object System.Collections.ArrayList
        $baselist = $null
        do {
            $PSBoundParameters['NextPageToken'] = $NextPageToken
            $list = Get-GDriveItemCommentList @PSBoundParameters
            if ($null -eq $list) { break }
            $baselist = $list
            $NextPageToken = $list.nextPageToken
            $comments.AddRange($list.comments)
        } while ($NextPageToken)
        if ($null -ne $baselist) {
            $baselist.comments = $comments.ToArray()
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
        if ($StartModifiedTime) {
            [void]$Params.Add("startModifiedTime=$($StartModifiedTime.ToString('u').Replace(' ','T'))")
        }
        
        if ($NextPageToken) {
            [void]$Params.Add('pageToken=' + $NextPageToken)
        }
        $Uri = '{0}{1}/comments/?supportsAllDrives=true&{2}' -f $GDriveUri, $ID,  ($Params -join '&')
        Write-Verbose "URI: $Uri"
        $requestParams = @{
            Uri = $Uri
            Headers = $Headers
            ContentType = "application/json; charset=utf-8"
        }
        Invoke-RestMethod @requestParams -Method Get @GDriveProxySettings
    }
}
