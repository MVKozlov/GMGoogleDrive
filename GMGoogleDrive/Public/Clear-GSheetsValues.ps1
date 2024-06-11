<#
.SYNOPSIS
    Clear data from Google Sheet
.DESCRIPTION
    Clear data from Google Sheet
.PARAMETER AccessToken
    Access Token for request
.PARAMETER SpreadsheetId
    SpreadsheetId file id
.EXAMPLE
    Clear-GSheetsValues -AccessToken $AccessToken -SpreadsheetId "123456789Qp4QuHv8KD0mMXPhkoPtoe2A9YESi0" -A1Notation "Test!1:15"
.OUTPUTS

.NOTES
    Author: Jan Elhaus
.LINK
    https://developers.google.com/sheets/api/samples/sheet
#>
function Clear-GSheetsValues {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$AccessToken,

        [Parameter(Mandatory)]
        [ValidatePattern('([a-zA-Z0-9-_]+)')]
        [string]$SpreadsheetId,

        [Parameter(Mandatory)]
        [string]$A1Notation
    )

    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }
    $requestParams = @{
        Uri = $GDriveSheetsUri + "/" + $SpreadsheetId + "/values/" + $A1Notation + ":clear"
        Headers = $Headers
        ContentType = "application/json; charset=utf-8"
    }

    Write-Verbose "Webrequest: $($requestParams | ConvertTo-Json -Depth 2)"
    Invoke-RestMethod @requestParams -Method POST @GDriveProxySettings

}
