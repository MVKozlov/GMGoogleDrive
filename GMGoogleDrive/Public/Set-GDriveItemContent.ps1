<#
.SYNOPSIS
    Creates or updates GoogleDrive Item, set metadata and upload content
.DESCRIPTION
    Creates or updates GoogleDrive Item, set metadata and upload content
    If needed tp update existing file, use ID
    If only metadata update required, use Set-GDriveItemProperty
.PARAMETER ID
    File ID to update
.PARAMETER StringContent
    Content to upload as string
.PARAMETER Encoding
    Enconding used for string
.PARAMETER RawContent
    Content to upload as raw byte[] array
.PARAMETER InFile
    Content to upload as path to file
.PARAMETER Name
    Name of an item to be created
.PARAMETER ParentID
    Folder ID(s) in which new item will be placed
.PARAMETER JsonProperty
    Json-formatted string with all needed file metadata
.PARAMETER ResumeID
    Upload ID to resume operations in case of uploading errors
.PARAMETER ContentType
    Uploaded item Content type (seems google automatically set it to most of uploaded files)
.PARAMETER ChunkSize
    Upload request size
.PARAMETER ShowProgress
    Show progress bar while uploading
.PARAMETER AccessToken
    Access Token for request
.EXAMPLE
    #Named File based upload
    Set-GDriveItemContent -AccessToken $access_token -InFile D:\SomeDocument.doc -Name SomeDocument.doc
.EXAMPLE
    #Named Raw data upload with ParentID
    [byte[]]$Content = Get-Content D:\SomeDocument.doc -Encoding Bytes
    $ParentFolder = Find-GDriveItem -AccessToken $access_token -Query 'name="myparentfolder"'
    Set-GDriveItemContent -AccessToken $access_token -RawContent -Name SomeDocument.doc -ParentID $ParentFolder.files.id
.EXAMPLE
    #String based upload with metadata
    Add-GDriveItem -AccessToken $access_token -StringContent 'test file' -JsonProperty '{ "name":"myfile.txt" }'
.EXAMPLE
    #String based update upload
    Set-GDriveItemContent -AccessToken $access_token -ID '0BAjkl4cBDNVpVbB5nGhKQ195aU0' -StringContent 'test file'
