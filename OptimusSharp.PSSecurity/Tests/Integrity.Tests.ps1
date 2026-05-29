#### # Integrity.Tests
#### > Pester unit tests for Get-Hash and Write-DirectoryHashes.
BeforeAll {
    Import-Module (Join-Path $PSScriptRoot '..' 'OptimusSharp.PSSecurity.psd1') -Force
}
AfterAll {
    Remove-Module OptimusSharp.PSSecurity -Force -ErrorAction SilentlyContinue
}

Describe 'Get-Hash' {
    It 'Matches Get-FileHash for SHA256' {
        $file = New-TemporaryFile
        try {
            Set-Content -LiteralPath $file -Value 'hello' -NoNewline
            $expected = (Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash
            Get-Hash -Path $file -Algorithm SHA256 | Should -Be $expected
        }
        finally { Remove-Item -LiteralPath $file -Force -ErrorAction SilentlyContinue }
    }
    It 'Throws on a missing file' {
        $missing = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
        { Get-Hash -Path $missing } | Should -Throw
    }
}

Describe 'Write-DirectoryHashes' {
    It 'Writes HashIndex.md and HashIndex.json with one record per included file' {
        $dir = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
        New-Item -ItemType Directory -Path $dir | Out-Null
        try {
            1..3 | ForEach-Object { Set-Content -LiteralPath (Join-Path $dir "f$_.ps1") -Value "$_" }
            Write-DirectoryHashes -Path $dir *> $null

            (Test-Path (Join-Path $dir 'HashIndex.json')) | Should -BeTrue
            (Test-Path (Join-Path $dir 'HashIndex.md')) | Should -BeTrue

            $records = @(Get-Content (Join-Path $dir 'HashIndex.json') -Raw | ConvertFrom-Json)
            $records.Count | Should -Be 3
            $records[0].Hash | Should -Not -BeNullOrEmpty

            $markdown = Get-Content (Join-Path $dir 'HashIndex.md') -Raw
            $markdown | Should -Match '^# Hash Index'
            $markdown | Should -Match '\*\*Algorithm\*\* : SHA256'
        }
        finally { Remove-Item -LiteralPath $dir -Recurse -Force -ErrorAction SilentlyContinue }
    }
}
