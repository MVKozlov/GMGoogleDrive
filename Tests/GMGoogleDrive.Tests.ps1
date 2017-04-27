Set-StrictMode -Version latest
Import-Module $PSScriptRoot\..\GMGoogleDrive -Verbose -Force -ErrorAction Stop
$ErrorActionPreference = 'Stop'

Describe "Prerequisites" {
    Context "should have GDrive credential variables and proxy" {
        It 'should have OAuth credentials' {
            $oauth_json | Should Not BeNullOrEmpty
            $oauth_json.web | Should Not BeNullOrEmpty
            $oauth_json.web.client_id | Should Not BeNullOrEmpty
            $oauth_json.web.client_secret | Should Not BeNullOrEmpty
        }
        It 'should have refresh token' {
            $refresh    | Should Not BeNullOrEmpty
            $refresh.refresh_token  | Should Not BeNullOrEmpty
        }
        It 'Should create temp file' {
            $script:tmpfile = [IO.Path]::GetTempFileName()
            Test-Path $tmpfile | Should Be $true
        }
    }
}

Describe "GMGoogleDrive" {
    Context "misc" {
        It 'should load all functions' {
            $Commands = Get-Command -CommandType Function -Module GMGoogleDrive | Select-Object -ExpandProperty Name
            $Commands.Count | Should be 21
            $Commands -contains "Get-GDriveSummary"                 | Should be $True
            $Commands -contains "Add-GDriveItem"                    | Should be $True
            $Commands -contains "Copy-GDriveItem"                   | Should be $True
            $Commands -contains "Find-GDriveItem"                   | Should be $True
            $Commands -contains "Get-GDriveChildItem"               | Should be $True
            $Commands -contains "Get-GDriveItemContent"             | Should be $True
            $Commands -contains "Get-GDriveItemProperty"            | Should be $True
            $Commands -contains "Get-GDriveProxySetting"            | Should be $True
            $Commands -contains "Move-GDriveItem"                   | Should be $True
            $Commands -contains "New-GDriveFolder"                  | Should be $True
            $Commands -contains "New-GDriveItem"                    | Should be $True
            $Commands -contains "Remove-GDriveItem"                 | Should be $True
            $Commands -contains "Rename-GDriveItem"                 | Should be $True
            $Commands -contains "Get-GDriveAccessToken"             | Should be $True
            $Commands -contains "Request-GDriveAuthorizationCode"   | Should be $True
            $Commands -contains "Request-GDriveRefreshToken"        | Should be $True
            $Commands -contains "Revoke-GDriveToken"                | Should be $True
            $Commands -contains "Set-GDriveItemContent"             | Should be $True
            $Commands -contains "Set-GDriveItemProperty"            | Should be $True
            $Commands -contains "Set-GDriveProxySetting"            | Should be $True
            $Commands -contains "Get-GDriveError"                   | Should be $True
        }
    }
}

Describe "GDriveProxySetting" {
    Context "Add Proxy" {
        It "Should set proxy" {
            { Set-GDriveProxySetting -Proxy 'http://ya.ru:800/' } | Should Not Throw
        }
        It "Should get proxy" {
            { $script:proxy = Get-GDriveProxySetting } | Should Not Throw
            $proxy | Should Not BeNullOrEmpty
            $proxy.Proxy -is [Uri] | Should Be $true
            $proxy.Proxy.AbsoluteUri | Should Be 'http://ya.ru:800/'
        }
    }
    Context "Remove Proxy" {
        It "Should remove proxy" {
            { Set-GDriveProxySetting -Proxy $null } | Should Not Throw
        }
        It "Should get empty proxy" {
            { $script:proxy = Get-GDriveProxySetting } | Should Not Throw
            $proxy | Should Not BeNullOrEmpty
            $proxy.Proxy | Should BeNullOrEmpty
        }
    }
}

Describe "Request-GDriveAuthorizationCode" {
    It "Should be MANUAL operation and you lose your refresh token, so does NOT test it" -Skip {
        { $script:code = Request-GDriveAuthorizationCode -ClientID $oauth_json.web.client_id -ClientSecret $oauth_json.web.client_secret -Automatic } | Should Not Throw
        $code | Should Not BeNullOrEmpty
    }
}
Describe "Request-GDriveRefreshToken" {
    It "Should be MANUAL operation and you lose your refresh token, so does NOT test it" -Skip {
        { $global:refresh = Request-GDriveRefreshToken -ClientID $oauth_json.web.client_id -ClientSecret $oauth_json.web.client_secret -AuthorizationCode $code } | Should Not Throw
        $refresh    | Should Not BeNullOrEmpty
        $refresh.refresh_token  | Should Not BeNullOrEmpty
    }
}
Describe "Get-GDriveAccessToken" {
    $params = @{
        ClientID = $oauth_json.web.client_id
        ClientSecret = $oauth_json.web.client_secret
        RefreshToken = $refresh.refresh_token
    }
    It "Should Request Access Token" {
        { $script:access = Get-GDriveAccessToken @params } | Should Not Throw
        $access | Should Not BeNullOrEmpty
        $access.access_token | Should Not BeNullOrEmpty
    }
}

