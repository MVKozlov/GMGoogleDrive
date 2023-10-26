BeforeAll {
    Set-StrictMode -Version latest
    Import-Module $PSScriptRoot\..\GMGoogleDrive -Verbose -Force -ErrorAction Stop
    $ErrorActionPreference = 'Stop'
    $global:tmpfile = [IO.Path]::GetTempFileName()
}

Describe "Prerequisites" {
    Context "should have GDrive credential variables and proxy" {
        It 'should have OAuth credentials' {
            $global:oauth_json | Should -Not -BeNullOrEmpty
            $oauth_json.web | Should -Not -BeNullOrEmpty
            $oauth_json.web.client_id | Should -Not -BeNullOrEmpty
            $oauth_json.web.client_secret | Should -Not -BeNullOrEmpty
        }
        It 'should have refresh token' {
            $global:refresh    | Should -Not -BeNullOrEmpty
            $refresh.refresh_token  | Should -Not -BeNullOrEmpty
        }
    }
}

Describe "GMGoogleDrive" {
    Context "misc" {
        It 'should load all functions' {
            $Commands = Get-Command -CommandType Function -Module GMGoogleDrive | Select-Object -ExpandProperty Name
            $Commands.Count | Should -Be 43
            $Commands -contains 'Request-GDriveAuthorizationCode' | Should -Be $True
            $Commands -contains 'Request-GDriveRefreshToken'      | Should -Be $True
            $Commands -contains 'Get-GDriveAccessToken'           | Should -Be $True
            $Commands -contains 'Revoke-GDriveToken'              | Should -Be $True
        
            $Commands -contains 'Get-GDriveSummary'               | Should -Be $True
            $Commands -contains 'Get-GDriveError'                 | Should -Be $True
        
            $Commands -contains 'Find-GDriveItem'                 | Should -Be $True
            $Commands -contains 'Get-GDriveChildItem'             | Should -Be $True
            $Commands -contains 'New-GDriveFolder'                | Should -Be $True
            $Commands -contains 'New-GDriveItem'                  | Should -Be $True
            $Commands -contains 'New-GDriveShortcut'              | Should -Be $True
            $Commands -contains 'Add-GDriveItem'                  | Should -Be $True
            $Commands -contains 'Add-GDriveFolder'                | Should -Be $True
        
            $Commands -contains 'Get-GDriveItemContent'           | Should -Be $True
            $Commands -contains 'Get-GDriveItemProperty'          | Should -Be $True
            $Commands -contains 'Get-GDriveItemRevisionList'      | Should -Be $True
            $Commands -contains 'Set-GDriveItemContent'           | Should -Be $True
            $Commands -contains 'Set-GDriveItemProperty'          | Should -Be $True
        
            $Commands -contains 'Move-GDriveItem'                 | Should -Be $True
            $Commands -contains 'Rename-GDriveItem'               | Should -Be $True
            $Commands -contains 'Copy-GDriveItem'                 | Should -Be $True
            $Commands -contains 'Remove-GDriveItem'               | Should -Be $True
            $Commands -contains 'Restore-GDriveItem'              | Should -Be $True
            $Commands -contains 'Clear-GDriveTrash'               | Should -Be $True
        
            $Commands -contains 'Get-GDriveProxySetting'          | Should -Be $True
            $Commands -contains 'Set-GDriveProxySetting'          | Should -Be $True
        }
    }
}

Describe "GDriveProxySetting" {
    Context "Add Proxy" {
        It "should set proxy" {
            { Set-GDriveProxySetting -Proxy 'http://ya.ru:800/' } | Should -Not -Throw
        }
        It "should get proxy" {
            { $script:proxy = Get-GDriveProxySetting } | Should -Not -Throw
            $proxy | Should -Not -BeNullOrEmpty
            $proxy.Proxy -is [Uri] | Should -Be $true
            $proxy.Proxy.AbsoluteUri | Should -Be 'http://ya.ru:800/'
        }
    }
    Context "Remove Proxy" {
        It "should remove proxy" {
            { Set-GDriveProxySetting -Proxy $null } | Should -Not -Throw
        }
        It "should get empty proxy" {
            { $script:proxy = Get-GDriveProxySetting } | Should -Not -Throw
            $proxy | Should -Not -BeNullOrEmpty
            $proxy.Proxy | Should -BeNullOrEmpty
        }
    }
}

