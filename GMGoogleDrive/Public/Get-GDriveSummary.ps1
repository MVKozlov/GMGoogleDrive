<#
.SYNOPSIS
    Get GDrive user summary
.DESCRIPTION
    Get GDrive user summary
    BUG?: v3 return bad request :-/
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    # rename file
    Get-GDriveSummary -AccessToken $access_token
.OUTPUTS
    Json with summary metadata as PSObject
.NOTES
    Author: Max Kozlov
.LINK
    https://developers.google.com/drive/v2/reference/about/get
#>
function Get-GDriveSummary {
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$AccessToken
)
    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-type"  = "application/json"
    }

    Invoke-RestMethod -Uri $GDriveAboutURI -Method Get -Headers $Headers @GDriveProxySettings
}
