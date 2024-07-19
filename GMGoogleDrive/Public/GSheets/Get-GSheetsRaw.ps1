<#
.SYNOPSIS
    Read data from a Google Sheet
.DESCRIPTION
    Read data from a Google Sheet
.PARAMETER SpreadsheetId
    SpreadsheetId file id
.PARAMETER A1Notation
    A1Notation of the data range that should be read
.PARAMETER IncludeGridData
    True if grid data should be returned. This parameter is ignored if a field mask was set in the request.
.PARAMETER Fields
    Field masks are a way for API callers to list the fields that a request should return or update.
    Using a FieldMask allows the API to avoid unnecessary work and improves performance.
    A field mask is used for both the read and update methods in the Google Sheets API.
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    Get-GSheetsRaw -AccessToken $access_token -SpreadsheetId $SpreadsheetId -A1Notation "Test!1:15"
.EXAMPLE
    Get-GSheetsRaw -AccessToken $access_token -SpreadsheetId $SpreadsheetId -A1Notation "Test!1:15" -IncludeGridData
.EXAMPLE
    Get-GSheetsRaw -AccessToken $access_token -SpreadsheetId $SpreadsheetId -Fields "sheets.properties(sheetId,title)"
.EXAMPLE
    Get-GSheetsRaw -AccessToken $access_token -SpreadsheetId $SpreadsheetId -A1Notation 'A1:A5' -Fields "sheets.data.rowData.values.effectiveFormat.backgroundColor"
.OUTPUTS

.NOTES
    Author: Max Kozlov
.LINK
    https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values/get
    https://developers.google.com/sheets/api/guides/field-masks
#>
function Get-GSheetsRaw {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidatePattern('^[a-zA-Z0-9-_]+$')]
        [Alias('ID')]
        [string]$SpreadsheetId,

        [string[]]$A1Notation,
        [string]$Fields,
        [switch]$IncludeGridData,

        [Parameter(Mandatory)]
        [string]$AccessToken
    )

    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }
    $requestParams = @{
        Uri = '{0}/{1}?' -f $GDriveSheetsUri, $SpreadsheetId
        Headers = $Headers
        ContentType = "application/json; charset=utf-8"
    }
    $query=@()
    foreach ($range in $A1Notation) {
        $query += 'ranges=' + $range
    }
    if ($IncludeGridData) {
        $query += "includeGridData=true"
    }
    if ($Fields) {
        $query += "fields=$Fields"
    }
    $requestParams.Uri += $query -join '&'

    Write-Verbose "Webrequest URI: $($requestParams.Uri)"
    Invoke-RestMethod @requestParams -Method GET @GDriveProxySettings
}
