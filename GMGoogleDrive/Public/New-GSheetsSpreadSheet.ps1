<#
.SYNOPSIS
    Adds a new GoogleSheet file
.DESCRIPTION
    Adds a new GoogleSheet file with default properties
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    New-GSheetsSpreadSheet -AccessToken $AccessToken
.OUTPUTS

.NOTES
    Author: Max Kozlov
.LINK
    https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/create
#>
function New-GSheetsSpreadSheet {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$AccessToken
    )
    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }
    $requestParams = @{
        Uri = $GDriveSheetsUri
        Headers = $Headers
        ContentType = "application/json; charset=utf-8"
        Body = '{}'
    }

    Write-Verbose "Webrequest:  $($requestParams | ConvertTo-Json)"

    if($PSCmdlet.ShouldProcess("New Spreadsheet")){
        Invoke-RestMethod @requestParams -Method POST @GDriveProxySettings
    }
}
