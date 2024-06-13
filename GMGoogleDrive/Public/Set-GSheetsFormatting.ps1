<#
.SYNOPSIS
    Changing the format of cells in a GSheet
.DESCRIPTION
    Changing the format of cells in a GSheet
.PARAMETER AccessToken
    Access Token for request
.PARAMETER SpreadsheetId
    SpreadsheetId file id
.EXAMPLE

.OUTPUTS

.NOTES
    Author: Jan Elhaus
.LINK
    https://developers.google.com/sheets/api/samples/sheet
    https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/cells
#>
function Set-GSheetsFormatting {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$AccessToken,

        [Parameter(Mandatory)]
        [ValidatePattern('([a-zA-Z0-9-_]+)')]
        [string]$SpreadsheetId,

        [Parameter(Mandatory)]
        [string]$A1Notation,

        [ValidatePattern('([A-F0-9]{6})')]
        [string]$BackgroudColorHex,

        [ValidatePattern('([A-F0-9]{6})')]
        [string]$FontColorHex,

        [ValidateRange("Positive")]
        [int]$FontSize,

        [bool]$Bold,

        [bool]$Italic,

        [bool]$Strikethrough,

        [bool]$Underline,

        [ValidateSet("CENTER","LEFT","RIGHT")]
        [string]$HorizontalAlignment,

        [ValidateSet("TOP","MIDDLE","BOTTOM")]
        [string]$VerticalAlignment,

        [ValidateSet("OVERFLOW_CELL","LEGACY_WRAP","CLIP","WRAP")]
        [string]$WrapStrategy
    )

    $GridRange = Convert-A1NotationToGridRange -AccessToken $AccessToken -SpreadsheetId $SpreadsheetId -A1Notation $A1Notation

    $cell = @{}
    $cell["userEnteredFormat"] = @{}
    $cell["userEnteredFormat"]["textFormat"] = @{}
    $fields = @()

    if($PSBoundParameters.ContainsKey('BackgroudColorHex')) {
        $cell["userEnteredFormat"]["backgroundColor"] = @{
            red =   [convert]::ToInt32($BackgroudColorHex.SubString(0,2), 16)
            green = [convert]::ToInt32($BackgroudColorHex.SubString(2,2), 16)
            blue =  [convert]::ToInt32($BackgroudColorHex.SubString(4,2), 16)
        }
        $fields += "userEnteredFormat.backgroundColor"
    }

    if($PSBoundParameters.ContainsKey('FontColorHex')) {
        $cell["userEnteredFormat"]["textFormat"]["foregroundColor"] = @{
            red =   [convert]::ToInt32($FontColorHex.SubString(0,2), 16)
            green = [convert]::ToInt32($FontColorHex.SubString(2,2), 16)
            blue =  [convert]::ToInt32($FontColorHex.SubString(4,2), 16)
        }
        $fields += "userEnteredFormat.textFormat.foregroundColor"
    }

    if($PSBoundParameters.ContainsKey('FontSize')) {
        $cell["userEnteredFormat"]["textFormat"]["fontSize"] = $FontSize
        $fields += "userEnteredFormat.textFormat.fontSize"
    }

    if($PSBoundParameters.ContainsKey('Bold')) {
        $cell["userEnteredFormat"]["textFormat"]["bold"] = $Bold
        $fields += "userEnteredFormat.textFormat.bold"
    }
    if($PSBoundParameters.ContainsKey('Italic')) {
        $cell["userEnteredFormat"]["textFormat"]["italic"] = $Italic
        $fields += "userEnteredFormat.textFormat.italic"
    }
    if($PSBoundParameters.ContainsKey('Strikethrough')) {
        $cell["userEnteredFormat"]["textFormat"]["strikethrough"] = $Strikethrough
        $fields += "userEnteredFormat.textFormat.strikethrough"
    }
    if($PSBoundParameters.ContainsKey('Underline')) {
        $cell["userEnteredFormat"]["textFormat"]["underline"] = $Underline
        $fields += "userEnteredFormat.textFormat.underline"
    }

    if($PSBoundParameters.ContainsKey('HorizontalAlignment')) {
        $cell["userEnteredFormat"]["horizontalAlignment"] = $HorizontalAlignment
        $fields += "userEnteredFormat.horizontalAlignment"
    }
    if($PSBoundParameters.ContainsKey('VerticalAlignment')) {
        $cell["userEnteredFormat"]["verticalAlignment"] = $VerticalAlignment
        $fields += "userEnteredFormat.verticalAlignment"
    }
    if($PSBoundParameters.ContainsKey('WrapStrategy')) {
        $cell["userEnteredFormat"]["wrapStrategy"] = $WrapStrategy
        $fields += "userEnteredFormat.wrapStrategy"
    }
    if($PSBoundParameters.ContainsKey('WrapStrategy')) {
        $cell["userEnteredFormat"]["wrapStrategy"] = $WrapStrategy
        $fields += "userEnteredFormat.wrapStrategy"
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
                    repeatCell = @{
                        range = $GridRange
                        cell = $cell
                        fields = ($fields -join ",")
                    }
                }
            )
        } | ConvertTo-Json -Depth 10 -Compress
    }

    Write-Verbose "Webrequest body: $($requestParams.Body)"
    Invoke-RestMethod @requestParams -Method POST @GDriveProxySettings

}