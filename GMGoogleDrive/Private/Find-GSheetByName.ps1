function Find-GSheetByName {
    param(
        [Parameter(Mandatory)]
        [ValidatePattern('^[a-zA-Z0-9-_]+$')]
        [string]$SpreadsheetId,

        [Parameter(Mandatory)]
        [string]$SheetName,

        [Parameter(Mandatory)]
        [string]$AccessToken
    )
    $SpreadsheetMeta = Get-GSheetsSpreadsheet -AccessToken $AccessToken -SpreadsheetId $SpreadsheetId
    $sheet = $SpreadsheetMeta.sheets.properties | Where-Object { $_.title -eq $SheetName }
    if($null -eq $sheet) {
        throw "SheetName $SheetName not found"
    }
    Write-Verbose "Found $SheetName as $($sheet.SheetId)"
    $sheet.SheetId
}
