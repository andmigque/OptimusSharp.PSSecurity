using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

#### # Get-SecureRandom32
function Get-SecureRandom32 {
    #### Generate a cryptographically secure random alphanumeric string.
    ####
    #### **Parameters**
    #### - `[int]`: __Length__
    ####     - *Length of the output string. Range 1 to 512. Defaults to 32.*
    ####
    #### **Returns**
    #### - `[string]`
    ####     - *Random alphanumeric string from the set `[A-Za-z0-9]`.*
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 512)]
        [int]$Length = 32
    )

    $alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
    return -join (1..$Length | ForEach-Object { $alphabet[[RandomNumberGenerator]::GetInt32(0, $alphabet.Length)] })
}

