using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

    #### # New-LocalAdminUser
    function New-LocalAdminUser {
        #### Create a local user account and add it to the Administrators group. Requires Administrator.
        ####
        #### **Parameters**
        #### - `[PSCredential]`: __Credential__
        ####     - *Username and password for the new account.*
        #### - `[string]`: __FullName__
        ####     - *Display name. Optional.*
        #### - `[string]`: __Description__
        ####     - *Account description. Optional.*
        #### - `[switch]`: __PasswordNeverExpires__
        ####     - *Sets the account password to never expire.*
        ####
        #### **Returns**
        #### - `[PSCustomObject]`
        ####     - `[string]`: __Username__
        ####         - *Account name from `Credential.UserName`.*
        ####     - `[string]`: __FullName__
        ####         - *Display name, or empty if not supplied.*
        ####     - `[bool]`: __Created__
        ####         - *Always `$true` on success.*
        ####     - `[bool]`: __IsAdministrator__
        ####         - *Always `$true` — the user is added to the Administrators group.*
        ####     - `[bool]`: __PasswordNeverExpires__
        ####         - *Reflects the `-PasswordNeverExpires` switch.*
        [CmdletBinding()]
        param(
            [Parameter(Mandatory = $true)]
            [System.Management.Automation.PSCredential]
            [System.Management.Automation.Credential()]
            $Credential,

            [Parameter(Mandatory = $false)]
            [string]$FullName,

            [Parameter(Mandatory = $false)]
            [string]$Description,

            [Parameter(Mandatory = $false)]
            [switch]$PasswordNeverExpires
        )

        Assert-Administrator

        $userParams = @{
            Name     = $Credential.UserName
            Password = $Credential.Password
        }

        if ($FullName) { $userParams['FullName'] = $FullName }
        if ($Description) { $userParams['Description'] = $Description }
        if ($PasswordNeverExpires) { $userParams['PasswordNeverExpires'] = $true }

        New-LocalUser @userParams | Out-Null
        Add-LocalGroupMember -Group 'Administrators' -Member $Credential.UserName

        [PSCustomObject]@{
            Username             = $Credential.UserName
            FullName             = $FullName
            Created              = $true
            IsAdministrator      = $true
            PasswordNeverExpires = $PasswordNeverExpires.IsPresent
        }
    }

