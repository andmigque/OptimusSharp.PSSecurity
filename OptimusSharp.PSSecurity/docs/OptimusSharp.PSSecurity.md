 # OptimusSharp.PSSecurity

 > Module loader for the OptimusSharp.PSSecurity security toolkit.

 Sets strict mode, opts out of telemetry, and fixes the hash-index policy at module scope.
 Dot-sources the Private helpers and Public functions, gates the Windows-only and Linux-only
 surfaces on the host platform, then exports the platform-appropriate public function set.

 > Module-scope policy. The hash-index settings are read by Write-DirectoryHashes and Get-IndexableFile.
 > Cross-platform surface. Always loaded.
 > Windows-only surface. ACL inspection and repair, UAC policy, local-admin creation, Authenticode audit.
 > Linux-only surface. Cron hardening, audit reporting, mkcert certificates.
