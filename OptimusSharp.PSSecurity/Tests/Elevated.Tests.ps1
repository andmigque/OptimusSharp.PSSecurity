#### # Elevated.Tests
#### > Pester integration tests for the admin-gated Windows surface. The whole file skips unless the
#### > host shell is elevated, so an unattended run reports these as skipped rather than failed.
####
#### Each block captures and restores the global state it mutates. The sacrificial local-admin user is
#### named `_OptimusSecurityTest_<random>` and removed in AfterAll.

$IsElevatedHost = $false
if ($IsWindows) {
    $principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    $IsElevatedHost = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

Describe 'UAC policy' -Skip:(-not $IsElevatedHost) {
    BeforeAll {
        Import-Module (Join-Path $PSScriptRoot '..' 'OptimusSharp.PSSecurity.psd1') -Force
        $script:uacRegPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
        $script:uacOriginal = (Get-ItemProperty -Path $script:uacRegPath -Name ConsentPromptBehaviorAdmin).ConsentPromptBehaviorAdmin
    }
    AfterAll {
        Set-ItemProperty -Path $script:uacRegPath -Name ConsentPromptBehaviorAdmin -Value $script:uacOriginal
        Remove-Module OptimusSharp.PSSecurity -Force -ErrorAction SilentlyContinue
    }
    It 'Set-UacRequirePassword sets ConsentPromptBehaviorAdmin to 1' {
        $result = Set-UacRequirePassword
        $result.After | Should -Be 1
        $result.Setting | Should -Be 'ConsentPromptBehaviorAdmin'
    }
    It 'Get-UacConfiguration reports STIG-compliant after require-password' {
        $cfg = Get-UacConfiguration
        $cfg.ConsentPromptBehaviorAdmin | Should -Be 1
        $cfg.StigCompliant | Should -BeTrue
    }
    It 'Set-UacConsentOnly sets ConsentPromptBehaviorAdmin to 5' {
        (Set-UacConsentOnly).After | Should -Be 5
    }
}

Describe 'ACL mutators' -Skip:(-not $IsElevatedHost) {
    BeforeAll {
        Import-Module (Join-Path $PSScriptRoot '..' 'OptimusSharp.PSSecurity.psd1') -Force
        $script:dir = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
        New-Item -ItemType Directory -Path $script:dir | Out-Null
        $script:fileA = Join-Path $script:dir 'a.txt'
        $script:fileB = Join-Path $script:dir 'b.txt'
        Set-Content -LiteralPath $script:fileA -Value 'a' -NoNewline
        Set-Content -LiteralPath $script:fileB -Value 'b' -NoNewline
        $script:me = "$($env:USERDOMAIN)\$($env:USERNAME)"
    }
    AfterAll {
        Remove-Item -LiteralPath $script:dir -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Module OptimusSharp.PSSecurity -Force -ErrorAction SilentlyContinue
    }
    It 'Set-AclItemOwner sets the owner and returns Changed' {
        $result = Set-AclItemOwner -Path $script:fileA -Identity $script:me
        $result.Status | Should -Be 'Changed'
        $result.NewOwner | Should -Be $script:me
    }
    It 'Grant-AclItem then Revoke-AclItem round-trips a Guests ACE' {
        (Grant-AclItem -Path $script:fileA -Identity 'Guests' -Rights Read).Status | Should -Be 'Granted'
        $granted = Get-AclItem -Path $script:fileA | Where-Object { $_.IdentityReference -like '*Guests*' }
        $granted | Should -Not -BeNullOrEmpty

        (Revoke-AclItem -Path $script:fileA -Identity 'Guests').Status | Should -Be 'Revoked'
        $remaining = Get-AclItem -Path $script:fileA | Where-Object { $_.IdentityReference -like '*Guests*' }
        $remaining | Should -BeNullOrEmpty
    }
    It 'Copy-AclItem copies an ACL between files' {
        $result = Copy-AclItem -Source $script:fileA -Destination $script:fileB
        $result.Status | Should -Be 'Copied'
        $result.AceCount | Should -BeGreaterThan 0
    }
    It 'Set-AclItemInheritance disables then enables inheritance' {
        (Set-AclItemInheritance -Path $script:fileA -Disable).InheritanceEnabled | Should -BeFalse
        (Set-AclItemInheritance -Path $script:fileA -Enable).InheritanceEnabled | Should -BeTrue
    }
    It 'Repair-AclItemOwnership recurses without throwing' {
        { Repair-AclItemOwnership -Path $script:dir -Identity $script:me } | Should -Not -Throw
    }
    It 'Reset-AclItem strips explicit ACEs' {
        Grant-AclItem -Path $script:fileA -Identity 'Guests' -Rights Read | Out-Null
        (Reset-AclItem -Path $script:fileA).Status | Should -BeIn @('Reset', 'AlreadyClean')
    }
    It 'Remove-AclItemAccountUnknown returns Clean on a fresh file' {
        $result = Remove-AclItemAccountUnknown -Path $script:fileB
        $result.Status | Should -Be 'Clean'
        $result.RemovedCount | Should -Be 0
    }
}

Describe 'Local admin provisioning' -Skip:(-not $IsElevatedHost) {
    BeforeAll {
        Import-Module (Join-Path $PSScriptRoot '..' 'OptimusSharp.PSSecurity.psd1') -Force
        $script:userName = '_OptimusSecurityTest_' + (Get-Random -Maximum 999999).ToString('D6')
        $password = ConvertTo-SecureString -String ('Tx!' + [guid]::NewGuid().ToString()) -AsPlainText -Force
        $script:cred = [PSCredential]::new($script:userName, $password)
    }
    AfterAll {
        try { Remove-LocalGroupMember -Group 'Administrators' -Member $script:userName -ErrorAction SilentlyContinue } catch {}
        try { Remove-LocalUser -Name $script:userName -ErrorAction SilentlyContinue } catch {}
        Remove-Module OptimusSharp.PSSecurity -Force -ErrorAction SilentlyContinue
    }
    It 'New-LocalAdminUser creates the user and adds it to Administrators' {
        $result = New-LocalAdminUser -Credential $script:cred -FullName 'OptimusSharp PSSecurity Test' -Description 'Sacrificial test account; safe to delete'
        $result.Username | Should -Be $script:userName
        $result.Created | Should -BeTrue
        $result.IsAdministrator | Should -BeTrue

        Get-LocalUser -Name $script:userName -ErrorAction Stop | Should -Not -BeNullOrEmpty
        $member = Get-LocalGroupMember -Group 'Administrators' | Where-Object { $_.Name -like "*\$($script:userName)" }
        $member | Should -Not -BeNullOrEmpty
    }
}