Describe "Request-GDriveAuthorizationCode" {
    It "should be MANUAL operation and you lose your refresh token, so does NOT test it" -Skip {
        { $script:code = Request-GDriveAuthorizationCode -ClientID $oauth_json.web.client_id -ClientSecret $oauth_json.web.client_secret -Automatic } | Should -Not -Throw
        $code | Should -Not -BeNullOrEmpty
    }
}
Describe "Request-GDriveRefreshToken" {
    It "should be MANUAL operation and you lose your refresh token, so does NNOT test it" -Skip {
        { $global:refresh = Request-GDriveRefreshToken -ClientID $oauth_json.web.client_id -ClientSecret $oauth_json.web.client_secret -AuthorizationCode $code } | Should -Not -Throw
        $refresh    | Should -Not -BeNullOrEmpty
        $refresh.refresh_token  | Should -Not -BeNullOrEmpty
    }
}
Describe "Get-GDriveAccessToken" {
    BeforeAll {
        $params = @{
            ClientID = $oauth_json.web.client_id
            ClientSecret = $oauth_json.web.client_secret
            RefreshToken = $refresh.refresh_token
        }
    }
    It "Should Request Access Token" {
        { $script:access = Get-GDriveAccessToken @params } | Should -Not -Throw
        $access | Should -Not -BeNullOrEmpty
        $access.access_token | Should -Not -BeNullOrEmpty
    }
}

Describe "Get-GDriveSummary" {
    It "should return drive summary" {
        { $script:summary = Get-GDriveSummary -AccessToken $access.access_token } | Should -Not -Throw
        $summary | Should -Not -BeNullOrEmpty
        $summary.rootFolderId | Should -Not -BeNullOrEmpty
    }
}

Describe "New-GDriveFolder" {
    It "should create test folder" {
        { $script:folder = New-GDriveFolder -AccessToken $access.access_token -Name "PesterTestFolder" } | Should -Not -Throw
        $folder | Should -Not -BeNullOrEmpty
        $folder.id | Should -Not -BeNullOrEmpty
        $folder.name | Should -Be "PesterTestFolder"
        $folder.mimeType | Should -Be "application/vnd.google-apps.folder"
    }
}
Describe "New-GDriveItem" {
    It "should create empty file" {
        { $script:file1 = New-GDriveItem -AccessToken $access.access_token -Name "PesterTestFile1" -ParentID $folder.id } | Should -Not -Throw
        $file1.id | Should -Not -BeNullOrEmpty
        $file1.name | Should -Be "PesterTestFile1"
        $file1.mimeType | Should -Be "application/octet-stream"
    }
}

Describe "New-GDriveShortcut" {
    It "should create shortcut to file" {
        { $script:shortcut = New-GDriveShortcut -AccessToken $access.access_token -Name "PesterTestShortcut"  -TargetID $file1.id  } | Should -Not -Throw
        $shortcut | Should -Not -BeNullOrEmpty
        $shortcut.id | Should -Not -BeNullOrEmpty
        $shortcut.name | Should -Be "PesterTestShortcut"
        $shortcut.mimeType | Should -Be "application/vnd.google-apps.shortcut"
    }
}

Describe "Set-GDriveItemContent" {
    BeforeAll {
        $params = @{
            AccessToken = $access.access_token
            ContentType = 'text/plain'
        }
    }
    It "should set file1 content by multiple chunks" {
        [byte[]]$buffer = 0..1124kb | ForEach-Object { [byte]($_ -band 0xff) }
        { $script:file1d = Set-GDriveItemContent @params -ID $file1.id -RawContent $buffer -ChunkSize 256kb | Select-Object -Expand Item } | Should -Not -Throw
        $file1d | Should -Not -BeNullOrEmpty
        $file1d.id | Should -Be $file1.id
    }
    It "should set file1 content to test string" {
        { $script:file1c = Set-GDriveItemContent @params -ID $file1.id -StringContent 'test file1' | Select-Object -Expand Item } | Should -Not -Throw
        $file1c | Should -Not -BeNullOrEmpty
        $file1c.id | Should -Be $file1.id
    }
}

