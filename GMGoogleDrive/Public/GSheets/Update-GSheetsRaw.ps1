<#
.SYNOPSIS
    Write data to a Google Sheet
.DESCRIPTION
    Write data to a Google Sheet
.PARAMETER SpreadsheetId
    SpreadsheetId file id
.PARAMETER Requests
    Array of raw requests that should be applied to the sheet
.PARAMETER IncludeSpreadsheet
    Determines if the update response should include the spreadsheet resource.
.PARAMETER IncludeGridData
    True if grid data should be returned.
    Meaningful only if includeSpreadsheetInResponse is 'true'.
    This parameter is ignored if a field mask was set in the request.
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    $r1 = Convert-A1NotationToGridRange -AccessToken $access_token -SpreadsheetId $SpreadsheetId -A1Notation 'test1!B2'
    $r2 = Convert-A1NotationToGridRange -AccessToken $access_token -SpreadsheetId $SpreadsheetId -A1Notation 'test1!C5'
    Update-GSheetsRaw -AccessToken $access_token -SpreadsheetId $SpreadsheetId -Requests @( @{ copyPaste = @{ source=$r1; destination=$r2 } } )
.OUTPUTS

.NOTES
    Author: Max Kozlov
.LINK
    https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/batchUpdate
    https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request
#>
function Update-GSheetsRaw {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidatePattern('^[a-zA-Z0-9-_]+$')]
        [Alias('ID')]
        [string]$SpreadsheetId,

        [Parameter(Mandatory)]
        [array]$Requests,

        [switch]$IncludeSpreadsheet,
        [switch]$IncludeGridData,

        [Parameter(Mandatory)]
        [string]$AccessToken
    )

    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }
    $requestParams = @{
        Uri = '{0}/{1}:batchUpdate?' -f $GDriveSheetsUri, $SpreadsheetId
        Headers = $Headers
        ContentType = "application/json; charset=utf-8"
        Body = @{
            requests = $Requests
        } | ConvertTo-Json -Compress -Depth 10
    }
    $query=@()
    if ($IncludeSpreadsheet) {
        $query += "includeSpreadsheetInResponse=true"
    }
    if ($IncludeGridData) {
        $query += "responseIncludeGridData=true"
    }
    $requestParams.Uri += $query -join '&'

    Write-Verbose "Webrequest Uri: $($requestParams.Uri)"
    Write-Verbose "Webrequest Body: $($requestParams.Body)"

    if ($PSCmdlet.ShouldProcess("SerValue $A1Notation")) {
        Invoke-RestMethod @requestParams -Method Post @GDriveProxySettings
    }
}
