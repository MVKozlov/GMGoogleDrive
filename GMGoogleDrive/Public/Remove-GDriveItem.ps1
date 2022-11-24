<#
.SYNOPSIS
    Move GoogleDrive Item to trash or remove it permanently
.DESCRIPTION
    Move GoogleDrive Item to trash or remove it permanently
.PARAMETER ID
    File ID to remove
.PARAMETER Permanently
    Permanently remove item. If not set, item moved to trash
.PARAMETER RevisionID
    File Revision ID to remove (Version history)
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
    https://developers.google.com/drive/api/v3/reference/files/delete
    https://developers.google.com/drive/api/v3/reference/revisions/delete
#>
function Remove-GDriveItem {
[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High', DefaultParameterSetName='Trash')]
param(
    [Parameter(Mandatory, Position=0)]
    [string]$ID,

    [Parameter(ParameterSetName='Permanent')]
    [switch]$Permanently,

    [Parameter(ParameterSetName='Permanent')]
    [string]$RevisionID,

    [Parameter(Mandatory)]
    [string]$AccessToken
)

    if ($Permanently -or $RevisionID) {
        $Headers = @{
            "Authorization" = "Bearer $AccessToken"
        }
        $Revision = if ($RevisionID) { '/revisions/' + $RevisionID } else { '' }
        $Uri = '{0}{1}{2}?{3}' -f $GDriveUri, $ID, $Revision, "?supportsAllDrives=true"
        Write-Verbose "URI: $Uri"

        if ($PSCmdlet.ShouldProcess($ID, "Remove Item")) {
            $requestParams = @{
                Uri = $Uri
                Headers = $Headers
                ContentType = "application/json; charset=utf-8"
            }
            Invoke-RestMethod @requestParams -Method Delete @GDriveProxySettings
        }
    }
    else {
        if ($PSCmdlet.ShouldProcess($ID, "Move Item to trash")) {
            Set-GDriveItemProperty @PSBoundParameters -JsonProperty '{ "trashed": "true" }'
        }
    }
}
