# Changelog

All notable changes to `OptimusSharp.PSSecurity` are documented here. The format follows
Keep a Changelog, and the project adheres to Semantic Versioning.

## [1.0.0] - 2026-05-28

### Added

- Initial release. Extracted from the OptimusSharp `src/Script/OptimusSecurity.psm1` monolith
  into a standard module with `Public` and `Private` domain files and a platform-gated loader.
- Cross-platform functions: `Get-Hash`, `Get-SecureRandom32`, `Protect-FileWithEncryption`,
  `Unprotect-EncryptedFile`, `Write-DirectoryHashes`.
- Windows functions: ACL inspection and repair, UAC policy, local-admin provisioning, and
  Authenticode signature auditing.
- Linux functions: cron permission hardening, audit reporting, and mkcert certificate creation.
