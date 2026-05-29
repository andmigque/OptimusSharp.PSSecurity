#### # Search.Tests
#### > Pester unit tests for Search-KeywordInFile.
BeforeAll {
    Import-Module (Join-Path (Split-Path -Parent $PSScriptRoot) 'OptimusSharp.PSSecurity.psd1') -Force
}
AfterAll {
    Remove-Module OptimusSharp.PSSecurity -Force -ErrorAction SilentlyContinue
}

Describe 'Search-KeywordInFile' {
    BeforeEach {
        $script:dir = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
        $script:out = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
        New-Item -ItemType Directory -Path $script:dir | Out-Null
        New-Item -ItemType Directory -Path $script:out | Out-Null
        Set-Content -LiteralPath (Join-Path $script:dir 'hit.txt') -Value 'the NEEDLE is here'
        Set-Content -LiteralPath (Join-Path $script:dir 'miss.txt') -Value 'nothing to see'
    }
    AfterEach {
        Remove-Item -LiteralPath $script:dir -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $script:out -Recurse -Force -ErrorAction SilentlyContinue
    }

    It 'Returns the matching file and excludes non-matching files' {
        $json = Search-KeywordInFile -Directory $script:dir -Pattern 'NEEDLE' -OutPath $script:out 6> $null
        $paths = @($json | ConvertFrom-Json)
        $paths.Count | Should -Be 1
        $paths[0] | Should -Match 'hit\.txt$'
    }

    It 'Writes FilesFound.json under OutPath' {
        Search-KeywordInFile -Directory $script:dir -Pattern 'NEEDLE' -OutPath $script:out 6> $null
        Test-Path -Path (Join-Path $script:out 'FilesFound.json') -PathType Leaf | Should -BeTrue
    }

    It 'Returns an empty array when nothing matches' {
        $json = Search-KeywordInFile -Directory $script:dir -Pattern 'NOTPRESENTANYWHERE' -OutPath $script:out 6> $null
        @($json | ConvertFrom-Json).Count | Should -Be 0
    }
}
