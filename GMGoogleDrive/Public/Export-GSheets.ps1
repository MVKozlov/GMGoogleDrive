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

        $Headers = @{
            "Authorization" = "Bearer $AccessToken"
        }
        $requestParams = @{
            Uri = $GDriveSheetsUri + "/" + $SpreadsheetId + "/values/" + $SheetName + "!1:1"
            Headers = $Headers
            ContentType = "application/json; charset=utf-8"
        }
        
        $ColumnsInputObject = ($InputObject | Get-Member -MemberType NoteProperty).Name
        $Columns = $ColumnsInputObject
        
        if($Append) {
            Write-Verbose "Webrequest read first row:  $($requestParams | Convertto-Json -Depth 5)"
            $FirstRow = Invoke-RestMethod @requestParams -Method GET @GDriveProxySettings
        }

        if(-not $FirstRow.values -or -not $Append) {

            #Clear the SpreadSheet
            $requestParams["Uri"] = $GDriveSheetsUri + "/" + $SpreadsheetId + "/values/" + $SheetName + ":clear"
            Write-Verbose "Webrequest clear:  $($requestParams | Convertto-Json -Depth 5)"
            try {
                Invoke-RestMethod @requestParams -Method POST @GDriveProxySettings
            } Catch {
                 
                if( (($_.ErrorDetails.Message | ConvertFrom-Json).error.message) -like "Unable to parse range*" ) {
                    New-GSheetsSheet -AccessToken $AccessToken -SpreadsheetId $SpreadsheetId -SheetName $SheetName
                }
            }

            # Adding Header Row
            $requestParams["Body"] = @{
                values = (,@( $ColumnsInputObject ))
            } | ConvertTo-Json -Compress
            
            $requestParams["Uri"] = $GDriveSheetsUri + "/" + $SpreadsheetId + "/values/" + $SheetName + "!1:1?valueInputOption=RAW"

            Write-Verbose "Webrequest header row: $($requestParams | Convertto-Json -Depth 5)"
            Invoke-RestMethod @requestParams -Method PUT @GDriveProxySettings

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

        $requestParams = @{
            Uri = $GDriveSheetsUri + "/" + $SpreadsheetId + "/values/" + $SheetName + "!A2:B:append?valueInputOption=RAW"
            Headers = $Headers
            ContentType = "application/json; charset=utf-8"
            Body = @{
                values = $values
            } | ConvertTo-Json -Compress
        }

        Write-Verbose "Webrequest: $($requestParams | Convertto-Json -Depth 5)"
        Invoke-RestMethod @requestParams -Method POST @GDriveProxySettings
        
    }
    