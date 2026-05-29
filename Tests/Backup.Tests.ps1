#### # Backup.Tests
#### > Pester unit tests for Backup-FileParallel.
BeforeAll {
    Import-Module (Join-Path (Split-Path -Parent $PSScriptRoot) 'OptimusSharp.PSSecurity.psd1') -Force
}
AfterAll {
    Remove-Module OptimusSharp.PSSecurity -Force -ErrorAction SilentlyContinue
}

Describe 'Backup-FileParallel' {
    BeforeEach {
        $script:src = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
        $script:dst = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
        New-Item -ItemType Directory -Path $script:src | Out-Null
        0..4 | ForEach-Object {
            Set-Content -LiteralPath (Join-Path $script:src "TestFile$_.txt") -Value "content $_"
        }
    }
    AfterEach {
        Remove-Item -LiteralPath $script:src -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $script:dst -Recurse -Force -ErrorAction SilentlyContinue
    }

    It 'Mirrors every source file to <destination>/<relative>.gz' {
        Backup-FileParallel -Path $script:src -OutPath $script:dst *> $null
        0..4 | ForEach-Object {
            Test-Path -Path (Join-Path $script:dst "TestFile$_.txt.gz") -PathType Leaf | Should -BeTrue
        }
    }

    It 'Does not emit CompressionErrors.json on a clean run' {
        Backup-FileParallel -Path $script:src -OutPath $script:dst *> $null
        Test-Path -Path (Join-Path $script:dst 'CompressionErrors.json') | Should -BeFalse
    }

    It 'Throws when Path does not exist' {
        $missing = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
        { Backup-FileParallel -Path $missing -OutPath $script:dst } | Should -Throw
    }
}
