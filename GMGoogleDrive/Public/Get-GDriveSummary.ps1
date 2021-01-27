﻿<#
.SYNOPSIS
    Get GDrive user summary
.DESCRIPTION
    Get GDrive user summary
    BUG?: v3 return bad request :-/
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    Get-GDriveSummary -AccessToken $access_token
.OUTPUTS
    Json with summary metadata as PSObject
.NOTES
    Author: Max Kozlov
.LINK
    https://developers.google.com/drive/api/v3/reference/about/get
#>
function Get-GDriveSummary {
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$AccessToken
)
    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }
    $requestParams = @{
        Uri = $GDriveAboutURI
        Headers = $Headers
        ContentType = "application/json; charset=utf-8"
    }
    Invoke-RestMethod @requestParams -Method Get @GDriveProxySettings
}
