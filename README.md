# OptimusSharp.PSSecurity

> A cross-platform PowerShell security toolkit. File integrity indexing, AES-256 file
> encryption, secure randomness, Windows ACL and UAC management, local-admin provisioning,
> Authenticode auditing, and Linux cron and certificate hardening.

![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/OptimusSharp.PSSecurity)
![PowerShell](https://img.shields.io/badge/PowerShell-7%2B-5391FE)
![Edition](https://img.shields.io/badge/edition-Core-2b579a)
![License](https://img.shields.io/badge/license-MIT-2ea44f)



## Install

```powershell
Install-Module -Name OptimusSharp.PSSecurity -RequiredVersion 1.1.0
```

The module targets PowerShell 7 or later on the Core edition.

## Quick start

Generate a cryptographically secure token.

```powershell
Import-Module OptimusSharp.PSSecurity
Get-SecureRandom32
```

Produces a 32-character alphanumeric string.

```text
2rGyl1WxcJcnHIbynrRZzGHN8kQ4pTfa
```

Write an integrity index over a directory tree.

```powershell
Write-DirectoryHashes -Path .\release
```

`HashIndex.md` and `HashIndex.json` land in the target directory, and a count prints to the host.

```text
Hashed 42 files into .\release\HashIndex.md and .\release\HashIndex.json
```

Round-trip a file through AES-256.

```powershell
$key = Read-Host -AsSecureString
$enc = Protect-FileWithEncryption -Path .\secret.txt -SecureKey $key
Unprotect-EncryptedFile -EncryptedFilePath $enc.Path -FilePassword $key -OutputFilePath .\secret.out
```

## Functions

### Cross-platform

| Function | Purpose |
| :--- | :--- |
| `Get-Hash` | Hash a file with MD5, SHA1, SHA256, SHA384, or SHA512. |
| `Get-SecureRandom32` | Generate a secure random alphanumeric string of length 1 to 512. |
| `Protect-FileWithEncryption` | Encrypt a file with AES-256-CBC and a PBKDF2-derived key. |
| `Unprotect-EncryptedFile` | Decrypt a file produced by `Protect-FileWithEncryption`. |
| `Write-DirectoryHashes` | Write `HashIndex.md` and `HashIndex.json` across a tree. |

### Windows

| Function | Purpose |
| :--- | :--- |
| `Get-AclItem` / `Show-AclItem` | List or render the access control entries on a path. |
| `Get-AclItemOwner` / `Set-AclItemOwner` | Read or set the owner of a path. |
| `Repair-AclItemOwnership` | Reassign ownership across a tree. |
| `Grant-AclItem` / `Revoke-AclItem` | Add or remove an access control entry. |
| `Copy-AclItem` | Copy an access control list from one path to another. |
| `Set-AclItemInheritance` | Enable or disable inheritance on a path. |
| `Get-AclItemAccountUnknown` / `Show-AclItemAccountUnknown` | Find orphaned SIDs in an ACL. |
| `Get-AclItemAccountAnomalies` | Report access control anomalies. |
| `Remove-AclItemAccountUnknown` | Strip orphaned SIDs from an ACL. |
| `Reset-AclItem` | Strip explicit entries back to inherited. |
| `Set-UacRequirePassword` / `Set-UacConsentOnly` | Set the UAC admin consent prompt. |
| `Get-UacConfiguration` | Read UAC policy and STIG compliance. |
| `New-LocalAdminUser` | Create a local user in the Administrators group. |
| `Get-ApplicationSignatureAudit` | Audit Authenticode signatures across PATH. |

### Linux

| Function | Purpose |
| :--- | :--- |
| `Set-CronPermissions` | Restrict the standard cron directories to 700. |
| `Show-SecurityReport` | Print an aureport audit summary. |
| `Start-SecurityWatch` | Tail the audit log in real time. |
| `New-SecurityCertificate` | Generate locally-trusted TLS certificates via mkcert. |

## Platform support

The five cross-platform functions load everywhere. The Windows surface loads only on Windows,
and the Linux surface only on Linux. The loader gates each set on the host, so importing on the
wrong platform never defines a function it cannot run.

## Development

The module is built and tested through Invoke-Build from the repository root.

| Task | What it does |
| :--- | :--- |
| `Invoke-Build -Task test_pssecurity` | Run the Pester 5 unit suite. Elevated cases skip unless elevated. |
| `Invoke-Build -Task test_security_elevated` | Run the elevated ACL, UAC, and local-admin integration cases. |
| `Invoke-Build -Task build_pssecurity_docs` | Generate the SharpDown Markdown under `docs`. |
| `Invoke-Build -Task publish_pssecurity` | Publish to the Gallery. Dry-run unless `PSGALLERY_API_KEY` is set. |

## License

MIT. See [LICENSE](LICENSE).
