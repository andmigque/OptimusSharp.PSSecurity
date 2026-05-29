using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

#### # Assert-Administrator
    function Assert-Administrator {
        #### Throw unless the current session is elevated to Administrator.
        ####
        #### **Returns**
        #### - *None. Throws when the session is not elevated.*
        $principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
        if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            throw 'This operation requires Administrator privileges. Run from an elevated session.'
        }
    }

