using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

    #### # Get-AclPathTargets
    function Get-AclPathTargets {
        #### Internal helper. Resolve a path to a list of `FileSystemInfo` targets. Used by all ACL functions to handle `-Recurse`, `-File`, and `-Directory` filtering consistently.
        ####
        #### **Parameters**
        #### - `[string]`: __Path__
        ####     - *Root path to resolve.*
        #### - `[switch]`: __Recurse__
        ####     - *Walk children recursively.*
        #### - `[switch]`: __File__
        ####     - *Include only files.*
        #### - `[switch]`: __Directory__
        ####     - *Include only directories.*
        ####
        #### **Returns**
        #### - `[List[FileSystemInfo]]`
        ####     - *Resolved targets.*
        param(
            [Parameter(Mandatory)][string]$Path,
            [switch]$Recurse,
            [switch]$File,
            [switch]$Directory
        )
        $resolved = Resolve-Path -Path $Path -ErrorAction Stop
        $root = Get-Item -LiteralPath $resolved.ProviderPath -Force
        $isDir = $root -is [System.IO.DirectoryInfo]
        $targets = [System.Collections.Generic.List[System.IO.FileSystemInfo]]::new()

        $includeRoot = $true
        if ($File -and $isDir) { $includeRoot = $false }
        if ($Directory -and -not $isDir) { $includeRoot = $false }
        if ($includeRoot) { $targets.Add($root) }

        if ($Recurse -and $isDir) {
            $childParams = @{ LiteralPath = $resolved.ProviderPath; Recurse = $true; Force = $true }
            if ($File -and -not $Directory) { $childParams['File'] = $true }
            if ($Directory -and -not $File) { $childParams['Directory'] = $true }
            Get-ChildItem @childParams | ForEach-Object { $targets.Add($_) }
        }

        $targets
    }

