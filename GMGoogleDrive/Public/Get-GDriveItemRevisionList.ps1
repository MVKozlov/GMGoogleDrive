<#
.SYNOPSIS
    Get GoogleDrive Item revisions
.DESCRIPTION
    Get GoogleDrive Item revisions
.PARAMETER ID
    File ID to return revisions from
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    Get-GDriveItemRevisionList -AccessToken $access_token -ID '0BAjkl4cBDNVpVbB5nGhKQ195aU0'
.OUTPUTS
    Json with item metadata as PSObject
.NOTES
    Author: Max Kozlov
.LINK
    Get-GDriveItemContent
    Set-GDriveItemProperty
    Set-GDriveItemContent
    https://developers.google.com/drive/api/v3/reference/revisions/list
#>
function Get-GDriveItemRevisionList {
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position=0)]
    [string]$ID,

    [string[]]$Property = @(),

    [Parameter(Mandatory)]
    [string]$AccessToken
)
    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-type"  = "application/json"
    }
    # Standart properties always present
    $Uri = $GDriveUri + $ID + '/revisions'
    Write-Verbose "URI: $Uri"

    Invoke-RestMethod -Uri $Uri -Method Get -Headers $Headers @GDriveProxySettings
}
