<#
.SYNOPSIS
    Export Data to Google Sheets
.DESCRIPTION
    Export Data to Google Sheets
.PARAMETER AccessToken
    
.EXAMPLE
    
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
        [string]$AccessToken,

        [Parameter(Mandatory)]
        [ValidatePattern('([a-zA-Z0-9-_]+)')]
        [string]$SpreadsheetId,

        [Parameter(Mandatory)]
        [string]$SheetName,

        [switch]$Append
    )
        
        $ColumnsInputObject = ($InputObject | Get-Member -MemberType NoteProperty,Property).Name
        $Columns = $ColumnsInputObject
        
        if($Append) {
            $FirstRow = Get-GSheetsValues -AccessToken $AccessToken -SpreadsheetId $SpreadsheetId -A1Notation ($SheetName + "!1:1")
        }

        if(-not $FirstRow.values -or -not $Append) {

            #Clear the SpreadSheet
            
            try {
                Clear-GSheetsValues -AccessToken $AccessToken -SpreadsheetId $SpreadsheetId -A1Notation $SheetName
            } Catch {
                 
                if( (($_.ErrorDetails.Message | ConvertFrom-Json).error.message) -like "Unable to parse range*" ) {
                    New-GSheetsSheet -AccessToken $AccessToken -SpreadsheetId $SpreadsheetId -SheetName $SheetName
                }
            }

            # Adding Header Row
            Set-GSheetsValues -AccessToken $AccessToken -SpreadsheetId $SpreadsheetId -A1Notation "$SheetName!1:1" -Values (,@( $ColumnsInputObject ))

        } else {
            $Columns = $FirstRow.values[0]
        }
        

        # Appending Data

        $values = @()
        foreach($data_ in $data) {
            $row = @()
            foreach($Column in $Columns) {
                $row += $data_.$Column
            }
            $values += @(,$row)
        }

        Set-GSheetsValues -AccessToken $AccessToken -SpreadsheetId $SpreadsheetId -A1Notation "$SheetName!A2:B" -Values $values -Append
        
    }
    