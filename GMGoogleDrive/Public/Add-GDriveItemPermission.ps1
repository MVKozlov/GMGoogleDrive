<#
.SYNOPSIS
    Add GoogleDrive Item permission
.DESCRIPTION
    Add GoogleDrive Item permission
.PARAMETER ID
    File ID to set permissions to
.PARAMETER Role
    The role granted by this permission.
.PARAMETER Type
    The type of the grantee
    When creating a permission, if type is user or group, you must provide an emailAddress for the user or group.
    When type is domain, you must provide a domain. (EmailAddress field have Domain alias)
    There isn't extra information required for a anyone type
.PARAMETER EmailAddress
    The email address of the user or group to which this permission refers if Type is 'user' or 'group'
    The domain to which this permission refers if Type is 'domain'
.PARAMETER AllowFileDiscovery
    Whether the permission allows the file to be discovered through search.
    This is only applicable for permissions of type domain or anyone
.PARAMETER EnforceSingleParent
    Set to true to opt in to API behavior that aims for all items to have exactly one parent.
    This parameter only takes effect if the item is not in a shared drive
.PARAMETER MoveToNewOwnersRoot
    This parameter only takes effect if the item is not in a shared drive and the request is attempting to transfer the ownership of the item.
    When set to true, the item is moved to the new owner's My Drive root folder and all prior parents removed.
    If set to false, when enforceSingleParent=true, parents are not changed.
    If set to false, when enforceSingleParent=false, existing parents are not changed;
        however, the file will be added to the new owner's My Drive root folder, unless it is already in the new owner's My Drive.
.PARAMETER TransferOwnership
    Whether to transfer ownership to the specified user and downgrade the current owner to a writer.
    This parameter is required as an acknowledgement of the side effect
.PARAMETER SendNotificationEmail
    Whether to send a notification email when sharing to users or groups.
    This defaults to true for users and groups, and is not allowed for other requests.
    It must not be disabled for ownership transfers
.PARAMETER EmailMessage
    A plain text custom message to include in the notification email
.PARAMETER UseDomainAdminAccess
    Issue the request as a domain administrator;
    The requester will be granted access if the file ID parameter refers to a shared drive and
    the requester is an administrator of the domain to which the shared drive belongs.
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    Add-GDriveItemPermission -AccessToken $access_token -ID '0BAjkl4cBDNVpVbB5nGhKQ195aU0' -Role writer -Type user -EmailAddress bill@example.com
.OUTPUTS
    Json with item permission as PSObject
.NOTES
    Author: Max Kozlov
.LINK
    Get-GDriveItemPermissionList
    Get-GDriveItemPermission
    Remove-GDriveItemPermission
    Set-GDriveItemPermission
    https://developers.google.com/drive/api/v3/reference/permissions/create
    https://developers.google.com/drive/api/v3/ref-roles
#>
function Add-GDriveItemPermission {
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position=0)]
    [string]$ID,

    [ValidateSet('owner','organizer','fileOrganizer','writer','commenter','reader')]
    [Parameter(Mandatory, Position=1)]
    [string]$Role,

    [ValidateSet('user','group','domain','anyone')]
    [Parameter(Mandatory, Position=2)]
    [string]$Type,

    [Alias('Domain')]
    [string]$EmailAddress,

    [switch]$AllowFileDiscovery,

    [switch]$EnforceSingleParent,
    [switch]$MoveToNewOwnersRoot,
    [switch]$TransferOwnership,
    [switch]$UseDomainAdminAccess,
    [switch]$SendNotificationEmail,

    [string]$EmailMessage,

    [Parameter(Mandatory)]
    [string]$AccessToken
)
    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }
    $Params = New-Object System.Collections.ArrayList
    # Always return all properties.
    [void]$Params.Add('fields=*')
    if ($EmailMessage) {
        [void]$Params.Add('emailMessage={0}' -f [System.Net.WebUtility]::UrlEncode($EmailMessage))
    }
    foreach ($k in 'enforceSingleParent','moveToNewOwnersRoot', 'sendNotificationEmail', 'transferOwnership', 'useDomainAdminAccess') {
        if ($PSBoundParameters.ContainsKey($k)) {
            [void]$Params.Add('{0}=true' -f $k)
        }
    }
    $Uri = '{0}{1}/permissions?supportsAllDrives=true&{2}' -f $GDriveUri, $ID, ($Params -join '&')
    Write-Verbose "URI: $Uri"
    $Body = @{
        role = $Role
        type = $Type
    }
    if ($Type -ne 'anyone' -and -not $EmailAddress) {
        Write-Error 'You must provive EmailAddress'
    }
    else {
        if ($Type -eq 'user' -or $Type -eq 'group') {
            $Body.emailAddress = $EmailAddress
        }
        if ($Type -eq 'domain') {
            $Body.domain = $EmailAddress
        }
        if ($AllowFileDiscovery) {
            $Body.allowFileDiscovery = 'true'
        }
        $JsonProperty = ConvertTo-Json $Body
        Write-Verbose "RequestBody: $JsonProperty"
        $requestParams = @{
            Uri = $Uri
            Headers = $Headers
            ContentType = "application/json; charset=utf-8"
        }
        Invoke-RestMethod @requestParams -Method Post -Body $JsonProperty @GDriveProxySettings
    }
}
