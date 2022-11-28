<#
.SYNOPSIS
    Get GoogleDrive Error responce
.DESCRIPTION
    Get GoogleDrive Error responce
.PARAMETER ErrorRecord
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
    https://developers.google.com/drive/api/guides/handle-errors
#>
function Get-GDriveError {
[CmdletBinding(DefaultParameterSetName='ex')]
param(
    [Parameter(Mandatory, Position=0, ParameterSetName='er')]
    [System.Management.Automation.ErrorRecord]$ErrorRecord,

    [Parameter(Mandatory, Position=0, ParameterSetName='ex')]
    [Exception]$Exception
)
    $result = [PSCustomObject]@{
        Type = $null
        StatusCode = $null
        Message = ''
        Error = ''
        Response = $null
        Location = ''
    }
    function decodeException($Exception) {
        if ($Exception -is [System.Net.WebException]) {
            $response = $Exception.Response
            $result.Response = $Exception.Response
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
                $ms = New-Object System.IO.MemoryStream # supports [System.Net.Http.HttpConnection+ChunkedEncodingReadStream]
                try {
                    $stream.CopyTo($ms)
                    $result.Error = $Encoding.GetString($ms.ToArray())
                    try {
                        $result.Error = $result.Error | ConvertFrom-Json | Select-Object -ExpandProperty error
                    }
                    catch {
                        Write-Warning "Can't decode error from json"
                    }
                }
                finally {
                    $ms.Dispose()
                    #? $stream.Close()
                    #? $stream.Dispose()
                }
            }
            finally {
                #? $response.Close()
                #? $response.Dispose()
            }

        }
        elseif ('System.Net.Http.HttpRequestException' -in $Exception.psobject.TypeNames) {
			$response = $Exception.Response
            $result.Response = $Exception.Response
            $result.StatusCode = [int]$response.StatusCode
            $result.Message = $Exception.Message
			$result.Location = if ($Exception.Response.Headers.Location) { $Exception.Response.Headers.Location.ToString() } else { '' }
            if ($ErrorRecord -and $ErrorRecord.ErrorDetails) {
                $result.Error = $ErrorRecord.ErrorDetails.Message
                try {
                    $result.Error = $result.Error | ConvertFrom-Json | Select-Object -ExpandProperty error
                }
                catch {
                    Write-Warning "Can't decode error from json"
                }
            }
        }
    }
    if ($ErrorRecord) {
        $Exception = $ErrorRecord.Exception
    }
    while ($Exception) {
        $result.Type = $Exception.GetType()
        $result.Message = $Exception.Message
        decodeException $Exception
        $Exception = $Exception.InnerException
    }
    $result
}
