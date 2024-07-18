<#
.SYNOPSIS
    Search GoogleDriver for items in selected ParentID
.DESCRIPTION
    Search GoogleDriver for items in selected ParentID
.PARAMETER ParentID
    Folder ID in which item will be searched
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
    Get-GDriveItem -AccessToken $access_token -ParentID 'root'
.EXAMPLE
    Get-GDriveItem -AccessToken $access_token -ParentID 'root' -Property 'id', 'parents'
.OUTPUTS
    Json search result with items metadata as PSObject
.NOTES
    Author: Max Kozlov
.LINK
    Find-GDriveItem
#>
function Get-GDriveChildItem {
[CmdletBinding(DefaultParameterSetName='Next')]
param(
    [Parameter(Position=0)]
    [string]$ParentID,

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
    if ($PSBoundParameters.ContainsKey('ParentID')) {
        $PSBoundParameters['Query'] = "'$ParentID' in parents"
        [void]$PSBoundParameters.Remove('ParentID')
    }
    else {
        $PSBoundParameters['Query'] = ''
    }
    Find-GDriveItem @PSBoundParameters
}
