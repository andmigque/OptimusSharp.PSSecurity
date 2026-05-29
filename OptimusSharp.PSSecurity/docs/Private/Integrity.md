 # Write-DirectoryHashes
```powershell
function Get-IndexableFile
```
 Recursive file enumeration with directory-level exclusion. Mirrors the PowerNixx ETL Index pattern:
 **exclusion occurs at the directory traversal decision point, never post-enumeration**.
 Directories whose `Name` is in `Exclude` are not descended into. Files in surviving directories
 are yielded only if their `Name` matches at least one wildcard in `Include`.

 **Parameters**
 - `[DirectoryInfo]`: __Directory__
     - *Root to walk.*
 - `[string[]]`: __Include__
     - *Wildcard patterns matched against each file's `Name`.*
 - `[string[]]`: __Exclude__
     - *Directory names refused at traversal time.*

 **Returns**
 - `[FileInfo]` *(stream)*
     - *One per matching file, yielded as the walk proceeds.*
