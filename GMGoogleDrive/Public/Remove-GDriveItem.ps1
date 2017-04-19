<#
.SYNOPSIS
    Move GoogleDrive Item to trash or remove it permanently
.DESCRIPTION
    Move GoogleDrive Item to trash or remove it permanently
.PARAMETER ID
    File ID to remove
.PARAMETER Permanently
    Permanently remove item. If not set, item moved to trash
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    # Trash item
    Remove-GDriveItem -AccessToken $access_token -ID '0BAjkl4cBDNVpVbB5nGhKQ195aU0'
.EXAMPLE
    # Remove item
    Remove-GDriveItem -AccessToken $access_token -ID '0BAjkl4cBDNVpVbB5nGhKQ195aU0' -Permanently
.OUTPUTS
    Json with item metadata as PSObject
    or None if removed permanently
.NOTES
    Author: Max Kozlov
.LINK
    Rename-GDriveItem
    Move-GDriveItem
    Set-GDriveItemProperty
#>
function Remove-GDriveItem {
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position=0)]
    [string]$ID,

    [switch]$Permanently,

    [Parameter(Mandatory)]
    [string]$AccessToken
)
#https://developers.google.com/drive/v3/reference/files/delete

    if ($Permanently) {
        $Headers = @{
            "Authorization" = "Bearer $AccessToken"
            "Content-type"  = "application/json"
        }
        $Uri = $GDriveUri + $ID
        Write-Verbose "URI: $Uri"

        Invoke-RestMethod -Uri $Uri -Method Delete -Headers $Headers @GDriveProxySettings
    }
    else {
        Set-GDriveItemProperty @PSBoundParameters -JsonProperty '{ "trashed":"true" }'
    }
}
