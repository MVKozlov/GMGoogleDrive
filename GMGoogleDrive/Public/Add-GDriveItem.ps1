﻿<#
.SYNOPSIS
    Creates new GoogleDrive Item, set metadata and upload content
.DESCRIPTION
    Creates new GoogleDrive Item, set metadata and upload content
.PARAMETER StringContent
    Content to upload as string
.PARAMETER Encoding
    Enconding used for string
.PARAMETER RawContent
    Content to upload as raw byte[] array
.PARAMETER InFile
    Content to upload as path to file
.PARAMETER Name
    Name of an item to be created
.PARAMETER ParentID
    Folder ID in which new item will be placed
.PARAMETER JsonProperty
    Json-formatted string with all needed file metadata
.PARAMETER UseMetadataFromFile
    Uses the metadata of the file provided in InFile
.PARAMETER Property
    List of properties that will be retured once upload is completed
.PARAMETER ContentType
    Uploaded item Content type (seems google automatically set it to most of uploaded files)
.PARAMETER ChunkSize
    Upload request size
.PARAMETER ShowProgress
    Show progress bar while uploading
.PARAMETER KeepRevisionForever
    Set the flag that this revision of the file will be kept forever.
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    #Named File based upload
    Add-GDriveItem -AccessToken $access_token -InFile D:\SomeDocument.doc -Name SomeDocument.doc
.EXAMPLE
    #Named Raw data upload with ParentID
    [byte[]]$Content = Get-Content D:\SomeDocument.doc -Encoding Bytes
    $ParentFolder = Find-GDriveItem -AccessToken $access_token -Query 'name="myparentfolder"'
    Add-GDriveItem -AccessToken $access_token -RawContent -Name SomeDocument.doc -ParentID $ParentFolder.files.id
.EXAMPLE
    #String based upload with metadata
    Add-GDriveItem -AccessToken $access_token -StringContent 'test file' -JsonProperty '{ "name":"myfile.txt" }'
.OUTPUTS
    PSObject with properties:
        Item: Json with item metadata as PSObject
        ResultID: Upload ID for resume operations
        Error: Error info if happen
.NOTES
    Author: Max Kozlov
.LINK
    Set-GDriveItemProperty
    Set-GDriveItemContent
#>
function Add-GDriveItem {
[CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory, ParameterSetName='stringName')]
        [Parameter(Mandatory, ParameterSetName='stringMeta')]
        [string]$StringContent,
        [Parameter(ParameterSetName='stringName')]
        [Parameter(ParameterSetName='stringMeta')]
        [System.Text.Encoding]$Encoding = [System.Text.Encoding]::UTF8,

        [Parameter(Mandatory, ParameterSetName='dataName')]
        [Parameter(Mandatory, ParameterSetName='dataMeta')]
        [byte[]]$RawContent,

        [Parameter(Mandatory, ParameterSetName='fileName')]
        [Parameter(Mandatory, ParameterSetName='fileMeta')]
        [Parameter(Mandatory, ParameterSetName='fileAutomaticMeta')]
        [string]$InFile,

        [Parameter(Mandatory, ParameterSetName='dataName')]
        [Parameter(Mandatory, ParameterSetName='stringName')]
        [Parameter(Mandatory, ParameterSetName='fileName')]
        [string]$Name,

        [Parameter(ParameterSetName='dataName')]
        [Parameter(ParameterSetName='stringName')]
        [Parameter(ParameterSetName='fileName')]
        [Parameter(ParameterSetName='fileAutomaticMeta')]
        [string[]]$ParentID = @('root'),

        [Parameter(ParameterSetName='dataMeta')]
        [Parameter(ParameterSetName='stringMeta')]
        [Parameter(ParameterSetName='fileMeta')]
        [Alias('Metadata')]
        [string]$JsonProperty = '',

        [Parameter(Mandatory, ParameterSetName='fileAutomaticMeta')]
        [switch]$UseMetadataFromFile,

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

        [string]$ContentType = 'application/octet-stream',

        [ValidateScript({
            (-not ($_ -band 0x3FFFF)) -or ( & { throw 'ChunkSize must be in multiples of 256 KB (256 x 1024 bytes) in size' } )
        })]
        [int]$ChunkSize = 4Mb,

        [switch]$ShowProgress,

        [switch]$KeepRevisionForever,

        [Parameter(Mandatory)]
        [string]$AccessToken
    )

    Set-GDriveItemContent @PSBoundParameters
}
