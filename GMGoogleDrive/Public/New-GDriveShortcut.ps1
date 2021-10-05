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

        [Parameter(Mandatory)]
        [string]$AccessToken
    )

    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }
    # Full property set will be supported after the rain on Thursday ;-)
    $Property = 'kind','id','name','mimeType','parents'
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
