<p align="center">
  <img
    src="https://raw.githubusercontent.com/andmigque/OptimusSharp.StaticAssets/refs/heads/main/optimus-mark-96.png"
    alt="Optimus Sharp"
    width="96"
    height="96" />
</p>

<h1 align="center">OptimusSharp.PSSecurity</h1>

<p align="center">
  A cross-platform PowerShell security toolkit.<br />
  File integrity indexing, AES-256 encryption, secure randomness,<br />
  Windows ACL and UAC management, local-admin provisioning,<br />
  and Authenticode auditing.
</p>

<p align="center">
  <a href="https://www.powershellgallery.com/packages/OptimusSharp.PSSecurity">
    <img alt="PowerShell Gallery Version" src="https://img.shields.io/powershellgallery/v/OptimusSharp.PSSecurity" />
  </a>
  <a href="https://www.powershellgallery.com/packages/OptimusSharp.PSSecurity">
    <img alt="PowerShell Gallery Downloads" src="https://img.shields.io/powershellgallery/dt/OptimusSharp.PSSecurity" />
  </a>
  <img alt="PowerShell 7+" src="https://img.shields.io/badge/PowerShell-7%2B-5391FE" />
  <img alt="Edition Core" src="https://img.shields.io/badge/edition-Core-2b579a" />
  <img alt="License MIT" src="https://img.shields.io/badge/license-MIT-2ea44f" />
</p>

---

## 🚀 Quick Start

Install from the
[PowerShell Gallery](https://www.powershellgallery.com/packages/OptimusSharp.PSSecurity).

```powershell
Install-Module -Name OptimusSharp.PSSecurity
```

Then generate a cryptographically secure token.

```powershell
Import-Module OptimusSharp.PSSecurity
```

```powershell
Get-SecureRandom32
```

It produces a 32-character alphanumeric string.

```text
2rGyl1WxcJcnHIbynrRZzGHN8kQ4pTfa
```

## 🔙 Background

Security chores are scattered across ad-hoc scripts and platform tools.

This module gathers them into one toolkit: hashing and integrity indexing,
AES-256 file encryption, secure randomness, Windows ACL and UAC management,
local-admin provisioning, and Authenticode auditing.

It targets PowerShell 7 or later on the Core edition.

## 🔐 How To

Write an integrity index over a directory tree.

```powershell
Write-DirectoryHashes -Path .\release
```

`HashIndex.md` and `HashIndex.json` land in the target directory.

```text
Hashed 42 files into .\release\HashIndex.md and .\release\HashIndex.json
```

Round-trip a file through AES-256. Read the key once, then reuse it.

```powershell
$key = Read-Host -AsSecureString
```

```powershell
$enc = Protect-FileWithEncryption -Path .\secret.txt -SecureKey $key
```

Splat the decrypt parameters so each option stays on its own line.

```powershell
$restore = @{
    EncryptedFilePath = $enc.Path
    FilePassword      = $key
    OutputFilePath    = '.\secret.out'
}
```

```powershell
Unprotect-EncryptedFile @restore
```

## 🧩 Functions

### Cross-platform

| Function | Purpose |
| :--- | :--- |
| `Get-Hash` | Hash a file with MD5, SHA1, SHA256, SHA384, or SHA512. |
| `Get-SecureRandom32` | Generate a secure alphanumeric string, length 1 to 512. |
| `Protect-FileWithEncryption` | Encrypt a file with AES-256-CBC and a PBKDF2 key. |
| `Unprotect-EncryptedFile` | Decrypt a file from `Protect-FileWithEncryption`. |
| `Write-DirectoryHashes` | Write `HashIndex.md` and `HashIndex.json` across a tree. |

### Windows

| Function | Purpose |
| :--- | :--- |
| `Get-AclItem` / `Show-AclItem` | List or render the access control entries on a path. |
| `Get-AclItemOwner` / `Set-AclItemOwner` | Read or set the owner of a path. |
| `Repair-AclItemOwnership` | Reassign ownership across a tree. |
| `Grant-AclItem` / `Revoke-AclItem` | Add or remove an access control entry. |
| `Copy-AclItem` | Copy an access control list between paths. |
| `Set-AclItemInheritance` | Enable or disable inheritance on a path. |
| `Get-AclItemAccountUnknown` | Find orphaned SIDs in an ACL. |
| `Show-AclItemAccountUnknown` | Render orphaned SIDs in an ACL. |
| `Get-AclItemAccountAnomalies` | Report access control anomalies. |
| `Remove-AclItemAccountUnknown` | Strip orphaned SIDs from an ACL. |
| `Reset-AclItem` | Strip explicit entries back to inherited. |
| `Set-UacRequirePassword` | Require a password at the UAC prompt. |
| `Set-UacConsentOnly` | Set the UAC prompt to consent only. |
| `Get-UacConfiguration` | Read UAC policy and STIG compliance. |
| `New-LocalAdminUser` | Create a local user in the Administrators group. |
| `Get-ApplicationSignatureAudit` | Audit Authenticode signatures across PATH. |

## 📦 Links

- [PowerShell Gallery](https://www.powershellgallery.com/packages/OptimusSharp.PSSecurity)
- [Source on GitHub](https://github.com/andmigque/OptimusSharp.PSSecurity)
- [Changelog](CHANGELOG.md)

## 📄 License

MIT. See [LICENSE](LICENSE).
