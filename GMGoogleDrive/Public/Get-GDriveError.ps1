<#
.SYNOPSIS
    Get GoogleDrive Error responce
.DESCRIPTION
    Get GoogleDrive Error responce
.PARAMETER Error
    Error record to decode
.PARAMETER Exception
    WebException object to decode
.OUTPUTS
    Json with error item as PSObject
.EXAMPLE
    try { Get-GDriveItemProperty -AccessToken 'error token' -id 'error id' } catch { $err = $_ }
    Get-GDriveError $err
.NOTES
    Author: Max Kozlov
.LINK
#>
function Get-GDriveError {
[CmdletBinding(DefaultParameterSetName='ex')]
param(
    [Parameter(Mandatory, Position=0, ParameterSetName='er')]
    [System.Management.Automation.ErrorRecord]$Error,

    [Parameter(Mandatory, Position=0, ParameterSetName='ex')]
    [System.Net.WebException]$Exception
)

    if ($Error) {
        $response = $Error.Exception.Response
    }
    else {
        $response = $Exception.Response
    }
    try {
        $Encoding = [Text.Encoding]::GetEncoding($response.CharacterSet)
    }
    catch {
        $Encoding = [Text.Encoding]::UTF8
    }
    try {
        Write-Verbose "StatusCode: $($response.StatusCode)"
        Write-Verbose "ContentLength: $($response.ContentLength)"
        Write-Verbose "ContentType: $($response.ContentType)"
        Write-Verbose "CharacterSet: $($response.CharacterSet)"
        $stream = $err.Exception.Response.GetResponseStream()
        try {
            $Encoding.GetString($stream.ToArray()) | ConvertFrom-Json
        }
        finally {
# ?
#            $stream.Close()
#            $stream.Dispose()
        }
    }
    finally {
# ?
#        $response.Close()
#        $response.Dispose()
    }
}
