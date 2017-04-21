<#
.SYNOPSIS
    Request Authorization code to work with GoogleDrive
.DESCRIPTION
    Request Authorization code to work with GoogleDrive
    If user logged into google account or username/password supplied that can be automatic

    NOT intended for use in scripts! Only cmdline with UI and real user behind the keyboard

.PARAMETER ClientID
    OAuth2 Client ID
.PARAMETER ClientSecret
    OAuth2 Client Secret
.PARAMETER Automatic
    DANGEROUS! Try to automatically approve access
.PARAMETER Credential
    DANGEROUS! Google account username/password to automatic code request
.PARAMETER RefreshToken
    OAuth2 RefreshToken
.EXAMPLE
    $oauth_json = $oauth | ConvertFrom-Json
    $code = Request-GDriveAuthorizationCode -ClientID $oauth_json.web.client_id -ClientSecret $oauth_json.web.client_secret
    Request-GDriveRefreshToken -ClientID $oauth_json.web.client_id -ClientSecret $oauth_json.web.client_secret -AuthorizationCode $code
.EXAMPLE
    $oauth_json = $oauth | ConvertFrom-Json
    $code = Request-GDriveAuthorizationCode -ClientID $oauth_json.web.client_id -ClientSecret $oauth_json.web.client_secret -Automatic
    Request-GDriveRefreshToken -ClientID $oauth_json.web.client_id -ClientSecret $oauth_json.web.client_secret -AuthorizationCode $code
.OUTPUTS
    None
.NOTES
    Author: Max Kozlov
.LINK
    Get-GDriveAccessToken
    Request-GDriveRefreshToken
    Revoke-GDriveToken
    https://developers.google.com/identity/protocols/OAuth2
    https://developers.google.com/identity/protocols/OAuth2InstalledApp
    https://developers.google.com/identity/protocols/OAuth2WebServer
#>
function Request-GDriveAuthorizationCode {
[CmdletBinding(DefaultParameterSetName='manual')]
    param(
        [Parameter(Mandatory, Position=0, ParameterSetName='auto')]
        [Parameter(Mandatory, Position=0, ParameterSetName='manual')]
        [string]$ClientID,

        [Parameter(Mandatory, Position=1, ParameterSetName='auto')]
        [Parameter(Mandatory, Position=1, ParameterSetName='manual')]
        [string]$ClientSecret,

        [Parameter(Mandatory, ParameterSetName='auto')]
        [switch]$Automatic,

        [Parameter(ParameterSetName='auto')]
        [PSCredential][System.Management.Automation.Credential()]$Credential,

        [string]$RedirectUri = 'https://developers.google.com/oauthplayground'
    )
	If ($PSBoundParameters['Debug']) { $DebugPreference = 'Continue' }

    $scope = [System.Uri]::EscapeDataString($GDriveAuthScope)
    $Uri = '{0}?access_type={1}&response_type={2}&prompt={3}&client_id={4}&redirect_uri={5}&scope={6}' -f
        $GDriveAccountsTokenUri, 'offline', 'code', 'consent',
        $ClientID, [System.Uri]::EscapeDataString($RedirectUri), $scope

    Write-Verbose $Uri
    Write-Debug "ErrorActionPreference $ErrorActionPreference"

    try {
        $ie = New-Object -ComObject InternetExplorer.Application
    }
    catch {
        throw "Unsupported. Can't load InternetExplorer COM Application: ($_.Exception)"
    }

    $ie.Navigate($Uri)
    #code variant
    #while ($ie.ReadyState -ne 4)
    #$ie.Document.getElementById("email").value = $username

    if ($PSBoundParameters.ContainsKey('Debug') -or (-not $Automatic)) {
        Write-Debug 'Not automatic access'
        $ie.Visible = $true
        $Automatic = $false
    }

    if ($PSBoundParameters.ContainsKey('Credential') -and -Not ($Credential)) {
        $Credential = Get-Credential
    }
    if ($Credential) {
        $Username = $Credential.UserName
        $Password = $Credential.GetNetworkCredential().Password
    }
    else {
        $Username = $Password = $null
    }

    $loginstate = 0
    $forms = $email = $emailbutton = $passwd = $passwdbutton = $accessbutton = $null
    do {
        try {
            do {
                Start-Sleep -Milliseconds 500
            } while ($ie.Busy -eq $true)
            $forms = $ie.Document | Select-Object -ExpandProperty forms
            $forms.Item(0) | Foreach-Object {
                $object = $_
                switch ($_.id) {
                    'Email' {
                        Write-Debug 'Email field found'
                        $email = $object
                    }
                    'next' {
                        Write-Debug 'Email next button found'
                        $emailbutton = $object
                    }
                    'Passwd' {
                        Write-Debug 'Password field found'
                        $passwd = $object
                    }
                    'signIn' {
                        Write-Debug 'Signin button found'
                        $passwdbutton = $object
                    }
                    'submit_approve_access' {
                        Write-Debug 'Approve access button found'
                        $accessbutton = $object
                    }
                    'logincaptcha' {
                        Write-Warning 'Captcha found !'
                        $ie.Visible = $true
                        $Automatic = $false
                    }
                }
            } # foreach

            Write-Debug "loginstate $loginstate"
            if ($ie.Document.url -match "^$RedirectUri") {
                Write-Debug "Exiting IE cycle"
                $loginstate = 4
            }
            elseif ($email -and $emailbutton) {
                $loginstate = 1
                if ($UserName) {
                    Write-Debug 'Username present'
                    if ($Automatic) {
                        Write-Debug 'Next Click'
                        $email.Value = $UserName
                        try { $emailbutton.Click() } catch { $null }
                    }
                }
                else {
                    Write-Debug 'Username not present'
                    Write-Warning 'Username not found, turn off Automatic'
                    $ie.Visible = $true
                    $Automatic = $false
                }
            }
            elseif ($passwd -and $passwdbutton) {
                $loginstate = 2
                if ($Password) {
                    Write-Debug 'Password present'
                    if ($Automatic) {
                        Write-Debug 'Passwd Click'
                        $passwd.Value = $Password
                        try { $passwdbutton.Click() } catch { $null }
                    }
                }
                else {
                    Write-Debug 'Password not present'
                    Write-Warning 'Password not found, turn off Automatic'
                    $ie.Visible = $true
                    $Automatic = $false
                }
            }
            elseif ($accessbutton) {
                $loginstate = 3
                if ($Automatic) {
                    Write-Debug 'Approve Click'
                    try { $accessbutton.Click() } catch { $null }
                }
            }
        }
        catch {
            $loginstate = -1
            $err = $_
            break
        }
        $forms = $email = $emailbutton = $passwd = $passwdbutton = $accessbutton = $null
    } until ($loginstate -eq 4)

    if ($loginstate -eq -1) {
        Write-Error $err
    }
    else {
        $url = $ie.Document.url
        if ($Automatic) {
            $ie.Quit()
        }
        $ie = $null
        [System.GC]::Collect(); [System.GC]::WaitForPendingFinalizers(); [System.GC]::Collect()
        if ($url -match "/?code=") {
            $code = $url -replace '.*/?code=' -replace '[&#].*'
            $code
        }
        else {
            Write-Error ($url -replace '.*/?error=' -replace '[&#].*') -Category PermissionDenied
        }
    }
}
