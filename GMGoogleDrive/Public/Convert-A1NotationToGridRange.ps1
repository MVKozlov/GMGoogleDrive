<#
.SYNOPSIS
    Read data from a Google Sheet
.DESCRIPTION
    Read data from a Google Sheet
.PARAMETER AccessToken
    Access Token for request
.PARAMETER SpreadsheetId
    SpreadsheetId file id
.PARAMETER A1Notation
    A1Notation of the data range that should be read
.EXAMPLE
    Get-GSheetsValues -AccessToken $AccessToken -SpreadsheetId "123456789Qp4QuHv8KD0mMXPhkoPtoe2A9YESi0" -A1Notation "Test!1:15"
.OUTPUTS

.NOTES
    Author: Jan Elhaus
.LINK

#>
function Convert-A1NotationToGridRange {
    [CmdletBinding()]
    param(
        [string]$AccessToken,

        [ValidatePattern('([a-zA-Z0-9-_]+)')]
        [string]$SpreadsheetId,

        [Parameter(Mandatory)]
        [string]$A1Notation
    )

    $A1Notation -match '^(?<sheet>.+\!)(?<startcolumn>[A-Za-z]{0,3})(?<startrow>\d{0,7}):(?<endcolumn>[A-Za-z]{0,3})(?<endrow>\d{0,7})$'

    $return = @{
        sheetId = $Matches.sheet
        startRowIndex = $Matches.startrow
        endRowIndex = $Matches.endrow
        startColumnIndex = $Matches.startcolumn
        endColumnIndex = $Matches.endcolumn
    }

    $return

}