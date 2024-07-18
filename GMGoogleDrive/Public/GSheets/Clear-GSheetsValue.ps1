<#
.SYNOPSIS
    Clear data from Google Sheet
.DESCRIPTION
    Clear data from Google Sheet
.PARAMETER SpreadsheetId
    SpreadsheetId file id
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    Clear-GSheetsValue -AccessToken $AccessToken -SpreadsheetId $SpreadsheetId -A1Notation "Test!1:15"
.OUTPUTS

.NOTES
    Author: Jan Elhaus
.LINK
    https://developers.google.com/sheets/api/samples/sheet
#>
function Clear-GSheetsValue {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidatePattern('^[a-zA-Z0-9-_]+$')]
        [string]$SpreadsheetId,

        [Parameter(Mandatory)]
        [string]$A1Notation,

        [Parameter(Mandatory)]
        [string]$AccessToken
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
    if ($PSCmdlet.ShouldProcess("Clear $A1Notation")) {
        Invoke-RestMethod @requestParams -Method POST @GDriveProxySettings
    }
}
