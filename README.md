<p align="center">
  <img
    src="https://raw.githubusercontent.com/andmigque/OptimusSharp.StaticAssets/refs/heads/main/optimus.svg"
    alt="Optimus Sharp"
    width="96" />
</p>

<h1 align="center">
  OptimusSharp
  <br />
  PSSecurity
</h1>

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

Every project repeats the same security chores. Hash a release. Encrypt a
secret. Audit an ACL. The scripts get copied, drift, and rot.

This module gathers those chores into one toolkit:

- Hashing and directory integrity indexing
- AES-256 file encryption
- Cryptographically secure randomness
- Windows ACL and UAC management
- Local-admin provisioning
- Authenticode auditing

It runs on PowerShell 7 and the Core edition.

## 🔐 How To

Write an integrity index over a directory tree.

```powershell
Write-DirectoryHashes -Path .\release
```

`HashIndex.md` and `HashIndex.json` land in the target directory.

```text
Hashed 42 files into .\release\HashIndex.md and .\release\HashIndex.json
```

Round-trip a file through AES-256. Pull the key from a vault with
[SecretManagement](https://learn.microsoft.com/powershell/utility-modules/secretmanagement/overview),
then reuse it for both directions.

```powershell
$key = Get-Secret -Name OptimusFileKey
```

```powershell
$enc = Protect-FileWithEncryption -Path .\secret.txt -SecureKey $key
```

Splat the decrypt parameters to keep each option on its own line.

```powershell
$restore = @{
    EncryptedFilePath = $enc['Path']
    FilePassword      = $key
    OutputFilePath    = '.\secret.out'
}
```

```powershell
Unprotect-EncryptedFile @restore
```

## 🧩 Functions

### Cross-platform

- **`Get-Hash`** hashes a file with MD5, SHA1, SHA256, SHA384, or SHA512.
- **`Get-SecureRandom32`** generates a secure alphanumeric string of length 1 to 512.
- **`Protect-FileWithEncryption`** encrypts a file with AES-256-CBC and a PBKDF2 key.
- **`Unprotect-EncryptedFile`** decrypts a file from `Protect-FileWithEncryption`.
- **`Write-DirectoryHashes`** writes `HashIndex.md` and `HashIndex.json` across a tree.

### Windows

- **`Get-AclItem`** and **`Show-AclItem`** list or render the access control entries on a path.
- **`Get-AclItemOwner`** and **`Set-AclItemOwner`** read or set the owner of a path.
- **`Repair-AclItemOwnership`** reassigns ownership across a tree.
- **`Grant-AclItem`** and **`Revoke-AclItem`** add or remove an access control entry.
- **`Copy-AclItem`** copies an access control list between paths.
- **`Set-AclItemInheritance`** enables or disables inheritance on a path.
- **`Get-AclItemAccountUnknown`** finds orphaned SIDs in an ACL.
- **`Show-AclItemAccountUnknown`** renders orphaned SIDs in an ACL.
- **`Get-AclItemAccountAnomalies`** reports access control anomalies.
- **`Remove-AclItemAccountUnknown`** strips orphaned SIDs from an ACL.
- **`Reset-AclItem`** strips explicit entries back to inherited.
- **`Set-UacRequirePassword`** requires a password at the UAC prompt.
- **`Set-UacConsentOnly`** sets the UAC prompt to consent only.
- **`Get-UacConfiguration`** reads UAC policy and STIG compliance.
- **`New-LocalAdminUser`** creates a local user in the Administrators group.
- **`Get-ApplicationSignatureAudit`** audits Authenticode signatures across PATH.

## 📦 Links

- [PowerShell Gallery](https://www.powershellgallery.com/packages/OptimusSharp.PSSecurity)
- [Source on GitHub](https://github.com/andmigque/OptimusSharp.PSSecurity)
- [Changelog](CHANGELOG.md)

## 📄 License

MIT. See [LICENSE](LICENSE).