Describe "Add-GDriveItem" {
    BeforeAll {
        $params = @{
            AccessToken = $access.access_token
            ParentID = $folder.id 
            ContentType = 'text/plain'
        }
    }
    Context "string" {
        It "should create file from string" {
            { $script:file2 = Add-GDriveItem @params -Name "PesterTestFile2"  -StringContent 'test file2' | Select-Object -Expand Item } | Should -Not -Throw
            $file2.id | Should -Not -BeNullOrEmpty
            $file2.name | Should -Be "PesterTestFile2"
            $file2.mimeType | Should -Be "text/plain"
        }
    }
    Context "byte[]" {
        It "should create file from byte[]" {
            { $script:file3 = Add-GDriveItem @params -Name "PesterTestFile3" -RawContent ([Text.Encoding]::Utf8.GetBytes('test file3')) | Select-Object -Expand Item } | Should -Not -Throw
            $file3.id | Should -Not -BeNullOrEmpty
            $file3.name | Should -Be "PesterTestFile3"
            $file3.mimeType | Should -Be "text/plain"
        }
    }
    Context "file" {
        BeforeAll {
            'test file4' | Set-Content -Path $global:tmpfile -Encoding ASCII
        }
        It "should create file from file" {
            { $script:file4 = Add-GDriveItem @params -Name "PesterTestFile4" -InFile $global:tmpfile | Select-Object -Expand Item } | Should -Not -Throw
            $file4.id | Should -Not -BeNullOrEmpty
            $file4.name | Should -Be "PesterTestFile4"
            $file4.mimeType | Should -Be "text/plain"
        }
    }
    Context "application/octet-stream" {
        It "should create file from string" {
            $params.ContentType = 'application/octet-stream'
            { $script:file5 = Add-GDriveItem @params -Name "PesterTestFile5"  -StringContent 'test file5' | Select-Object -Expand Item } | Should -Not -Throw
            $file5.id | Should -Not -BeNullOrEmpty
            $file5.name | Should -Be "PesterTestFile5"
            $file5.mimeType | Should -Be "application/octet-stream"
        }
    }
}


Describe "Set-GDriveItemProperty" {
        It "should set file1 description" {
            { $script:file1ds = Set-GDriveItemProperty -AccessToken $access.access_token -ID $file1.id -JsonProperty '{ "description": "file1 description" }' } | Should -Not -Throw
            $file1ds.id | Should -Be $file1.id
        }
}
Describe "Get-GDriveItemProperty" {
        It "should get file1 description" {
            { $script:file1dg = Get-GDriveItemProperty -AccessToken $access.access_token -ID $file1.id -Property id,description } | Should -Not -Throw
            $file1dg | Should -Not -BeNullOrEmpty
            $file1dg.id | Should -Be $file1.id
            $file1dg.description | Should -Be 'file1 description'
        }
}
Describe "Copy-GDriveItem" {
        It "should create file from existing item" {
            { $script:file6 = Copy-GDriveItem -AccessToken $access.access_token -ID $file1.id -Name "PesterTestFile6" } | Should -Not -Throw
            $file6.id | Should -Not -BeNullOrEmpty
            $file6.name | Should -Be "PesterTestFile6"
        }
}
Describe "Rename-GDriveItem" {
        It "should rename file" {
            { $script:file5 = Rename-GDriveItem -AccessToken $access.access_token -ID $file5.id -NewName "PesterTestFile5r" } | Should -Not -Throw
            $file5.id | Should -Not -BeNullOrEmpty
            $file5.name | Should -Be "PesterTestFile5r"
        }
}
Describe "Move-GDriveItem" {
        It "should move file1 to root" {
            { $script:file1 = Move-GDriveItem -AccessToken $access.access_token -ID $file1.id -NewParentID 'root' } | Should -Not -Throw
            $file1.parents.Count | Should -Be 1
            $file1.parents[0] | Should -Be $summary.rootFolderId
        }
}
Describe "Find-GDriveItem" {
        It "should find 6 files" {
            { $script:files = Find-GDriveItem -AccessToken $access.access_token -Query 'name contains "PesterTestFile"' } | Should -Not -Throw
            $files.files.Count | Should -Be 6
        }
}
Describe "Get-GDriveChildItem" {
    It "should return item list" {
        { $script:list = Get-GDriveChildItem -AccessToken $access.access_token -ParentID $folder.id  } | Should -Not -Throw
        $list | Should -Not -BeNullOrEmpty
        $list.files | Should -Not -BeNullOrEmpty
        $list.files.Count | Should -Be 5
    }
    It "should return item list (all)" {
        { $script:list = Get-GDriveChildItem -AccessToken $access.access_token -ParentID $folder.id -AllResults -PageSize 2 } | Should -Not -Throw
        $list | Should -Not -BeNullOrEmpty
        $list.files | Should -Not -BeNullOrEmpty
        $list.files.Count | Should -Be 5
    }
}

