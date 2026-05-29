using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

    #### # Get-ApplicationSignatureAudit
    function Get-ApplicationSignatureAudit {
        #### Audit Authenticode signatures for all commands visible in PATH. Excludes WindowsApps stubs.
        ####
        #### **Parameters**
        #### - `[int]`: __ThrottleLimit__
        ####     - *Parallel throttle limit. Range 1–64. Defaults to 4.*
        ####
        #### **Returns**
        #### - `[PSCustomObject[]]`
        ####     - `[string]`: __Name__
        ####         - *Command name.*
        ####     - `[string]`: __Path__
        ####         - *Absolute path to the executable.*
        ####     - `[string]`: __Status__
        ####         - *Authenticode signature status (e.g. `Valid`, `NotSigned`, `Error`).*
        ####     - `[string]`: __StatusMessage__
        ####         - *Free-form status text from the signature check.*
        ####     - `[string]`: __SignerCertificate__
        ####         - *Subject of the signer certificate, or `'Unsigned'`.*
        ####     - `[string]`: __TimeStamper__
        ####         - *Subject of the timestamp certificate, or `'None'`.*
        ####     - `[bool]`: __IsOSBinary__
        ####         - *`$true` for Microsoft-signed OS binaries.*
        ####     - `[string]`: __SignatureType__
        ####         - *Signature type (e.g. `Authenticode`, `Catalog`, `Unknown`).*
        [CmdletBinding()]
        [OutputType([PSCustomObject[]])]
        param(
            [Parameter()]
            [ValidateRange(1, 64)]
            [int] $ThrottleLimit = 4
        )

        Get-Command -CommandType Application -All |
        Where-Object { $_.Source -notlike "*\AppData\Local\Microsoft\WindowsApps\*" } |
        ForEach-Object -Parallel {
            $cmd = $_
            try {
                $sig = Get-AuthenticodeSignature -FilePath $cmd.Source -ErrorAction Stop
                [PSCustomObject]@{
                    Name              = $cmd.Name
                    Path              = $cmd.Source
                    Status            = $sig.Status.ToString()
                    StatusMessage     = $sig.StatusMessage
                    SignerCertificate = if ($sig.SignerCertificate) { $sig.SignerCertificate.Subject } else { 'Unsigned' }
                    TimeStamper       = if ($sig.TimeStamperCertificate) { $sig.TimeStamperCertificate.Subject } else { 'None' }
                    IsOSBinary        = $sig.IsOSBinary
                    SignatureType     = $sig.SignatureType.ToString()
                }
            }
            catch {
                [PSCustomObject]@{
                    Name              = $cmd.Name
                    Path              = $cmd.Source
                    Status            = 'Error'
                    StatusMessage     = $_.Exception.Message
                    SignerCertificate = 'Error'
                    TimeStamper       = 'None'
                    IsOSBinary        = $false
                    SignatureType     = 'Unknown'
                }
            }
        } -ThrottleLimit $ThrottleLimit
    }