Describe "Get-GDriveSummary" {
    It "should return drive summary" {
        { $script:summary = Get-GDriveSummary -AccessToken $access.access_token } | Should Not Throw
        $summary | Should Not BeNullOrEmpty
        $summary.rootFolderId | Should Not BeNullOrEmpty
    }
}

Describe "New-GDriveFolder" {
    It "should create test folder" {
        { $script:folder = New-GDriveFolder -AccessToken $access.access_token -Name "PesterTestFolder" } | Should Not Throw
        $folder | Should Not BeNullOrEmpty
        $folder.id | Should Not BeNullOrEmpty
        $folder.name | Should Be "PesterTestFolder"
        $folder.mimeType | Should Be "application/vnd.google-apps.folder"
    }
}
Describe "New-GDriveItem" {
    It "should create empty file" {
        { $script:file1 = New-GDriveItem -AccessToken $access.access_token -Name "PesterTestFile1" -ParentID $folder.id } | Should Not Throw
        $file1.id | Should Not BeNullOrEmpty
        $file1.name | Should Be "PesterTestFile1"
        $file1.mimeType | Should Be "application/octet-stream"
    }
}
Describe "Set-GDriveItemContent" {
    $params = @{
        AccessToken = $access.access_token
        ContentType = 'text/plain'
    }
    It "should set file1 content"  {
        { $script:file1c = Set-GDriveItemContent @params -ID $file1.id -StringContent 'test file1' | Select -Expand Item } | Should Not Throw
        $file1c | Should Not BeNullOrEmpty
        $file1c.id | Should Be $file1.id
    }
}