Describe "Get-GDriveItemContent" {
    BeforeAll {
        $params = @{
            AccessToken = $access.access_token
        }
    }
    Context "string" {
        It "should get file content as string" {
            { $script:content = Get-GDriveItemContent @params -ID $file5.id } | Should -Not -Throw
            $content | Should -Be 'test file5'
        }
        It "should get partial content as string" {
            { $script:content = Get-GDriveItemContent @params -ID $file5.id -Offset 3 -Length 5 } | Should -Not -Throw
            $content | Should -Be 't fil'
        }
    }
    Context "byte[]" {
        It "should get file content as byte[]" {
            { $script:content = Get-GDriveItemContent @params -ID $file4.id -Raw } | Should -Not -Throw
            [Text.Encoding]::ASCII.GetString($content) | Should -Be "test file4`r`n"
        }
    }
    Context "file" {
        BeforeAll {
            'test file4' | Set-Content -Path $global:tmpfile
        }
        It "should get file content and save it to file" {
            { Get-GDriveItemContent @params -ID $file3.id -OutFile $global:tmpfile } | Should -Not -Throw
            $content = Get-Content -Path $global:tmpfile
            $content | Should -Be 'test file3'
        }
    }
}

Describe "Remove-GDriveItem" {
    Context "Remove Items" {
        It "should trash file1" {
            { Remove-GDriveItem -AccessToken $access.access_token -Confirm:$false -ID $file1.id } | Should -Not -Throw
            $f1 = Get-GDriveItemProperty -AccessToken $access.access_token -ID $file1.id -Property trashed
            $f1.trashed | Should -Be $true
        }
        It "should untrash file1" {
            { Restore-GDriveItem -AccessToken $access.access_token -Confirm:$false -ID $file1.id } | Should -Not -Throw
            $f1 = Get-GDriveItemProperty -AccessToken $access.access_token -ID $file1.id -Property trashed
            $f1.trashed | Should -Be $false
        }
        It "should remove file1" {
            { Remove-GDriveItem -AccessToken $access.access_token -Confirm:$false -ID $file1.id -Permanently } | Should -Not -Throw
            { Get-GDriveItemProperty -AccessToken $access.access_token -ID $file1.id } | Should -Throw
        }
        It "should remove shortcut to file1" {
            { Remove-GDriveItem -AccessToken $access.access_token -Confirm:$false -ID $shortcut.id -Permanently } | Should -Not -Throw
            { Get-GDriveItemProperty -AccessToken $access.access_token -ID $shortcut.id } | Should -Throw
        }
    }
    Context "Remove Folders" {
        It "should remove testfolder" {
            { Remove-GDriveItem -AccessToken $access.access_token -Confirm:$false -ID $folder.id -Permanently } | Should -Not -Throw
        }
        It "should -Not find testfolder" {
            $query = Find-GDriveItem -AccessToken $access.access_token -Query 'name="PesterTestFolder"'
            $query.files.Count | Should -Be 0
        }
    }
    # Sometimes google drive does not delete files from deleted folders, but leaves them orphaned
    # They can be found and retrieved, but their parents not found, although their id is in the properties
    # This is probably a temporary bug, so I'll leave it commented out
    # Context "Remove orphaned files" {
    #     It "should remove orphaned files" {
    #         { $list.files.id | ForEach-Object { Remove-GDriveItem -AccessToken $access.access_token -Confirm:$false -ID $_ -Permanently } } | Should -Not -Throw
    #     }
    # }
}
Describe 'Revisions support' {
    # Add revisions to file
    It "should create test file" {
        { $script:revfile = Add-GDriveItem -AccessToken $access.access_token -Name 'PesterTestFileRev' -StringContent '0' } | Should -Not -Throw
        $revfile | Should -Not -BeNullOrEmpty
        $revfile.Item | Should -Not -BeNullOrEmpty
        $revfile.Item.id | Should -Not -BeNullOrEmpty
    }
    It "should create 5 additional revisions" {
        { 1..5 | ForEach-Object { Set-GDriveItemContent -AccessToken $access.access_token -ID $revfile.Item.id -StringContent $_ } } | Should -Not -Throw
    }
    Context "Get-GDriveItemRevisionList" {
        It "should list 6 revisions" {
            { $script:revlist = Get-GDriveItemRevisionList -AccessToken $access.access_token -ID $revfile.Item.id } | Should -Not -Throw
            $revlist | Should -Not -BeNullOrEmpty
            $revlist.revisions | Should -Not -BeNullOrEmpty
            $revlist.revisions.Count | Should -Be 6
        }
    }
    Context "Get-GDriveItemContent" {
        BeforeAll {
            $e = [System.Text.Encoding]::Utf8
        }
        It "should get content for each revision" {
            foreach ($i in (0..5)) {
                $content = Get-GDriveItemContent -AccessToken $access.access_token -ID $revfile.Item.id -RevisionID $revlist.revisions[$i].id -Encoding $e
                $content | Should -Be $i
            }
        }
    }
    Context "Set-GDriveItemContent" {
        BeforeAll {
            $e = [System.Text.Encoding]::Utf8
        }
        It "should get content for each revision" {
            foreach ($i in (0..5)) {
                $content = Get-GDriveItemContent -AccessToken $access.access_token -ID $revfile.Item.id -RevisionID $revlist.revisions[$i].id -Encoding $e
                $content | Should -Be $i
            }
        }
    }
    Context "Set-GDriveItemProperty" {
        It "should set property for revision 0" {
            { Set-GDriveItemProperty -AccessToken $access.access_token -ID $revfile.Item.id -RevisionID $revlist.revisions[0].id -JsonProperty (@{ keepForever='true' } | ConvertTo-Json) } | Should -Not -Throw
        }
    }
    Context "Get-GDriveItemProperty" {
        It "should get property for revision 0" {
            { $script:content = Get-GDriveItemProperty -AccessToken $access.access_token -ID $revfile.Item.id -RevisionID $revlist.revisions[0].id -Property keepForever } | Should -Not -Throw
            $content | Should -Not -BeNullOrEmpty
            $content.keepForever | Should -Not -BeNullOrEmpty
            $content.keepForever | Should -Be $true
        }
    }
    Context "Remove-GDriveItem" {
        It "should remove revision 0" {
            { Remove-GDriveItem -AccessToken $access.access_token -ID $revfile.Item.id -RevisionID $revlist.revisions[0].id -Confirm:$false } | Should -Not -Throw
        }
        It "should -Not get revision 0" {
            { $script:content = Get-GDriveItemProperty -AccessToken $access.access_token -ID $revfile.Item.id -RevisionID $revlist.revisions[0].id -Property keepForever } | Should -Throw
        }
        It "should get 5 revisions" {
            { $script:revlist = Get-GDriveItemRevisionList -AccessToken $access.access_token -ID $revfile.Item.id } | Should -Not -Throw
            $revlist | Should -Not -BeNullOrEmpty
            $revlist.revisions | Should -Not -BeNullOrEmpty
            $revlist.revisions.Count | Should -Be 5
        }
    }
    It "should remove test file" {
        { Remove-GDriveItem -AccessToken $access.access_token -Confirm:$false -ID $revfile.Item.id -Permanently } | Should -Not -Throw
    }
}
Describe 'Charset support' {
    Context "cyrillic" {
        BeforeAll {
            $testcontent = "съешь ещё этих мягких французских булок, да выпей чаю"
        }
        It "should create folder with cyrillic name" {
            { $script:cfolder = New-GDriveFolder -AccessToken $access.access_token -Name $testcontent.Substring(1) } | Should -Not -Throw
            $cfolder | Should -Not -BeNullOrEmpty
            $cfolder.id | Should -Not -BeNullOrEmpty
            $cfolder.name | Should -Be $testcontent.Substring(1)
        }
        It "should create file item in folder with cyrillic name" {
            { $script:cfile = New-GDriveItem -AccessToken $access.access_token -Name $testcontent -ParentID $cfolder.id } | Should -Not -Throw
            $cfile | Should -Not -BeNullOrEmpty
            $cfile.id | Should -Not -BeNullOrEmpty
            $cfile.name | Should -Be $testcontent
        }
        It "should set cyrillic file property" {
            { Set-GDriveItemProperty -AccessToken $access.access_token -ID $cfile.id -JsonProperty ('{ "description": "' + $testcontent + '" }') } | Should -Not -Throw
        }
        It "should return file item" {
            { $script:cfile1 = Find-GDriveItem -AccessToken $access.access_token -Query "name = '$testcontent'" | Select-Object -ExpandProperty files } | Should -Not -Throw
            $cfile1 | Should -Not -BeNullOrEmpty
            $cfile1.id | Should -Not -BeNullOrEmpty
            $cfile1.id | Should -Be $cfile.id
            $cfile1.name | Should -Be $testcontent
        }
        It "should return file item properties" {
            { $script:cfilep = Get-GDriveItemProperty -AccessToken $access.access_token -Id $cfile.id -Property id, name, description } | Should -Not -Throw
            $cfilep | Should -Not -BeNullOrEmpty
            $cfilep.id | Should -Not -BeNullOrEmpty
            $cfilep.name | Should -Be $testcontent
            $cfilep.description | Should -Be $testcontent
        }
        It "should place cyrillic content into file" {
            { $script:cfile2 = Set-GDriveItemContent -AccessToken $access.access_token -ID $cfile.id -ContentType 'text/plain' -StringContent $testcontent | Select-Object -Expand Item } | Should -Not -Throw
            $cfile2 | Should -Not -BeNullOrEmpty
            $cfile2.id | Should -Not -BeNullOrEmpty
            $cfile2.id | Should -Be $cfile.id
            $cfile2.name | Should -Be $testcontent
        }
        It "should return cyrillic content from file" {
            { $script:content = Get-GDriveItemContent -AccessToken $access.access_token -ID $cfile.id -Raw } | Should -Not -Throw
            [Text.Encoding]::UTF8.GetString($content) | Should -Be $testcontent
        }
        It "should remove cyrillic file" {
            { Remove-GDriveItem -AccessToken $access.access_token -Confirm:$false -ID $cfile.id -Permanently } | Should -Not -Throw
        }
        It "should remove cyrillic folder" {
            { Remove-GDriveItem -AccessToken $access.access_token -Confirm:$false -ID $cfolder.id -Permanently } | Should -Not -Throw
        }
    }
}

