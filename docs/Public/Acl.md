 # Get-AclItem
```powershell
function Get-AclItem
```
 Return all ACEs for a path as structured objects.
 One row per ACE per target.

 **Parameters**
 - `[string]`: __Path__
     - *File or directory path. Accepts pipeline input.*
 - `[switch]`: __Recurse__ / __File__ / __Directory__
     - *Passed to `Get-AclPathTargets` for target scoping.*

 **Returns**
 - `[PSCustomObject[]]`
     - `[string]`: __Path__
         - *Absolute path of the item.*
     - `[string]`: __ItemType__
         - *`'File'` or `'Directory'`.*
     - `[string]`: __Owner__
         - *Current owner principal.*
     - `[string]`: __IdentityReference__
         - *Principal the ACE applies to.*
     - `[FileSystemRights]`: __FileSystemRights__
         - *Rights granted or denied.*
     - `[AccessControlType]`: __AccessControlType__
         - *`Allow` or `Deny`.*
     - `[bool]`: __IsInherited__
         - *`$true` if inherited from a parent container.*
     - `[InheritanceFlags]`: __InheritanceFlags__
         - *How inheritance propagates.*
     - `[PropagationFlags]`: __PropagationFlags__
         - *Inheritance propagation modifiers.*
 # Show-AclItem
```powershell
function Show-AclItem
```
 Format `Get-AclItem` output as an auto-sized table to the host.

 **Parameters**
 - `[string]`: __Path__
     - *File or directory path. Accepts pipeline input.*
 - `[switch]`: __Recurse__ / __File__ / __Directory__
     - *Passed through to `Get-AclItem`.*
 # Get-AclItemOwner
```powershell
function Get-AclItemOwner
```
 Return ownership information for each target.
 Reports who owns it and whether the owner is SYSTEM, Administrators, or the current user.

 **Parameters**
 - `[string]`: __Path__
     - *File or directory path. Accepts pipeline input.*
 - `[switch]`: __Recurse__ / __File__ / __Directory__
     - *Passed to `Get-AclPathTargets`.*

 **Returns**
 - `[PSCustomObject[]]`
     - `[string]`: __Path__
         - *Absolute path of the item.*
     - `[string]`: __ItemType__
         - *`'File'` or `'Directory'`.*
     - `[string]`: __Owner__
         - *Current owner principal.*
     - `[bool]`: __IsAdminOwned__
         - *Owner matches `*Administrators*`.*
     - `[bool]`: __IsSystemOwned__
         - *Owner matches `*SYSTEM*`.*
     - `[bool]`: __IsCurrentUserOwned__
         - *Owner matches the current `$env:USERNAME`.*
 # Set-AclItemOwner
```powershell
function Set-AclItemOwner
```
 Change the owner of one or more file system items.
 Requires Administrator.
 Supports `-WhatIf`.

 **Parameters**
 - `[string]`: __Path__
     - *File or directory path. Accepts pipeline input.*
 - `[string]`: __Identity__
     - *New owner as `DOMAIN\User`. Defaults to the current user.*
 - `[switch]`: __Recurse__ / __File__ / __Directory__
     - *Passed to `Get-AclPathTargets`.*

 **Returns**
 - `[PSCustomObject[]]`
     - `[string]`: __Path__
         - *Absolute path of the item.*
     - `[string]`: __ItemType__
         - *`'File'` or `'Directory'`.*
     - `[string]`: __PreviousOwner__
         - *Owner before the change.*
     - `[string]`: __NewOwner__
         - *Owner after the change.*
     - `[string]`: __Status__
         - *`'Changed'` on success, or `'Error: <message>'` on failure.*
 # Repair-AclItemOwnership
```powershell
function Repair-AclItemOwnership
```
 Convenience wrapper that calls `Set-AclItemOwner -Recurse`.
 Reassigns ownership across an entire directory tree.
 Requires Administrator.

 **Parameters**
 - `[string]`: __Path__
     - *Root path. Accepts pipeline input.*
 - `[string]`: __Identity__
     - *New owner as `DOMAIN\User`. Defaults to the current user.*
 # Grant-AclItem
