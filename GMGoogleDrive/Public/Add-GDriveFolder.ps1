<#
.SYNOPSIS
    Creates new GoogleDrive Item, set metadata and upload content
.DESCRIPTION
    Creates new GoogleDrive Item, set metadata and upload content
.PARAMETER Path
    Path to folder to upload
.PARAMETER ParentID
    Folder ID in which new item will be placed
.PARAMETER Recurse
    Recursive upload
.PARAMETER ShowProgress
    Show progress bar while uploading
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    Add-GDriveFolder -AccessToken $access_token -Path D:\SomeFolder
.OUTPUTS
    Json with uploaded folder metadata as PSObject
.NOTES
    Author: Max Kozlov
.LINK
    New-GDriveFolder
    Add-GDriveItem
#>
function Add-GDriveFolder {
[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Parameter(Mandatory)]
    $Path,
    [string[]]$ParentID = @('root'),

    [switch]$Recurse,

    [switch]$ShowProgress,

    [Parameter(Mandatory)]
    [string]$AccessToken
)
    $folder = Get-Item $path

    $CommonParams = @{
        ParentID = $ParentID
        AccessToken = $AccessToken
    }

    if ($ShowProgress) {
        Write-Progress -Activity ('Uploading ' + $Path) -Status ('Create Folder ' + $folder.Name)
    }
    $gdfolder = New-GDriveFolder -Name $folder.Name @CommonParams
    if ($gdfolder) {
        $CommonParams.ParentID = $gdfolder.Id
        foreach ($file in (Get-ChildItem $folder)) {
            if ($file -is [System.IO.DirectoryInfo]) {
                if ($Recurse) {
                    $null = Add-GDriveFolder -Path $file.FullName -Recurse @CommonParams -ShowProgress:$ShowProgress
                }
            }
            else {
                $null = Add-GDriveItem @CommonParams -Name $file.Name -InFile $file.FullName -ShowProgress:$ShowProgress
            }
        }
        $gdfolder
    }
    if ($ShowProgress) {
        Write-Progress -Activity ('Uploading ' + $Path) -Completed
    }
}
