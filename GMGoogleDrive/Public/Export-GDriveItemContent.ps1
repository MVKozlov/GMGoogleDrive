<#
.SYNOPSIS
    Export GoogleDrive Item content
.DESCRIPTION
    Exports a Google Workspace document to the requested MIME type and returns exported byte content
    Note that the exported content is limited to 10MB.
    Content can be returned as string, as byte[] array or saved to file
.PARAMETER ID
    The ID of the file
.PARAMETER OutFile
    Save content into file path
.PARAMETER Raw
    Return content as raw byte[] array
.PARAMETER Encoding
    Set output encoding if content will be returned as string.
    By default used GoodleDrive supplied encoding 
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    # return string with exported file contents
    Export-GDriveItemContent -AccessToken $access_token -ID '0BAjkl4cBDNVpVbB5nGhKQ195aU0' -ContentType 'application/pdf'
.OUTPUTS
    string
    byte[]
    file
.NOTES
    Author: Max Kozlov
.LINK
    Get-GDriveItemContent
    Set-GDriveItemContent
    https://developers.google.com/drive/api/v3/reference/files/export
    https://developers.google.com/drive/api/guides/manage-downloads#download_a_document
    https://developers.google.com/drive/api/guides/ref-export-formats
#>
function Export-GDriveItemContent {
[CmdletBinding(DefaultParameterSetName='String')]
param(
    [Parameter(Mandatory, Position=0)]
    [string]$ID,

    [ValidateSet(
        # Google Doc Format
        # Corresponding MIME type    	            Conversion Format
        # Documents
        'text/html',                                # HTML
        'application/zip',                          # HTML (zipped)
        'text/plain',                               # Plain text
        'application/rtf',                          # Rich text
        'application/vnd.oasis.opendocument.text',  # Open Office doc
        'application/pdf',                          # PDF
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',      # MS Word document
        'application/epub+zip',                                                         # EPUB
        # Spreadsheets
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',            # MS Excel
        'application/x-vnd.oasis.opendocument.spreadsheet',                             # Open Office sheet
        #'application/pdf',                         # PDF
        'text/csv',                                 # CSV (first sheet only)
        'text/tab-separated-values',                # (sheet only)
        #'application/zip',                         # HTML (zipped)
        # Drawings
        'image/jpeg',                               # JPEG
        'image/png',                                # PNG
        'image/svg+xml',                            # SVG
        #'application/pdf',                         # PDF
        # Presentations
        'application/vnd.openxmlformats-officedocument.presentationml.presentation',    # MS PowerPoint
        'application/vnd.oasis.opendocument.presentation',                              # Open Office presentation
        #'application/pdf',                         # PDF
        #'text/plain',                              # Plain text
        # Apps Scripts
        'application/vnd.google-apps.script+json'   # JSON
    )]
    [string]$ContentType = 'text/plain',

    [Parameter(ParameterSetName='File')]
    [string]$OutFile,

    [Parameter(ParameterSetName='Raw')]
    [switch]$Raw,

    [Parameter(ParameterSetName='String')]
    [System.Text.Encoding]$Encoding,

    [Parameter(Mandatory)]
    [string]$AccessToken
)
    $Uri = '{0}{1}/export?mimeType={2}' -f $GDriveUri, $ID, $ContentType
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
    $wr.ContentType = "application/json; charset=utf-8"
    $wr.Headers.Add("Authorization", "Bearer $($AccessToken)")
    Write-Verbose "ParameterSetName: $($PSCmdlet.ParameterSetName)"
    Write-Verbose "Content Url: $Uri"

    $response = $wr.GetResponse() # no ErrorAction=Continue support, but can decode error
    try {
        Write-Verbose "StatusCode: $($response.StatusCode)"
        Write-Verbose "ContentLength: $($response.ContentLength)"
        Write-Verbose "ContentType: $($response.ContentType)"
        Write-Verbose "CharacterSet: $($response.CharacterSet)"
        if ($response.StatusCode -in 'PartialContent', 'OK') {
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
