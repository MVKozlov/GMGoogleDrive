<#
.SYNOPSIS
    Changing the format of cells in a GSheet
.DESCRIPTION
    Changing the format of cells in a GSheet
.PARAMETER SpreadsheetId
    SpreadsheetId file id
.PARAMETER A1Notation
    A1Notation of the area to modify
.PARAMETER BackgroudColorHex
    HexCode of the cell background color
.PARAMETER FontColorHex
    HexCode of the font color
.PARAMETER FontSize
    Specify the font size
.PARAMETER Bold
    Specify whether the font should be bold
.PARAMETER Italic
    Specify whether the font should be italic
.PARAMETER Strikethrough
    Specify whether the font should be strikethrough
.PARAMETER Underline
    Specify whether the font should be underlined
.PARAMETER HorizontalAlignment,
    Specify the horizontal alignment of the cell
.PARAMETER VerticalAlignment,
    Specify the vertical alignment of the cell
.PARAMETER WrapStrategy
    Specify the text wrap strategy alignment of the cell
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    Set-GSheetsFormatting -AccessToken $access_token -SpreadsheetId $SpreadsheetId -A1Notation "Test!1:1" -FontSize 10 -Strikethrough $false -BackgroudColorHex 623f56
.EXAMPLE
    Set-GSheetsFormatting -AccessToken $access_token -SpreadsheetId $SpreadsheetId -A1Notation "Test!1:1" -Bold $true -FontColorHex 623f56
.OUTPUTS

.NOTES
    Author: Jan Elhaus
.LINK
    https://developers.google.com/sheets/api/samples/sheet
    https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/cells
#>
function Set-GSheetsFormatting {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidatePattern('^[a-zA-Z0-9-_]+$')]
        [Alias('ID')]
        [string]$SpreadsheetId,

        [Parameter(Mandatory)]
        [string]$A1Notation,

        [ValidatePattern('^[A-F0-9]{6}$')]
        [string]$BackgroudColorHex,

        [ValidatePattern('^[A-F0-9]{6}$')]
        [string]$FontColorHex,

        [ValidateRange(1, [int]::MaxValue)]
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
        [string]$WrapStrategy,

        [Parameter(Mandatory)]
        [string]$AccessToken
    )

    $GridRange = Convert-A1NotationToGridRange -AccessToken $AccessToken -SpreadsheetId $SpreadsheetId -A1Notation $A1Notation

    $cell = @{}
    $cell["userEnteredFormat"] = @{}
    $cell["userEnteredFormat"]["textFormat"] = @{}
    $fields = @()

    if ($PSBoundParameters.ContainsKey('BackgroudColorHex')) {
        $cell["userEnteredFormat"]["backgroundColor"] = @{
            red =   [convert]::ToInt32($BackgroudColorHex.SubString(0,2), 16)
            green = [convert]::ToInt32($BackgroudColorHex.SubString(2,2), 16)
            blue =  [convert]::ToInt32($BackgroudColorHex.SubString(4,2), 16)
        }
        $fields += "userEnteredFormat.backgroundColor"
    }

    if ($PSBoundParameters.ContainsKey('FontColorHex')) {
        $cell["userEnteredFormat"]["textFormat"]["foregroundColor"] = @{
            red =   [convert]::ToInt32($FontColorHex.SubString(0,2), 16)
            green = [convert]::ToInt32($FontColorHex.SubString(2,2), 16)
            blue =  [convert]::ToInt32($FontColorHex.SubString(4,2), 16)
        }
        $fields += "userEnteredFormat.textFormat.foregroundColor"
    }

    if ($PSBoundParameters.ContainsKey('FontSize')) {
        $cell["userEnteredFormat"]["textFormat"]["fontSize"] = $FontSize
        $fields += "userEnteredFormat.textFormat.fontSize"
    }

    if ($PSBoundParameters.ContainsKey('Bold')) {
        $cell["userEnteredFormat"]["textFormat"]["bold"] = $Bold
        $fields += "userEnteredFormat.textFormat.bold"
    }
    if ($PSBoundParameters.ContainsKey('Italic')) {
        $cell["userEnteredFormat"]["textFormat"]["italic"] = $Italic
        $fields += "userEnteredFormat.textFormat.italic"
    }
    if ($PSBoundParameters.ContainsKey('Strikethrough')) {
        $cell["userEnteredFormat"]["textFormat"]["strikethrough"] = $Strikethrough
        $fields += "userEnteredFormat.textFormat.strikethrough"
    }
    if ($PSBoundParameters.ContainsKey('Underline')) {
        $cell["userEnteredFormat"]["textFormat"]["underline"] = $Underline
        $fields += "userEnteredFormat.textFormat.underline"
    }

    if ($PSBoundParameters.ContainsKey('HorizontalAlignment')) {
        $cell["userEnteredFormat"]["horizontalAlignment"] = $HorizontalAlignment
        $fields += "userEnteredFormat.horizontalAlignment"
    }
    if ($PSBoundParameters.ContainsKey('VerticalAlignment')) {
        $cell["userEnteredFormat"]["verticalAlignment"] = $VerticalAlignment
        $fields += "userEnteredFormat.verticalAlignment"
    }
    if ($PSBoundParameters.ContainsKey('WrapStrategy')) {
        $cell["userEnteredFormat"]["wrapStrategy"] = $WrapStrategy
        $fields += "userEnteredFormat.wrapStrategy"
    }
    if ($PSBoundParameters.ContainsKey('WrapStrategy')) {
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

    if ($PSCmdlet.ShouldProcess("Format $A1Notation")) {
        Invoke-RestMethod @requestParams -Method POST @GDriveProxySettings
    }
}
