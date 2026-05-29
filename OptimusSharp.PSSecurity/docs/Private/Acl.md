 # Get-AclPathTargets
```powershell
function Get-AclPathTargets
```
 Internal helper. Resolve a path to a list of `FileSystemInfo` targets. Used by all ACL functions to handle `-Recurse`, `-File`, and `-Directory` filtering consistently.

 **Parameters**
 - `[string]`: __Path__
     - *Root path to resolve.*
 - `[switch]`: __Recurse__
     - *Walk children recursively.*
 - `[switch]`: __File__
     - *Include only files.*
 - `[switch]`: __Directory__
     - *Include only directories.*

 **Returns**
 - `[List[FileSystemInfo]]`
     - *Resolved targets.*
