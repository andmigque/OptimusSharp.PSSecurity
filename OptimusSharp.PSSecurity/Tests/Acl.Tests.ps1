#### # Acl.Tests
#### > Contract tests for the Windows ACL surface. Mutating behavior is covered by the elevated suite.
BeforeAll {
    Import-Module (Join-Path $PSScriptRoot '..' 'OptimusSharp.PSSecurity.psd1') -Force
}
AfterAll {
    Remove-Module OptimusSharp.PSSecurity -Force -ErrorAction SilentlyContinue
}

Describe 'ACL surface' -Skip:(-not $IsWindows) {
    It 'Exports every ACL function as a function' {
        $names = @(
            'Get-AclItem', 'Show-AclItem', 'Get-AclItemOwner', 'Set-AclItemOwner', 'Repair-AclItemOwnership',
            'Grant-AclItem', 'Revoke-AclItem', 'Copy-AclItem', 'Set-AclItemInheritance', 'Get-AclItemAccountUnknown',
            'Show-AclItemAccountUnknown', 'Get-AclItemAccountAnomalies', 'Remove-AclItemAccountUnknown', 'Reset-AclItem'
        )
        foreach ($name in $names) {
            $cmd = Get-Command -Module OptimusSharp.PSSecurity -Name $name -ErrorAction SilentlyContinue
            $cmd | Should -Not -BeNullOrEmpty
            $cmd.CommandType | Should -Be 'Function'
        }
    }
    It 'Does not leak the private Get-AclPathTargets helper' {
        Get-Command -Module OptimusSharp.PSSecurity -Name 'Get-AclPathTargets' -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
    }
}
