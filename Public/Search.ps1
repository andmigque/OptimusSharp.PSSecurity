#### # Search-KeywordInFile
function Search-KeywordInFile {
    #### Walks a directory tree and returns every file whose contents match a regex pattern.
    ####
    #### `Select-String` runs in parallel with eight worker threads. The matched paths are
    #### written to `FilesFound.json` under `OutPath` and also returned on the pipeline as a
    #### compact JSON string.
    ####
    #### **Parameters**
    #### - `[string]`: __Directory__
    ####     - *Root of the recursive walk. Resolved against the current location.*
    #### - `[string]`: __Pattern__
    ####     - *Regex passed to `Select-String -Pattern`.*
    #### - `[string]`: __OutPath__
    ####     - *Directory the `FilesFound.json` result lands in. Created if missing. Defaults to the current location.*
    ####
    #### **Returns**
    #### - `[string]`
    ####     - *Compact JSON array of matching file paths.*
    ####
    #### **Requires**
    #### - *PowerShell 7+ for `ForEach-Object -Parallel`.*
    ####
    #### **Example**
    #### ```powershell
    #### Search-KeywordInFile -Directory ./src -Pattern 'TODO'
    #### ```
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Directory,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Pattern,

        [Parameter(Mandatory = $false)]
        [string]$OutPath = (Get-Location).Path
    )

    # Resolve once so the parallel block sees an absolute path; relative paths bind to
    # each worker's own working directory, not guaranteed to match the caller.
    $resolvedDirectory = Resolve-Path -Path $Directory

    # SilentlyContinue plus Force keeps the walk alive across hidden, system, and
    # access-denied items. ThrottleLimit 8 fits most laptop core counts without
    # saturating the disk queue.
    $results = @(
        Get-ChildItem -Path $resolvedDirectory -Recurse -File -ErrorAction SilentlyContinue -Force |
            ForEach-Object -ThrottleLimit 8 -Parallel {
                $pattern = $using:Pattern
                # Quiet returns a bool so each worker ships one value back to the parent
                # runspace per file instead of the full set of match objects.
                $matched = Select-String -Path $_.FullName -Pattern $pattern -Encoding utf8 -Quiet -ErrorAction SilentlyContinue -AllMatches
                [PSCustomObject]@{
                    Path = $_.FullName
                    Matched = [bool]$matched
                }
            }
    )

    # Project the matched paths and persist them under OutPath so the JSON survives the
    # session. The same string is also returned so callers can pipe it forward.
    $matchedFiles = @($results | Where-Object Matched | Select-Object -ExpandProperty Path)
    if (-not (Test-Path -Path $OutPath)) {
        [void](New-Item -Path $OutPath -ItemType Directory -Force)
    }
    $jsonPath = Join-Path $OutPath 'FilesFound.json'
    $jsonOut = ConvertTo-Json -InputObject $matchedFiles -Compress
    $jsonOut | Out-File -FilePath $jsonPath -Encoding utf8
    Write-Host -BackgroundColor Cyan "Results json file has been written to $jsonPath" -ForegroundColor DarkRed
    return $jsonOut
}