Describe 'Comments and Replies'{
    Context 'Workflow' {
        It "should create text file" {
            { $script:file_c = Add-GDriveItem -AccessToken $access.access_token -Name "PesterTestFileComment" -StringContent 'test' -ContentType 'text/plain' } | Should -Not -Throw
            $file_c.Item.id | Should -Not -BeNullOrEmpty
            $file_c.Item.name | Should -Be "PesterTestFileComment"
            $file_c.Item.mimeType | Should -Be "text/plain"
        }
        It "should add comment 1" {
            { $script:comment1 = Add-GDriveItemComment -AccessToken $access.access_token -ID $file_c.Item.id -Comment '1st comment' } | Should -Not -Throw
            $comment1.id | Should -Not -BeNullOrEmpty
            $comment1.content | Should -Be "1st comment"
        }
        It "should add comment 2" {
            { $script:comment2 = Add-GDriveItemComment -AccessToken $access.access_token -ID $file_c.Item.id -Comment '2nd comment' -Ancor (@{r='head';a=@(@{line=@{n=2; l=1}})} | ConvertTo-Json -Compress -Depth 5) -QuotedContent 'es' } | Should -Not -Throw
            $comment2.id | Should -Not -BeNullOrEmpty
            $comment2.content | Should -Be "2nd comment"
        }
        It "should get comment" {
            { $script:comment = Get-GDriveItemComment -AccessToken $access.access_token -ID $file_c.Item.id -CommentId $comment1.id } | Should -Not -Throw
            $comment.id | Should -Not -BeNullOrEmpty
            $comment.content | Should -Be "1st comment"
        }
        It "should get comment list" {
            { $script:comments = Get-GDriveItemCommentList -AccessToken $access.access_token -ID $file_c.Item.id } | Should -Not -Throw
            $comments.comments | Should -Not -BeNullOrEmpty
            $comments.comments.Count | Should -Be 2
        }
        It "should get comment list (all)" {
            { $script:comments = Get-GDriveItemCommentList -AccessToken $access.access_token -ID $file_c.Item.id -PageSize 1 -AllResults } | Should -Not -Throw
            $comments.comments | Should -Not -BeNullOrEmpty
            $comments.comments.Count | Should -Be 2
        }
        It "should set comment" {
            { $script:comment = Set-GDriveItemComment -AccessToken $access.access_token -ID $file_c.Item.id -CommentId $comment1.id -Comment "1st changed" } | Should -Not -Throw
            $comment.id | Should -Not -BeNullOrEmpty
            $comment.content | Should -Be "1st changed"
        }
        It "should add reply 1" {
            { $script:reply1 = Add-GDriveItemReply -AccessToken $access.access_token -ID $file_c.Item.id -CommentID $comment1.id -Reply '1st reply' } | Should -Not -Throw
            $reply1.id | Should -Not -BeNullOrEmpty
            $reply1.content | Should -Be "1st reply"
        }
        It "should add reply 2 (reopen)" {
            { $script:reply2 = Add-GDriveItemReply -AccessToken $access.access_token -ID $file_c.Item.id -CommentID $comment1.id -Reply '2nd reply' -Action reopen } | Should -Not -Throw
            $reply2.id | Should -Not -BeNullOrEmpty
            $reply2.content | Should -Be "2nd reply"
            $reply2.action | Should -Be "reopen"
        }
        It "should get reply" {
            { $script:reply = Get-GDriveItemReply -AccessToken $access.access_token -ID $file_c.Item.id -CommentId $comment1.id -ReplyID $reply1.id } | Should -Not -Throw
            $reply.id | Should -Not -BeNullOrEmpty
            $reply.content | Should -Be "1st reply"
        }
        It "should get reply list" {
            { $script:replies = Get-GDriveItemReplyList -AccessToken $access.access_token -ID $file_c.Item.id -CommentID $comment1.id } | Should -Not -Throw
            $replies.replies | Should -Not -BeNullOrEmpty
            $replies.replies.Count | Should -Be 2
        }
        It "should get reply list (all)" {
            { $script:replies = Get-GDriveItemReplyList -AccessToken $access.access_token -ID $file_c.Item.id -CommentID $comment1.id -PageSize 1 -AllResults } | Should -Not -Throw
            $replies.replies | Should -Not -BeNullOrEmpty
            $replies.replies.Count | Should -Be 2
        }
        #without changing file, reply can't have action/be resolved
        It "should update text file" {
            { $script:file_c1 = Set-GDriveItemContent -AccessToken $access.access_token -ID $file_c.Item.id -StringContent 'changed test' -ContentType 'text/plain' } | Should -Not -Throw
            $file_c1.Item.id | Should -Be $file_c.Item.id
        }
        It "should set reply 1" {
            { $script:reply = Set-GDriveItemReply -AccessToken $access.access_token -ID $file_c.Item.id -CommentId $comment1.id -ReplyID $reply1.id -Reply "1st changed" } | Should -Not -Throw
            $reply.id | Should -Not -BeNullOrEmpty
            $reply.content | Should -Be "1st changed"
        }
        It "should set reply 2" {
            { $script:reply = Set-GDriveItemReply -AccessToken $access.access_token -ID $file_c.Item.id -CommentId $comment1.id -ReplyID $reply2.id -Reply "2nd changed" } | Should -Not -Throw
            $reply.id | Should -Not -BeNullOrEmpty
            $reply.content | Should -Be "2nd changed"
        }
        #seems we cannot set reply as resolved, only add ?
        It "should add reply 3 as resolved" {
            { $script:reply3 = Add-GDriveItemReply -AccessToken $access.access_token -ID $file_c.Item.id -CommentId $comment1.id -Action resolve } | Should -Not -Throw
            $reply3.id | Should -Not -BeNullOrEmpty
            $reply3.action | Should -Be "resolve"
        }
        It "should get comment as resolved" {
            { $script:comment = Get-GDriveItemComment -AccessToken $access.access_token -ID $file_c.Item.id -CommentId $comment1.id } | Should -Not -Throw
            $comment.id | Should -Not -BeNullOrEmpty
            $comment.resolved | Should -BeTrue
        }
        It "should remove reply" {
            { $script:reply = Remove-GDriveItemReply -AccessToken $access.access_token -ID $file_c.Item.id -CommentId $comment1.id -ReplyID $reply2.id -Confirm:$false } | Should -Not -Throw
            $reply | Should -BeNullOrEmpty
        }
        It "should not get removed reply" {
            { $script:reply = Get-GDriveItemReply -AccessToken $access.access_token -ID $file_c.Item.id -CommentId $comment1.id -ReplyID $reply2.id } | Should -Throw
        }
        It "should get removed reply" {
            { $script:reply = Get-GDriveItemReply -AccessToken $access.access_token -ID $file_c.Item.id -CommentId $comment1.id -ReplyID $reply2.id -IncludeDeleted } | Should -Not -Throw
            $reply.id | Should -Not -BeNullOrEmpty
            $reply.deleted | Should -Be $True
        }
        It "should remove comment" {
            { $script:comment = Remove-GDriveItemComment -AccessToken $access.access_token -ID $file_c.Item.id -CommentId $comment1.id -Confirm:$false } | Should -Not -Throw
            $comment | Should -BeNullOrEmpty
        }
        It "should not get removed comment" {
            { $script:comment = Get-GDriveItemComment -AccessToken $access.access_token -ID $file_c.Item.d -CommentId $comment1.id } | Should -Throw
        }
        It "should get removed comment" {
            { $script:comment = Get-GDriveItemComment -AccessToken $access.access_token -ID $file_c.Item.id -CommentId $comment1.id -IncludeDeleted } | Should -Not -Throw
            $comment.id | Should -Not -BeNullOrEmpty
            $comment.deleted | Should -Be $True
        }
        It "should remove text file" {
            { $script:file = Remove-GDriveItem -AccessToken $access.access_token -ID $file_c.Item.id -Permanently -Confirm:$false } | Should -Not -Throw
            $file | Should -BeNullOrEmpty
        }
    }
}

