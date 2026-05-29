 # Get-IndexableFile
```powershell
function Get-IndexableFile
```
 Walk a directory tree and yield the files worth indexing.
 Exclusion happens at the traversal decision, never after enumeration.

 A directory whose `Name` is in `Exclude` is never descended into.
 A file is yielded only when its `Name` matches a wildcard in `Include`.

 **Parameters**
 - `[DirectoryInfo]`: __Directory__
     - *Root to walk.*
 - `[string[]]`: __Include__
     - *Wildcard patterns matched against each file name.*
 - `[string[]]`: __Exclude__
     - *Directory names refused at traversal time.*

 **Returns**
 - `[FileInfo]`
     - *One per matching file, streamed as the walk proceeds.*
