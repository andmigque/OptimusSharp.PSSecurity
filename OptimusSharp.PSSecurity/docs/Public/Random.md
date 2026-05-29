 # Get-SecureRandom32
```powershell
function Get-SecureRandom32
```
 Generate a cryptographically secure random alphanumeric string.

 **Parameters**
 - `[int]`: __Length__
     - *Length of the output string. Range 1–512. Defaults to 32.*

 **Returns**
 - `[string]`
     - *Random alphanumeric string from the set `[A-Za-z0-9]`.*
