#### # OptimusSharp.PSSecurity
####
#### > Module loader for the OptimusSharp.PSSecurity security toolkit.
####
#### Sets strict mode, opts out of telemetry, and fixes the hash-index policy at module scope.
#### Dot-sources the Private helpers and Public functions, gates the Windows-only and Linux-only
#### surfaces on the host platform, then exports the platform-appropriate public function set.
####
using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

Set-StrictMode -Version Latest
$env:POWERSHELL_TELEMETRY_OPTOUT = 'true'

#### > Module-scope policy. The hash-index settings are read by Write-DirectoryHashes and Get-IndexableFile.
$script:OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$script:IsInteractive = $Host.Name -eq 'ConsoleHost' -and $Host.UI -and $Host.UI.RawUI -and [Environment]::UserInteractive
$script:HasConsole = -not [Console]::IsInputRedirected -and -not [Console]::IsOutputRedirected
$script:HashIndexAlgorithm = 'SHA256'
$script:HashIndexInclude = @('*.md', '*.ps1', '*.psm1', '*.cs', '*.psd1', '*.ts', '*.sql', '*.json', '*.csv', '*.zip', '*.js', '*.cshtml')
$script:HashIndexExclude = @('bin', 'obj', 'node_modules', '.git')

$here = $PSScriptRoot

#### > Cross-platform surface. Always loaded.
. (Join-Path $here 'Private' 'Integrity.ps1')
. (Join-Path $here 'Public' 'Integrity.ps1')
. (Join-Path $here 'Public' 'Encryption.ps1')
. (Join-Path $here 'Public' 'Random.ps1')

$publicFunctions = @(
    'Get-Hash'
    'Get-SecureRandom32'
    'Protect-FileWithEncryption'
    'Unprotect-EncryptedFile'
    'Write-DirectoryHashes'
)

#### > Windows-only surface. ACL inspection and repair, UAC policy, local-admin creation, Authenticode audit.
if ($IsWindows) {
    . (Join-Path $here 'Private' 'Admin.ps1')
    . (Join-Path $here 'Private' 'Acl.ps1')
    . (Join-Path $here 'Public' 'Acl.ps1')
    . (Join-Path $here 'Public' 'Uac.ps1')
    . (Join-Path $here 'Public' 'LocalUser.ps1')
    . (Join-Path $here 'Public' 'Signature.ps1')

    $publicFunctions += @(
        'Get-AclItem'
        'Show-AclItem'
        'Get-AclItemOwner'
        'Set-AclItemOwner'
        'Repair-AclItemOwnership'
        'Grant-AclItem'
        'Revoke-AclItem'
        'Copy-AclItem'
        'Set-AclItemInheritance'
        'Get-AclItemAccountUnknown'
        'Show-AclItemAccountUnknown'
        'Get-AclItemAccountAnomalies'
        'Remove-AclItemAccountUnknown'
        'Reset-AclItem'
        'Set-UacRequirePassword'
        'Set-UacConsentOnly'
        'Get-UacConfiguration'
        'New-LocalAdminUser'
        'Get-ApplicationSignatureAudit'
    )
}

#### > Linux-only surface. Cron hardening, audit reporting, mkcert certificates.
if ($IsLinux) {
    . (Join-Path $here 'Public' 'Linux.ps1')

    $publicFunctions += @(
        'Set-CronPermissions'
        'Show-SecurityReport'
        'Start-SecurityWatch'
        'New-SecurityCertificate'
    )
}

Export-ModuleMember -Function $publicFunctions
