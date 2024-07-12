<#
.SYNOPSIS
    Copy an existing Sheet to another existing GoogleSheet file
.DESCRIPTION
    Copy an existing Sheet from one GoogleSheet to another existing GoogleSheet file
.PARAMETER AccessToken
    Access Token for request
.PARAMETER SpreadsheetId
    SpreadsheetId file id
.PARAMETER DestinationSpreadsheetId
    Destination SpreadsheetId file id
.PARAMETER SheetName
    name of the sheet to be copied
.EXAMPLE
    Copy-GSheetsSheet -AccessToken $AccessToken -SpreadsheetId "123456789Qp4QuHv8KD0mMXPhkoPtoe2A9YESi0" $DestinationSpreadsheetId "123456789Qp4QuHv8KD0mMXPhkoPtoe2A9YESi1" -SheetName "Test1"
.EXAMPLE
    Copy-GSheetsSheet -AccessToken $AccessToken -SpreadsheetId "123456789Qp4QuHv8KD0mMXPhkoPtoe2A9YESi0" $DestinationSpreadsheetId "123456789Qp4QuHv8KD0mMXPhkoPtoe2A9YESi1" -SheetId 1
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
        [string]$AccessToken,

        [Parameter(Mandatory)]
        [ValidatePattern('([a-zA-Z0-9-_]+)')]
        [string]$SpreadsheetId,

        [Parameter(Mandatory)]
        [ValidatePattern('([a-zA-Z0-9-_]+)')]
        [Alias('TargetSpreadsheetId')]
        [string]$DestinationSpreadsheetId,

        [Parameter(Mandatory, ParameterSetName='SheetId')]
        [int]$SheetId,
        [Parameter(Mandatory, ParameterSetName='SheetName')]
        [string]$SheetName
    )
    if ($PSCmdlet.ParameterSetName -eq 'SheetName') {
        $SpreadsheetMeta = Get-GSheetsSpreadsheet -AccessToken $AccessToken -SpreadsheetId $SpreadsheetId
        $SheetId = ($SpreadsheetMeta.sheets.properties | Where-Object {$_.title -eq $SheetName}).sheetId
        if($null -eq $SheetId) {
            throw "SheetName not found"
        }
        Write-Verbose "Found $SheetName as $SheetId"
        $SheetId = $Id
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

    if($PSCmdlet.ShouldProcess("SheetName $SheetName")){
        Invoke-RestMethod @requestParams -Method POST @GDriveProxySettings
    }

}