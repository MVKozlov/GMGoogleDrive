<#
.SYNOPSIS
    Adds a new Sheet to an existing GoogleSheet
.DESCRIPTION
    Adds a new Sheet to an existing GoogleSheet
.PARAMETER SpreadsheetId
    SpreadsheetId file id
.PARAMETER SheetName
    Name of the sheet to be added
.PARAMETER RowCount
    Number of initial rows of the new sheet
.PARAMETER ColumnCount
    Number of initial columns of the new sheet
.PARAMETER ColorHex
    Number of of the new sheet (tab)
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    New-GSheetsSheet -AccessToken $access_token -SpreadsheetId $SpreadsheetId -SheetName "Test1"
.OUTPUTS
    Sheet
.NOTES
    Author: Jan Elhaus
.LINK
    https://developers.google.com/sheets/api/samples/sheet
#>
function New-GSheetsSheet {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidatePattern('^[a-zA-Z0-9-_]+$')]
        [Alias('ID')]
        [string]$SpreadsheetId,

        [Parameter(Mandatory)]
        [string]$SheetName,

        [ValidateRange(1, [int]::MaxValue)]
        [int]$RowCount = 100,

        [ValidateRange(1, [int]::MaxValue)]
        [int]$ColumnCount = 26,

        [ValidatePattern('^[A-F0-9]{6}$')]
        [string]$ColorHex = "FFFFFF",

        [Parameter(Mandatory)]
        [string]$AccessToken
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

    if ($PSCmdlet.ShouldProcess("New Sheet $SheetName")){
        Invoke-RestMethod @requestParams -Method POST @GDriveProxySettings | Select-Object -ExpandProperty replies | Select-Object -ExpandProperty addSheet
    }
}
