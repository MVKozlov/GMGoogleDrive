<#
.SYNOPSIS
    Remove a Sheet from an existing GoogleSheet
.DESCRIPTION
    Remove a Sheet from an existing GoogleSheet
.PARAMETER AccessToken
    Access Token for request
.PARAMETER SpreadsheetId
    SpreadsheetId file id
.PARAMETER SheetId
    Id of the sheet to be deleted (can be found in url)
.PARAMETER SheetName
    name of the sheet to be deleted
.EXAMPLE
    Remove-GSheetsSheet -AccessToken $AccessToken -SpreadsheetId "123456789Qp4QuHv8KD0mMXPhkoPtoe2A9YESi0" -SheetId "2045344383"
.EXAMPLE
    Remove-GSheetsSheet -AccessToken $AccessToken -SpreadsheetId "123456789Qp4QuHv8KD0mMXPhkoPtoe2A9YESi0" -SheetName "Sheet1"
.OUTPUTS

.NOTES
    Author: Jan Elhaus
.LINK
    https://developers.google.com/sheets/api/samples/sheet
    https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values/batchUpdate
#>
function Remove-GSheetsSheet {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    param(
        [Parameter(Mandatory)]
        [string]$AccessToken,

        [Parameter(Mandatory)]
        [ValidatePattern('([a-zA-Z0-9-_]+)')]
        [string]$SpreadsheetId,

        [Parameter(ParameterSetName='SheetId', Mandatory=$true)]
        [string]$SheetId,

        [Parameter(ParameterSetName='SheetName', Mandatory=$true)]
        [string]$SheetName
    )

    if ($PSCmdlet.ParameterSetName -eq 'SheetName') {
        $SpreadsheetMeta = Get-GSheetsSpreadsheet -AccessToken $AccessToken -SpreadsheetId $SpreadsheetId
        $SheetId = ($SpreadsheetMeta.sheets.properties | Where-Object {$_.title -eq $SheetName}).sheetId
        if($null -eq $SheetId) {
            throw "SheetName not found"
        }
    }

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
                    deleteSheet = @{
                        sheetId = $SheetId
                    }
                }
            )
        } | ConvertTo-Json -Depth 4 -Compress
    }

    Write-Verbose "Webrequest:  $($requestParams | ConvertTo-Json -Depth 3)"

    if($PSCmdlet.ShouldProcess("SheetId $SheetId")){
        Invoke-RestMethod @requestParams -Method POST @GDriveProxySettings
    }

}