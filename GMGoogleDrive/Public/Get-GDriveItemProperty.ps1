<#
.SYNOPSIS
    Get GoogleDrive Item properties (metadata)
.DESCRIPTION
    Get GoogleDrive Item properties (metadata)
    Standart properties (kind,id,name,mimeType) always present
.PARAMETER ID
    File ID to return metadata from
.PARAMETER RevisionID
    File Revision ID to return property from (Version history)
.PARAMETER Property
    Properties to return
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    Get-GDriveItemProperty -AccessToken $access_token -ID '0BAjkl4cBDNVpVbB5nGhKQ195aU0' -Property parents, description, owners
.OUTPUTS
    Json with item metadata as PSObject
.NOTES
    Author: Max Kozlov
.LINK
    Get-GDriveItemContent
    Set-GDriveItemProperty
    Set-GDriveItemContent
    https://developers.google.com/drive/api/v3/reference/files/get
    https://developers.google.com/drive/api/v3/reference/files#resource
    https://developers.google.com/drive/api/v3/reference/revisions/get
#>
function Get-GDriveItemProperty {
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position=0)]
    [string]$ID,

    [string]$RevisionID,

    [Parameter(Position=1)]
    [ValidateSet("*",'kind','id','name','mimeType',
    'description','starred','trashed','explicitlyTrashed','parents','properties','appProperties','spaces','version',
    'webContentLink','webViewLink','iconLink','thumbnailLink','viewedByMe','viewedByMeTime','createdTime','modifiedTime',
    'modifiedByMeTime','sharedWithMeTime','sharingUser','owners','lastModifyingUser','shared','ownedByMe',
    'viewersCanCopyContent','writersCanShare','permissions','folderColorRgb','originalFilename','fullFileExtension',
    'fileExtension','md5Checksum','size','quotaBytesUsed','headRevisionId','contentHints',
    'imageMediaMetadata','videoMediaMetadata','capabilities','isAppAuthorized','hasThumbnail','thumbnailVersion',
    'modifiedByMe','trashingUser','trashedTime','teamDriveId','hasAugmentedPermissions',
    'keepForever', 'published', # revisions
     IgnoreCase = $false)]
    [Alias('Metadata')]
    [string[]]$Property = @(),

    [Parameter(Mandatory)]
    [string]$AccessToken
)
    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }
    $Revision = if ($RevisionID) { '/revisions/' + $RevisionID } else { '' }
    if ($Property -contains "*") {
         $Property = "*"
    }
    $Uri = '{0}{1}{2}?supportsAllDrives=true' -f $GDriveUri, $ID, $Revision
    if ($Property) {
        $Uri += '&fields={0}' -f ($Property -join ',')
    }
    Write-Verbose "URI: $Uri"
    $requestParams = @{
        Uri = $Uri
        Headers = $Headers
        ContentType = "application/json; charset=utf-8"
    }
    Invoke-RestMethod @requestParams -Method Get @GDriveProxySettings
}
