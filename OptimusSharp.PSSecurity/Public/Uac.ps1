using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

    #### # Set-UacRequirePassword
    function Set-UacRequirePassword {
        #### Set UAC to prompt for credentials on the secure desktop — STIG V-220963 compliant. Requires Administrator.
        ####
        #### **Returns**
        #### - `[PSCustomObject]`
        ####     - `[string]`: __Setting__
        ####         - *Always `'ConsentPromptBehaviorAdmin'`.*
        ####     - `[int]`: __Before__
        ####         - *Previous registry value.*
        ####     - `[int]`: __After__
        ####         - *New registry value (`1`).*
        ####     - `[string]`: __Status__
        ####         - *Human-readable status message.*
        [CmdletBinding()]
        param()

        Assert-Administrator

        $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
        $before = Get-ItemProperty -Path $regPath -Name ConsentPromptBehaviorAdmin
        Set-ItemProperty -Path $regPath -Name ConsentPromptBehaviorAdmin -Value 1
        $after = Get-ItemProperty -Path $regPath -Name ConsentPromptBehaviorAdmin

        [PSCustomObject]@{
            Setting = 'ConsentPromptBehaviorAdmin'
            Before  = $before.ConsentPromptBehaviorAdmin
            After   = $after.ConsentPromptBehaviorAdmin
            Status  = 'Password required for elevation (STIG-compliant)'
        }
    }

    #### # Set-UacConsentOnly
    function Set-UacConsentOnly {
        #### Set UAC back to consent-only elevation — the Windows default (value 5). Requires Administrator.
        ####
        #### **Returns**
        #### - `[PSCustomObject]`
        ####     - `[string]`: __Setting__
        ####         - *Always `'ConsentPromptBehaviorAdmin'`.*
        ####     - `[int]`: __Before__
        ####         - *Previous registry value.*
        ####     - `[int]`: __After__
        ####         - *New registry value (`5`).*
        ####     - `[string]`: __Status__
        ####         - *Human-readable status message.*
        [CmdletBinding()]
        param()

        Assert-Administrator

        $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'

        $before = Get-ItemProperty -Path $regPath -Name ConsentPromptBehaviorAdmin

        Set-ItemProperty -Path $regPath -Name ConsentPromptBehaviorAdmin -Value 5

        
        $after = Get-ItemProperty -Path $regPath -Name ConsentPromptBehaviorAdmin

        [PSCustomObject]@{
            Setting = 'ConsentPromptBehaviorAdmin'
            Before  = $before.ConsentPromptBehaviorAdmin
            After   = $after.ConsentPromptBehaviorAdmin
            Status  = 'Consent-only elevation (Windows default)'
        }
    }

    #### # Get-UacConfiguration
    function Get-UacConfiguration {
        #### Read UAC registry settings and evaluate STIG compliance across V-220963, V-220964, V-220965.
        ####
        #### **Returns**
        #### - `[PSCustomObject]`
        ####     - `[int]`: __ConsentPromptBehaviorAdmin__
        ####         - *Raw registry value (0–5).*
        ####     - `[string]`: __ConsentPromptBehaviorAdminMeaning__
        ####         - *Human-readable interpretation of the prompt behavior.*
        ####     - `[int]`: __EnableLUA__
        ####         - *`1` if UAC is enabled, `0` if disabled.*
        ####     - `[string]`: __EnableLUAMeaning__
        ####         - *Either `'UAC Enabled'` or `'UAC Disabled (INSECURE)'`.*
        ####     - `[int]`: __PromptOnSecureDesktop__
        ####         - *`1` if the secure desktop is used for prompts, `0` otherwise.*
        ####     - `[string]`: __PromptOnSecureDesktopMeaning__
        ####         - *Human-readable interpretation.*
        ####     - `[bool]`: __StigCompliant__
        ####         - *`$true` when all three settings match the STIG baseline.*
        ####     - `[string]`: __StigStatus__
        ####         - *Status message naming the relevant STIG controls.*
        [CmdletBinding()]
        param()

        $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
        $config = Get-ItemProperty -Path $regPath

        $stigCompliant = $config.ConsentPromptBehaviorAdmin -eq 1 -and
        $config.EnableLUA -eq 1 -and
        $config.PromptOnSecureDesktop -eq 1

        [PSCustomObject]@{
            ConsentPromptBehaviorAdmin        = $config.ConsentPromptBehaviorAdmin
            ConsentPromptBehaviorAdminMeaning = switch ($config.ConsentPromptBehaviorAdmin) {
                0 { 'Elevate without prompting (INSECURE)' }
                1 { 'Prompt for credentials on secure desktop (STIG-COMPLIANT)' }
                2 { 'Prompt for consent on secure desktop' }
                3 { 'Prompt for credentials' }
                4 { 'Prompt for consent' }
                5 { 'Prompt for consent for non-Windows binaries (DEFAULT)' }
                default { 'Unknown' }
            }
            EnableLUA                         = $config.EnableLUA
            EnableLUAMeaning                  = if ($config.EnableLUA -eq 1) { 'UAC Enabled' } else { 'UAC Disabled (INSECURE)' }
            PromptOnSecureDesktop             = $config.PromptOnSecureDesktop
            PromptOnSecureDesktopMeaning      = if ($config.PromptOnSecureDesktop -eq 1) { 'Secure Desktop Enabled' } else { 'Secure Desktop Disabled' }
            StigCompliant                     = $stigCompliant
            StigStatus                        = if ($stigCompliant) { 'COMPLIANT (STIG V-220963, V-220964, V-220965)' } else { 'NON-COMPLIANT - Run Set-UacRequirePassword' }
        }
    }

