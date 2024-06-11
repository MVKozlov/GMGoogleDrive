<#
.SYNOPSIS
    Convert A1Notation to GridRange
.DESCRIPTION
    Convert A1Notation to GridRange
.PARAMETER AccessToken
    Access Token for request
.PARAMETER SpreadsheetId
    SpreadsheetId file id
.PARAMETER A1Notation
    A1Notation of the data range
.EXAMPLE
    Convert-A1NotationToGridRange -AccessToken $AccessToken -SpreadsheetId "123456789Qp4QuHv8KD0mMXPhkoPtoe2A9YESi0" -A1Notation "Test!1:15"
.OUTPUTS

.NOTES
    Author: Jan Elhaus
.LINK

#>
function Convert-A1NotationToGridRange {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$AccessToken,

        [Parameter(Mandatory)]
        [ValidatePattern('([a-zA-Z0-9-_]+)')]
        [string]$SpreadsheetId,

        [Parameter(Mandatory)]
        [string]$A1Notation
    )

    $A1Notation = "Test!A:A"
    if($A1Notation -match '^(?<sheet>.+\!)(?<startcolumn>[A-Za-z]{0,3})(?<startrow>\d{0,7})$') {
        $A1Notation = $A1Notation + ":" + $Matches.startcolumn + $Matches.startrow
    }

    if($A1Notation -match '^(?<sheet>.+\!)(?<startcolumn>[A-Za-z]{0,3})(?<startrow>\d{0,7}):(?<endcolumn>[A-Za-z]{0,3})(?<endrow>\d{0,7})$') {

        $Alphabet = "#ABCDEFGHIJKLMNOPQRSTUVWXYZ"

        $StartColumn = 0
        for ($i = 0; $i -lt $Matches.startcolumn.Length; $i++) {
            $StartColumn += $Alphabet.IndexOf($Matches.startcolumn.Substring($i,1).toUpper()) * [math]::pow(26, $i)
        }
        $StartColumn -= 1

        $EndColumn = 0
        for ($i = 0; $i -lt $Matches.endcolumn.Length; $i++) {
            $EndColumn += $Alphabet.IndexOf($Matches.endcolumn.Substring($i,1).toUpper()) * [math]::pow(26, $i)
        }
        $EndColumn -= 1

        $SheetName = $Matches.sheet.Substring(0,$Matches.sheet.Length-1)
        $SpreadsheetMeta = Get-GSheetsSpreadsheet -AccessToken $AccessToken -SpreadsheetId $SpreadsheetId
        $SheetId = ($SpreadsheetMeta.sheets.properties | Where-Object {$_.title -eq $SheetName}).sheetId
        if(-not $SheetId) {
            throw "SheetName not found"
        }

        $return = @{
            sheetId = $SheetId
            startRowIndex = $Matches.startrow -1
            endRowIndex = $Matches.endrow -1
            startColumnIndex = $StartColumn
            endColumnIndex = $EndColumn
        }

        $return

    } else {
        throw "does not match A1Notation format"
    }

}