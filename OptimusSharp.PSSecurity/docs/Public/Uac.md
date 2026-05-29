 # Set-UacRequirePassword
```powershell
function Set-UacRequirePassword
```
 Set UAC to prompt for credentials on the secure desktop — STIG V-220963 compliant. Requires Administrator.

 **Returns**
 - `[PSCustomObject]`
     - `[string]`: __Setting__
         - *Always `'ConsentPromptBehaviorAdmin'`.*
     - `[int]`: __Before__
         - *Previous registry value.*
     - `[int]`: __After__
         - *New registry value (`1`).*
     - `[string]`: __Status__
         - *Human-readable status message.*
 # Set-UacConsentOnly
```powershell
function Set-UacConsentOnly
```
 Set UAC back to consent-only elevation — the Windows default (value 5). Requires Administrator.

 **Returns**
 - `[PSCustomObject]`
     - `[string]`: __Setting__
         - *Always `'ConsentPromptBehaviorAdmin'`.*
     - `[int]`: __Before__
         - *Previous registry value.*
     - `[int]`: __After__
         - *New registry value (`5`).*
     - `[string]`: __Status__
         - *Human-readable status message.*
 # Get-UacConfiguration
```powershell
function Get-UacConfiguration
```
 Read UAC registry settings and evaluate STIG compliance across V-220963, V-220964, V-220965.

 **Returns**
 - `[PSCustomObject]`
     - `[int]`: __ConsentPromptBehaviorAdmin__
         - *Raw registry value (0–5).*
     - `[string]`: __ConsentPromptBehaviorAdminMeaning__
         - *Human-readable interpretation of the prompt behavior.*
     - `[int]`: __EnableLUA__
         - *`1` if UAC is enabled, `0` if disabled.*
     - `[string]`: __EnableLUAMeaning__
         - *Either `'UAC Enabled'` or `'UAC Disabled (INSECURE)'`.*
     - `[int]`: __PromptOnSecureDesktop__
         - *`1` if the secure desktop is used for prompts, `0` otherwise.*
     - `[string]`: __PromptOnSecureDesktopMeaning__
         - *Human-readable interpretation.*
     - `[bool]`: __StigCompliant__
         - *`$true` when all three settings match the STIG baseline.*
     - `[string]`: __StigStatus__
         - *Status message naming the relevant STIG controls.*
