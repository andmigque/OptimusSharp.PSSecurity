 # Backup-FilesParallel
```powershell
function Backup-FilesParallel
```
 Mirror a directory tree to a destination as gzip files.
 The walk is recursive and the destination mirrors the source tree.
 Compression runs in parallel across files.
 Per-file failures are collected and written to `CompressionErrors.json`.
 Progress and elapsed time print when the host is interactive.

 **Parameters**
 - `[string]`: __Path__
     - *Existing source directory. Walked recursively.*
 - `[string]`: __OutPath__
     - *Destination root. Created if missing. Mirrors the source tree.*
 - `[int]`: __Throttle__
     - *Throttle for `ForEach-Object -Parallel`. Defaults to 4.*

 **Returns**
 - *None. Writes `.gz` files to `OutPath`, plus `CompressionErrors.json` on partial failure.*

 **Throws**
 - *When `Path` does not exist.*
