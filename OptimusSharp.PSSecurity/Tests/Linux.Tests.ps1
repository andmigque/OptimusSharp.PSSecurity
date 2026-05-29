#### # Linux.Tests
#### > Contract tests for the Linux surface. The functions shell out to sudo, aureport, and mkcert,
#### > so execution is out of scope for an unattended unit run.
BeforeAll {
    Import-Module (Join-Path $PSScriptRoot '..' 'OptimusSharp.PSSecurity.psd1') -Force
}
AfterAll {
    Remove-Module OptimusSharp.PSSecurity -Force -ErrorAction SilentlyContinue
}

Describe 'Linux surface' -Skip:(-not $IsLinux) {
    It 'Exports the Linux functions' {
        foreach ($name in 'Set-CronPermissions', 'Show-SecurityReport', 'Start-SecurityWatch', 'New-SecurityCertificate') {
            $cmd = Get-Command -Module OptimusSharp.PSSecurity -Name $name -ErrorAction SilentlyContinue
            $cmd | Should -Not -BeNullOrEmpty
            $cmd.CommandType | Should -Be 'Function'
        }
    }
    It 'New-SecurityCertificate exposes Hostname and Subdomains parameters' {
        $p = (Get-Command New-SecurityCertificate).Parameters
        $p.ContainsKey('Hostname') | Should -BeTrue
        $p.ContainsKey('Subdomains') | Should -BeTrue
    }
}
