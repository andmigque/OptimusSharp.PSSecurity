 # Set-CronPermissions
```powershell
function Set-CronPermissions
```
 Restrict all standard cron directories to 700 via `sudo chmod`.

 **Returns**
 - *None. Writes status to host per directory.*
 # Show-SecurityReport
```powershell
function Show-SecurityReport
```
 Print an aureport summary of audit events.
 # Start-SecurityWatch
```powershell
function Start-SecurityWatch
```
 Tail the Linux audit log in real time.
 # New-SecurityCertificate
```powershell
function New-SecurityCertificate
```
 Generate locally-trusted TLS certificates via mkcert for a hostname and optional subdomains.

 **Parameters**
 - `[string]`: __Hostname__
     - *Primary hostname. Defaults to the system hostname.*
 - `[string[]]`: __Subdomains__
     - *Optional subdomain prefixes. Each becomes `<subdomain>.<Hostname>`.*

 **Returns**
 - `[PSCustomObject[]]`
     - `[string]`: __Domain__
         - *Fully-qualified domain the certificate was generated for.*
     - `[string]`: __Status__
         - *Always `'Generated'`.*
