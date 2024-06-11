<#
.SYNOPSIS

.DESCRIPTION

.PARAMETER Name

.EXAMPLE

.OUTPUTS
    Json with item metadata as PSObject
.NOTES
    Author: Jan Elhaus
.LINK
    https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/get
#>
function Get-GSheetsSpreadsheet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$AccessToken,

        [Parameter(Mandatory)]
        [ValidatePattern('([a-zA-Z0-9-_]+)')]
        [string]$SpreadsheetId
    )

    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }
    $requestParams = @{
        Uri = $GDriveSheetsUri + "/" + $SpreadsheetId
        Headers = $Headers
        ContentType = "application/json; charset=utf-8"
    }


    Write-Verbose "Webrequest:  $($requestParams | ConvertTo-Json -Depth 2)"
    Invoke-RestMethod @requestParams -Method GET @GDriveProxySettings

}