Describe "Add-GDriveItem" {
    $params = @{
        AccessToken = $access.access_token
        ParentID = $folder.id 
        ContentType = 'text/plain'
    }
    Context "string" {
        It "should create file from string" {
            { $script:file2 = Add-GDriveItem @params -Name "PesterTestFile2"  -StringContent 'test file2' | Select -Expand Item } | Should Not Throw
            $file2.id | Should Not BeNullOrEmpty
            $file2.name | Should Be "PesterTestFile2"
            $file2.mimeType | Should Be "text/plain"
        }
    }
    Context "byte[]" {
        It "should create file from byte[]" {
            { $script:file3 = Add-GDriveItem @params -Name "PesterTestFile3" -RawContent ([Text.Encoding]::Utf8.GetBytes('test file3')) | Select -Expand Item } | Should Not Throw
            $file3.id | Should Not BeNullOrEmpty
            $file3.name | Should Be "PesterTestFile3"
            $file3.mimeType | Should Be "text/plain"
        }
    }
    Context "file" {
        'test file4' | Set-Content -Path $tmpfile -Encoding ASCII
        It "should create file from file" {
            { $script:file4 = Add-GDriveItem @params -Name "PesterTestFile4" -InFile $tmpfile | Select -Expand Item } | Should Not Throw
            $file4.id | Should Not BeNullOrEmpty
            $file4.name | Should Be "PesterTestFile4"
            $file4.mimeType | Should Be "text/plain"
        }
    }
}
Describe "Set-GDriveItemProperty" {
        It "should set file1 description" {
            { Set-GDriveItemProperty -AccessToken $access.access_token -ID $file1.id -JsonProperty '{ "description": "file1 description" }' } | Should Not Throw
        }
}
Describe "Get-GDriveItemProperty" {
        It "should get file1 description" {
            { $script:file1d = Get-GDriveItemProperty -AccessToken $access.access_token -ID $file1.id -Property description } | Should Not Throw
            $file1d | Should Not BeNullOrEmpty
            $file1d.id | Should Be $file1.id
            $file1d.description | Should Be 'file1 description'
        }
}
Describe "Copy-GDriveItem" {
        It "should create file from existing item" {
            { $script:file5 = Copy-GDriveItem -AccessToken $access.access_token -ID $file1.id -Name "PesterTestFile1a" } | Should Not Throw
            $file5.id | Should Not BeNullOrEmpty
            $file5.name | Should Be "PesterTestFile1a"
        }
}
Describe "Rename-GDriveItem" {
        It "should rename file" {
            { $script:file5 = Rename-GDriveItem -AccessToken $access.access_token -ID $file5.id -NewName "PesterTestFile5" } | Should Not Throw
            $file5.id | Should Not BeNullOrEmpty
            $file5.name | Should Be "PesterTestFile5"
        }
}
Describe "Move-GDriveItem" {
        It "should move file1 to root" {
            { $script:file1a = Move-GDriveItem -AccessToken $access.access_token -ID $file1.id -NewParentID 'root' } | Should Not Throw
            $file1a.parents.Count | Should Be 1
            $file1a.parents[0] | Should Be $summary.rootFolderId
        }
}
Describe "Find-GDriveItem" {
        It "should find 5 files" {
            { $script:files = Find-GDriveItem -AccessToken $access.access_token -Query 'name contains "PesterTestFile"' } | Should Not Throw
            $files.files.Count | Should Be 5
        }
}
Describe "Get-GDriveChildItem" {
    It "should return item list" {
        { $script:list = Get-GDriveChildItem -AccessToken $access.access_token -ParentID $folder.id  } | Should Not Throw
        $list | Should Not BeNullOrEmpty
        $list.files | Should Not BeNullOrEmpty
        $list.files.Count | Should Be 4
    }
    It "should return item list (all)" {
        { $script:list = Get-GDriveChildItem -AccessToken $access.access_token -ParentID $folder.id -AllResults -PageSize 2 } | Should Not Throw
        $list | Should Not BeNullOrEmpty
        $list.files | Should Not BeNullOrEmpty
        $list.files.Count | Should Be 4
    }
}
Describe "Get-GDriveItemContent" {
    $params = @{
        AccessToken = $access.access_token
    }
    Context "string" {
        It "should get file content as string" {
            { $script:content = Get-GDriveItemContent @params -ID $file5.id } | Should Not Throw
            $content | Should Be 'test file1'
        }
        It "should get partial content as string" {
            { $script:content = Get-GDriveItemContent @params -ID $file5.id -Offset 3 -Length 5 } | Should Not Throw
            $content | Should Be 't fil'
        }
    }
    Context "byte[]" {
        It "should get file content as byte[]" {
            { $script:content = Get-GDriveItemContent @params -ID $file4.id -Raw } | Should Not Throw
            [Text.Encoding]::ASCII.GetString($content) | Should Be "test file4`r`n"
        }
    }
    Context "file" {
        'test file4' | Set-Content -Path $tmpfile
        It "should get file content and save it to file" {
            { Get-GDriveItemContent @params -ID $file3.id -OutFile $tmpfile } | Should Not Throw
            $content = Get-Content -Path $tmpfile
            $content | Should Be 'test file3'
        }
    }
}
Describe "Remove-GDriveItem" {
    Context "Remove Items" {
        It "should trash file1" {
            { Remove-GDriveItem -AccessToken $access.access_token -Confirm:$false -ID $file1.id } | Should Not Throw
            $f1 = Get-GDriveItemProperty -AccessToken $access.access_token -ID $file1.id -Property trashed
            $f1.trashed | Should Be $true
        }
        It "should remove file1" {
            { Remove-GDriveItem -AccessToken $access.access_token -Confirm:$false -ID $file1.id -Permanently } | Should Not Throw
            { Get-GDriveItemProperty -AccessToken $access.access_token -ID $file1.id } | Should Throw
        }
    }
    Context "Remove Folders" {
        It "should remove testfolder" {
            { Remove-GDriveItem -AccessToken $access.access_token -Confirm:$false -ID $folder.id -Permanently } | Should Not Throw
        }
        It "should not find testfolder" {
            $query = Find-GDriveItem -AccessToken $access.access_token -Query 'name="PesterTestFolder"'
            $query.files.Count | Should Be 0
        }
    }
}
Describe "Revoke-GDriveToken - you lose your refresh token, so does NOT test it" {
    It "should revoke access Token" -Skip {
        { Revoke-GDriveToken -Token $access.access_token -Confirm:$false } | Should Not Throw
    }
    It "should not retrieve files" -Skip {
        { Get-GDriveChildItem -AccessToken $access.access_token } | Should Throw
    }
}

Describe "Get-GDriveError" {
    It "should return RuntimeException error object" {
        try { throw 'err1' } catch { $err = $_ }
        { $script:rec = Get-GDriveError $err } | Should Not Throw
        $rec.Type | Should Not BeNullOrEmpty
        $rec.Type.FullName | Should Be 'System.Management.Automation.RuntimeException'
        $rec.StatusCode | Should BeNullOrEmpty
        $rec.Message | Should Be 'err1'
    }
    It "should return WebException error object" {
        try { invoke-restmethod http://ya.ru/notexistenturl } catch { $err = $_ }
        { $script:rec = Get-GDriveError $err -WarningAction SilentlyContinue } | Should Not Throw
        $rec.Type | Should Not BeNullOrEmpty
        $rec.Type.FullName | Should Be 'System.Net.WebException'
        $rec.StatusCode | Should Be 404
    }
    It "should return Fully decoded error object" {
        try { Get-GDriveItemProperty -AccessToken 'error token' -id 'error id' } catch { $err = $_ }
        { $script:rec = Get-GDriveError $err } | Should Not Throw
        $rec.Type | Should Not BeNullOrEmpty
        $rec.Type.FullName | Should Be 'System.Net.WebException'
        $rec.StatusCode | Should Be 401
        $rec.error | Should Not BeNullOrEmpty
        $rec.error.code | Should Be 401
    }
}

Describe "Remove temp file" {
    It "should remove temp file" {
        Remove-Item -Path $tmpfile
        Test-Path $tmpfile | Should Be $false
    }
}
