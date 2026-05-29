 # Unprotect-EncryptedFile
```powershell
function Unprotect-EncryptedFile
```
 Decrypt a file encrypted by `Protect-FileWithEncryption`.
 Uses AES-256-CBC with PBKDF2 key derivation.

 **Parameters**
 - `[string]`: __EncryptedFilePath__
     - *Path to the `.enc` file.*
 - `[securestring]`: __FilePassword__
     - *Password used during encryption.*
 - `[string]`: __OutputFilePath__
     - *Destination path for the decrypted output.*

 **Returns**
 - `[PSCustomObject]`
     - `[string]`: __Status__
         - *Always `'Success'`.*
     - `[string]`: __EncryptedFile__
         - *Resolved path of the input.*
     - `[string]`: __DecryptedFile__
         - *Path of the decrypted output.*
     - `[int]`: __EncryptedFileSizeKB__
         - *Size of the input in KB.*
     - `[int]`: __DecryptedFileSizeKB__
         - *Size of the output in KB.*
     - `[string]`: __Salt__
         - *Base64-encoded salt read from the file header.*
     - `[string]`: __IV__
         - *Base64-encoded AES IV read from the file header.*
 # Protect-FileWithEncryption
```powershell
function Protect-FileWithEncryption
```
 Encrypt a file with AES-256-CBC.
 Derives a 256-bit key from `SecureKey` via PBKDF2 using 100 000 iterations.
 Writes a 32-byte header of salt + IV followed by ciphertext.
 Output is the source path with `.enc` appended.

 **Parameters**
 - `[string]`: __Path__
     - *Path to the file to encrypt. Accepts pipeline input.*
 - `[securestring]`: __SecureKey__
     - *Encryption passphrase.*

 **Returns**
 - `[ImmutableDictionary[string, object]]`
     - *`Path` is the encrypted file path, plus `SizeBytes`.*
