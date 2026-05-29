#### # Module.Tests
#### > Pester unit tests for the manifest and the exported public surface.
BeforeAll {
    $script:Manifest = Join-Path $PSScriptRoot '..' 'OptimusSharp.PSSecurity.psd1'
    Import-Module $script:Manifest -Force
}
AfterAll {
    Remove-Module OptimusSharp.PSSecurity -Force -ErrorAction SilentlyContinue
}

Describe 'Manifest' {
    It 'Passes Test-ModuleManifest' {
        Test-ModuleManifest -Path $script:Manifest | Should -Not -BeNullOrEmpty
    }
    It 'Declares version 1.0.0' {
        (Test-ModuleManifest -Path $script:Manifest).Version | Should -Be ([version]'1.0.0')
    }
    It 'Targets the Core edition' {
        (Test-ModuleManifest -Path $script:Manifest).CompatiblePSEditions | Should -Contain 'Core'
    }
    It 'Carries Gallery metadata' {
        $manifest = Test-ModuleManifest -Path $script:Manifest
        $manifest.LicenseUri | Should -Not -BeNullOrEmpty
        $manifest.ProjectUri | Should -Not -BeNullOrEmpty
        $manifest.Tags | Should -Contain 'Security'
    }
}

Describe 'Exported surface' {
    It 'Exports the five cross-platform functions' {
        foreach ($name in 'Get-Hash', 'Get-SecureRandom32', 'Protect-FileWithEncryption', 'Unprotect-EncryptedFile', 'Write-DirectoryHashes') {
            Get-Command -Module OptimusSharp.PSSecurity -Name $name -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }
    }
    It 'Does not export a legacy V2 function' {
        Get-Command -Module OptimusSharp.PSSecurity -Name 'Protect-FileWithEncryptionV2' -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
    }
    It 'Exports the Windows surface on Windows' -Skip:(-not $IsWindows) {
        foreach ($name in 'Get-AclItem', 'Set-UacRequirePassword', 'New-LocalAdminUser', 'Get-ApplicationSignatureAudit') {
            Get-Command -Module OptimusSharp.PSSecurity -Name $name -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }
    }
    It 'Exports the Linux surface on Linux' -Skip:(-not $IsLinux) {
        foreach ($name in 'Set-CronPermissions', 'New-SecurityCertificate', 'Show-SecurityReport', 'Start-SecurityWatch') {
            Get-Command -Module OptimusSharp.PSSecurity -Name $name -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }
    }
}
