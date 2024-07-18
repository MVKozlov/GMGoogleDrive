<#
.SYNOPSIS
    Export Data to Google Sheets
.DESCRIPTION
    Export Data to Google Sheets
.PARAMETER SpreadsheetId
    SpreadsheetId file id
.PARAMETER SheetName
    Name of the sheet where the data should be exported
.PARAMETER Columns
    List of columns to create (headers)
    If it not defined, column headers will be taken from the properties of the objects being passed
.PARAMETER TransferLines
    Number of lines that should be transfered to the Google Api with one API call
.PARAMETER Append
    Use this parameter so that the data is added to the end of the specified file. Without this parameter, data will be overwritten without warning
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    Export-GSheets -InputObject $data -AccessToken $AccessToken -SpreadsheetId $SpreadsheetId -SheetName "Test"
.EXAMPLE
    $data | Export-GSheets -AccessToken $AccessToken -SpreadsheetId $SpreadsheetId -SheetName "Test" -Append
.EXAMPLE
    Get-ChildItem "C:\" | Export-GSheets -AccessToken $AccessToken -SpreadsheetId $SpreadsheetId -SheetName "Test"
.EXAMPLE
    $data = @{header1='value11'; header2='value12'}, @{header1='value21'; header2='value22'}
    $data | Export-GSheets -AccessToken $AccessToken -SpreadsheetId $SpreadsheetId -SheetName "Test" -Columns header1,header2
.OUTPUTS

.NOTES
    Author: Jan Elhaus
.LINK

#>
function Export-GSheets {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$InputObject,

        [Parameter(Mandatory)]
        [ValidatePattern('^[a-zA-Z0-9-_]+$')]
        [string]$SpreadsheetId,

        [Parameter(Mandatory)]
        [string]$SheetName,

        [Alias('Header')]
        [string[]]$Columns,

        [ValidateRange(1, 10000)]
        [int]$TransferLines = 100,

        [switch]$Append,

        [Parameter(Mandatory)]
        [string]$AccessToken
    )

    BEGIN {

        $FirstRun = $true
        $Values  = @()
        $requestParams = @{
            AccessToken = $AccessToken 
            SpreadsheetId = $SpreadsheetId 
        }

        if ($Append) {
            $FirstRow = Get-GSheetsValue @requestParams -A1Notation ($SheetName + "!1:1")
            if ($FirstRow.values) {
                $Columns = $FirstRow.values[0]
            }
        }

    }

    PROCESS {

        if ($FirstRun) {
            if (-not $Columns) {
                $Columns = ($InputObject | Get-Member -MemberType NoteProperty,Property | Where-Object {$_.Definition -notlike "System.*"}).Name
            }
            if (-not $Append) {
                # Clear the SpreadSheet
                try {
                    Clear-GSheetsValue @requestParams -A1Notation $SheetName | Out-Null
                }
                catch {
                    if( (($_.ErrorDetails.Message | ConvertFrom-Json).error.message) -like "Unable to parse range*" ) {
                        New-GSheetsSheet @requestParams -SheetName $SheetName -RowCount 2 -ColumnCount 1 | Out-Null
                    }
                }

                # Adding Header Row
                Set-GSheetsValue @requestParams -A1Notation "$SheetName!1:1" -Values (,@( $Columns )) | Out-Null
                Set-GSheetsFormatting @requestParams -A1Notation "$SheetName!1:1" -Bold $true | Out-Null
            }
            $FirstRun = $false
        }

        # Appending Data
        foreach ($Data in $InputObject) {
            $Row = @()
            foreach ($Column in $Columns) {
                $Row += $Data.$Column
            }
            $Values += @(,$Row)
        }

        if ($Values.Count -ge $TransferLines) {
            Set-GSheetsValue @requestParams -A1Notation "$SheetName!A2:B" -Values $Values -Append
            $Values = @()
        }
    }

    END {
        if ($Values) {
            Set-GSheetsValue @requestParams -A1Notation "$SheetName!A2:B" -Values $Values -Append
        }
    }
}
