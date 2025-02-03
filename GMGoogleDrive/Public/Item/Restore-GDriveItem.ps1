<#
.SYNOPSIS
    Restore GoogleDrive Item from trash
.DESCRIPTION
    Restore GoogleDrive Item from trash
.PARAMETER ID
    File ID to restore
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    # Untrash item
    Restore-GDriveItem -AccessToken $access_token -ID '0BAjkl4cBDNVpVbB5nGhKQ195aU0'
.OUTPUTS
    Json with item metadata as PSObject
.NOTES
    Author: Max Kozlov
.LINK
    Remove-GDriveItem
    Set-GDriveItemProperty
    https://developers.google.com/drive/api/v3/reference/files/update
#>
function Restore-GDriveItem {
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
param(
    [Parameter(Mandatory, Position=0)]
    [string]$ID,

    [Parameter(Mandatory)]
    [string]$AccessToken
)

    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }
    $Uri = '{0}{1}?supportsAllDrives=true' -f $GDriveUri, $ID
    Write-Verbose "URI: $Uri"
    if ($PSCmdlet.ShouldProcess($ID, "Restore Item from trash")) {
        Set-GDriveItemProperty @PSBoundParameters -JsonProperty '{ "trashed": "false" }'
    }
}
