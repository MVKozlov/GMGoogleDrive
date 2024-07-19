<#
.SYNOPSIS
    Rename existing Sheet
.DESCRIPTION
    Rename existing Sheet
.PARAMETER SpreadsheetId
    SpreadsheetId file id
.PARAMETER SheetId
    Id of the sheet to be renamed (can be found in url)
.PARAMETER SheetName
    Name of the sheet to be renamed
.PARAMETER NewName
    New Name of the sheet
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    Rename-GSheetsSheet -AccessToken $access_token -SpreadsheetId $SpreadsheetId -NewSheetName "Test2"
.OUTPUTS

.NOTES
    Author: Max Kozlov
.LINK
    https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#UpdateSheetPropertiesRequest
#>
function Rename-GSheetsSheet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidatePattern('^[a-zA-Z0-9-_]+$')]
        [Alias('ID')]
        [string]$SpreadsheetId,

        [Parameter(Mandatory, ParameterSetName='SheetId')]
        [int]$SheetId,
        [Parameter(Mandatory, ParameterSetName='SheetName')]
        [string]$SheetName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$NewName,

        [Parameter(Mandatory)]
        [string]$AccessToken
    )
    if ($PSCmdlet.ParameterSetName -eq 'SheetName') {
        $SheetId = Find-GSheetByName -AccessToken $AccessToken -SpreadsheetId $SpreadsheetId -SheetName $SheetName
    }
    Update-GSheetsRaw -AccessToken $AccessToken -SpreadsheetId $SpreadsheetId -Requests @(
        @{
            updateSheetProperties = @{
                properties = @{
                    sheetId = $SheetId
                    title = $NewName
                }
                fields = 'title'
            }
        }
    ) -IncludeSpreadsheet |
    Select-Object -ExpandProperty updatedSpreadsheet |
    Select-Object -ExpandProperty sheets |
    Where-Object { $_.properties.sheetId -eq $SheetId }
}
