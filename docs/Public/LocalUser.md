 # New-LocalAdminUser
```powershell
function New-LocalAdminUser
```
 Create a local user account and add it to the Administrators group. Requires Administrator.

 **Parameters**
 - `[PSCredential]`: __Credential__
     - *Username and password for the new account.*
 - `[string]`: __FullName__
     - *Display name. Optional.*
 - `[string]`: __Description__
     - *Account description. Optional.*
 - `[switch]`: __PasswordNeverExpires__
     - *Sets the account password to never expire.*

 **Returns**
 - `[PSCustomObject]`
     - `[string]`: __Username__
         - *Account name from `Credential.UserName`.*
     - `[string]`: __FullName__
         - *Display name, or empty if not supplied.*
     - `[bool]`: __Created__
         - *Always `$true` on success.*
     - `[bool]`: __IsAdministrator__
         - *Always `$true` — the user is added to the Administrators group.*
     - `[bool]`: __PasswordNeverExpires__
         - *Reflects the `-PasswordNeverExpires` switch.*
