<#
.SYNOPSIS
    Get information about the Google Sheets file
.DESCRIPTION
    Get information about the Google Sheets file
.PARAMETER AccessToken
    Access Token for request
.PARAMETER SpreadsheetId
    SpreadsheetId file id
.EXAMPLE
    Get-GSheetsSpreadsheet -AccessToken $AccessToken -SpreadsheetId "123456789Qp4QuHv8KD0mMXPhkoPtoe2A9YESi0"
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
        [string]$AccessToken,

        [Parameter(Mandatory)]
        [ValidatePattern('([a-zA-Z0-9-_]+)')]
        [string]$SpreadsheetId
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