﻿<#
.SYNOPSIS
    Copy existing GoogleDrive Item into new Item
.DESCRIPTION
    Copy existing GoogleDrive Item into new Item
    By default item copied into same folder as original
.PARAMETER ID
    File ID to copy
.PARAMETER Name
    Name of an item to be created
.PARAMETER ParentID
    Folder ID(s) in which new item will be placed
.PARAMETER JsonProperty
    Json-formatted string with all needed file metadata
.PARAMETER Property
    List of properties that will be retured once item is created
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    #Name based copy
    Copy-GDriveItem -AccessToken $access_token -ID '0BAjkl4cBDNVpVbB5nGhKQ195aU0' -Name SomeDocument.doc -ParentID 'root'
.EXAMPLE
    #Metadata based copy
    Copy-GDriveItem -AccessToken $access_token -ID '0BAjkl4cBDNVpVbB5nGhKQ195aU0' -JsonProperty '{ "name":"test1" }'
.OUTPUTS
    Json with item metadata as PSObject
.NOTES
    Author: Max Kozlov
.LINK
    Set-GDriveItemProperty
    Move-GDriveItem
    Rename-GDriveItem
    https://developers.google.com/drive/api/v3/reference/files/copy
#>
function Copy-GDriveItem {
[CmdletBinding(SupportsShouldProcess=$true,
    DefaultParameterSetName='String')]
param(
    [Parameter(Mandatory, Position=0)]
    [string]$ID,

    [Parameter(Mandatory, Position=1, ParameterSetName='name')]
    [string]$Name,

    [Parameter(Position=2, ParameterSetName='name')]
    [Alias('DestinationID')]
    [string[]]$ParentID = @(),

    [Parameter(ParameterSetName='meta')]
    [Alias('Metadata')]
    [string]$JsonProperty = '',

    [ValidateSet("*",'kind','id','name','mimeType',
    'description','starred','trashed','explicitlyTrashed','parents','properties','appProperties','spaces','version',
    'webContentLink','webViewLink','iconLink','thumbnailLink','viewedByMe','viewedByMeTime','createdTime','modifiedTime',
    'modifiedByMeTime','sharedWithMeTime','sharingUser','owners','lastModifyingUser','shared','ownedByMe',
    'viewersCanCopyContent','writersCanShare','permissions','originalFilename','fullFileExtension',
    'fileExtension','md5Checksum','sha1Checksum','sha256Checksum','size','quotaBytesUsed','headRevisionId','contentHints',
    'imageMediaMetadata','videoMediaMetadata','capabilities','isAppAuthorized','hasThumbnail','thumbnailVersion',
    'modifiedByMe','trashingUser','trashedTime','teamDriveId','hasAugmentedPermissions',
    'keepForever', 'published', # revisions
    IgnoreCase = $false)]
    [string[]]$Property = @('kind','id','name','mimeType','parents'),

    [Parameter(Mandatory)]
    [string]$AccessToken
)
    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }

    if ($Property -contains "*") {
        $Property = "*"
    }
    $Uri = '{0}{1}/copy?supportsAllDrives=true&fields={2}' -f $GDriveUri, $ID, ($Property -join ',')
    if ($PSCmdlet.ParameterSetName -eq 'name') {
        $Body = @{
            name = $Name
        }
        if ($ParentID) {
            $Body.parents = $ParentID
        }
    }
    $JsonProperty = ConvertTo-Json $Body -Compress
    Write-Verbose "URI: $Uri"
    Write-Verbose "RequestBody: $JsonProperty"
    if ($PSCmdlet.ShouldProcess("Copy item $ID")) {
        $requestParams = @{
            Uri = $Uri
            Headers = $Headers
            ContentType = "application/json; charset=utf-8"
        }
        Invoke-RestMethod @requestParams -Method Post -Body $JsonProperty @GDriveProxySettings
    }
}
