<#
.SYNOPSIS
    Creates new GoogleDrive Item, set metadata
.DESCRIPTION
    Creates new GoogleDrive Item, set metadata
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
    #Name based creation
    New-GDriveItem -AccessToken $access_token -Name 'test.txt' -ParentID 'root'
.EXAMPLE
    #Metadata based creation
    New-GDriveItem -AccessToken $access_token -JsonProperty '{ "name": "test.txt", "parents": ["root"] }'
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
function New-GDriveItem {
[CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory, ParameterSetName='name')]
        [string]$Name,

        [Parameter(ParameterSetName='name')]
        [string[]]$ParentID = @('root'),

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

    if ($PSCmdlet.ParameterSetName -eq 'name') {
        $JsonProperty = '{{ "name": "{0}", "parents": ["{1}"] }}' -f $Name, ($ParentID -join '","')
        $Body = @{
            name = $Name
            parents = $ParentID
        }
        $JsonProperty = ConvertTo-Json $Body -Compress
    }

    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }
    if ($Property -contains "*") {
        $Property = "*"
    }
    $Uri = '{0}?supportsAllDrives=true&fields={1}' -f $GDriveUri, ($Property -join ',')
    Write-Verbose "URI: $Uri"
    Write-Verbose "RequestBody: $JsonProperty"
    if ($PSCmdlet.ShouldProcess("Create new item $Name")) {
        $requestParams = @{
            Uri = $Uri
            Headers = $Headers
            ContentType = "application/json; charset=utf-8"
        }
        Invoke-RestMethod @requestParams -Method Post -Body $JsonProperty @GDriveProxySettings
    }
}
