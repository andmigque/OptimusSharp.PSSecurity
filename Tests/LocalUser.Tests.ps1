#### # LocalUser.Tests
#### > Contract tests for local-admin provisioning. Account creation is covered by the elevated suite.
BeforeAll {
    Import-Module (Join-Path $PSScriptRoot '..' 'OptimusSharp.PSSecurity.psd1') -Force
}
AfterAll {
    Remove-Module OptimusSharp.PSSecurity -Force -ErrorAction SilentlyContinue
}

Describe 'New-LocalAdminUser' -Skip:(-not $IsWindows) {
    It 'Is exported as a function' {
        $cmd = Get-Command -Module OptimusSharp.PSSecurity -Name 'New-LocalAdminUser' -ErrorAction SilentlyContinue
        $cmd | Should -Not -BeNullOrEmpty
        $cmd.CommandType | Should -Be 'Function'
    }
    It 'Does not leak the private Assert-Administrator helper' {
        Get-Command -Module OptimusSharp.PSSecurity -Name 'Assert-Administrator' -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
    }
}
