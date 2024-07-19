<#
.SYNOPSIS
    Convert A1Notation to GridRange
.DESCRIPTION
    Convert A1Notation to GridRange
.PARAMETER SpreadsheetId
    SpreadsheetId file id
.PARAMETER A1Notation
    A1Notation of the data range
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    Convert-A1NotationToGridRange -AccessToken $access_token -SpreadsheetId $SpreadsheetId -A1Notation "Test!1:15"
.OUTPUTS
    GridRange
.NOTES
    Author: Jan Elhaus
.LINK

#>
function Convert-A1NotationToGridRange {
    [CmdletBinding()]
    [OutputType([String])]
    param(
        [Parameter(Mandatory)]
        [ValidatePattern('^[a-zA-Z0-9-_]+$')]
        [Alias('ID')]
        [string]$SpreadsheetId,

        [Parameter(Mandatory)]
        [string]$A1Notation,

        [Parameter(Mandatory)]
        [string]$AccessToken
    )

    if ($A1Notation -match '^(?<sheet>.+\!)(?<startcolumn>[A-Za-z]{0,3})(?<startrow>\d{0,7})$') {
        $A1Notation = $A1Notation + ":" + $Matches.startcolumn + $Matches.startrow
    }

    if ($A1Notation -match '^(?<sheet>.+\!)(?<startcolumn>[A-Za-z]{0,3})(?<startrow>\d{0,7}):(?<endcolumn>[A-Za-z]{0,3})(?<endrow>\d{0,7})$') {

        $Return = @{}

        $SheetName = $Matches.sheet.Substring(0, $Matches.sheet.Length - 1)
        $Return.sheetId = Find-GSheetByName -AccessToken $AccessToken -SpreadsheetId $SpreadsheetId -SheetName $SheetName

        if ($Matches.startcolumn) {
            $Alphabet = "#ABCDEFGHIJKLMNOPQRSTUVWXYZ"

            [int]$Return.startColumnIndex = 0
            for ($i = 0; $i -lt $Matches.startcolumn.Length; $i++) {
                [int]$Return.startColumnIndex += $Alphabet.IndexOf($Matches.startcolumn.Substring($i, 1).toUpper()) * [math]::pow(26, $i)
            }
            [int]$Return.startColumnIndex -= 1

            [int]$Return.endColumnIndex = 0
            for ($i = 0; $i -lt $Matches.endcolumn.Length; $i++) {
                [int]$Return.endColumnIndex += $Alphabet.IndexOf($Matches.endcolumn.Substring($i, 1).toUpper()) * [math]::pow(26, $i)
            }
        }

        if ($Matches.startrow) {
            [int]$Return.startRowIndex = $Matches.startrow - 1
            [int]$Return.endRowIndex = $Matches.endrow
        }

        Write-Verbose "GridRange: $($Return | ConvertTo-Json -Compress)"

        $Return

    } else {
        throw "does not match A1Notation format"
    }
}
