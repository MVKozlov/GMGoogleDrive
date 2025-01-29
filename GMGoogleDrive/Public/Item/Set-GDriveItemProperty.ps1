<#
.SYNOPSIS
    Updates GoogleDrive Item metadata
.DESCRIPTION
    Updates GoogleDrive Item metadata
.PARAMETER ID
    File ID to update
.PARAMETER RevisionID
    File Revision ID to set property (Version history)
.PARAMETER JsonProperty
    Json-formatted string with all needed file metadata
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    # rename file
    Set-GDriveItemProperty -AccessToken $access_token -ID '0BAjkl4cBDNVpVbB5nGhKQ195aU0' -JsonProperty '{ "name":"test1" }'
.OUTPUTS
    Json with item metadata as PSObject
.NOTES
    Author: Max Kozlov
.LINK
    Set-GDriveItemContent
    Move-GDriveItem
    Rename-GDriveItem
    https://developers.google.com/drive/api/v3/reference/files/update
    https://developers.google.com/drive/api/v3/reference/files#resource
    https://developers.google.com/drive/api/v3/reference/revisions/update
#>
function Set-GDriveItemProperty {
[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Parameter(Mandatory, Position=0)]
    [string]$ID,

    [string]$RevisionID,

    [Parameter(Mandatory, Position=1)]
    [Alias('Metadata')]
    [string]$JsonProperty,

    [Parameter(Mandatory)]
    [string]$AccessToken
)
    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }
    $Revision = if ($RevisionID) { '/revisions/' + $RevisionID } else { '' }
    $Uri = '{0}{1}{2}?supportsAllDrives=true' -f $GDriveUri, $ID, $Revision
    Write-Verbose "URI: $Uri"

    if ($PSCmdlet.ShouldProcess("Set property for item $ID")) {
        $requestParams = @{
            Uri = $Uri
            Headers = $Headers
            ContentType = "application/json; charset=utf-8"
        }
        Invoke-RestMethod @requestParams -Method Patch -Body $JsonProperty @GDriveProxySettings
    }
}
