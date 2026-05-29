using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

#### # Write-DirectoryHashes
function Write-DirectoryHashes {
    #### Hash every file under `Path` and write the index into that directory.
    #### Two files are produced: `HashIndex.json` and `HashIndex.md`.
    ####
    #### The JSON is a flat array of `{ File, Hash, Path }` records for tooling.
    #### The Markdown carries a header block and `path,file,hash` rows for humans.
    ####
    #### Algorithm, include, and exclude lists are fixed at module scope.
    #### The default algorithm is `SHA256`.
    #### The default exclude set covers `bin`, `obj`, `node_modules`, and `.git`.
    ####
    #### Excluded directories are refused at traversal time by `Get-IndexableFile`.
    #### They are never descended into, so their files are never hashed.
    ####
    #### **Parameters**
    #### - `[string]`: __Path__
    ####     - *Root directory to walk.*
    ####
    #### **Returns**
    #### - *None. Writes `HashIndex.md` and `HashIndex.json`, then prints a count.*
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $resolvedPath = (Resolve-Path -Path $Path -ErrorAction Stop).Path
    $pathRedactionPrefix = (Resolve-Path '~').Path
    $markdownFile = Join-Path $resolvedPath 'HashIndex.md'
    $jsonFile = Join-Path $resolvedPath 'HashIndex.json'
    $rootDirectory = [System.IO.DirectoryInfo]::new($resolvedPath)

    $records = Get-IndexableFile -Directory $rootDirectory -Include $script:HashIndexInclude -Exclude $script:HashIndexExclude |
        Where-Object { $_.FullName -ne $jsonFile -and $_.FullName -ne $markdownFile } |
        ForEach-Object {
            $hashObject = Get-FileHash -Path $_.FullName -Algorithm $script:HashIndexAlgorithm
            [PSCustomObject]@{
                File = $_.Name
                Hash = $hashObject.Hash
                Path = $hashObject.Path.Replace($pathRedactionPrefix, '')
            }
        }

    $header = @"
# Hash Index

**TickStamp** : $((Get-Date).Ticks)
**Algorithm** : $($script:HashIndexAlgorithm)
**Include** : $($script:HashIndexInclude -join ' ')
**RedactionPath** : [[REDACTED]]

"@

    $rows = foreach ($record in $records) {
        "- $($record.Path),$($record.File),$($record.Hash)"
    }

    ($header + ($rows -join "`n") + "`n") | Out-File -FilePath $markdownFile -Encoding utf8
    @($records) | ConvertTo-Json -Depth 10 | Out-File -FilePath $jsonFile -Encoding utf8
    Write-Host "Hashed $(@($records).Count) files into $markdownFile and $jsonFile"
}

#### # Get-Hash
function Get-Hash {
    #### Hash a file using the specified algorithm.
    ####
    #### **Parameters**
    #### - `[string]`: __Path__
    ####     - *Path to the file.*
    #### - `[string]`: __Algorithm__
    ####     - *Hash algorithm. One of `MD5`, `SHA1`, `SHA256`, `SHA384`, `SHA512`. Defaults to `MD5`.*
    ####
    #### **Returns**
    #### - `[string]`
    ####     - *Hex hash string.*
    ####
    #### **Throws**
    #### - When `Path` does not resolve to an existing file.
    param (
        [Parameter(Mandatory)]
        [string]$Path,
        [ValidateSet('MD5', 'SHA1', 'SHA256', 'SHA384', 'SHA512')]
        [string]$Algorithm = 'MD5'
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Get-Hash: file not found: $Path"
    }

    $fileHash = Get-FileHash -LiteralPath $Path -Algorithm $Algorithm -ErrorAction Stop
    return $fileHash.Hash
}

