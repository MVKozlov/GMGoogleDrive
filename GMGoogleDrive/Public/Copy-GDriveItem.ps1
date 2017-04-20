<#
.SYNOPSIS
    Copy existing GoogleDrive Item into new Item
.DESCRIPTION
    Copy existing GoogleDrive Item into new Item
    By default item copied into same folder as original
.PARAMETER ID
    File ID to copy
.PARAMETER Name
    Name of an item to be created
.PARAMETER ParentID
    Folder ID(s) in which new item will be placed
.PARAMETER JsonProperty
    Json-formatted string with all needed file metadata
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    #Name based copy
    Copy-GDriveItem -AccessToken $access_token -ID '0BAjkl4cBDNVpVbB5nGhKQ195aU0' -Name SomeDocument.doc -ParentID 'root'
.EXAMPLE
    #Metadata based copy
    Copy-GDriveItem -AccessToken $access_token -ID '0BAjkl4cBDNVpVbB5nGhKQ195aU0' -JsonProperty '{ "name":"test1" }'
.OUTPUTS
    Json with item metadata as PSObject
.NOTES
    Author: Max Kozlov
.LINK
    Set-GDriveItemProperty
    Move-GDriveItem
    Rename-GDriveItem
    https://developers.google.com/drive/v3/reference/files/copy
#>
function Copy-GDriveItem {
[CmdletBinding(SupportsShouldProcess=$true,
    DefaultParameterSetName='String')]
param(
    [Parameter(Mandatory, Position=0)]
    [string]$ID,

    [Parameter(Mandatory, Position=1, ParameterSetName='name')]
    [string]$Name,

    [Parameter(Position=2, ParameterSetName='name')]
    [Alias('DestinationID')]
    [string[]]$ParentID = @(),

    [Parameter(ParameterSetName='meta')]
    [Alias('Metadata')]
    [string]$JsonProperty = '',

    [Parameter(Mandatory)]
    [string]$AccessToken
)
    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-type"  = "application/json"
    }

    # Full property set will be supported after the rain on Thursday ;-)
    $Property = 'kind','id','name','mimeType','parents'
    $Uri = '{0}{1}/copy?fields={2}' -f $GDriveUri, $ID, ($Property -join ',')
    if ($PSCmdlet.ParameterSetName -eq 'name') {
        if ($ParentID) {
            $JsonProperty = '{{ "name": "{0}", "parents": ["{1}"] }}' -f $Name, ($ParentID -join '","')
        }
        else {
            $JsonProperty = '{{ "name": "{0}" }}' -f $Name
        }
    }
    Write-Verbose "Copy URI: $Uri"
    Write-Verbose "Copy Metadata: $JsonProperty"
    if ($PSCmdlet.ShouldProcess("Copy item $ID")) {
        Invoke-RestMethod -Uri $Uri -Method Post -Headers $Headers -Body $JsonProperty @GDriveProxySettings
    }
}
