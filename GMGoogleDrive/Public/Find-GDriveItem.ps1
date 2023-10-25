<#
.SYNOPSIS
    Search GoogleDriver for items with specified Query
.DESCRIPTION
    Search GoogleDriver for items with specified Query
.PARAMETER Query
    Search Query
.PARAMETER Property
    Properties to return
.PARAMETER OrderBy
    Set output order
.PARAMETER AllDriveItems
    Get result from all drives (inluding shared drives)
.PARAMETER AllResults
    Collect all results in one output
.PARAMETER NextPageToken
    Supply NextPage Token from Previous paged search
.PARAMETER PageSize
    Set Page Size for paged search
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    Find-GDriveItem -AccessToken $access_token -Query 'name contains "test"'
.EXAMPLE
    Find-GDriveItem -AccessToken $access_token -Query 'name contains "test"' -AllResults
.EXAMPLE
    Find-GDriveItem -AccessToken $access_token -Query 'name contains "shareddrivetest"' -AllResults -AllDriveItems
.EXAMPLE
    Find-GDriveItem -AccessToken $access_token -Query 'name contains "test"' -AllResults -Property 'id', 'parents'
.OUTPUTS
    Json search result with items metadata as PSObject
.NOTES
    Author: Max Kozlov
.LINK
    Get-GDriveChildItem
    https://developers.google.com/drive/api/v3/search-shareddrives
    https://developers.google.com/drive/api/v3/reference/files/list
#>
function Find-GDriveItem {
[CmdletBinding(DefaultParameterSetName='Next')]
param(
    [Parameter(Position=0)]
    [string]$Query,

    [Parameter(Position=1)]
    [ValidateSet("*",'kind','id','name','mimeType',
    'description','starred','trashed','explicitlyTrashed','parents','properties','appProperties','spaces','version',
    'webContentLink','webViewLink','iconLink','thumbnailLink','viewedByMe','viewedByMeTime','createdTime','modifiedTime',
    'modifiedByMeTime','sharedWithMeTime','sharingUser','owners','lastModifyingUser','shared','ownedByMe',
    'viewersCanCopyContent','writersCanShare','permissions','folderColorRgb','originalFilename','fullFileExtension',
    'fileExtension','md5Checksum','sha256Checksum','sha1Checksum','size','quotaBytesUsed','headRevisionId','contentHints',
    'imageMediaMetadata','videoMediaMetadata','capabilities','isAppAuthorized','hasThumbnail','thumbnailVersion',
    'modifiedByMe','trashingUser','trashedTime','teamDriveId','hasAugmentedPermissions',
    'keepForever', 'published', # revisions
     IgnoreCase = $false)]
    [Alias('Metadata')]
    [string[]]$Property = @(),

    [ValidateSet(    'createdTime', 'folder', 'modifiedByMeTime', 'modifiedTime', 'name', 'quotaBytesUsed', 'recency',
                    'sharedWithMeTime', 'starred', 'viewedByMeTime',
                    'createdTime desc', 'folder desc', 'modifiedByMeTime desc', 'modifiedTime desc', 'name desc', 'quotaBytesUsed desc', 'recency desc',
                    'sharedWithMeTime desc', 'starred desc', 'viewedByMeTime desc'
    )]
    [string[]]$OrderBy,

    [parameter(Mandatory=$false)]
    [switch]$AllDriveItems,

    [Parameter(ParameterSetName='All')]
    [switch]$AllResults,

    [Parameter(ParameterSetName='Next')]
    [string]$NextPageToken,

    [ValidateRange(1,1000)]
    [int]$PageSize = 100,

    [Parameter(Mandatory)]
    [string]$AccessToken

)

    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }
    Write-Verbose "URI: $GDriveUri"
    $Params = New-Object System.Collections.ArrayList
    [void]$Params.Add('pageSize=' + $PageSize)
    if ($AllDriveItems) {
        [void]$Params.Add('includeItemsFromAllDrives=true')
    }
    if ($Query) {
        [void]$Params.Add('q=' + [URI]::EscapeDataString($Query) )
    }
    if ($NextPageToken) {
        [void]$Params.Add('pageToken=' + $NextPageToken)
    }
    if ($PSBoundParameters.ContainsKey('OrderBy')) {
        [void]$Params.Add('orderBy=' + ($OrderBy -replace ' ','+' -join ','))
    }
    if ($Property) {
        if ($Property -contains "*") {
            $Property = "*"
        }
        [void]$Params.Add('fields=kind,nextPageToken,incompleteSearch,files({0})' -f ($Property -join ','))
    }
    # TODO: teams driveId	string	ID of the shared drive to search.
    if ($AllResults) {
        [void]$PSBoundParameters.Remove('AllResults')
        $files = New-Object System.Collections.ArrayList
        $baselist = $null
        do {
            $PSBoundParameters['NextPageToken'] = $NextPageToken
            $list = Find-GDriveItem @PSBoundParameters
            if ($null -eq $list) { break }
            $baselist = $list
            $NextPageToken = $list.nextPageToken
            $files.AddRange($list.files)
        } while ($NextPageToken)
        if ($null -ne $baselist) {
            $baselist.files = $files.ToArray()
            $baselist
        }
    }
    else {
        $Uri = '{0}?supportsAllDrives=true&{1}' -f $GDriveUri, ($Params -join '&')
        Write-Verbose "URI: $Uri"
        $requestParams = @{
            Uri = $Uri
            Headers = $Headers
            ContentType = "application/json; charset=utf-8"
        }
        Invoke-RestMethod @requestParams -Method Get @GDriveProxySettings
    }
}
