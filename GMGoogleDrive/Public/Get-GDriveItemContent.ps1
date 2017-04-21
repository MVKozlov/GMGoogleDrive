<#
.SYNOPSIS
    Get GoogleDrive Item content
.DESCRIPTION
    Get GoogleDrive Item content
    Content can be returned as string, as byte[] array or saved to file
.PARAMETER ID
    File ID to return content from
.PARAMETER OutFile
    Save content into file path
.PARAMETER Raw
    Return content as raw byte[] array
.PARAMETER Offset
    Set Offset from which content will be returned, 0 of not set
.PARAMETER Length
    Set Length of content will be returned, full file if not set
.PARAMETER Encoding
    Set output encoding if content will be returned as string.
    By default used GoodleDrive supplied encoding 
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    # return string with file contents
    Get-GDriveItemContent -AccessToken $access_token -ID '0BAjkl4cBDNVpVbB5nGhKQ195aU0'
.EXAMPLE
    # return string with file contents in 866 encoding
    Get-GDriveItemContent -AccessToken $access_token -ID '0BAjkl4cBDNVpVbB5nGhKQ195aU0' -Encoding ([Text.Encoding]::GetEncoding(866))
.EXAMPLE
    # return byte[] with file contents
    Get-GDriveItemContent -AccessToken $access_token -ID '0BAjkl4cBDNVpVbB5nGhKQ195aU0' -Raw
.EXAMPLE
    # save fine content to file
    Get-GDriveItemContent -AccessToken $access_token -ID '0BAjkl4cBDNVpVbB5nGhKQ195aU0' -OutFile D:\test.txt
.OUTPUTS
    string
    byte[]
    file    
.NOTES
    Author: Max Kozlov
.LINK
    Get-GDriveItemProperty
    Set-GDriveItemContent
    https://developers.google.com/drive/v3/reference/files/get
    https://developers.google.com/drive/v3/web/manage-downloads
#>
function Get-GDriveItemContent {
[CmdletBinding(DefaultParameterSetName='String')]
param(
    [Parameter(Mandatory, Position=0)]
    [string]$ID,

    [Parameter(ParameterSetName='File')]
    [string]$OutFile,

    [Parameter(ParameterSetName='Raw')]
    [switch]$Raw,

    [int64]$Offset,
    [int64]$Length,

    [Parameter(ParameterSetName='String')]
    [System.Text.Encoding]$Encoding,

    [Parameter(Mandatory)]
    [string]$AccessToken
)

    $Uri = '{0}{1}?{2}' -f $GDriveUri, $ID, 'alt=media&mimeType=application/octet-stream'
    $wr = [System.Net.HttpWebRequest]::Create($Uri)
    if ($GDriveProxySettings.Proxy) {
        $proxy = New-Object System.Net.WebProxy $GDriveProxySettings.Proxy
        if ($GDriveProxySettings.ProxyUseDefaultCredentials) {
            $proxy.UseDefaultCredentials = $true
        }
        if ($GDriveProxySettings.ProxyCredential) {
            $proxy.Credentials = $GDriveProxySettings.ProxyCredential
        }
        $wr.Proxy = $proxy
    }

    $wr.Method = 'Get'
    $wr.ContentType = "application/json"
    $wr.Headers.Add("Authorization", "Bearer $($AccessToken)")
    Write-Verbose "ParameterSetName: $($PSCmdlet.ParameterSetName)"
    Write-Verbose "Content Url: $Uri"
    if ($PSBoundParameters.ContainsKey('Offset') -and $PSBoundParameters.ContainsKey('Length')) {
        $wr.AddRange($Offset, $Offset + $Length - 1)
        Write-Verbose "Range: $($wr.Headers['Range'])"
    }

    try {
        $response = $wr.GetResponse()
    }
    catch {
        Write-Error $_.Exception
        return
    }
    try {
        Write-Verbose "StatusCode: $($response.StatusCode)"
        Write-Verbose "ContentLength: $($response.ContentLength)"
        Write-Verbose "ContentType: $($response.ContentType)"
        Write-Verbose "CharacterSet: $($response.CharacterSet)"
        if ($response.StatusCode -in 'PartialContent','OK') {
            $resp_stream = $response.GetResponseStream()
            try {
                if ($PSCmdlet.ParameterSetName -eq 'File') {
                    Write-Verbose "Save to file $OutFile"
                    $stream = New-Object System.IO.FileStream $OutFile, 'Create'
                }
                else {
                    Write-Verbose "Save to memory"
                    $stream = New-Object System.IO.MemoryStream
                }
                if ($stream) {
                    try {
                        $resp_stream.CopyTo($stream)
                        if ($PSCmdlet.ParameterSetName -ne 'File') {
                            $buffer = $stream.ToArray()
                            if ($Raw) {
                                Write-Verbose "Memory to raw byte[]"
                                $buffer
                            }
                            else {
                                try {
                                    if (-not $PSBoundParameters.ContainsKey('Encoding')) {
                                        $Encoding = [System.Text.Encoding]::GetEncoding($response.CharacterSet)
                                    }
                                }
                                catch {
                                    $Encoding = [System.Text.Encoding]::UTF8
                                    Write-Warning "Encoding can't be determined from `"$($response.CharacterSet)`", use default `"$($Encoding.EncodingName)`""
                                }
                                Write-Verbose "Memory to string, encoding $($Encoding.EncodingName)"
                                $Encoding.GetString($buffer)
                            }
                        }
                    }
                    finally {
                        $stream.Close()
                        $stream.Dispose()
                    }
                }
                else {
                    Write-Error 'Can''t create stream'
                }
            }
            finally {
                $resp_stream.Close()
                $resp_stream.Dispose()
            }
        }
        else {
            Write-Error $response.StatusDescription
        }
    }
    finally {
        $response.Close()
        $response.Dispose()
    }
}
