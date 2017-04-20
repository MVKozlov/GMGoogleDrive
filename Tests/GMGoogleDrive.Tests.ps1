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
            $Commands.Count | Should be 20
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
            $Commands -contains "Request-GDriveAccessToken"         | Should be $True
            $Commands -contains "Request-GDriveAuthorizationCode"   | Should be $True
            $Commands -contains "Request-GDriveRefreshToken"        | Should be $True
            $Commands -contains "Revoke-GDriveToken"                | Should be $True
            $Commands -contains "Set-GDriveItemContent"             | Should be $True
            $Commands -contains "Set-GDriveItemProperty"            | Should be $True
            $Commands -contains "Set-GDriveProxySetting"            | Should be $True
        }
    }
}

Describe "GDriveProxySetting"         {
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

Describe "Request-GDriveAuthorizationCode"{
    It "Does not test it" -Skip {
        $true | Should Be $false
    }
}
Describe "Request-GDriveRefreshToken"     {
    It "Does not test it" -Skip {
        $true | Should Be $false
    }
}
Describe "Request-GDriveAccessToken"      {
    $params = @{
        ClientID = $oauth_json.web.client_id
        ClientSecret = $oauth_json.web.client_secret
        RefreshToken = $refresh.refresh_token
    }
    It "Should Request Access Token" {
        { $script:access = Request-GDriveAccessToken @params } | Should Not Throw
        $access | Should Not BeNullOrEmpty
        $access.access_token | Should Not BeNullOrEmpty
    }
}

Describe "Get-GDriveSummary"              {
    It "should return drive summary" {
        { $script:summary = Get-GDriveSummary -AccessToken $access.access_token } | Should Not Throw
        $summary | Should Not BeNullOrEmpty
        $summary.rootFolderId | Should Not BeNullOrEmpty
    }
}

Describe "Get-GDriveChildItem"            {
    It "should return item list" {
        { $script:list = Get-GDriveChildItem -AccessToken $access.access_token } | Should Not Throw
        $list | Should Not BeNullOrEmpty
        $list.files | Should Not BeNullOrEmpty
    }
}
Describe "New-GDriveFolder"               {
    It "should create test folder" {
        { $script:folder = New-GDriveFolder -AccessToken $access.access_token -Name "PesterTestFolder" } | Should Not Throw
        $folder | Should Not BeNullOrEmpty
        $folder.id | Should Not BeNullOrEmpty
        $folder.name | Should Be "PesterTestFolder"
        $folder.mimeType | Should Be "application/vnd.google-apps.folder"
    }
}
Describe "New-GDriveItem"                 {
    It "should create empty file" {
        { $script:file1 = New-GDriveItem -AccessToken $access.access_token -Name "PesterTestFile1" -ParentID $folder.id } | Should Not Throw
        $file1.id | Should Not BeNullOrEmpty
        $file1.name | Should Be "PesterTestFile1"
        $file1.mimeType | Should Be "application/octet-stream"
    }
}

Describe "Add-GDriveItem"                 {
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
        'test file4' | Set-Content -Path $tmpfile
        It "should create file from file" {
            { $script:file4 = Add-GDriveItem @params -Name "PesterTestFile4" -InFile $tmpfile | Select -Expand Item } | Should Not Throw
            $file4.id | Should Not BeNullOrEmpty
            $file4.name | Should Be "PesterTestFile4"
            $file4.mimeType | Should Be "text/plain"
        }
    }
}
Describe "Set-GDriveItemProperty"         {
}
Describe "Get-GDriveItemProperty"         {
}
Describe "Copy-GDriveItem"                {
        It "should create file from existing item" {
            { $script:file5 = Copy-GDriveItem -AccessToken $access.access_token -ID $file1.id -Name "PesterTestFile1a" } | Should Not Throw
            $file5.id | Should Not BeNullOrEmpty
            $file5.name | Should Be "PesterTestFile1a"
        }
}
Describe "Rename-GDriveItem"              {
        It "should rename file" {
            { $script:file5 = Rename-GDriveItem -AccessToken $access.access_token -ID $file5.id -NewName "PesterTestFile5" } | Should Not Throw
            $file5.id | Should Not BeNullOrEmpty
            $file5.name | Should Be "PesterTestFile5"
        }
}
Describe "Find-GDriveItem"                {
        It "should find 5 files" {
            { $script:files = Find-GDriveItem -AccessToken $access.access_token -Query 'name contains "PesterTestFile"' } | Should Not Throw
            $files.files.Count | Should Be 5
        }
}
Describe "Get-GDriveItemContent"          {
}
Describe "Set-GDriveItemContent"          {
}
Describe "Move-GDriveItem"                {
        It "should move file1 to root" {
            { $script:file1a = Move-GDriveItem -AccessToken $access.access_token -ID $file1.id -NewParentID 'root' } | Should Not Throw
            $file1a.parents.Count | Should Be 1
            $file1a.parents[0] | Should Be $summary.rootFolderId
        }
}
Describe "Remove-GDriveItem"              {
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
Describe "Revoke-GDriveToken - not test it because revoke ANY token leads to revoking all tokens" {
    It "should revoke access Token" -Skip {
        { Revoke-GDriveToken -Token $access.access_token -Confirm:$false } | Should Not Throw
    }
    It "should not retrieve files" -Skip {
        { Get-GDriveChildItem -AccessToken $access.access_token } | Should Throw
    }
}

Describe "Remove temp file" {
    It "should remove temp file" {
        Remove-Item -Path $tmpfile
        Test-Path $tmpfile | Should Be $false
    }
}