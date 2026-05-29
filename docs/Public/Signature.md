 # Get-ApplicationSignatureAudit
```powershell
function Get-ApplicationSignatureAudit
```
 Audit Authenticode signatures for all commands visible in PATH.
 Excludes WindowsApps stubs.

 **Parameters**
 - `[int]`: __ThrottleLimit__
     - *Parallel throttle limit. Range 1 to 64. Defaults to 4.*

 **Returns**
 - `[PSCustomObject[]]`
     - `[string]`: __Name__
         - *Command name.*
     - `[string]`: __Path__
         - *Absolute path to the executable.*
     - `[string]`: __Status__
         - *Authenticode signature status, for example `Valid`, `NotSigned`, or `Error`.*
     - `[string]`: __StatusMessage__
         - *Free-form status text from the signature check.*
     - `[string]`: __SignerCertificate__
         - *Subject of the signer certificate, or `'Unsigned'`.*
     - `[string]`: __TimeStamper__
         - *Subject of the timestamp certificate, or `'None'`.*
     - `[bool]`: __IsOSBinary__
         - *`$true` for Microsoft-signed OS binaries.*
     - `[string]`: __SignatureType__
         - *Signature type, for example `Authenticode`, `Catalog`, or `Unknown`.*