```powershell
function Grant-AclItem
```
 Add a `FileSystemAccessRule` to one or more targets.
 Requires Administrator.
 Supports `-WhatIf`.

 **Parameters**
 - `[string]`: __Path__
     - *File or directory path. Accepts pipeline input.*
 - `[string]`: __Identity__
     - *Principal to grant access to, for example `DOMAIN\User`.*
 - `[FileSystemRights]`: __Rights__
     - *Rights to grant, for example `ReadAndExecute`, `Modify`, or `FullControl`.*
 - `[AccessControlType]`: __AccessControlType__
     - *`Allow` or `Deny`. Defaults to `Allow`.*
 - `[InheritanceFlags]`: __InheritanceFlags__
     - *Defaults to `ContainerInherit, ObjectInherit`.*
 - `[switch]`: __Recurse__ / __File__ / __Directory__
     - *Passed to `Get-AclPathTargets`.*

 **Returns**
 - `[PSCustomObject[]]`
     - `[string]`: __Path__
         - *Absolute path of the item.*
     - `[string]`: __ItemType__
         - *`'File'` or `'Directory'`.*
     - `[string]`: __Identity__
         - *Principal that received the grant.*
     - `[FileSystemRights]`: __Rights__
         - *Rights granted.*
     - `[AccessControlType]`: __AccessControlType__
         - *`Allow` or `Deny`.*
     - `[string]`: __Status__
         - *`'Granted'` on success, or `'Error: <message>'` on failure.*
 # Revoke-AclItem
```powershell
function Revoke-AclItem
```
 Remove ACEs matching an identity from one or more targets.
 If `-Rights` is specified, only ACEs that include those rights are removed.
 Requires Administrator.
 Supports `-WhatIf`.

 **Parameters**
 - `[string]`: __Path__
     - *File or directory path. Accepts pipeline input.*
 - `[string]`: __Identity__
     - *Principal whose ACEs to remove.*
 - `[FileSystemRights]`: __Rights__
     - *Optional rights filter. Omit to remove all ACEs for the identity.*
 - `[switch]`: __Recurse__ / __File__ / __Directory__
     - *Passed to `Get-AclPathTargets`.*

 **Returns**
 - `[PSCustomObject[]]`
     - `[string]`: __Path__
         - *Absolute path of the item.*
     - `[string]`: __ItemType__
         - *`'File'` or `'Directory'`.*
     - `[string]`: __Identity__
         - *Principal whose ACEs were revoked.*
     - `[int]`: __RemovedCount__
         - *Number of ACEs removed.*
     - `[string]`: __Status__
         - *`'Revoked'`, `'NoMatchFound'`, or `'Error: <message>'`.*
 # Copy-AclItem
```powershell
function Copy-AclItem
```
 Apply the full ACL from a source path to one or more destination paths.
 Requires Administrator.
 Supports `-WhatIf`.

 **Parameters**
 - `[string]`: __Source__
     - *Path whose ACL to copy from.*
 - `[string[]]`: __Destination__
     - *One or more target paths. Accepts pipeline input.*

 **Returns**
 - `[PSCustomObject[]]`
     - `[string]`: __Source__
         - *Resolved source path.*
     - `[string]`: __Destination__
         - *Resolved destination path.*
     - `[string]`: __Owner__
         - *Owner from the source ACL.*
     - `[int]`: __AceCount__
         - *Number of ACEs copied.*
     - `[string]`: __Status__
         - *`'Copied'` on success, or `'Error: <message>'` on failure.*
 # Set-AclItemInheritance
```powershell
function Set-AclItemInheritance
```
 Enable or disable ACL inheritance on file system items.
 Use `-Enable` to restore inheritance or `-Disable` to break it.
 `-PreserveExisting` copies inherited rules as explicit ACEs before breaking.
 Requires Administrator.
 Supports `-WhatIf`.

 **Parameters**
 - `[string]`: __Path__
     - *File or directory path. Accepts pipeline input.*
 - `[switch]`: __Enable__
     - *Restore inheritance. This is the default parameter set.*
 - `[switch]`: __Disable__
     - *Break inheritance.*
 - `[switch]`: __PreserveExisting__
     - *When disabling, copy inherited rules as explicit ACEs before breaking.*
     - *Only valid with `-Disable`.*
 - `[switch]`: __Recurse__ / __File__ / __Directory__
     - *Passed to `Get-AclPathTargets`.*

 **Returns**
 - `[PSCustomObject[]]`
     - `[string]`: __Path__
         - *Absolute path of the item.*
     - `[string]`: __ItemType__
         - *`'File'` or `'Directory'`.*
     - `[bool]`: __InheritanceEnabled__
         - *Reflects the `-Enable` switch.*
     - `[int]`: __PreservedCount__
         - *Inherited ACEs copied as explicit when `-PreserveExisting` is used.*
     - `[string]`: __Status__
         - *`'Applied'` on success, or `'Error: <message>'` on failure.*
 # Get-AclItemAccountUnknown