.EXAMPLE
    #File based resume operation
    $Result = Set-GDriveItemContent -AccessToken $access_token -InFile D:\SomeDocument.doc -Name SomeDocument.doc
    if ($Result.Error) {
        Set-GDriveItemContent -AccessToken $access_token -InFile D:\SomeDocument.doc `
            -Name SomeDocument.doc -ResumeID $Result.ResumeID
    }
.OUTPUTS
    PSObject with properties:
        Item: Json with item metadata as PSObject
        ResultID: Upload ID for resume operations
        Error: Error info if happen
.NOTES
    Author: Max Kozlov
.LINK
    Add-GDriveItem
    Set-GDriveItemProperty
    https://developers.google.com/drive/v3/reference/files/create
    https://developers.google.com/drive/v3/reference/files/update
    https://developers.google.com/drive/v3/web/resumable-upload
#>
function Set-GDriveItemContent {
[CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Position=0, ParameterSetName='dataMeta')]
        [Parameter(Position=0, ParameterSetName='stringMeta')]
        [Parameter(Position=0, ParameterSetName='fileMeta')]
        [string]$ID,

        [Parameter(Mandatory, ParameterSetName='stringName')]
        [Parameter(Mandatory, ParameterSetName='stringMeta')]
        [string]$StringContent,
        [Parameter(ParameterSetName='stringName')]
        [Parameter(ParameterSetName='stringMeta')]
        [System.Text.Encoding]$Encoding = [System.Text.Encoding]::UTF8,

        [Parameter(Mandatory, ParameterSetName='dataName')]
        [Parameter(Mandatory, ParameterSetName='dataMeta')]
        [byte[]]$RawContent,

        [Parameter(Mandatory, ParameterSetName='fileName')]
        [Parameter(Mandatory, ParameterSetName='fileMeta')]
        [string]$InFile,

        [Parameter(Mandatory, ParameterSetName='dataName')]
        [Parameter(Mandatory, ParameterSetName='stringName')]
        [Parameter(Mandatory, ParameterSetName='fileName')]
        [string]$Name,

        [Parameter(ParameterSetName='dataName')]
        [Parameter(ParameterSetName='stringName')]
        [Parameter(ParameterSetName='fileName')]
        [Alias('DestinationID')]
        [string[]]$ParentID = @('root'),

        [Parameter(ParameterSetName='dataMeta')]
        [Parameter(ParameterSetName='stringMeta')]
        [Parameter(ParameterSetName='fileMeta')]
        [Alias('Metadata')]
        [string]$JsonProperty = '',

        [string]$ResumeID,

        [string]$ContentType = 'application/octet-stream',

        [ValidateScript({
            (-not ($_ -band 0x3FFFF)) -or ( & { throw 'ChunkSize must be in multiples of 256 KB (256 x 1024 bytes) in size' } )
        })]
        [int]$ChunkSize = 4Mb,

        [switch]$ShowProgress,

        [Parameter(Mandatory)]
        [string]$AccessToken
    )

    $UploadResult = [PSCustomObject]@{
        Item = $null
        ResumeID = ''
        Error = $null
    }

    if ($PSCmdlet.ParameterSetName -in 'stringName','stringMeta') {
        [byte[]]$RawContent = $Encoding.GetBytes($StringContent)
        Write-Verbose "Encoded $($StringContent.Length) characters to $($RawContent.Count) bytes ($($Encoding.EncodingName))"
    }
    if ($PSCmdlet.ParameterSetName -in 'stringName','dataName','fileName') {
        $JsonProperty = '{{ "name": "{0}", "parents": ["{1}"] }}' -f $Name, ($ParentID -join '","')
        Write-Verbose "Constructed Metadata: $JsonProperty"
    }
    try {
        if ($PSCmdlet.ParameterSetName -in 'fileName','fileMeta') {
            $stream = New-Object System.IO.FileStream $InFile, 'Open'
        }
        else {
            $stream = New-Object System.IO.MemoryStream $RawContent, $false
        }
    }
    catch {
        $UploadResult.Error = $_.Exception
        $UploadResult
        Write-Error $_.Exception
        return
    }
    try {
        $Headers = @{
            "Authorization"           = "Bearer $AccessToken"
            "Content-type"            = "application/json"
            "X-Upload-Content-Type"   = $ContentType
            "X-Upload-Content-Length" = $stream.Length
        }

        $WebRequestParams = @{
            Headers = $Headers
            MaximumRedirection  = 0
            UseBasicParsing = $true
            Body = $JsonProperty
        }

        if ($PSBoundParameters.ContainsKey('ID')) {
            Write-Verbose "Updating File $ID"
            # Patch instead of Put! docs are wrong? Put give 404
            $WebRequestParams.Method = 'Patch'
            $WebRequestParams.Uri = "$($GDriveUploadUri)$($ID)?uploadType=resumable&fields=kind,id,name,mimeType,parents"
        }
        else {
            Write-Verbose "Creating New file"
            $WebRequestParams.Method = 'Post'
            $WebRequestParams.Uri = "$($GDriveUploadUri)?uploadType=resumable&fields=kind,id,name,mimeType,parents"
        }
        Write-Verbose ("URI: " + $WebRequestParams.Uri)

        if ($ResumeID) {
            #To request the upload status, create an empty PUT request to the resumable session URI.
            Write-Verbose "Use Resume ID $ResumeID"
            $WebRequestParams.Uri += '&upload_id=' + $ResumeID
            $WebRequestParams.Method = 'Put'
            [void]$WebRequestParams.Remove('Body')
            $WebRequestParams.Headers['Content-Range'] = 'bytes */{0}' -f $stream.Length
        }
        Write-Verbose ('Metadata upload, resumable, {0} bytes, {1}' -f $stream.Length, $ContentType)
        $uploadString = 'Uploading ' + $PSCmdlet.ParameterSetName -replace '(Name|Meta)'
        if ($PSCmdlet.ParameterSetName -match 'Name')   { $uploadString += " named '$Name'" }
        if ($PSCmdlet.ParameterSetName -match 'file')   { $uploadString += " from [$InFile]" }
        elseif ($PSCmdlet.ParameterSetName -match 'string') { $uploadString += " from [string]" }
        elseif ($PSCmdlet.ParameterSetName -match 'data')   { $uploadString += " from [byte[] array]" }

        if ($ShowProgress) {
            Write-Progress -Activity $uploadString -Status 'Metadata upload' -PercentComplete 1
        }
        $wr = $null
        try {
            if ($PSCmdlet.ShouldProcess($ID, $uploadString)) {
                $wr = Invoke-WebRequest @WebRequestParams @GDriveProxySettings
            }
        }
        catch {
            $UploadResult.Error = $_.Exception
            $UploadResult
            Write-Error $_.Exception
            return
        }

        if ($wr.StatusCode -in 200,308) {
            $UploadResult.ResumeID = $wr.Headers['X-GUploader-UploadID']
            Write-Verbose "ResumeID: $($UploadResult.ResumeID)"
            try {
                # Resume already have the right URI
                if ($wr.Headers['Location']) {
                    $WebRequestParams['Uri'] = $wr.Headers['Location']
                }

                [long]$UploadedSize = 0
                Write-Verbose "Received Range: $($wr.Headers['Range'])"
                if ($wr.Headers['Range'] -match 'bytes=(\d+)-(\d+)')
                {
                    $UploadedSize = ([long]$matches[2]) + 1
                    Write-Verbose "Stream Position: $($stream.Position), UploadedSize:$($UploadedSize)"
                    if ($stream.Position -ne $UploadedSize)
                    {
                        Write-Verbose "Fast Forward to:$($UploadedSize)"
                        [void]$stream.Seek($UploadedSize, [System.IO.SeekOrigin]::Begin)
                    }
                }
                $WebRequestParams.Method = 'Put'

                if ($PSCmdlet.ShouldProcess($ID, $uploadString)) {
                    if ($UploadedSize -eq 0 -and
                        $stream.Length -le $ChunkSize -and
                        ($PSCmdlet.ParameterSetName -notin 'fileName','fileMeta'))
                    {
                        Write-Verbose 'Single request upload'
                        $WebRequestParams.Headers = @{
                            "Authorization"  = "Bearer $AccessToken"
                            "Content-Type"   = $ContentType
                            "Content-Length" = $stream.Length
                        }
                        $WebRequestParams.Body = $RawContent

                        Write-Verbose ("Content-Length: {0}" -f $WebRequestParams.Headers['Content-Length'])
                        if ($ShowProgress) {
                            Write-Progress -Activity $uploadString -Status "Content upload [0-$($stream.Length)/$($stream.Length)]" -PercentComplete 99
                        }
                        $wr = Invoke-WebRequest @WebRequestParams @GDriveProxySettings
                    }
                    else {
                        Write-Verbose 'Multiple requests upload'
                        [byte[]]$buffer = New-Object byte[] $ChunkSize
                        do {
                            [long]$nextSize = [Math]::Min($UploadedSize + $ChunkSize, $stream.Length)
                            $Range = "bytes $($UploadedSize)-$($nextSize-1)/$($stream.Length)"
                            $Length = [Math]::Min($stream.Length - $UploadedSize, $ChunkSize)
                            $WebRequestParams.Headers = @{
                                "Authorization"  = "Bearer $AccessToken"
                                "Content-Type"   = $ContentType
                                "Content-Range"  = $Range
                                "Content-Length" = $Length
                            }
                            # last buffer can be smaller
                            if ($Length -lt $ChunkSize) {
                                [byte[]]$buffer = New-Object byte[] $Length
                            }
                            $len = $stream.Read($buffer, 0, $Length);
                            if ($len -ne $Length) {
                                throw "Stream read error: Readed $len bytes instead of $Length"
                            }
                            $WebRequestParams.Body = $buffer
                            Write-Verbose ("Content-Length: {0}, Content-Range {1}, readed: {2}" -f $WebRequestParams.Headers["Content-Length"], $WebRequestParams.Headers['Content-Range'], $len)
                            if ($ShowProgress) {
                                Write-Progress -Activity $uploadString -Status "Content upload [$($Range -replace 'bytes ')]" -PercentComplete ($nextSize*100/$stream.Length)
                            }
                            $wr = Invoke-WebRequest @WebRequestParams @GDriveProxySettings
                            switch ($wr.StatusCode) {
                                308 {
                                        # bytes=0-262143
                                        Write-Verbose "Received Range: $($wr.Headers['Range'])"
                                        if ($wr.Headers['Range'] -match 'bytes=(\d+)-(\d+)')
                                        {
                                            $UploadedSize = ([long]$matches[2]) + 1
                                            Write-Verbose "Stream Position: $($stream.Position), UploadedSize:$($UploadedSize)"
                                            if ($stream.Position -ne $UploadedSize)
                                            {
                                                Write-Verbose "Fast Forward to:$($UploadedSize)"
                                                [void]$stream.Seek($UploadedSize, [System.IO.SeekOrigin]::Begin)
                                            }
                                        }
                                    }
                            }
                        } until ($wr.StatusCode -eq 200)
                    }
                    $UploadResult.Item = ($wr.Content | ConvertFrom-Json)
                }
                $UploadResult
            }
            catch {
                $UploadResult.Error = $_.Exception
                $UploadResult
                   Write-Error $_.Exception
            }
        }
    }
    finally {
        $stream.Close()
        $stream.Dispose()
    }
}
