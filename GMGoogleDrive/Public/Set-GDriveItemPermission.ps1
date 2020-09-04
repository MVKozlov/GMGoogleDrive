<#
.SYNOPSIS
    Update GoogleDrive Item permission
.DESCRIPTION
    Update GoogleDrive Item permission
.PARAMETER ID
    File ID to set permissions to
.PARAMETER PermissionID
    Permission ID to return
.PARAMETER Role
    The role granted by this permission.
.PARAMETER ExpirationTime
    The time at which this permission will expire (RFC 3339 date-time)
    Expiration times have the following restrictions:
     - They can only be set on user and group permissions
     - The time must be in the future
     - The time cannot be more than a year in the future
.PARAMETER RemoveExpiration
    Whether to remove the expiration date
.PARAMETER TransferOwnership
    Whether to transfer ownership to the specified user and downgrade the current owner to a writer.
    This parameter is required as an acknowledgement of the side effect
.PARAMETER UseDomainAdminAccess
    Issue the request as a domain administrator;
    The requester will be granted access if the file ID parameter refers to a shared drive and
    the requester is an administrator of the domain to which the shared drive belongs.
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    Set-GDriveItemPermission -AccessToken $access_token -ID '0BAjkl4cBDNVpVbB5nGhKQ195aU0'
.OUTPUTS
    Json with item permission as PSObject
.NOTES
    Author: Max Kozlov
.LINK
    Get-GDriveItemPermissionList
    Get-GDriveItemPermission
    Add-GDriveItemPermission
    Remove-GDriveItemPermission
    https://developers.google.com/drive/api/v3/reference/permissions/update
    https://developers.google.com/drive/api/v3/ref-roles
#>
function Set-GDriveItemPermission {
[CmdletBinding(DefaultParameterSetName='Add')]
param(
    [Parameter(Mandatory, Position=0)]
    [string]$ID,

    [Parameter(Mandatory, Position=1)]
    [string]$PermissionID,

    [ValidateSet('owner','organizer','fileOrganizer','writer','commenter','reader')]
    [Parameter(Mandatory, Position=2)]
    [string]$Role,

    [Parameter(ParameterSetName='Add')]
    [DateTime]$ExpirationTime,
    [Parameter(ParameterSetName='Remove')]
    [switch]$RemoveExpiration,
    [switch]$TransferOwnership,
    [switch]$UseDomainAdminAccess,

    [Parameter(Mandatory)]
    [string]$AccessToken
)
    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-type"  = "application/json"
    }
    $Params = New-Object System.Collections.ArrayList
    # Always return all properties.
    [void]$Params.Add('fields=*')
    foreach ($k in 'removeExpiration', 'transferOwnership', 'useDomainAdminAccess') {
        if ($PSBoundParameters.ContainsKey($k)) {
            [void]$Params.Add('{0}=true' -f $k)
        }
    }
    $Uri = '{0}{1}/permissions/{2}?supportsAllDrives=true&{3}' -f $GDriveUri, $ID, $PermissionID, ($Params -join '&')
    $Body = @{
        role = $Role
    }
    if ($ExpirationTime) {
        $Body.expirationTime = $ExpirationTime.ToUniversalTime().ToString('u').Replace(' ','T')
    }
    $JsonProperty = ConvertTo-Json $Body
    Write-Verbose "RequestBody: $JsonProperty"
    Invoke-RestMethod -Uri $Uri -Method Patch -Headers $Headers @GDriveProxySettings -Body $JsonProperty
}
