<#
.SYNOPSIS
    Creates new GoogleDrive Item, set metadata
.DESCRIPTION
    Creates new GoogleDrive Item, set metadata
.PARAMETER Name
    Name of an item to be created
.PARAMETER ParentID
    Folder ID(s) in which new item will be placed
.PARAMETER JsonProperty
    Json-formatted string with all needed file metadata
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    #Name based creation
    New-GDriveItem -AccessToken $access_token -Name 'test.txt' -ParentID 'root'
.EXAMPLE
    #Metadata based creation
    New-GDriveItem -AccessToken $access_token -JsonProperty '{ "name": "test.txt", "parents": ["root"] }'
.OUTPUTS
    Json with item metadata as PSObject
.NOTES
    Author: Max Kozlov
.LINK
    New-GDriveFolder
    Add-GDriveItem
    Set-GDriveItemProperty
    Set-GDriveItemContent
    https://developers.google.com/drive/v3/reference/files/create
#>
function New-GDriveItem {
[CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory, ParameterSetName='name')]
        [string]$Name,

        [Parameter(ParameterSetName='name')]
        [string[]]$ParentID = @('root'),

        [Parameter(ParameterSetName='meta')]
        [Alias('Metadata')]
        [string]$JsonProperty = '',

        [Parameter(Mandatory)]
        [string]$AccessToken
    )

    if ($PSCmdlet.ParameterSetName -eq 'name') {
        $JsonProperty = '{{ "name": "{0}", "parents": ["{1}"] }}' -f $Name, ($ParentID -join '","')
        Write-Verbose "Constructed Metadata: $JsonProperty"
    }

    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-type"  = "application/json"
    }
    # Full property set will be supported after the rain on Thursday ;-)
    $Property = 'kind','id','name','mimeType','parents'
    $Uri = '{0}?fields={1}' -f $GDriveUri, ($Property -join ',')
    Write-Verbose "URI: $Uri"
    Write-Verbose "RequestBody: $JsonProperty"
    if ($PSCmdlet.ShouldProcess("Create new item $Name")) {
        Invoke-RestMethod -Uri $Uri -Method Post -Headers $Headers -Body $JsonProperty @GDriveProxySettings
    }
}
