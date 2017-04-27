<#
.SYNOPSIS
    Get GoogleDrive Error responce
.DESCRIPTION
    Get GoogleDrive Error responce
.PARAMETER Error
    Error record to decode
.PARAMETER Exception
    Exception object to decode
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
    [Exception]$Exception
)
    $result = [PSCustomObject]@{
        Type = $null
        StatusCode = $null
        Message = ''
        Error = ''
    }
    if ($Error) {
        $Exception = $Error.Exception
    }
    if ($Exception) {
        $result.Type = $Exception.GetType()
        $result.Message = $Exception.Message
        if ($Exception -is [System.Net.WebException]) {
            $response = $Exception.Response
            $result.StatusCode = $response.StatusCode
            $result.Message = $response.StatusDescription
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
                $stream = $response.GetResponseStream()

                try {
                    $s = $Encoding.GetString($stream.ToArray())
                    try {
                        $result.Error = $s | ConvertFrom-Json | Select-Object -ExpandProperty error
                    }
                    catch {
                        Write-Warning "Can't decode error"
                    }
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
    }
    $result
}
