<#
.SYNOPSIS
    Export Data to Google Sheets
.DESCRIPTION
    Export Data to Google Sheets
.PARAMETER AccessToken
    Access Token for request
.PARAMETER SpreadsheetId
    SpreadsheetId file id
.PARAMETER SheetName
    name of the sheet where the data should be exported
.PARAMETER TransferLines
    number of lines that should be transfered to the Google Api with one API call
.PARAMETER Append
    Use this parameter so that the data is added to the end of the specified file. Without this parameter, data will be overwritten without warning
.EXAMPLE
    Export-GSheets -InputObject $data -AccessToken $AccessToken -SpreadsheetId "123456789Qp4QuHv8KD0mMXPhkoPtoe2A9YESi0" -SheetName "Test"
    $data | Export-GSheets -AccessToken $AccessToken -SpreadsheetId "123456789Qp4QuHv8KD0mMXPhkoPtoe2A9YESi0" -SheetName "Test" -Append
    Get-ChildItem "C:\" | Export-GSheets -AccessToken $AccessToken -SpreadsheetId "123456789Qp4QuHv8KD0mMXPhkoPtoe2A9YESi0" -SheetName "Test"
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

        [ValidateRange("Positive")]
        [int]$TransferLines = 100,

        [switch]$Append
    )
        
    begin {
        
        $FirstRun = $true
        $Columns = @()
        $Values  = @()
        
        if($Append) {
            $FirstRow = Get-GSheetsValues -AccessToken $AccessToken -SpreadsheetId $SpreadsheetId -A1Notation ($SheetName + "!1:1")
            if($FirstRow.values) {
                $Columns = $FirstRow.values[0]
            }
        }
        
    }

    process {

        if($FirstRun -and -not $Columns) {

            $ColumnsInputObject = ($InputObject | Get-Member -MemberType NoteProperty,Property | Where-Object {$_.Definition -notlike "System.*"}).Name
            $Columns = $ColumnsInputObject

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
    
            }

            $FirstRun = $false
        }

        # Appending Data

        foreach($Data in $InputObject) {
            $Row = @()
            foreach($Column in $Columns) {
                $Row += $Data.$Column
            }
            $Values += @(,$Row)
        }

        if($Values.Count -ge $TransferLines) {
            Set-GSheetsValues -AccessToken $AccessToken -SpreadsheetId $SpreadsheetId -A1Notation "$SheetName!A2:B" -Values $Values -Append
            $Values = @()
        }
        
    }

    End {
        if($Values) {
            Set-GSheetsValues -AccessToken $AccessToken -SpreadsheetId $SpreadsheetId -A1Notation "$SheetName!A2:B" -Values $Values -Append
        }
    }

}
    