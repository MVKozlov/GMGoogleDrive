<#
.SYNOPSIS
    Copy an existing Sheet to another existing GoogleSheet file
.DESCRIPTION
    Copy an existing Sheet from one GoogleSheet to another existing GoogleSheet file
.PARAMETER SpreadsheetId
    SpreadsheetId file id
.PARAMETER DestinationSpreadsheetId
    Destination SpreadsheetId file id
.PARAMETER SheetName
    name of the sheet to be copied
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    Copy-GSheetsSheet -AccessToken $AccessToken -SpreadsheetId $SpreadsheetId -DestinationSpreadsheetId $DestinationSpreadsheetId -SheetName "Test1"
.EXAMPLE
    Copy-GSheetsSheet -AccessToken $AccessToken -SpreadsheetId $SpreadsheetId -DestinationSpreadsheetId $SpreadsheetId -SheetId 1
.OUTPUTS

.NOTES
    Author: Max Kozlov
.LINK
    https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.sheets/copyTo
#>
function Copy-GSheetsSheet {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidatePattern('^[a-zA-Z0-9-_]+$')]
        [string]$SpreadsheetId,

        [Parameter(Mandatory)]
        [ValidatePattern('^[a-zA-Z0-9-_]+$')]
        [Alias('TargetSpreadsheetId')]
        [string]$DestinationSpreadsheetId,

        [Parameter(Mandatory, ParameterSetName='SheetId')]
        [int]$SheetId,
        [Parameter(Mandatory, ParameterSetName='SheetName')]
        [string]$SheetName,

        [Parameter(Mandatory)]
        [string]$AccessToken
    )
    if ($PSCmdlet.ParameterSetName -eq 'SheetName') {
        $SpreadsheetMeta = Get-GSheetsSpreadsheet -AccessToken $AccessToken -SpreadsheetId $SpreadsheetId
        $SheetId = ($SpreadsheetMeta.sheets.properties | Where-Object {$_.title -eq $SheetName}).sheetId
        if($null -eq $SheetId) {
            throw "SheetName not found"
        }
        Write-Verbose "Found $SheetName as $SheetId"
    }
    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }
    $requestParams = @{
        Uri = $GDriveSheetsUri + "/" + $SpreadsheetId + "/sheets/" + $SheetId + ":copyTo"
        Headers = $Headers
        ContentType = "application/json; charset=utf-8"
        Body = @{
          destinationSpreadsheetId = $DestinationSpreadsheetId
        } | ConvertTo-Json
    }

    Write-Verbose "Webrequest:  $($requestParams | ConvertTo-Json)"

    if ($PSCmdlet.ShouldProcess("Copy Sheet $SheetId")) {
        Invoke-RestMethod @requestParams -Method POST @GDriveProxySettings
    }
}
