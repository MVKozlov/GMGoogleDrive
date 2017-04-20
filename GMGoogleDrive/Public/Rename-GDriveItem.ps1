<#
.SYNOPSIS
    Rename GoogleDrive Item
.DESCRIPTION
    Rename GoogleDrive Item
.PARAMETER ID
    File ID to rename
.PARAMETER NewName
    New Item name
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    Rename-GDriveItem -AccessToken $access_token -ID '0BAjkl4cBDNVpVbB5nGhKQ195aU0' -NewName 'test1'
.OUTPUTS
    Json with item metadata as PSObject
.NOTES
    Author: Max Kozlov
.LINK
    Move-GDriveItem
    Set-GDriveItemProperty
    Set-GDriveItemContent
#>
function Rename-GDriveItem {
[CmdletBinding(SupportsShouldProcess=$true,
    DefaultParameterSetName='String')]
param(
    [Parameter(Mandatory, Position=0)]
    [string]$ID,

    [Parameter(Mandatory, Position=1)]
    [string]$NewName,

    [Parameter(Mandatory)]
    [string]$AccessToken
)

    $PSBoundParameters.Add('JsonProperty', ('{{ "name": "{0}" }}' -f $NewName) )
    Write-Verbose ('JsonProperty: ' + $PSBoundParameters['JsonProperty'])
    [void]$PSBoundParameters.Remove('NewName')
    if ($PSCmdlet.ShouldProcess("Rename Item $ID to $NewName")) {
        Set-GDriveItemProperty @PSBoundParameters
    }
}
