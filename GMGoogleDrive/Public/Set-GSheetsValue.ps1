<#
.SYNOPSIS
    Write data to a Google Sheet
.DESCRIPTION
    Write data to a Google Sheet
.PARAMETER AccessToken
    Access Token for request
.PARAMETER SpreadsheetId
    SpreadsheetId file id
.PARAMETER A1Notation
    A1Notation of the data range that should be modified
.PARAMETER Values
    2D array of values that should be written to the sheet
.PARAMETER ValueInputOption

.PARAMETER Append
    Use this parameter so that the data is added to the end of the specified range
.EXAMPLE
    Set-GSheetsValue -AccessToken $AccessToken -SpreadsheetId "123456789Qp4QuHv8KD0mMXPhkoPtoe2A9YESi0" -A1Notation "Test!D3:G5" -Values @(,@("Test1", "Test2"))
.OUTPUTS

.NOTES
    Author: Jan Elhaus
.LINK
    https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values/update
    https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values/append
#>
function Set-GSheetsValue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$AccessToken,

        [Parameter(Mandatory)]
        [ValidatePattern('([a-zA-Z0-9-_]+)')]
        [string]$SpreadsheetId,

        [Parameter(Mandatory)]
        [string]$A1Notation,

        [Parameter(Mandatory)]
        [array[]]$Values,

        [ValidateSet("RAW","USER_ENTERED")]
        [string]$ValueInputOption = "RAW",

        [switch]$Append
    )

    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }

    $requestParams = @{
        Uri = $GDriveSheetsUri + "/" + $SpreadsheetId + "/values/" + $A1Notation + "?valueInputOption=" + $ValueInputOption
        Headers = $Headers
        ContentType = "application/json; charset=utf-8"
        Body = @{
            values = $Values
        } | ConvertTo-Json -Compress
    }

    if($Append) {
        $requestParams["Uri"] = $GDriveSheetsUri + "/" + $SpreadsheetId + "/values/" + $A1Notation + ":append?valueInputOption=" + $ValueInputOption
        $requestParams["Method"] = "POST"
    } else {
        $requestParams["Uri"] = $GDriveSheetsUri + "/" + $SpreadsheetId + "/values/" + $A1Notation + "?valueInputOption=" + $ValueInputOption
        $requestParams["Method"] = "PUT"
    }

    Write-Verbose "Webrequest Uri: $($requestParams.Uri)"
    Write-Verbose "Webrequest Body: $($requestParams.Body)"

    Invoke-RestMethod @requestParams @GDriveProxySettings

}