 # Write-DirectoryHashes
```powershell
function Write-DirectoryHashes
```
 Hash every file under `Path` and write the index into that directory.
 Two files are produced: `HashIndex.json` and `HashIndex.md`.

 The JSON is a flat array of `{ File, Hash, Path }` records for tooling.
 The Markdown carries a header block and `path,file,hash` rows for humans.

 Algorithm, include, and exclude lists are fixed at module scope.
 The default algorithm is `SHA256`.
 The default exclude set covers `bin`, `obj`, `node_modules`, and `.git`.

 Excluded directories are refused at traversal time by `Get-IndexableFile`.
 They are never descended into, so their files are never hashed.

 **Parameters**
 - `[string]`: __Path__
     - *Root directory to walk.*

 **Returns**
 - *None. Writes `HashIndex.md` and `HashIndex.json`, then prints a count.*
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
