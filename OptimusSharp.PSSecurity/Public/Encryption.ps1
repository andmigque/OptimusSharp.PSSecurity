using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

#### # Unprotect-EncryptedFile
function Unprotect-EncryptedFile {
    #### Decrypt a file encrypted by `Protect-FileWithEncryption`. AES-256-CBC with PBKDF2 key derivation.
    ####
    #### **Parameters**
    #### - `[string]`: __EncryptedFilePath__
    ####     - *Path to the `.enc` file.*
    #### - `[securestring]`: __FilePassword__
    ####     - *Password used during encryption.*
    #### - `[string]`: __OutputFilePath__
    ####     - *Destination path for the decrypted output.*
    ####
    #### **Returns**
    #### - `[PSCustomObject]`
    ####     - `[string]`: __Status__
    ####         - *Always `'Success'`.*
    ####     - `[string]`: __EncryptedFile__
    ####         - *Resolved path of the input.*
    ####     - `[string]`: __DecryptedFile__
    ####         - *Path of the decrypted output.*
    ####     - `[int]`: __EncryptedFileSizeKB__
    ####         - *Size of the input in KB.*
    ####     - `[int]`: __DecryptedFileSizeKB__
    ####         - *Size of the output in KB.*
    ####     - `[string]`: __Salt__
    ####         - *Base64-encoded salt read from the file header.*
    ####     - `[string]`: __IV__
    ####         - *Base64-encoded AES IV read from the file header.*
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$EncryptedFilePath,

        [Parameter(Mandatory = $true)]
        [securestring]$FilePassword,

        [Parameter(Mandatory = $true)]
        [string]$OutputFilePath
    )

    $EncryptedFilePath = Resolve-Path -Path $EncryptedFilePath -ErrorAction Stop

    try {
        $encryptedStream = [File]::Open($EncryptedFilePath, 'Open', 'Read')

        try {
            
            $salt = [byte[]]::new(16)
            $encryptedStream.Read($salt, 0, $salt.Length) | Out-Null

            $iv = [byte[]]::new(16)
            $encryptedStream.Read($iv, 0, $iv.Length) | Out-Null

            
            $pbkdf2 = [Rfc2898DeriveBytes]::new($FilePassword, $salt, 100000)
            $key = $pbkdf2.GetBytes(32)

            
            $aes = [Aes]::Create()
            $aes.Key = $key
            $aes.IV = $iv

            
            $decryptor = $aes.CreateDecryptor()

            
            $cryptoStream = [CryptoStream]::new($encryptedStream, $decryptor, [CryptoStreamMode]::Read)

            
            $outputStream = [File]::Open($OutputFilePath, 'Create', 'Write')

            try {
                
                $buffer = [byte[]]::new(4096)
                while (($bytesRead = $cryptoStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
                    $outputStream.Write($buffer, 0, $bytesRead)
                }

                $dataObject = [PSCustomObject]@{
                    Status              = 'Success'
                    EncryptedFile       = $EncryptedFilePath
                    DecryptedFile       = $OutputFilePath
                    EncryptedFileSizeKB = (([FileInfo]::new($EncryptedFilePath).Length / 1KB) -as [int])
                    DecryptedFileSizeKB = (([FileInfo]::new($OutputFilePath).Length / 1KB) -as [int])
                    Salt                = ([Convert]::ToBase64String($salt))
                    IV                  = ([Convert]::ToBase64String($iv))
                }

                $dataObject
            }
            finally {
                
                $outputStream.Close()
                $cryptoStream.Close()
            }
        }
        finally {
            $encryptedStream.Close()
        }
    }
    catch {
        throw
    }
}

#### # Protect-FileWithEncryption
function Protect-FileWithEncryption {
    #### Encrypt a file with AES-256-CBC. Derives a 256-bit key from `SecureKey` via PBKDF2 (100 000 iterations). Writes a 32-byte header of salt + IV followed by ciphertext. Output is the source path with `.enc` appended.
    ####
    #### **Parameters**
    #### - `[string]`: __Path__
    ####     - *Path to the file to encrypt. Accepts pipeline input.*
    #### - `[securestring]`: __SecureKey__
    ####     - *Encryption passphrase.*
    ####
    #### **Returns**
    #### - `[ImmutableDictionary[string, object]]`
    ####     - *`Path` (encrypted file path) and `SizeBytes`.*
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('FilePath')]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [securestring]$SecureKey
    )

    process {
        $FilePath = Resolve-Path -Path $Path -ErrorAction Stop

        $salt = [byte[]]::new(16)
        [RandomNumberGenerator]::Fill($salt)

        $aes = [Aes]::Create()
        $aes.Key = ([Rfc2898DeriveBytes]::new($SecureKey, $salt, 100000)).GetBytes(32)
        $aes.GenerateIV()

        $encryptedFilePath = [string]$FilePath + '.enc'
        $fileStream = [File]::Open($FilePath, 'Open', 'Read')
        $encryptedStream = [File]::Open($encryptedFilePath, 'Create', 'Write')
        $cryptoStream = $null

        try {
            $encryptedStream.Write($salt, 0, $salt.Length)
            $encryptedStream.Write($aes.IV, 0, $aes.IV.Length)
            $cryptoStream = [CryptoStream]::new($encryptedStream, $aes.CreateEncryptor(), [CryptoStreamMode]::Write)

            $buffer = [byte[]]::new(4096)
            while (($bytesRead = $fileStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
                $cryptoStream.Write($buffer, 0, $bytesRead)
            }
        }
        finally {
            if ($cryptoStream) { $cryptoStream.Close() }
            $fileStream.Close()
            $encryptedStream.Close()
        }

        [ImmutableDictionary[string, object]]::Empty.Add('Path', $encryptedFilePath).Add('SizeBytes', [FileInfo]::new($encryptedFilePath).Length)
    }
}

