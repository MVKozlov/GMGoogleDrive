<#
.SYNOPSIS
    Write data to a Google Sheet
.DESCRIPTION
    Write data to a Google Sheet
.PARAMETER SpreadsheetId
    SpreadsheetId file id
.PARAMETER A1Notation
    A1Notation of the data range that should be modified
.PARAMETER Values
    2D array of values that should be written to the sheet
.PARAMETER ValueInputOption
    Determines how input data should be interpreted.
.PARAMETER IncludeValuesInResponse
    Determines if the update response should include the values of the cells that were updated. By default, responses do not include the updated values.
.PARAMETER RenderOption
    How values should be represented in the output. The default render option is FORMATTED_VALUE.
.PARAMETER DateTimeRenderOption
    How dates, times, and durations should be represented in the output. This is ignored if valueRenderOption is FORMATTED_VALUE. The default dateTime render option is SERIAL_NUMBER.
.PARAMETER Append
    Use this parameter so that the data is added to the end of the specified range
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    Set-GSheetsValue -AccessToken $AccessToken -SpreadsheetId $SpreadsheetId -A1Notation "Test!D3:G5" -Values @(,@("Test1", "Test2"))
.EXAMPLE
    Set-GSheetsValue -AccessToken $AccessToken -SpreadsheetId $SpreadsheetId -A1Notation "Test1!A1:B2" -Values @(@(10, 20),@("=a1+b1", "test4")) -ValueInputOption USER_ENTERED -IncludeValuesInResponse -RenderOption FORMULA
.OUTPUTS

.NOTES
    Author: Jan Elhaus
.LINK
    https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values/update
    https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values/append
#>
function Set-GSheetsValue {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidatePattern('^[a-zA-Z0-9-_]+$')]
        [string]$SpreadsheetId,

        [Parameter(Mandatory)]
        [string]$A1Notation,

        [Parameter(Mandatory)]
        [array[]]$Values,

        [ValidateSet("RAW", "USER_ENTERED")]
        [string]$ValueInputOption = "RAW",
        [switch]$IncludeValuesInResponse,

        [ValidateSet('FORMULA', 'UNFORMATTED_VALUE', 'FORMATTED_VALUE')]
        [string]$RenderOption = 'FORMATTED_VALUE',
        [ValidateSet('SERIAL_NUMBER', 'FORMATTED_STRING')]
        [string]$DateTimeRenderOption = 'SERIAL_NUMBER',

        [switch]$Append,

        [Parameter(Mandatory)]
        [string]$AccessToken
    )

    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }
    $requestParams = @{
        Uri = $GDriveSheetsUri + "/" + $SpreadsheetId + "/values/" + $A1Notation
        Headers = $Headers
        ContentType = "application/json; charset=utf-8"
        Body = @{
            values = $Values
        } | ConvertTo-Json -Compress
    }

    if ($Append) {
        $requestParams.Uri += ":append"
        $requestParams.Method = "POST"
    } else {
        $requestParams.Method = "PUT"
    }
    $requestParams.Uri += "?valueInputOption=" + $ValueInputOption
    if ($IncludeValuesInResponse) {
        $requestParams.Uri += "&includeValuesInResponse=true&responseValueRenderOption={0}&responseDateTimeRenderOption={1}" -f $RenderOption, $DateTimeRenderOption
    }

    Write-Verbose "Webrequest Uri: $($requestParams.Uri)"
    Write-Verbose "Webrequest Body: $($requestParams.Body)"

    if ($PSCmdlet.ShouldProcess("SerValue $A1Notation")) {
        Invoke-RestMethod @requestParams @GDriveProxySettings
    }
}
