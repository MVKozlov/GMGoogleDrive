<#
.SYNOPSIS
    Remove existing GoogleSheet file
.DESCRIPTION
    Remove existing GoogleSheet file
.PARAMETER SpreadsheetId
    SpreadsheetId file id
.PARAMETER Permanently
    Permanently remove GoogleSheet. If not set, item moved to trash
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    Remove-GSheetsSpreadsheet -AccessToken $access_token -SpreadsheetId $SpreadsheetId
.OUTPUTS

.NOTES
    Author: Max Kozlov
.LINK
    https://developers.google.com/sheets/api/samples/sheet
#>
function Remove-GSheetsSpreadsheet {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    param(
        [Parameter(Mandatory)]
        [ValidatePattern('^[a-zA-Z0-9-_]+$')]
        [Alias('ID')]
        [string]$SpreadsheetId,

        [switch]$Permanently,

        [Parameter(Mandatory)]
        [string]$AccessToken
    )
    $PSBoundParameters.ID = $PSBoundParameters.SpreadsheetId
    $PSBoundParameters.Remove('SpreadsheetId')

    Remove-GDriveItem @PSBoundParameters
}
