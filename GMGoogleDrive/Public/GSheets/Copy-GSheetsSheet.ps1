<#
.SYNOPSIS
    Copy an existing Sheet to another existing GoogleSheet file
.DESCRIPTION
    Copy an existing Sheet from one GoogleSheet to another existing GoogleSheet file
.PARAMETER SpreadsheetId
    SpreadsheetId file id
.PARAMETER DestinationSpreadsheetId
    Destination SpreadsheetId file id
.PARAMETER SheetId
    Id of the sheet to be copied (can be found in url)
.PARAMETER SheetName
    Name of the sheet to be copied
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    Copy-GSheetsSheet -AccessToken $access_token -SpreadsheetId $SpreadsheetId -DestinationSpreadsheetId $DestinationSpreadsheetId -SheetName "Test1"
.EXAMPLE
    Copy-GSheetsSheet -AccessToken $access_token -SpreadsheetId $SpreadsheetId -DestinationSpreadsheetId $SpreadsheetId -SheetId 1
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
        [Alias('ID')]
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
        $SheetId = Find-GSheetByName -AccessToken $AccessToken -SpreadsheetId $SpreadsheetId -SheetName $SheetName
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
