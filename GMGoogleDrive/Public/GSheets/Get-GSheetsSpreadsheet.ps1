<#
.SYNOPSIS
    Get information about the Google Sheets file
.DESCRIPTION
    Get information about the Google Sheets file
.PARAMETER SpreadsheetId
    SpreadsheetId file id
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    Get-GSheetsSpreadsheet -AccessToken $AccessToken -SpreadsheetId $SpreadsheetId
.OUTPUTS

.NOTES
    Author: Jan Elhaus
.LINK
    https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/get
#>
function Get-GSheetsSpreadsheet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidatePattern('^[a-zA-Z0-9-_]+$')]
        [string]$SpreadsheetId,

        [Parameter(Mandatory)]
        [string]$AccessToken
    )

    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }
    $requestParams = @{
        Uri = $GDriveSheetsUri + "/" + $SpreadsheetId
        Headers = $Headers
        ContentType = "application/json; charset=utf-8"
    }

    Write-Verbose "Webrequest uri:  $($requestParams.Uri)"
    Invoke-RestMethod @requestParams -Method GET @GDriveProxySettings
}
