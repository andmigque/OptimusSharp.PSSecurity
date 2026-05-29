#### # Signature.Tests
#### > Contract tests for the Windows Authenticode audit. A full PATH scan is out of scope for a unit test.
BeforeAll {
    Import-Module (Join-Path $PSScriptRoot '..' 'OptimusSharp.PSSecurity.psd1') -Force
}
AfterAll {
    Remove-Module OptimusSharp.PSSecurity -Force -ErrorAction SilentlyContinue
}

Describe 'Get-ApplicationSignatureAudit' -Skip:(-not $IsWindows) {
    It 'Is exported as a function' {
        $cmd = Get-Command -Module OptimusSharp.PSSecurity -Name 'Get-ApplicationSignatureAudit' -ErrorAction SilentlyContinue
        $cmd | Should -Not -BeNullOrEmpty
        $cmd.CommandType | Should -Be 'Function'
    }
    It 'Exposes a ThrottleLimit parameter' {
        (Get-Command Get-ApplicationSignatureAudit).Parameters.ContainsKey('ThrottleLimit') | Should -BeTrue
    }
}
