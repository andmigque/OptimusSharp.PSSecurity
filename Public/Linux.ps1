using namespace System
using namespace System.IO
using namespace System.Security.Cryptography
using namespace System.Collections.Immutable

    #### # Set-CronPermissions
    function Set-CronPermissions {
        #### Restrict all standard cron directories to 700 via `sudo chmod`.
        ####
        #### **Returns**
        #### - *None. Writes status to host per directory.*
        [CmdletBinding()]
        param()

        $CronDirectories = @('/etc/cron.d', '/etc/cron.daily', '/etc/cron.hourly', '/etc/cron.weekly', '/etc/cron.monthly')

        foreach ($Directory in $CronDirectories) {
            try {
                if (Test-Path -Path $Directory -PathType Container) {
                    & sudo chmod -R 700 -- $Directory
                    Write-Host "Successfully set permissions to 700 for: $Directory"
                }
                else {
                    Write-Warning "Directory not found: $Directory"
                }
            }
            catch {
                Write-Error $_
            }
        }
    }

    #### # Show-SecurityReport
    function Show-SecurityReport {
        #### Print an aureport summary of audit events.
        aureport --summary
    }

    #### # Start-SecurityWatch
    function Start-SecurityWatch {
        #### Tail the Linux audit log in real time.
        tail -f /var/log/audit/audit.log
    }

    #### # New-SecurityCertificate
    function New-SecurityCertificate {
        #### Generate locally-trusted TLS certificates via mkcert for a hostname and optional subdomains.
        ####
        #### **Parameters**
        #### - `[string]`: __Hostname__
        ####     - *Primary hostname. Defaults to the system hostname.*
        #### - `[string[]]`: __Subdomains__
        ####     - *Optional subdomain prefixes. Each becomes `<subdomain>.<Hostname>`.*
        ####
        #### **Returns**
        #### - `[PSCustomObject[]]`
        ####     - `[string]`: __Domain__
        ####         - *Fully-qualified domain the certificate was generated for.*
        ####     - `[string]`: __Status__
        ####         - *Always `'Generated'`.*
        [CmdletBinding()]
        param(
            [Parameter(Mandatory = $false)]
            [string]$Hostname = (hostname),

            [Parameter(Mandatory = $false)]
            [string[]]$Subdomains = @()
        )

        try {
            $mkcert = Get-Command mkcert -ErrorAction SilentlyContinue
            if (-not $mkcert) {
                Write-Warning 'mkcert not found. On Linux, run Install-PowerNixxAptTools to install.'
                return
            }

            $results = @()

            Write-Host "Generating certificate for $Hostname..." -ForegroundColor Cyan
            & mkcert $Hostname
            $results += [PSCustomObject]@{ Domain = $Hostname; Status = 'Generated' }

            foreach ($subdomain in $Subdomains) {
                $fqdn = "$subdomain.$Hostname"
                Write-Host "Generating certificate for $fqdn..." -ForegroundColor Cyan
                & mkcert $fqdn
                $results += [PSCustomObject]@{ Domain = $fqdn; Status = 'Generated' }
            }

            Write-Host 'Certificate generation complete.' -ForegroundColor Green
            return $results
        }
        catch {
            Write-Error "Certificate generation failed: $_"
        }
    }

