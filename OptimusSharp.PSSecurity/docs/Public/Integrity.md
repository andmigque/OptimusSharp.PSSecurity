```powershell
function Write-DirectoryHashes
```
 Hash files under `Path` and write both `HashIndex.md` and `HashIndex.json` into that directory.

 JSON is a flat array of `{ File, Hash, Path }` records for agents and tooling.
 Markdown carries a header block and dash-prefixed `path,file,hash` rows for humans.
 Algorithm (`SHA256`), include list, and exclude list are fixed at the module scope
 (`$script:HashIndexAlgorithm`, `$script:HashIndexInclude`, `$script:HashIndexExclude`).

 Directory exclusion is enforced at traversal time by `Get-IndexableFile`, not after enumeration.
 Build output and similar trees (`bin`, `obj`, `node_modules`, `.git`) are never descended into.

 **Parameters**
 - `[string]`: __Path__
     - *Root directory to walk.*

 **Returns**
 - *None. Writes `<Path>\HashIndex.md`, `<Path>\HashIndex.json`, and a count line to host.*
 # Get-Hash
```powershell
function Get-Hash
```
 Hash a file using the specified algorithm.

 **Parameters**
 - `[string]`: __Path__
     - *Path to the file.*
 - `[string]`: __Algorithm__
     - *Hash algorithm. One of `MD5`, `SHA1`, `SHA256`, `SHA384`, `SHA512`. Defaults to `MD5`.*

 **Returns**
 - `[string]`
     - *Hex hash string.*

 **Throws**
 - When `Path` does not resolve to an existing file.
