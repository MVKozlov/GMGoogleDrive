﻿<#
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
    https://developers.google.com/drive/api/v3/reference/files/create
    https://developers.google.com/drive/api/v3/folder#inserting_a_file_in_a_folder
#>
function New-GDriveFolder {
[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Parameter(Mandatory, Position=0)]
    [string]$Name,

    [Parameter(Position=1)]
    [string[]]$ParentID = @('root'),

    [DateTime]$CreationDate,

    [Parameter(Mandatory)]
    [string]$AccessToken
)
    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }
    $Uri = $GDriveUri + '?supportsAllDrives=true'
    Write-Verbose "URI: $Uri"
    $Body = @{
        name = $Name
        mimeType = "application/vnd.google-apps.folder"
        parents = $ParentID
        shortcutDetails = @{ targetId = $TargetID }
    }
    if($CreationDate) {
        $Body["createdTime"] = (Get-Date $CreationDate  -Format "yyyy-MM-ddTHH:mm:ss.fffzzz" -AsUTC)
        $Body["modifiedTime"] = $Body["createdTime"]
    }

    $JsonProperty = ConvertTo-Json $Body -Compress
    Write-Verbose "RequestBody: $JsonProperty"
    if ($PSCmdlet.ShouldProcess("Create new folder $Name")) {
        $requestParams = @{
            Uri = $Uri
            Headers = $Headers
            ContentType = "application/json; charset=utf-8"
        }
        Invoke-RestMethod @requestParams -Method Post -Body $JsonProperty @GDriveProxySettings
    }
}
