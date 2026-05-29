#### # Uac.Tests
#### > Contract tests for the Windows UAC surface. Registry mutation is covered by the elevated suite.
BeforeAll {
    Import-Module (Join-Path $PSScriptRoot '..' 'OptimusSharp.PSSecurity.psd1') -Force
}
AfterAll {
    Remove-Module OptimusSharp.PSSecurity -Force -ErrorAction SilentlyContinue
}

Describe 'UAC surface' -Skip:(-not $IsWindows) {
    It 'Exports the UAC functions' {
        foreach ($name in 'Set-UacRequirePassword', 'Set-UacConsentOnly', 'Get-UacConfiguration') {
            $cmd = Get-Command -Module OptimusSharp.PSSecurity -Name $name -ErrorAction SilentlyContinue
            $cmd | Should -Not -BeNullOrEmpty
            $cmd.CommandType | Should -Be 'Function'
        }
    }
}
