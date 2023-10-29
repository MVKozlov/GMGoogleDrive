<#
.SYNOPSIS
    Creates new GoogleDrive Item shortcut
.DESCRIPTION
    Creates new GoogleDrive Item shortcut
.PARAMETER Name
    Name of an item to be created
.PARAMETER ParentID
    Folder ID(s) in which new item will be placed
.PARAMETER TargetID
    Target ID of file/folder for which shortcut should be created
.PARAMETER Property
    List of properties that will be retured once item is created
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    New-GDriveShortcut -AccessToken $access_token -Name 'test.txt' -ParentID 'root' -TargetID '0BAjkl4cBDNVpVbB5nGhKQ195aU0'
.OUTPUTS
    Json with item metadata as PSObject
.NOTES
    Author: Max Kozlov
.LINK
    New-GDriveFolder
    Add-GDriveItem
    Set-GDriveItemProperty
    Set-GDriveItemContent
    https://developers.google.com/drive/api/v3/reference/files/create
#>
function New-GDriveShortcut {
[CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [string[]]$ParentID = @('root'),

        [Parameter(Mandatory)]
        [string]$TargetID,

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
    $Uri = '{0}?supportsAllDrives=true&fields={1}' -f $GDriveUri, ($Property -join ',')
    Write-Verbose "URI: $Uri"
    $Body = @{
        name = $Name
        mimeType ="application/vnd.google-apps.shortcut"
        parents = $ParentID
        shortcutDetails = @{ targetId = $TargetID }
    }
    $JsonProperty = ConvertTo-Json $Body -Compress
    Write-Verbose "RequestBody: $JsonProperty"
    if ($PSCmdlet.ShouldProcess("Create new item link $Name")) {
        $requestParams = @{
            Uri = $Uri
            Headers = $Headers
            ContentType = "application/json; charset=utf-8"
        }
        Invoke-RestMethod @requestParams -Method Post -Body $JsonProperty @GDriveProxySettings
    }
}
