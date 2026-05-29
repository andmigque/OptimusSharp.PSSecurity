#### # Encryption.Tests
#### > Pester unit tests for the AES-256 Protect/Unprotect round-trip.
BeforeAll {
    Import-Module (Join-Path $PSScriptRoot '..' 'OptimusSharp.PSSecurity.psd1') -Force
}
AfterAll {
    Remove-Module OptimusSharp.PSSecurity -Force -ErrorAction SilentlyContinue
}

Describe 'Protect-FileWithEncryption + Unprotect-EncryptedFile' {
    It 'Round-trips plaintext through AES-256' {
        $plain = "The quick brown fox jumps over the lazy dog.`nLine two ends here."
        $key = ConvertTo-SecureString -String 'p@ss-Word!2026' -AsPlainText -Force
        $tempIn = New-TemporaryFile
        $tempOut = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString() + '.out')
        $encPath = $null
        try {
            Set-Content -LiteralPath $tempIn -Value $plain -NoNewline -Encoding utf8NoBOM
            $encPath = [string](Protect-FileWithEncryption -Path $tempIn -SecureKey $key)['Path']
            (Test-Path -LiteralPath $encPath) | Should -BeTrue
            ([System.IO.FileInfo]::new($encPath).Length) | Should -BeGreaterThan 0

            Unprotect-EncryptedFile -EncryptedFilePath $encPath -FilePassword $key -OutputFilePath $tempOut | Out-Null
            (Get-Content -LiteralPath $tempOut -Raw -Encoding utf8NoBOM) | Should -Be $plain
        }
        finally {
            Remove-Item -LiteralPath $tempIn -Force -ErrorAction SilentlyContinue
            if ($encPath -and (Test-Path -LiteralPath $encPath)) { Remove-Item -LiteralPath $encPath -Force -ErrorAction SilentlyContinue }
            Remove-Item -LiteralPath $tempOut -Force -ErrorAction SilentlyContinue
        }
    }

    It 'Produces different ciphertext for different keys' {
        $plain = 'same plaintext'
        $keyA = ConvertTo-SecureString -String 'keyA-secret' -AsPlainText -Force
        $keyB = ConvertTo-SecureString -String 'keyB-secret' -AsPlainText -Force
        $sourceA = New-TemporaryFile
        $sourceB = New-TemporaryFile
        $encA = $null
        $encB = $null
        try {
            Set-Content -LiteralPath $sourceA -Value $plain -NoNewline
            Set-Content -LiteralPath $sourceB -Value $plain -NoNewline
            $encA = [string](Protect-FileWithEncryption -Path $sourceA -SecureKey $keyA)['Path']
            $encB = [string](Protect-FileWithEncryption -Path $sourceB -SecureKey $keyB)['Path']
            $bytesA = [Convert]::ToBase64String([IO.File]::ReadAllBytes($encA))
            $bytesB = [Convert]::ToBase64String([IO.File]::ReadAllBytes($encB))
            $bytesA | Should -Not -Be $bytesB
        }
        finally {
            Remove-Item -LiteralPath $sourceA -Force -ErrorAction SilentlyContinue
            Remove-Item -LiteralPath $sourceB -Force -ErrorAction SilentlyContinue
            if ($encA) { Remove-Item -LiteralPath $encA -Force -ErrorAction SilentlyContinue }
            if ($encB) { Remove-Item -LiteralPath $encB -Force -ErrorAction SilentlyContinue }
        }
    }
}
