<#
.SYNOPSIS
    Read data from a Google Sheet
.DESCRIPTION
    Read data from a Google Sheet
.PARAMETER AccessToken
    Access Token for request
.PARAMETER SpreadsheetId
    SpreadsheetId file id
.PARAMETER A1Notation
    A1Notation of the data range that should be read
.EXAMPLE
    Get-GSheetsValues -AccessToken $AccessToken -SpreadsheetId "123456789Qp4QuHv8KD0mMXPhkoPtoe2A9YESi0" -A1Notation "Test!1:15"
.OUTPUTS

.NOTES
    Author: Jan Elhaus
.LINK

#>
function Get-GSheetsValues {
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
        Uri = $GDriveSheetsUri + "/" + $SpreadsheetId + "/values/" + $A1Notation
        Headers = $Headers
        ContentType = "application/json; charset=utf-8"
    }

    Write-Verbose "Webrequest URI: $($requestParams.Uri)"
    Invoke-RestMethod @requestParams -Method GET @GDriveProxySettings

}