<#
.SYNOPSIS
    Resolves a hierarchical folder path into a Google Drive folder ID
.DESCRIPTION
    Traverses a folder path element-by-element by querying the Google Drive API recursively. 
    The function can either fail when a subfolder is missing or dynamically build out the 
    directory structure on the fly.
.PARAMETER Path
    The structural string path of the target folder (e.g., "Test/ABC/123" or "Test\ABC\123"). 
.PARAMETER AccessToken
    Access Token for request
.PARAMETER ParentId
    An optional Google Drive Folder ID or Shared Drive ID to start the search from. 
    Providing this optimizes performance by bypassing the global root-level search.
.PARAMETER CreateIfNotExisting
    If specified, the function will dynamically create any missing folders along the path 
    rather than throwing an error.
.EXAMPLE
    $FolderId = Get-GDriveFolderIdByPath -Path "SharedDrive/Test/ABC" -AccessToken $MyToken
    Resolves the ID for the folder "ABC" starting from the global root.
.EXAMPLE
    $FolderId = Get-GDriveFolderIdByPath -Path "Test\ABC\123" -AccessToken $MyToken -ParentId "0B-zZ...xyz" -CreateIfNotExisting
    Starts searching inside the folder defined by ParentId. If "ABC" or "123" do not exist, they are created automatically.
.OUTPUTS
    System.String. Returns the alpha-numeric Google Drive ID of the target folder, or $null if the operation fails.
.NOTES
    - This function issues one API call per path depth level.
#>
function Get-GDriveFolderIdByPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$AccessToken,

        [string]$ParentId,

        [switch]$CreateIfNotExisting
    )

    # Split the path across both / and \ and strip empty elements via the .Where() method
    $Elements = ($Path -split '[/\\]').Where({ $_ })
    
    if ($Elements.Count -eq 0) {
        Write-Error "The provided path is empty or invalid."
        return $null
    }

    foreach ($Element in $Elements) {
        # Escape single quotes in folder names to prevent Google Drive API query syntax errors
        $EscapedName = $Element.Replace("'", "\'")

        if ([string]::IsNullOrWhiteSpace($ParentId)) {
            # Step 1: Search globally for the root folder or Shared Drive top-level directory
            $Query = "name = '{0}' and mimeType = 'application/vnd.google-apps.folder' and trashed = false" -f $EscapedName
        } else {
            # Step 2: Target sub-folders strictly within the verified parent ID
            $Query = "name = '{0}' and '{1}' in parents and mimeType = 'application/vnd.google-apps.folder' and trashed = false" -f $EscapedName, $ParentId
        }

        Write-Verbose "Querying for '$Element' using: $Query"
        
        # -AllDriveItems forces the API to look inside Shared Drives 
        $SearchResult = Find-GDriveItem -AccessToken $AccessToken -Query $Query -AllDriveItems

        # Validate if the API returned a valid file list object containing files
        if ($null -eq $SearchResult -or $null -eq $SearchResult.files -or $SearchResult.files.Count -eq 0) {
            
            if ($CreateIfNotExisting) {
                Write-Verbose "Creating folder for '$Element' (Parent: '$ParentId')"
                
                # Build parameter splatting table dynamically
                $FolderParams = @{
                    Name        = $Element
                    AccessToken = $AccessToken
                }
                # Only append ParentID parameter if it actually exists
                if (-not [string]::IsNullOrWhiteSpace($ParentId)) {
                    $FolderParams['ParentID'] = $ParentId
                }

                # Create the folder safely
                $NewFolder = New-GDriveFolder @FolderParams

                # CRITICAL: Verify the folder was actually created successfully
                if ($null -eq $NewFolder -or [string]::IsNullOrWhiteSpace($NewFolder.id)) {
                    Write-Error "Failed to create folder '$Element' under parent '$ParentId'."
                    return $null
                }

                $ParentId = $NewFolder.id
            } else {
                Write-Error "Failed to resolve path: Folder '$Element' was not found."
                return $null
            }

        } else {
            # If duplicate folder names exist at the same level, default to the first one returned
            if ($SearchResult.files.Count -gt 1) {
                Write-Warning "Multiple folders named '$Element' were found at this level. Proceeding with the first match."
            }

            # Update parent context to the current folder's ID for the next iteration
            $ParentId = $SearchResult.files[0].id
        }
    }

    # Return the final destination ID
    return $ParentId
}