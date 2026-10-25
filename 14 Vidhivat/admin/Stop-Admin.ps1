$ErrorActionPreference = 'Stop'
$sessionPath = Join-Path $PSScriptRoot '.runtime\session.json'
if (-not (Test-Path -LiteralPath $sessionPath)) { Write-Output 'Admin is not running.'; exit 0 }
$session = Get-Content -LiteralPath $sessionPath -Raw | ConvertFrom-Json
$uri = [Uri]$session.url
if ($uri.Host -ne '127.0.0.1' -or $uri.Scheme -ne 'http') { throw 'Unexpected local panel address.' }
try { $health = Invoke-RestMethod -Uri ($session.url + '/api/health') -TimeoutSec 2 }
catch { Write-Output 'Admin is already stopped.'; exit 0 }
if ($health.application -ne 'vidhivat-admin' -or $health.workspace -ne (Split-Path -Parent $PSScriptRoot)) { throw 'This is not the expected project panel.' }
$sessionToken = (Invoke-RestMethod -Uri ($session.url + '/api/session')).token
Invoke-RestMethod -Method Post -Uri ($session.url + '/api/stop') -ContentType 'application/json' -Headers @{'X-Admin-Token' = $sessionToken} -Body '{}' | Out-Null
for ($attempt = 0; $attempt -lt 30; $attempt++) {
    Start-Sleep -Milliseconds 100
    try { Invoke-RestMethod -Uri ($session.url + '/api/health') -TimeoutSec 1 | Out-Null }
    catch { break }
}
Write-Output 'Admin stopped. Drafts remain saved.'
