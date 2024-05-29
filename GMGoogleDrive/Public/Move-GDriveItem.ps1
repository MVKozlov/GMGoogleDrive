<#
.SYNOPSIS
    Move GoogleDrive Item into other folder(s)
.DESCRIPTION
    Move GoogleDrive Item into other folder(s)
.PARAMETER ID
    File ID to move
.PARAMETER ParentID
    Folder ID(s) from which item will be removed
.PARAMETER NewParentID
    Folder ID(s) in which item will be placed
.PARAMETER Property
    List of properties that will be retured once item is moved
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    Move-GDriveItem -AccessToken $access_token -ID '0BAjkl4cBDNVpVbB5nGhKQ195aU0' `
        -ParentID 'root' -NewParentID '0BAjkl4cBDNVpVbB5nGhKQ195a20', '0BAjkl4cBDNVpVbB5nGhKQ195a10'
.OUTPUTS
    Json with item metadata as PSObject
.NOTES
    Author: Max Kozlov
.LINK
    Set-GDriveItemProperty
    Set-GDriveItemContent
    Rename-GDriveItem
    Remove-GDriveItem
#>
function Move-GDriveItem {
[CmdletBinding(SupportsShouldProcess=$true,
    DefaultParameterSetName='String')]
param(
    [Parameter(Mandatory, Position=0)]
    [string]$ID,

    [Parameter(Position=1)]
    [string[]]$ParentID,

    [Parameter(Mandatory, Position=2)]
    [Alias('DestinationID')]
    [string[]]$NewParentID,

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
    if (-not $PSBoundParameters.ContainsKey('ParentID')) {
        try {
            $info = Get-GDriveItemProperty -ID $ID -AccessToken $AccessToken -Property parents
            $ParentID = $info.parents
        }
        catch {
            Write-Error $_.Exception
            return
        }
    }
    if ($Property -contains "*") {
        $Property = "*"
    }
    $Uri = '{0}{1}?supportsAllDrives=true&fields={2}&removeParents={3}&addParents={4}' -f $GDriveUri, $ID, ($Property -join ','), ($ParentID -join ','), ($NewParentID -join ',')
    Write-Verbose "Move URI: $Uri"

    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }
    if ($PSCmdlet.ShouldProcess("Move item $ID to $($NewParentID -join ',')")) {
        $requestParams = @{
            Uri = $Uri
            Headers = $Headers
            ContentType = "application/json; charset=utf-8"
        }
        Invoke-RestMethod @requestParams -Method Patch @GDriveProxySettings
    }
}
