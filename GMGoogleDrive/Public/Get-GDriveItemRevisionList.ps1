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
    Json with item revisions list as PSObject
.NOTES
    Author: Max Kozlov
.LINK
    Get-GDriveItemContent
    Set-GDriveItemProperty
    Set-GDriveItemContent
    https://developers.google.com/drive/api/v3/reference/revisions/list
#>
function Get-GDriveItemRevisionList {
[CmdletBinding(DefaultParameterSetName='Next')]
param(
    [Parameter(Mandatory, Position=0)]
    [string]$ID,

    [Parameter(ParameterSetName='Next')]
    [string]$NextPageToken,

    [Parameter(ParameterSetName='All')]
    [switch]$AllResults,

    # seems for now it keep only 101 revision in free version
    [ValidateRange(1,1000)]
    [int]$PageSize = 200,

    [Parameter(Mandatory)]
    [string]$AccessToken
)
    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-type"  = "application/json"
    }
    if ($AllResults) {
        [void]$PSBoundParameters.Remove('AllResults')
        $revisions = New-Object System.Collections.ArrayList
        $baselist = $null
        do {
            $PSBoundParameters['NextPageToken'] = $NextPageToken
            $list = Get-GDriveItemRevisionList @PSBoundParameters
            if ($null -eq $list) { break }
            $baselist = $list
            $NextPageToken = $list.nextPageToken
            $revisions.AddRange($list.revisions)
        } while ($NextPageToken)
        if ($null -ne $baselist) {
            $baselist.revisions = $revisions.ToArray()
            $baselist
        }
    }
    else {
        $Params = New-Object System.Collections.ArrayList
        [void]$Params.Add('pageSize=' + $PageSize)
        # Always return all properties.
        [void]$Params.Add('fields=*')
        if ($NextPageToken) {
            [void]$Params.Add('pageToken=' + $NextPageToken)
        }
        $Uri = '{0}{1}/revisions/?supportsAllDrives=true&{2}' -f $GDriveUri, $ID,  ($Params -join '&')
        Invoke-RestMethod -Uri $Uri -Method Get -Headers $Headers @GDriveProxySettings
    }
}
