<#
.SYNOPSIS
    Get GoogleDrive Item properties (metadata)
.DESCRIPTION
    Get GoogleDrive Item properties (metadata)
    Standart properties (kind,id,name,mimeType) always present
.PARAMETER ID
    File ID to return metadata from
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
    https://developers.google.com/drive/v3/reference/files/get
    https://developers.google.com/drive/v3/reference/files#resource
#>
function Get-GDriveItemProperty {
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position=0)]
    [string]$ID,

    [Parameter(Position=1)]
    [ValidateSet('kind','id','name','mimeType',
    'description','starred','trashed','explicitlyTrashed','parents','properties','appProperties','spaces','version',
    'webContentLink','webViewLink','iconLink','thumbnailLink','viewedByMe','viewedByMeTime','createdTime','modifiedTime',
    'modifiedByMeTime','sharedWithMeTime','sharingUser','owners','lastModifyingUser','shared','ownedByMe',
    'viewersCanCopyContent','writersCanShare','permissions','folderColorRgb','originalFilename','fullFileExtension',
    'fileExtension','md5Checksum','size','quotaBytesUsed','headRevisionId','contentHints',
    'imageMediaMetadata','videoMediaMetadata','capabilities','isAppAuthorized','hasThumbnail','thumbnailVersion',
    'modifiedByMe','trashingUser','trashedTime','teamDriveId','hasAugmentedPermissions',IgnoreCase = $false)]
    [Alias('Metadata')]
    [string[]]$Property = @(),

    [Parameter(Mandatory)]
    [string]$AccessToken
)
    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-type"  = "application/json"
    }
    # Standart properties always present
    $Property = ('kind','id','name','mimeType' + $Property) | Sort-Object -Unique
    $Uri = $GDriveUri + $ID + '?' + 'fields=' + ($Property -join ',')
    Write-Verbose "URI: $Uri"

    Invoke-RestMethod -Uri $Uri -Method Get -Headers $Headers @GDriveProxySettings
}
