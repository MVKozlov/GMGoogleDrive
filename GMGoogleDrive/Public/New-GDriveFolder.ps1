<#
.SYNOPSIS
    Creates new GoogleDrive Folder
.DESCRIPTION
    Creates new GoogleDrive Folder
.PARAMETER Name
    Name of an folder item to be created
.PARAMETER ParentID
    Folder ID(s) in which new item will be placed
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    New-GDriveFolder -AccessToken $access_token -Name 'testfolder' -ParentID 'root'
.OUTPUTS
    Json with item metadata as PSObject
.NOTES
    Author: Max Kozlov
.LINK
    New-GDriveItem
    Set-GDriveItemProperty
    https://developers.google.com/drive/v3/reference/files/create
#>
function New-GDriveFolder {
[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Parameter(Mandatory, Position=0)]
    [string]$Name,

    [Parameter(Position=1)]
    [string[]]$ParentID = @('root'),

    [Parameter(Mandatory)]
    [string]$AccessToken
)
# https://developers.google.com/drive/v3/web/folder#inserting_a_file_in_a_folder
    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-type"  = "application/json"
    }
    $Uri = $GDriveUri
    Write-Verbose "URI: $Uri"
    $RequestBody = '{{ "name": "{0}", "mimeType": "application/vnd.google-apps.folder", "parents": ["{1}"] }}' -f $Name, ($ParentID -join '","')
    Write-Verbose "RequestBody: $RequestBody"
    if ($PSCmdlet.ShouldProcess("Create new folder $Name")) {
        Invoke-RestMethod -Uri $Uri -Method Post -Headers $Headers -Body $RequestBody @GDriveProxySettings
    }
}