```powershell
function Get-AclItemAccountUnknown
```
 Filter ACEs where `IdentityReference` is a raw SID such as `S-1-...`.
 A raw SID indicates a deleted or orphaned account.

 **Parameters**
 - `[string]`: __Path__
     - *File or directory path. Accepts pipeline input.*
 - `[switch]`: __Recurse__ / __File__ / __Directory__
     - *Passed to `Get-AclItem`.*

 **Returns**
 - `[PSCustomObject[]]`
     - *Same shape as `Get-AclItem`, filtered to orphaned SID entries.*
 # Show-AclItemAccountUnknown
```powershell
function Show-AclItemAccountUnknown
```
 Format `Get-AclItemAccountUnknown` as a table, or print a green "clean" message if none are found.

 **Parameters**
 - `[string]`: __Path__
     - *File or directory path. Accepts pipeline input.*
 - `[switch]`: __Recurse__ / __File__ / __Directory__
     - *Passed through to `Get-AclItemAccountUnknown`.*
 # Get-AclItemAccountAnomalies
```powershell
function Get-AclItemAccountAnomalies
```
 Detect anomalous ACEs.
 Flags orphaned SIDs, Sandbox principals, and unexpected writes from untrusted identities.
 Each result includes an `AnomalyReasons` field listing which rules fired.

 **Parameters**
 - `[string]`: __Path__
     - *File or directory path. Accepts pipeline input.*
 - `[string[]]`: __TrustedPrincipals__
     - *Identities considered safe.*
     - *Defaults to `NT AUTHORITY\SYSTEM`, `BUILTIN\Administrators`, and `CREATOR OWNER`.*
 - `[switch]`: __Recurse__ / __File__ / __Directory__
     - *Passed to `Get-AclItem`.*

 **Returns**
 - `[PSCustomObject[]]`
     - `[string]`: __Path__
         - *Absolute path of the item.*
     - `[string]`: __ItemType__
         - *`'File'` or `'Directory'`.*
     - `[string]`: __IdentityReference__
         - *Principal the anomalous ACE applies to.*
     - `[FileSystemRights]`: __FileSystemRights__
         - *Rights granted or denied.*
     - `[AccessControlType]`: __AccessControlType__
         - *`Allow` or `Deny`.*
     - `[bool]`: __IsInherited__
         - *`$true` if inherited from a parent.*
     - `[string]`: __AnomalyReasons__
         - *Comma-separated list of triggered rules.*
         - *One or more of `OrphanedSid`, `SandboxPrincipal`, and `UnexpectedWrite`.*
 # Remove-AclItemAccountUnknown
```powershell
function Remove-AclItemAccountUnknown
```
 Remove all ACEs with orphaned SID identity references from one or more targets.
 Requires Administrator.
 Supports `-WhatIf`.

 **Parameters**
 - `[string]`: __Path__
     - *File or directory path. Accepts pipeline input.*
 - `[switch]`: __Recurse__ / __File__ / __Directory__
     - *Passed to `Get-AclPathTargets`.*

 **Returns**
 - `[PSCustomObject[]]`
     - `[string]`: __Path__
         - *Absolute path of the item.*
     - `[string]`: __ItemType__
         - *`'File'` or `'Directory'`.*
     - `[string[]]`: __RemovedSids__
         - *SID strings that were removed from the ACL.*
     - `[int]`: __RemovedCount__
         - *Number of orphaned SIDs removed.*
     - `[string]`: __Status__
         - *`'Cleaned'` when changes were made, `'Clean'` when none were needed.*
 # Reset-AclItem
```powershell
function Reset-AclItem
```
 Strip all explicit non-inherited ACEs from one or more targets, leaving only inherited rules.
 Requires Administrator.
 Supports `-WhatIf`.

 **Parameters**
 - `[string]`: __Path__
     - *File or directory path. Accepts pipeline input.*
 - `[switch]`: __Recurse__ / __File__ / __Directory__
     - *Passed to `Get-AclPathTargets`.*

 **Returns**
 - `[PSCustomObject[]]`
     - `[string]`: __Path__
         - *Absolute path of the item.*
     - `[string]`: __ItemType__
         - *`'File'` or `'Directory'`.*
     - `[int]`: __BeforeCount__
         - *Total ACE count before the reset.*
     - `[int]`: __AfterCount__
         - *Total ACE count after the reset.*
     - `[int]`: __Removed__
         - *Number of explicit ACEs stripped.*
     - `[string]`: __Status__
         - *`'Reset'` when ACEs were removed, `'AlreadyClean'` when none were explicit.*
