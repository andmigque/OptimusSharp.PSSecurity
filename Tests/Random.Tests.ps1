#### # Random.Tests
#### > Pester unit tests for Get-SecureRandom32.
BeforeAll {
    Import-Module (Join-Path $PSScriptRoot '..' 'OptimusSharp.PSSecurity.psd1') -Force
}
AfterAll {
    Remove-Module OptimusSharp.PSSecurity -Force -ErrorAction SilentlyContinue
}

Describe 'Get-SecureRandom32' {
    It 'Returns 32 characters by default' {
        (Get-SecureRandom32).Length | Should -Be 32
    }
    It 'Honors -Length' {
        (Get-SecureRandom32 -Length 16).Length | Should -Be 16
        (Get-SecureRandom32 -Length 64).Length | Should -Be 64
    }
    It 'Returns alphanumeric characters only' {
        Get-SecureRandom32 | Should -Match '^[A-Za-z0-9]+$'
    }
    It 'Returns different values across calls' {
        (Get-SecureRandom32) | Should -Not -Be (Get-SecureRandom32)
    }
    It 'Rejects a length outside 1..512' {
        { Get-SecureRandom32 -Length 0 } | Should -Throw
        { Get-SecureRandom32 -Length 513 } | Should -Throw
    }
}
