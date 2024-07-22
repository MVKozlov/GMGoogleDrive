<#
.SYNOPSIS
    Adds a new GoogleSheet file
.DESCRIPTION
    Adds a new GoogleSheet file with default properties
.PARAMETER Name
    Name of the GoogleSheet file to be added
.PARAMETER SheetName
    Name of the default Sheet in file to be added
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    New-GSheetsSpreadsheet -AccessToken $access_token -Name 'New table'
.EXAMPLE
    New-GSheetsSpreadsheet -AccessToken $access_token -Name 'New table' -SheetName 'sheet1'
.EXAMPLE
    New-GSheetsSpreadsheet -AccessToken $access_token
.OUTPUTS
    Spreadsheet
.NOTES
    Author: Max Kozlov
.LINK
    https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/create
#>
function New-GSheetsSpreadsheet {
    [CmdletBinding()]
    param(
        [string]$Name,

        [string]$SheetName,

        [Parameter(Mandatory)]
        [string]$AccessToken
    )
    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }
    $requestParams = @{
        Uri = $GDriveSheetsUri
        Headers = $Headers
        ContentType = "application/json; charset=utf-8"
        Body = @{
            properties = @{
                title = $Name
            }
            sheets = @(
                @{
                    properties = @{
                        title = $SheetName
                    }
                }
            )
        } | ConvertTo-Json -Depth 3 -Compress
    }

    Write-Verbose "Webrequest:  $($requestParams | ConvertTo-Json)"

    Invoke-RestMethod @requestParams -Method POST @GDriveProxySettings
}