Describe "Revoke-GDriveToken - you lose your refresh token, so does Not test it" {
    It "should revoke access Token" -Skip {
        { Revoke-GDriveToken -Token $access.access_token -Confirm:$false } | Should -Not -Throw
    }
    It "should not retrieve files" -Skip {
        { Get-GDriveChildItem -AccessToken $access.access_token } | Should Throw
    }
}

Describe "Get-GDriveError" {
    It "should return RuntimeException error object" {
        try { throw 'err1' } catch { $err = $_ }
        { $script:rec = Get-GDriveError $err } | Should -Not -Throw
        $rec.Type | Should -Not -BeNullOrEmpty
        $rec.Type.FullName | Should -Be 'System.Management.Automation.RuntimeException'
        $rec.StatusCode | Should -BeNullOrEmpty
        $rec.Message | Should -Be 'err1'
    }
    It "should return WebException error object" {
        try { invoke-restmethod http://ya.ru/notexistenturl } catch { $err = $_ }
        { $script:rec = Get-GDriveError $err -WarningAction SilentlyContinue } | Should -Not -Throw
        $rec.Type | Should -Not -BeNullOrEmpty
        $rec.Type.FullName | Should -BeIn 'System.Net.WebException', 'System.Net.Http.HttpRequestException', 'Microsoft.PowerShell.Commands.HttpResponseException'
        $rec.StatusCode | Should -Be 404
    }
    It "should return Fully decoded error object" {
        try { Get-GDriveItemProperty -AccessToken 'error token' -id 'error id' } catch { $err = $_ }
        { $script:rec = Get-GDriveError $err } | Should -Not -Throw
        $rec.Type | Should -Not -BeNullOrEmpty
        $rec.Type.FullName | Should -BeIn 'System.Net.WebException', 'System.Net.Http.HttpRequestException', 'Microsoft.PowerShell.Commands.HttpResponseException'
        $rec.StatusCode | Should -Be 401
        $rec.error | Should -Not -BeNullOrEmpty
        $rec.error.code | Should -Be 401
    }
}

AfterAll {
    Remove-Item -Path $global:tmpfile
}
