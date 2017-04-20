<#
.SYNOPSIS
    Updates GoogleDrive Item metadata
.DESCRIPTION
    Updates GoogleDrive Item metadata
.PARAMETER ID
    File ID to update
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
    https://developers.google.com/drive/v3/reference/files/update
    https://developers.google.com/drive/v3/reference/files#resource
#>
function Set-GDriveItemProperty {
[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Parameter(Mandatory, Position=0)]
    [string]$ID,

    [Parameter(Mandatory, Position=1)]
    [Alias('Metadata')]
    [string]$JsonProperty,

    [Parameter(Mandatory)]
    [string]$AccessToken
)
    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-type"  = "application/json"
    }
    # Standart properties always present
    $Uri = $GDriveUri + $ID
    Write-Verbose "URI: $Uri"

    if ($PSCmdlet.ShouldProcess("Set property for item $ID")) {
        Invoke-RestMethod -Uri $Uri -Method Patch -Headers $Headers -Body $JsonProperty @GDriveProxySettings
    }
}
