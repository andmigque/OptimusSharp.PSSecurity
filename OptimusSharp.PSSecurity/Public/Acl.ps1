using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

    #### # Get-AclItem
    function Get-AclItem {
        #### Return all ACEs for a path as structured objects. One row per ACE per target.
        ####
        #### **Parameters**
        #### - `[string]`: __Path__
        ####     - *File or directory path. Accepts pipeline input.*
        #### - `[switch]`: __Recurse__ / __File__ / __Directory__
        ####     - *Passed to `Get-AclPathTargets` for target scoping.*
        ####
        #### **Returns**
        #### - `[PSCustomObject[]]`
        ####     - `[string]`: __Path__
        ####         - *Absolute path of the item.*
        ####     - `[string]`: __ItemType__
        ####         - *`'File'` or `'Directory'`.*
        ####     - `[string]`: __Owner__
        ####         - *Current owner principal.*
        ####     - `[string]`: __IdentityReference__
        ####         - *Principal the ACE applies to.*
        ####     - `[FileSystemRights]`: __FileSystemRights__
        ####         - *Rights granted or denied.*
        ####     - `[AccessControlType]`: __AccessControlType__
        ####         - *`Allow` or `Deny`.*
        ####     - `[bool]`: __IsInherited__
        ####         - *`$true` if inherited from a parent container.*
        ####     - `[InheritanceFlags]`: __InheritanceFlags__
        ####         - *How inheritance propagates.*
        ####     - `[PropagationFlags]`: __PropagationFlags__
        ####         - *Inheritance propagation modifiers.*
        [CmdletBinding()]
        param(
            [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
            [ValidateNotNullOrEmpty()]
            [Alias('FullName')]
            [string]$Path,

            [Parameter()][switch]$Recurse,
            [Parameter()][switch]$File,
            [Parameter()][switch]$Directory
        )
        process {
            $targets = Get-AclPathTargets -Path $Path -Recurse:$Recurse -File:$File -Directory:$Directory
            foreach ($target in $targets) {
                $acl = Get-Acl -Path $target.FullName
                $itemType = if ($target -is [System.IO.DirectoryInfo]) { 'Directory' } else { 'File' }
                $acl.Access | ForEach-Object {
                    [PSCustomObject]@{
                        Path              = $target.FullName
                        ItemType          = $itemType
                        Owner             = $acl.Owner
                        IdentityReference = $_.IdentityReference.Value
                        FileSystemRights  = $_.FileSystemRights
                        AccessControlType = $_.AccessControlType
                        IsInherited       = $_.IsInherited
                        InheritanceFlags  = $_.InheritanceFlags
                        PropagationFlags  = $_.PropagationFlags
                    }
                }
            }
        }
    }

    #### # Show-AclItem
    function Show-AclItem {
        #### Format `Get-AclItem` output as an auto-sized table to the host.
        ####
        #### **Parameters**
        #### - `[string]`: __Path__
        ####     - *File or directory path. Accepts pipeline input.*
        #### - `[switch]`: __Recurse__ / __File__ / __Directory__
        ####     - *Passed through to `Get-AclItem`.*
        [CmdletBinding()]
        param(
            [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
            [ValidateNotNullOrEmpty()]
            [Alias('FullName')]
            [string]$Path,

            [Parameter()][switch]$Recurse,
            [Parameter()][switch]$File,
            [Parameter()][switch]$Directory
        )
        process {
            Get-AclItem -Path $Path -Recurse:$Recurse -File:$File -Directory:$Directory |
            Format-Table Path, ItemType, Owner, IdentityReference, FileSystemRights, AccessControlType, IsInherited -AutoSize
        }
    }

    #### # Get-AclItemOwner
    function Get-AclItemOwner {
        #### Return ownership information for each target: who owns it and whether the owner is SYSTEM, Administrators, or the current user.
        ####
        #### **Parameters**
        #### - `[string]`: __Path__
        ####     - *File or directory path. Accepts pipeline input.*
        #### - `[switch]`: __Recurse__ / __File__ / __Directory__
        ####     - *Passed to `Get-AclPathTargets`.*
        ####
        #### **Returns**
        #### - `[PSCustomObject[]]`
        ####     - `[string]`: __Path__
        ####         - *Absolute path of the item.*
        ####     - `[string]`: __ItemType__
        ####         - *`'File'` or `'Directory'`.*
        ####     - `[string]`: __Owner__
        ####         - *Current owner principal.*
        ####     - `[bool]`: __IsAdminOwned__
        ####         - *Owner matches `*Administrators*`.*
        ####     - `[bool]`: __IsSystemOwned__
        ####         - *Owner matches `*SYSTEM*`.*
        ####     - `[bool]`: __IsCurrentUserOwned__
        ####         - *Owner matches the current `$env:USERNAME`.*
        [CmdletBinding()]
        param(
            [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
            [ValidateNotNullOrEmpty()]
            [Alias('FullName')]
            [string]$Path,

            [Parameter()][switch]$Recurse,
            [Parameter()][switch]$File,
            [Parameter()][switch]$Directory
        )
        process {
            $targets = Get-AclPathTargets -Path $Path -Recurse:$Recurse -File:$File -Directory:$Directory
            foreach ($target in $targets) {
                $acl = Get-Acl -Path $target.FullName
                $owner = $acl.Owner
                $itemType = if ($target -is [System.IO.DirectoryInfo]) { 'Directory' } else { 'File' }
                [PSCustomObject]@{
                    Path               = $target.FullName
                    ItemType           = $itemType
                    Owner              = $owner
                    IsAdminOwned       = $owner -like '*Administrators*'
                    IsSystemOwned      = $owner -like '*SYSTEM*'
                    IsCurrentUserOwned = $owner -like "*$($env:USERNAME)*"
                }
            }
        }
    }

    #### # Set-AclItemOwner
    function Set-AclItemOwner {
        #### Change the owner of one or more file system items. Requires Administrator. Supports `-WhatIf`.
        ####
        #### **Parameters**
        #### - `[string]`: __Path__
        ####     - *File or directory path. Accepts pipeline input.*
        #### - `[string]`: __Identity__
        ####     - *New owner as `DOMAIN\User`. Defaults to the current user.*
        #### - `[switch]`: __Recurse__ / __File__ / __Directory__
        ####     - *Passed to `Get-AclPathTargets`.*
        ####
        #### **Returns**
        #### - `[PSCustomObject[]]`
        ####     - `[string]`: __Path__
        ####         - *Absolute path of the item.*
        ####     - `[string]`: __ItemType__
        ####         - *`'File'` or `'Directory'`.*
        ####     - `[string]`: __PreviousOwner__
        ####         - *Owner before the change.*
        ####     - `[string]`: __NewOwner__
        ####         - *Owner after the change.*
        ####     - `[string]`: __Status__
        ####         - *`'Changed'` on success, or `'Error: <message>'` on failure.*
        [CmdletBinding(SupportsShouldProcess)]
        param(
            [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
            [ValidateNotNullOrEmpty()]
            [Alias('FullName')]
            [string]$Path,

            [Parameter()]
            [ValidateNotNullOrEmpty()]
            [string]$Identity = "$($env:USERDOMAIN)\$($env:USERNAME)",

            [Parameter()][switch]$Recurse,
            [Parameter()][switch]$File,
            [Parameter()][switch]$Directory
        )
        begin {
            Assert-Administrator
            $newOwner = [System.Security.Principal.NTAccount]::new($Identity)
        }
        process {
            $targets = Get-AclPathTargets -Path $Path -Recurse:$Recurse -File:$File -Directory:$Directory
            foreach ($target in $targets) {
                $acl = Get-Acl -Path $target.FullName
                $previousOwner = $acl.Owner
                $itemType = if ($target -is [System.IO.DirectoryInfo]) { 'Directory' } else { 'File' }

                if ($PSCmdlet.ShouldProcess($target.FullName, "Set owner to '$Identity' (was '$previousOwner')")) {
                    try {
                        $acl.SetOwner($newOwner)
                        Set-Acl -Path $target.FullName -AclObject $acl
                        [PSCustomObject]@{
                            Path          = $target.FullName
                            ItemType      = $itemType
                            PreviousOwner = $previousOwner
                            NewOwner      = $Identity
                            Status        = 'Changed'
                        }
                    }
                    catch {
                        [PSCustomObject]@{
                            Path          = $target.FullName
                            ItemType      = $itemType
                            PreviousOwner = $previousOwner
                            NewOwner      = $Identity
                            Status        = "Error: $($_.Exception.Message)"
                        }
                    }
                }
            }
        }
    }

    #### # Repair-AclItemOwnership
    function Repair-AclItemOwnership {
        #### Convenience wrapper: calls `Set-AclItemOwner -Recurse` to reassign ownership across an entire directory tree. Requires Administrator.
        ####
        #### **Parameters**
        #### - `[string]`: __Path__
        ####     - *Root path. Accepts pipeline input.*
        #### - `[string]`: __Identity__
        ####     - *New owner as `DOMAIN\User`. Defaults to the current user.*
        [CmdletBinding(SupportsShouldProcess)]
        param(
            [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
            [ValidateNotNullOrEmpty()]
            [Alias('FullName')]
            [string]$Path,

            [Parameter()]
            [ValidateNotNullOrEmpty()]
            [string]$Identity = "$($env:USERDOMAIN)\$($env:USERNAME)"
        )
        begin {
            Assert-Administrator
        }
        process {
            Write-Host "Repairing ownership on '$Path' → '$Identity'" -ForegroundColor Cyan
            Set-AclItemOwner -Path $Path -Identity $Identity -Recurse -WhatIf:$WhatIfPreference
        }
    }

    #### # Grant-AclItem
    function Grant-AclItem {
        #### Add a `FileSystemAccessRule` to one or more targets. Requires Administrator. Supports `-WhatIf`.
        ####
        #### **Parameters**
        #### - `[string]`: __Path__
        ####     - *File or directory path. Accepts pipeline input.*
        #### - `[string]`: __Identity__
        ####     - *Principal to grant access to (e.g. `DOMAIN\User`).*
        #### - `[FileSystemRights]`: __Rights__
        ####     - *Rights to grant (e.g. `ReadAndExecute`, `Modify`, `FullControl`).*
        #### - `[AccessControlType]`: __AccessControlType__
        ####     - *`Allow` or `Deny`. Defaults to `Allow`.*
        #### - `[InheritanceFlags]`: __InheritanceFlags__
        ####     - *Defaults to `ContainerInherit, ObjectInherit`.*
        #### - `[switch]`: __Recurse__ / __File__ / __Directory__
        ####     - *Passed to `Get-AclPathTargets`.*
        ####
        #### **Returns**
        #### - `[PSCustomObject[]]`
        ####     - `[string]`: __Path__
        ####         - *Absolute path of the item.*
        ####     - `[string]`: __ItemType__
        ####         - *`'File'` or `'Directory'`.*
        ####     - `[string]`: __Identity__
        ####         - *Principal that received the grant.*
        ####     - `[FileSystemRights]`: __Rights__
        ####         - *Rights granted.*
        ####     - `[AccessControlType]`: __AccessControlType__
        ####         - *`Allow` or `Deny`.*
        ####     - `[string]`: __Status__
        ####         - *`'Granted'` on success, or `'Error: <message>'` on failure.*
        [CmdletBinding(SupportsShouldProcess)]
        param(
            [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
            [ValidateNotNullOrEmpty()]
            [Alias('FullName')]
            [string]$Path,

            [Parameter(Mandatory)]
            [ValidateNotNullOrEmpty()]
            [string]$Identity,

            [Parameter(Mandatory)]
            [System.Security.AccessControl.FileSystemRights]$Rights,

            [Parameter()]
            [System.Security.AccessControl.AccessControlType]$AccessControlType = [System.Security.AccessControl.AccessControlType]::Allow,

            [Parameter()]
            [System.Security.AccessControl.InheritanceFlags]$InheritanceFlags =
            [System.Security.AccessControl.InheritanceFlags]::ContainerInherit -bor
            [System.Security.AccessControl.InheritanceFlags]::ObjectInherit,

            [Parameter()]
            [System.Security.AccessControl.PropagationFlags]$PropagationFlags = [System.Security.AccessControl.PropagationFlags]::None,

            [Parameter()][switch]$Recurse,
            [Parameter()][switch]$File,
            [Parameter()][switch]$Directory
        )
        begin {
            Assert-Administrator
            $rule = [System.Security.AccessControl.FileSystemAccessRule]::new(
                $Identity, $Rights, $InheritanceFlags, $PropagationFlags, $AccessControlType
            )
        }
        process {
            $targets = Get-AclPathTargets -Path $Path -Recurse:$Recurse -File:$File -Directory:$Directory
            foreach ($target in $targets) {
                $itemType = if ($target -is [System.IO.DirectoryInfo]) { 'Directory' } else { 'File' }
                if ($PSCmdlet.ShouldProcess($target.FullName, "Grant '$Identity' $Rights ($AccessControlType)")) {
                    try {
                        $acl = Get-Acl -Path $target.FullName
                        $acl.AddAccessRule($rule)
                        Set-Acl -Path $target.FullName -AclObject $acl
                        [PSCustomObject]@{
                            Path              = $target.FullName
                            ItemType          = $itemType
                            Identity          = $Identity
                            Rights            = $Rights
                            AccessControlType = $AccessControlType
                            Status            = 'Granted'
                        }
                    }
                    catch {
                        [PSCustomObject]@{
                            Path              = $target.FullName
                            ItemType          = $itemType
                            Identity          = $Identity
                            Rights            = $Rights
                            AccessControlType = $AccessControlType
                            Status            = "Error: $($_.Exception.Message)"
                        }
                    }
                }
            }
        }
    }

    #### # Revoke-AclItem
    function Revoke-AclItem {
        #### Remove ACEs matching an identity from one or more targets. If `-Rights` is specified, only ACEs that include those rights are removed. Requires Administrator. Supports `-WhatIf`.
        ####
        #### **Parameters**
        #### - `[string]`: __Path__
        ####     - *File or directory path. Accepts pipeline input.*
        #### - `[string]`: __Identity__
        ####     - *Principal whose ACEs to remove.*
        #### - `[FileSystemRights]`: __Rights__
        ####     - *Optional rights filter. Omit to remove all ACEs for the identity.*
        #### - `[switch]`: __Recurse__ / __File__ / __Directory__
        ####     - *Passed to `Get-AclPathTargets`.*
        ####
        #### **Returns**
        #### - `[PSCustomObject[]]`
        ####     - `[string]`: __Path__
        ####         - *Absolute path of the item.*
        ####     - `[string]`: __ItemType__
        ####         - *`'File'` or `'Directory'`.*
        ####     - `[string]`: __Identity__
        ####         - *Principal whose ACEs were revoked.*
        ####     - `[int]`: __RemovedCount__
        ####         - *Number of ACEs removed.*
        ####     - `[string]`: __Status__
        ####         - *`'Revoked'`, `'NoMatchFound'`, or `'Error: <message>'`.*
        [CmdletBinding(SupportsShouldProcess)]
        param(
            [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
            [ValidateNotNullOrEmpty()]
            [Alias('FullName')]
            [string]$Path,

            [Parameter(Mandatory)]
            [ValidateNotNullOrEmpty()]
            [string]$Identity,

            [Parameter()]
            [System.Security.AccessControl.FileSystemRights]$Rights,

            [Parameter()][switch]$Recurse,
            [Parameter()][switch]$File,
            [Parameter()][switch]$Directory
        )
        begin {
            Assert-Administrator
        }
        process {
            $targets = Get-AclPathTargets -Path $Path -Recurse:$Recurse -File:$File -Directory:$Directory
            foreach ($target in $targets) {
                $itemType = if ($target -is [System.IO.DirectoryInfo]) { 'Directory' } else { 'File' }
                $acl = Get-Acl -Path $target.FullName
                $toRemove = $acl.Access | Where-Object {
                    $_.IdentityReference.Value -like "*$Identity*" -and
                    (-not $PSBoundParameters.ContainsKey('Rights') -or ($_.FileSystemRights -band $Rights))
                }

                if (-not $toRemove) {
                    [PSCustomObject]@{
                        Path         = $target.FullName
                        ItemType     = $itemType
                        Identity     = $Identity
                        RemovedCount = 0
                        Status       = 'NoMatchFound'
                    }
                    continue
                }

                if ($PSCmdlet.ShouldProcess($target.FullName, "Revoke $($toRemove.Count) ACE(s) for '$Identity'")) {
                    try {
                        foreach ($rule in $toRemove) { $acl.RemoveAccessRule($rule) | Out-Null }
                        Set-Acl -Path $target.FullName -AclObject $acl
                        [PSCustomObject]@{
                            Path         = $target.FullName
                            ItemType     = $itemType
                            Identity     = $Identity
                            RemovedCount = $toRemove.Count
                            Status       = 'Revoked'
                        }
                    }
                    catch {
                        [PSCustomObject]@{
                            Path         = $target.FullName
                            ItemType     = $itemType
                            Identity     = $Identity
                            RemovedCount = 0
                            Status       = "Error: $($_.Exception.Message)"
                        }
                    }
                }
            }
        }
    }

    #### # Copy-AclItem
    function Copy-AclItem {
        #### Apply the full ACL from a source path to one or more destination paths. Requires Administrator. Supports `-WhatIf`.
        ####
        #### **Parameters**
        #### - `[string]`: __Source__
        ####     - *Path whose ACL to copy from.*
        #### - `[string[]]`: __Destination__
        ####     - *One or more target paths. Accepts pipeline input.*
        ####
        #### **Returns**
        #### - `[PSCustomObject[]]`
        ####     - `[string]`: __Source__
        ####         - *Resolved source path.*
        ####     - `[string]`: __Destination__
        ####         - *Resolved destination path.*
        ####     - `[string]`: __Owner__
        ####         - *Owner from the source ACL.*
        ####     - `[int]`: __AceCount__
        ####         - *Number of ACEs copied.*
        ####     - `[string]`: __Status__
        ####         - *`'Copied'` on success, or `'Error: <message>'` on failure.*
        [CmdletBinding(SupportsShouldProcess)]
        param(
            [Parameter(Mandatory)]
            [ValidateNotNullOrEmpty()]
            [string]$Source,

            [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
            [ValidateNotNullOrEmpty()]
            [Alias('FullName')]
            [string[]]$Destination
        )
        begin {
            Assert-Administrator
            $sourceResolved = Resolve-Path -Path $Source -ErrorAction Stop
            $sourceAcl = Get-Acl -Path $sourceResolved.ProviderPath
        }
        process {
            foreach ($dest in $Destination) {
                $destResolved = Resolve-Path -Path $dest -ErrorAction Stop
                if ($PSCmdlet.ShouldProcess($destResolved.ProviderPath, "Apply ACL from '$($sourceResolved.ProviderPath)'")) {
                    try {
                        Set-Acl -Path $destResolved.ProviderPath -AclObject $sourceAcl
                        [PSCustomObject]@{
                            Source      = $sourceResolved.ProviderPath
                            Destination = $destResolved.ProviderPath
                            Owner       = $sourceAcl.Owner
                            AceCount    = $sourceAcl.Access.Count
                            Status      = 'Copied'
                        }
                    }
                    catch {
                        [PSCustomObject]@{
                            Source      = $sourceResolved.ProviderPath
                            Destination = $destResolved.ProviderPath
                            Owner       = $sourceAcl.Owner
                            AceCount    = $sourceAcl.Access.Count
                            Status      = "Error: $($_.Exception.Message)"
                        }
                    }
                }
            }
        }
    }

    #### # Set-AclItemInheritance
    function Set-AclItemInheritance {
        #### Enable or disable ACL inheritance on file system items. Use `-Enable` to restore inheritance or `-Disable` to break it. `-PreserveExisting` copies inherited rules as explicit ACEs before breaking. Requires Administrator. Supports `-WhatIf`.
        ####
        #### **Parameters**
        #### - `[string]`: __Path__
        ####     - *File or directory path. Accepts pipeline input.*
        #### - `[switch]`: __Enable__
        ####     - *Restore inheritance (default parameter set).*
        #### - `[switch]`: __Disable__
        ####     - *Break inheritance.*
        #### - `[switch]`: __PreserveExisting__
        ####     - *When disabling, copy inherited rules as explicit ACEs before breaking. Only valid with `-Disable`.*
        #### - `[switch]`: __Recurse__ / __File__ / __Directory__
        ####     - *Passed to `Get-AclPathTargets`.*
        ####
        #### **Returns**
        #### - `[PSCustomObject[]]`
        ####     - `[string]`: __Path__
        ####         - *Absolute path of the item.*
        ####     - `[string]`: __ItemType__
        ####         - *`'File'` or `'Directory'`.*
        ####     - `[bool]`: __InheritanceEnabled__
        ####         - *Reflects the `-Enable` switch.*
        ####     - `[int]`: __PreservedCount__
        ####         - *Inherited ACEs copied as explicit when `-PreserveExisting` is used.*
        ####     - `[string]`: __Status__
        ####         - *`'Applied'` on success, or `'Error: <message>'` on failure.*
        [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Enable')]
        param(
            [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
            [ValidateNotNullOrEmpty()]
            [Alias('FullName')]
            [string]$Path,

            [Parameter(Mandatory, ParameterSetName = 'Enable')]
            [switch]$Enable,

            [Parameter(Mandatory, ParameterSetName = 'Disable')]
            [switch]$Disable,

            [Parameter(ParameterSetName = 'Disable')]
            [switch]$PreserveExisting,

            [Parameter()][switch]$Recurse,
            [Parameter()][switch]$File,
            [Parameter()][switch]$Directory
        )
        begin {
            Assert-Administrator
        }
        process {
            $targets = Get-AclPathTargets -Path $Path -Recurse:$Recurse -File:$File -Directory:$Directory
            foreach ($target in $targets) {
                $itemType = if ($target -is [System.IO.DirectoryInfo]) { 'Directory' } else { 'File' }
                $acl = Get-Acl -Path $target.FullName
                $action = if ($Enable) { 'Enable inheritance' } else { 'Disable inheritance' }

                if ($PSCmdlet.ShouldProcess($target.FullName, $action)) {
                    try {
                        $preservedCount = 0
                        if ($Disable) {
                            $acl.SetAccessRuleProtection($true, $PreserveExisting.IsPresent)
                            if ($PreserveExisting) {
                                $preservedCount = ($acl.Access | Where-Object { $_.IsInherited }).Count
                            }
                        }
                        else {
                            $acl.SetAccessRuleProtection($false, $false)
                        }
                        Set-Acl -Path $target.FullName -AclObject $acl
                        [PSCustomObject]@{
                            Path               = $target.FullName
                            ItemType           = $itemType
                            InheritanceEnabled = $Enable.IsPresent
                            PreservedCount     = $preservedCount
                            Status             = 'Applied'
                        }
                    }
                    catch {
                        [PSCustomObject]@{
                            Path               = $target.FullName
                            ItemType           = $itemType
                            InheritanceEnabled = $Enable.IsPresent
                            PreservedCount     = 0
                            Status             = "Error: $($_.Exception.Message)"
                        }
                    }
                }
            }
        }
    }

    #### # Get-AclItemAccountUnknown
    function Get-AclItemAccountUnknown {
        #### Filter ACEs where `IdentityReference` is a raw SID (`S-1-...`), indicating a deleted or orphaned account.
        ####
        #### **Parameters**
        #### - `[string]`: __Path__
        ####     - *File or directory path. Accepts pipeline input.*
        #### - `[switch]`: __Recurse__ / __File__ / __Directory__
        ####     - *Passed to `Get-AclItem`.*
        ####
        #### **Returns**
        #### - `[PSCustomObject[]]`
        ####     - *Same shape as `Get-AclItem`, filtered to orphaned SID entries.*
        [CmdletBinding()]
        param(
            [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
            [ValidateNotNullOrEmpty()]
            [Alias('FullName')]
            [string]$Path,

            [Parameter()][switch]$Recurse,
            [Parameter()][switch]$File,
            [Parameter()][switch]$Directory
        )
        process {
            Get-AclItem -Path $Path -Recurse:$Recurse -File:$File -Directory:$Directory |
            Where-Object { $_.IdentityReference -match '^S-1-' }
        }
    }

    #### # Show-AclItemAccountUnknown
    function Show-AclItemAccountUnknown {
        #### Format `Get-AclItemAccountUnknown` as a table, or print a green "clean" message if none are found.
        ####
        #### **Parameters**
        #### - `[string]`: __Path__
        ####     - *File or directory path. Accepts pipeline input.*
        #### - `[switch]`: __Recurse__ / __File__ / __Directory__
        ####     - *Passed through to `Get-AclItemAccountUnknown`.*
        [CmdletBinding()]
        param(
            [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
            [ValidateNotNullOrEmpty()]
            [Alias('FullName')]
            [string]$Path,

            [Parameter()][switch]$Recurse,
            [Parameter()][switch]$File,
            [Parameter()][switch]$Directory
        )
        process {
            $unknown = Get-AclItemAccountUnknown -Path $Path -Recurse:$Recurse -File:$File -Directory:$Directory
            if (-not $unknown) {
                Write-Host "No unknown account principals found on: $Path" -ForegroundColor Green
                return
            }
            $unknown | Format-Table Path, IdentityReference, FileSystemRights, AccessControlType -AutoSize
        }
    }

    #### # Get-AclItemAccountAnomalies
    function Get-AclItemAccountAnomalies {
        #### Detect anomalous ACEs: orphaned SIDs, Sandbox principals, and unexpected write permissions from untrusted identities. Each result includes an `AnomalyReasons` field listing which rules fired.
        ####
        #### **Parameters**
        #### - `[string]`: __Path__
        ####     - *File or directory path. Accepts pipeline input.*
        #### - `[string[]]`: __TrustedPrincipals__
        ####     - *Identities considered safe. Defaults to `NT AUTHORITY\SYSTEM`, `BUILTIN\Administrators`, `CREATOR OWNER`.*
        #### - `[switch]`: __Recurse__ / __File__ / __Directory__
        ####     - *Passed to `Get-AclItem`.*
        ####
        #### **Returns**
        #### - `[PSCustomObject[]]`
        ####     - `[string]`: __Path__
        ####         - *Absolute path of the item.*
        ####     - `[string]`: __ItemType__
        ####         - *`'File'` or `'Directory'`.*
        ####     - `[string]`: __IdentityReference__
        ####         - *Principal the anomalous ACE applies to.*
        ####     - `[FileSystemRights]`: __FileSystemRights__
        ####         - *Rights granted or denied.*
        ####     - `[AccessControlType]`: __AccessControlType__
        ####         - *`Allow` or `Deny`.*
        ####     - `[bool]`: __IsInherited__
        ####         - *`$true` if inherited from a parent.*
        ####     - `[string]`: __AnomalyReasons__
        ####         - *Comma-separated list of triggered rules: `OrphanedSid`, `SandboxPrincipal`, `UnexpectedWrite`.*
        [CmdletBinding()]
        param(
            [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
            [ValidateNotNullOrEmpty()]
            [Alias('FullName')]
            [string]$Path,

            [Parameter()]
            [string[]]$TrustedPrincipals = @('NT AUTHORITY\SYSTEM', 'BUILTIN\Administrators', 'CREATOR OWNER'),

            [Parameter()][switch]$Recurse,
            [Parameter()][switch]$File,
            [Parameter()][switch]$Directory
        )
        process {
            $entries = Get-AclItem -Path $Path -Recurse:$Recurse -File:$File -Directory:$Directory
            $anomalies = [System.Collections.Generic.List[PSCustomObject]]::new()

            foreach ($entry in $entries) {
                $identity = $entry.IdentityReference
                $isOrphanedSid = $identity -match '^S-1-'
                $isSandbox = $identity -match 'Sandbox'
                $isTrusted = $TrustedPrincipals | Where-Object { $identity -like "*$_*" }
                $isOwner = $identity -like "*$($env:USERNAME)*"
                $hasDangerousRights = $entry.FileSystemRights -match 'Modify|Write|Delete|FullControl'

                $reasons = [System.Collections.Generic.List[string]]::new()
                if ($isOrphanedSid) { $reasons.Add('OrphanedSid') }
                if ($isSandbox) { $reasons.Add('SandboxPrincipal') }
                if (-not $isTrusted -and -not $isOwner -and $hasDangerousRights) { $reasons.Add('UnexpectedWrite') }

                if ($reasons.Count -gt 0) {
                    $anomalies.Add([PSCustomObject]@{
                            Path              = $entry.Path
                            ItemType          = $entry.ItemType
                            IdentityReference = $identity
                            FileSystemRights  = $entry.FileSystemRights
                            AccessControlType = $entry.AccessControlType
                            IsInherited       = $entry.IsInherited
                            AnomalyReasons    = ($reasons -join ', ')
                        })
                }
            }

            $anomalies
        }
    }

    #### # Remove-AclItemAccountUnknown
    function Remove-AclItemAccountUnknown {
        #### Remove all ACEs with orphaned SID identity references from one or more targets. Requires Administrator. Supports `-WhatIf`.
        ####
        #### **Parameters**
        #### - `[string]`: __Path__
        ####     - *File or directory path. Accepts pipeline input.*
        #### - `[switch]`: __Recurse__ / __File__ / __Directory__
        ####     - *Passed to `Get-AclPathTargets`.*
        ####
        #### **Returns**
        #### - `[PSCustomObject[]]`
        ####     - `[string]`: __Path__
        ####         - *Absolute path of the item.*
        ####     - `[string]`: __ItemType__
        ####         - *`'File'` or `'Directory'`.*
        ####     - `[string[]]`: __RemovedSids__
        ####         - *SID strings that were removed from the ACL.*
        ####     - `[int]`: __RemovedCount__
        ####         - *Number of orphaned SIDs removed.*
        ####     - `[string]`: __Status__
        ####         - *`'Cleaned'` when changes were made, `'Clean'` when none were needed.*
        [CmdletBinding(SupportsShouldProcess)]
        param(
            [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
            [ValidateNotNullOrEmpty()]
            [Alias('FullName')]
            [string]$Path,

            [Parameter()][switch]$Recurse,
            [Parameter()][switch]$File,
            [Parameter()][switch]$Directory
        )
        begin {
            Assert-Administrator
        }
        process {
            $targets = Get-AclPathTargets -Path $Path -Recurse:$Recurse -File:$File -Directory:$Directory
            foreach ($target in $targets) {
                $itemType = if ($target -is [System.IO.DirectoryInfo]) { 'Directory' } else { 'File' }
                $acl = Get-Acl -Path $target.FullName
                $unknown = $acl.Access | Where-Object { $_.IdentityReference.Value -match '^S-1-' }

                if (-not $unknown) {
                    Write-Verbose "No orphaned SIDs found on: $($target.FullName)"
                    [PSCustomObject]@{
                        Path         = $target.FullName
                        ItemType     = $itemType
                        RemovedSids  = @()
                        RemovedCount = 0
                        Status       = 'Clean'
                    }
                    continue
                }

                $removed = [System.Collections.Generic.List[string]]::new()
                foreach ($entry in $unknown) {
                    if ($PSCmdlet.ShouldProcess($entry.IdentityReference.Value, "Remove orphaned SID from ACL of $($target.FullName)")) {
                        $acl.RemoveAccessRule($entry) | Out-Null
                        $removed.Add($entry.IdentityReference.Value)
                    }
                }

                if ($removed.Count -gt 0) { Set-Acl -Path $target.FullName -AclObject $acl }

                [PSCustomObject]@{
                    Path         = $target.FullName
                    ItemType     = $itemType
                    RemovedSids  = $removed
                    RemovedCount = $removed.Count
                    Status       = 'Cleaned'
                }
            }
        }
    }

    #### # Reset-AclItem
    function Reset-AclItem {
        #### Strip all explicit (non-inherited) ACEs from one or more targets, leaving only inherited rules. Requires Administrator. Supports `-WhatIf`.
        ####
        #### **Parameters**
        #### - `[string]`: __Path__
        ####     - *File or directory path. Accepts pipeline input.*
        #### - `[switch]`: __Recurse__ / __File__ / __Directory__
        ####     - *Passed to `Get-AclPathTargets`.*
        ####
        #### **Returns**
        #### - `[PSCustomObject[]]`
        ####     - `[string]`: __Path__
        ####         - *Absolute path of the item.*
        ####     - `[string]`: __ItemType__
        ####         - *`'File'` or `'Directory'`.*
        ####     - `[int]`: __BeforeCount__
        ####         - *Total ACE count before the reset.*
        ####     - `[int]`: __AfterCount__
        ####         - *Total ACE count after the reset.*
        ####     - `[int]`: __Removed__
        ####         - *Number of explicit ACEs stripped.*
        ####     - `[string]`: __Status__
        ####         - *`'Reset'` when ACEs were removed, `'AlreadyClean'` when none were explicit.*
        [CmdletBinding(SupportsShouldProcess)]
        param(
            [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
            [ValidateNotNullOrEmpty()]
            [Alias('FullName')]
            [string]$Path,

            [Parameter()][switch]$Recurse,
            [Parameter()][switch]$File,
            [Parameter()][switch]$Directory
        )
        begin {
            Assert-Administrator
        }
        process {
            $targets = Get-AclPathTargets -Path $Path -Recurse:$Recurse -File:$File -Directory:$Directory
            foreach ($target in $targets) {
                $itemType = if ($target -is [System.IO.DirectoryInfo]) { 'Directory' } else { 'File' }
                $acl = Get-Acl -Path $target.FullName
                $explicit = $acl.Access | Where-Object { -not $_.IsInherited }
                $beforeCount = $acl.Access.Count

                if (-not $explicit) {
                    Write-Verbose "No explicit ACEs on: $($target.FullName) — already inherited-only"
                    [PSCustomObject]@{
                        Path        = $target.FullName
                        ItemType    = $itemType
                        BeforeCount = $beforeCount
                        AfterCount  = $beforeCount
                        Removed     = 0
                        Status      = 'AlreadyClean'
                    }
                    continue
                }

                if ($PSCmdlet.ShouldProcess($target.FullName, "Strip $($explicit.Count) explicit ACE(s), keep inherited")) {
                    foreach ($rule in $explicit) { $acl.RemoveAccessRule($rule) | Out-Null }
                    Set-Acl -Path $target.FullName -AclObject $acl
                    $afterCount = (Get-Acl -Path $target.FullName).Access.Count
                    [PSCustomObject]@{
                        Path        = $target.FullName
                        ItemType    = $itemType
                        BeforeCount = $beforeCount
                        AfterCount  = $afterCount
                        Removed     = $beforeCount - $afterCount
                        Status      = 'Reset'
                    }
                }
            }
        }
    }

