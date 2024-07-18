<#
.SYNOPSIS
    Read data from a Google Sheet
.DESCRIPTION
    Read data from a Google Sheet
.PARAMETER SpreadsheetId
    SpreadsheetId file id
.PARAMETER A1Notation
    A1Notation of the data range that should be read
.PARAMETER RenderOption
    How values should be represented in the output. The default render option is FORMATTED_VALUE.
.PARAMETER MajorDimension
    The major dimension that results should use. The default major dimension is ROWS.
.PARAMETER DateTimeRenderOption
    How dates, times, and durations should be represented in the output. This is ignored if valueRenderOption is FORMATTED_VALUE. The default dateTime render option is SERIAL_NUMBER.
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    Get-GSheetsValue -AccessToken $AccessToken -SpreadsheetId $SpreadsheetId -A1Notation "Test!1:15"
.EXAMPLE
    Get-GSheetsValue -AccessToken $AccessToken -SpreadsheetId $SpreadsheetId -A1Notation "Test!1:15" -RenderOption formula -MajorDimension columns
.OUTPUTS

.NOTES
    Author: Jan Elhaus
.LINK
    https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values/get
#>
function Get-GSheetsValue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidatePattern('^[a-zA-Z0-9-_]+$')]
        [string]$SpreadsheetId,

        [Parameter(Mandatory)]
        [string]$A1Notation,

        [ValidateSet('FORMULA', 'UNFORMATTED_VALUE', 'FORMATTED_VALUE')]
        [string]$RenderOption = 'FORMATTED_VALUE',
        [ValidateSet('ROWS', 'COLUMNS')]
        [string]$MajorDimension = 'ROWS',
        [ValidateSet('SERIAL_NUMBER', 'FORMATTED_STRING')]
        [string]$DateTimeRenderOption = 'SERIAL_NUMBER',

        [Parameter(Mandatory)]
        [string]$AccessToken
    )

    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }
    $requestParams = @{
        Uri = '{0}/{1}/values/{2}?valueRenderOption={3}&majorDimension={4}&dateTimeRenderOption={5}' -f $GDriveSheetsUri, $SpreadsheetId, $A1Notation, $RenderOption, $MajorDimension, $DateTimeRenderOption
        Headers = $Headers
        ContentType = "application/json; charset=utf-8"
    }

    Write-Verbose "Webrequest URI: $($requestParams.Uri)"
    Invoke-RestMethod @requestParams -Method GET @GDriveProxySettings
}
