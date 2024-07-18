<#
.SYNOPSIS
    Remove existing GoogleSheet file
.DESCRIPTION
    Remove existing GoogleSheet file
.PARAMETER AccessToken
    Access Token for request
.PARAMETER SpreadsheetId
    SpreadsheetId file id
.EXAMPLE
    Remove-GSheetsSpreadSheet -AccessToken $AccessToken
.OUTPUTS

.NOTES
    Author: Max Kozlov
.LINK
    https://developers.google.com/sheets/api/samples/sheet
#>
function Remove-GSheetsSpreadSheet {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    param(
        [Parameter(Mandatory)]
        [string]$AccessToken,
        [Parameter(Mandatory)]
        [ValidatePattern('([a-zA-Z0-9-_]+)')]
        [string]$SpreadsheetId,
        [switch]$Permanently
    )
    Remove-GDriveItem -AccessToken $AccessToken -Id $SpreadsheetId -Permanently:$Permanently
}
