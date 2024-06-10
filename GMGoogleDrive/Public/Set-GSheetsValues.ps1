<#
.SYNOPSIS
    
.DESCRIPTION
    
.PARAMETER AccessToken
    Access Token for request
.PARAMETER SpreadsheetId
    SpreadsheetId file id
.EXAMPLE

.OUTPUTS
    
.NOTES
    Author: Jan Elhaus
.LINK

#>
function Set-GSheetsValues {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$AccessToken,

        [Parameter(Mandatory)]
        [ValidatePattern('([a-zA-Z0-9-_]+)')]
        [string]$SpreadsheetId,

        [Parameter(Mandatory)]
        [string]$A1Notation,
        
        [Parameter(Mandatory)]
        [array[]]$Values,

        [ValidateSet("RAW","USER_ENTERED")]
        [string]$ValueInputOption = "RAW",

        [switch]$Append
    )

    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }

    $requestParams = @{
        Uri = $GDriveSheetsUri + "/" + $SpreadsheetId + "/values/" + $A1Notation + "?valueInputOption=" + $ValueInputOption
        Headers = $Headers
        ContentType = "application/json; charset=utf-8"
        Body = @{
            values = $Values
        } | ConvertTo-Json -Compress
    }

    if($Append) {
        $requestParams["Uri"] = $GDriveSheetsUri + "/" + $SpreadsheetId + "/values/" + $A1Notation + ":append?valueInputOption=" + $ValueInputOption
        $requestParams["Method"] = "POST"
    } else {
        $requestParams["Uri"] = $GDriveSheetsUri + "/" + $SpreadsheetId + "/values/" + $A1Notation + "?valueInputOption=" + $ValueInputOption
        $requestParams["Method"] = "PUT"
    }

    Write-Verbose "Webrequest Uri: $($requestParams.Uri)"
    Write-Verbose "Webrequest Body: $($requestParams.Body)"

    Invoke-RestMethod @requestParams @GDriveProxySettings
    
    
}
    