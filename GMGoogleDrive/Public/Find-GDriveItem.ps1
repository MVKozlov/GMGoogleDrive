<#
.SYNOPSIS
    Search GoogleDriver for items with specified Query
.DESCRIPTION
    Search GoogleDriver for items with specified Query
.PARAMETER Query
    Search Query
.PARAMETER AllResults
    Collect all results in one output
.PARAMETER NextPageToken
    Supply NextPage Token from Previous paged search
.PARAMETER PageSize
    Set Page Size for paged search
.PARAMETER OrderBy
    Set output order
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    Find-GDriveItem -AccessToken $access_token -Query 'name contains "test"'
.EXAMPLE
    Find-GDriveItem -AccessToken $access_token -Query 'name contains "test"' -AllResults
.OUTPUTS
    Json search result with items metadata as PSObject
.NOTES
    Author: Max Kozlov
.LINK
    Get-GDriveChildItem
    https://developers.google.com/drive/v3/web/search-parameters
    https://developers.google.com/drive/v3/reference/files/list
#>
function Find-GDriveItem {
[CmdletBinding(DefaultParameterSetName='Next')]
param(
    [Parameter(Position=0)]
    [string]$Query,

    [Parameter(ParameterSetName='All')]
    [switch]$AllResults,

    [Parameter(ParameterSetName='Next')]
    [string]$NextPageToken,

    [ValidateRange(1,1000)]
    [int]$PageSize = 100,

    #TODO: Properties

    [ValidateSet(    'createdTime', 'folder', 'modifiedByMeTime', 'modifiedTime', 'name', 'quotaBytesUsed', 'recency',
                    'sharedWithMeTime', 'starred', 'viewedByMeTime',
                    'createdTime desc', 'folder desc', 'modifiedByMeTime desc', 'modifiedTime desc', 'name desc', 'quotaBytesUsed desc', 'recency desc',
                    'sharedWithMeTime desc', 'starred desc', 'viewedByMeTime desc'
    )]
    [string[]]$OrderBy,

    [Parameter(Mandatory)]
    [string]$AccessToken
)

    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-type"  = "application/json"
    }
    Write-Verbose "URI: $GDriveUri"
    $Params = New-Object System.Collections.ArrayList
    [void]$Params.Add('pageSize=' + $PageSize)
    if ($Query) {
        [void]$Params.Add('q=' + $Query)
    }
    if ($NextPageToken) {
        [void]$Params.Add('pageToken=' + $NextPageToken)
    }
    if ($PSBoundParameters.ContainsKey('OrderBy')) {
        [void]$Params.Add('orderBy=' + ($OrderBy -replace ' ','+' -join ','))
    }
    if ($AllResults) {
        $PSBoundParameters.Remove('AllResults')
        $files = New-Object System.Collections.ArrayList
        do {
            $PSBoundParameters['NextPageToken'] = $NextPageToken
            $list = Find-GDriveItem @PSBoundParameters
            if ($null -eq $list) { break }
            $NextPageToken = $list.nextPageToken
            $files.AddRange($list.files)
        } while ($NextPageToken)
        if ($null -eq $list) {
            $list.files = $files.ToArray()
            $list
        }
    }
    else {
        Invoke-RestMethod -Uri ('{0}?{1}' -f $GDriveUri, ($Params -join '&')) -Method Get -Headers $Headers @GDriveProxySettings
    }
}
