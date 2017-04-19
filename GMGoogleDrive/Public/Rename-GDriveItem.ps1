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
[CmdletBinding(DefaultParameterSetName='String')]
param(
    [Parameter(Mandatory, Position=0)]
    [string]$ID,

    [Parameter(Mandatory, Position=1)]
    [string]$NewName,

    [Parameter(Mandatory)]
    [string]$AccessToken
)

    $PSBoundParameters.Add('Property', ('{{ "name": "{0}" }}' -f $NewName) )
    Write-Verbose ('Property: ' + $PSBoundParameters['Property'])
    [void]$PSBoundParameters.Remove('NewName')

    Set-GDriveItemProperty @PSBoundParameters
}
