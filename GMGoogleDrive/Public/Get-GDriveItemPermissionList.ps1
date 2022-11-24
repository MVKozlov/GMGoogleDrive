<#
.SYNOPSIS
    Get GoogleDrive Item permissions
.DESCRIPTION
    Get GoogleDrive Item permissions
.PARAMETER ID
    File ID to return permissions from
.PARAMETER UseDomainAdminAccess
    Issue the request as a domain administrator;
    The requester will be granted access if the file ID parameter refers to a shared drive and
    the requester is an administrator of the domain to which the shared drive belongs.
.PARAMETER AllResults
    Collect all results in one output
.PARAMETER NextPageToken
    Supply NextPage Token from Previous paged search
.PARAMETER PageSize
    Set Page Size for paged search
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    Get-GDriveItemPermissionList -AccessToken $access_token -ID '0BAjkl4cBDNVpVbB5nGhKQ195aU0'
.OUTPUTS
    Json with item permissions list as PSObject
.NOTES
    Author: Max Kozlov
.LINK
    Get-GDriveItemPermission
    Add-GDriveItemPermission
    Remove-GDriveItemPermission
    Set-GDriveItemPermission
    https://developers.google.com/drive/api/v3/reference/permissions/list
    https://developers.google.com/drive/api/v3/ref-roles
    https://developers.google.com/drive/api/v3/manage-sharing
#>
function Get-GDriveItemPermissionList {
[CmdletBinding(DefaultParameterSetName='Next')]
param(
    [Parameter(Mandatory, Position=0)]
    [string]$ID,

    [switch]$UseDomainAdminAccess,

    [Parameter(ParameterSetName='All')]
    [switch]$AllResults,

    [Parameter(ParameterSetName='Next')]
    [string]$NextPageToken,

    [ValidateRange(1,100)]
    [int]$PageSize = 100,

    [Parameter(Mandatory)]
    [string]$AccessToken
)
    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }
    if ($AllResults) {
        [void]$PSBoundParameters.Remove('AllResults')
        $permissions = New-Object System.Collections.ArrayList
        $baselist = $null
        do {
            $PSBoundParameters['NextPageToken'] = $NextPageToken
            $list = Get-GDriveItemPermissionList @PSBoundParameters
            if ($null -eq $list) { break }
            $baselist = $list
            $NextPageToken = $list.nextPageToken
            $permissions.AddRange($list.permissions)
        } while ($NextPageToken)
        if ($null -ne $baselist) {
            $baselist.permissions = $permissions.ToArray()
            $baselist
        }
    }
    else {
        $Params = New-Object System.Collections.ArrayList
        [void]$Params.Add('pageSize=' + $PageSize)
        # Always return all properties.
        [void]$Params.Add('fields=*')
        if ($UseDomainAdminAccess) {
            [void]$Params.Add('useDomainAdminAccess=true')
        }
        if ($NextPageToken) {
            [void]$Params.Add('pageToken=' + $NextPageToken)
        }
        $Uri = '{0}{1}/permissions/?supportsAllDrives=true&{2}' -f $GDriveUri, $ID,  ($Params -join '&')
        Write-Verbose "URI: $Uri"
        $requestParams = @{
            Uri = $Uri
            Headers = $Headers
            ContentType = "application/json; charset=utf-8"
        }
        Invoke-RestMethod @requestParams -Method Get @GDriveProxySettings
    }
}
