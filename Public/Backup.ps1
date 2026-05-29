using namespace System.Collections
using namespace System.Collections.Concurrent
using namespace System.IO.Compression
using namespace System.IO

Set-StrictMode -Version Latest

Set-Alias -Name tp -Value Test-Path
Set-Alias -Name nuit -Value New-Item

#### ## Backup-FilesParallel

function Backup-FilesParallel {
    #### Recursive gzip streaming parallel compression with fail fast semantics and interactive feedback.
    #### **Parameters**
    #### - `string`: __Path__
    ####     - *Existing source directory. Walked recursively.*
    #### - `string`: __OutPath__
    ####     - *Destination root. Created if missing. Mirrors the source tree.*
    #### - `int`: __Throttle__
    ####     - *Throttle passed to `ForEach-Object -Parallel`. Defaults to 4.*
    ####
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$OutPath,

        [Parameter(Mandatory = $false)]
        [int]$Throttle = 4
    )

    #### - Displays time elapsed when run interactively in the terminal
    #### - OutPath is created on demand
    #### - @ToDo The termination of this function is not good at all. Find a better way to complete the job.

    $validDir = (Test-Path $Path -PathType Container)
    if(-not $validDir){throw "Path not found"}
    if(-not (Test-Path $OutPath)){New-Item $OutPath -ItemType Directory -Force}

    $Path = Resolve-Path $Path
    $OutPath = Resolve-Path $OutPath

    ### - `ConcurrentDictionary[string,string]` for holding errors
    $prlErr = [ConcurrentDictionary[string, string]]::new()
    [ArrayList]$mtxProg = [ArrayList]::Synchronized(@(0))

    $startTime = Get-Date

    gci $Path -Recurse -File -ErrorAction SilentlyContinue | % -Parallel {
        $errors = $using:prlErr
        $prog = $using:mtxProg

        [void]$prog.Add(1)

        if (($prog.Count % 100) -eq 0) {
            $currentTime = Get-Date
            $elapsedTime = [string]::Format('{0:hh\:mm\:ss}', ($currentTime - $using:startTime))
            Write-Progress -Activity 'Compressing' -Status "$elapsedTime ⛷ Processed: $($prog.Count)"
        }

        $fPath = $_.FullName
        $relativePath = [System.IO.Path]::GetRelativePath($using:Path, $_.FullName)
        $destPath = Join-Path -Path $using:OutPath -ChildPath $relativePath
        $destDir = [System.IO.Path]::GetDirectoryName($destPath)

        if (-not (Test-Path -Path $destDir)) {
            [void](New-Item -Path $destDir -ItemType Directory -Force)
        }
        $gzipfPath = "${destPath}.gz"

        try {
            #### ```powershell
            #### # Uses
            #### [System.IO.Compression.GZipStream]
            #### [System.IO.Compression.CompressionLevel]::SmallestSize
            #### ```
            ####
            $fileStream = [System.IO.File]::OpenRead($fPath)
            $gzipStream = [System.IO.File]::Create($gzipfPath)
            $gzipWriter = [System.IO.Compression.GZipStream]::new($gzipStream, [System.IO.Compression.CompressionLevel]::SmallestSize, $false)
            $fileStream.CopyTo($gzipWriter)
        }
        catch {
            [void]($errors.TryAdd($fPath, $_.Exception.Message))
        }
        finally {
            if ($null -ne $gzipWriter) {
                $gzipWriter.Close()
            }

            if ($null -ne $fileStream) {
                $fileStream.Close()
            }
        }
    } -ThrottleLimit $Throttle

    if ($prlErr.Count -gt 0) {
        $errFilePath = Join-Path $OutPath "CompressionErrors.json"
        $prlErr.GetEnumerator() |
            ConvertTo-Json -Depth 10 |
            Out-File -FilePath "$errFilePath"
        Write-Warning "See error details in $errFilePath"
    }
    else {
        Write-Information 'Compression complete'
    }
    #### **Returns**
    #### - *None. Writes .gz files to OutPath and a CompressionErrors.json on partial failure.*
    ####
    #### **Throws**
    #### - *When Path does not exist.*
}


