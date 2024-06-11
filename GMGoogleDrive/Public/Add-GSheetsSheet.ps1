<#
.SYNOPSIS
    Adds a new Sheet to an exsting GoogleSheet
.DESCRIPTION
    Adds a new Sheet to an exsting GoogleSheet
.PARAMETER AccessToken
    Access Token for request
.PARAMETER SpreadsheetId
    SpreadsheetId file id
.PARAMETER SheetName
    name of the sheet to be added
.PARAMETER RowCount
    number of initial rows of the new sheet
.PARAMETER ColumnCount
    number of initial columns of the new sheet
.PARAMETER ColorHex
    number of of the new sheet (tab)
.EXAMPLE
    New-GSheetsSheet -AccessToken $AccessToken -SpreadsheetId "123456789Qp4QuHv8KD0mMXPhkoPtoe2A9YESi0" -SheetName "Test1"
.OUTPUTS

.NOTES
    Author: Jan Elhaus
.LINK
    https://developers.google.com/sheets/api/samples/sheet
#>
function New-GSheetsSheet {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$AccessToken,

        [Parameter(Mandatory)]
        [ValidatePattern('([a-zA-Z0-9-_]+)')]
        [string]$SpreadsheetId,

        [Parameter(Mandatory)]
        [string]$SheetName,

        [ValidateRange("Positive")]
        [int]$RowCount = 100,

        [ValidateRange("Positive")]
        [int]$ColumnCount = 26,

        [ValidatePattern('([A-F0-9]{6})')]
        [string]$ColorHex = "FFFFFF"
    )

    # Convert Hex to RGB
    $Red   = [convert]::ToInt32($ColorHex.SubString(0,2), 16)
    $Green = [convert]::ToInt32($ColorHex.SubString(2,2), 16)
    $Blue  = [convert]::ToInt32($ColorHex.SubString(4,2), 16)

    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }
    $requestParams = @{
        Uri = $GDriveSheetsUri + "/" + $SpreadsheetId + ":batchUpdate"
        Headers = $Headers
        ContentType = "application/json; charset=utf-8"
        Body = @{
            requests = @(
                @{
                    addSheet = @{
                        properties = @{
                            title = $SheetName
                            gridProperties = @{
                                rowCount = $RowCount
                                columnCount = $ColumnCount
                            }
                            tabColor = @{
                                red = $Red/255
                                green = $Green/255
                                blue = $Blue/255
                            }
                        }
                    }
                }
            )
        } | ConvertTo-Json -Depth 6 -Compress
    }

    Write-Verbose "Webrequest:  $($requestParams | ConvertTo-Json -Depth 7)"

    if($PSCmdlet.ShouldProcess("SheetName $SheetName")){
        Invoke-RestMethod @requestParams -Method POST @GDriveProxySettings
    }

}