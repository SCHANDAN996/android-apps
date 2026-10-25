param([switch]$NoBrowser)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$runtimeDir = Join-Path $PSScriptRoot '.runtime'
$sessionPath = Join-Path $runtimeDir 'session.json'
New-Item -ItemType Directory -Force -Path $runtimeDir | Out-Null

function Test-AdminSession($session) {
    try {
        $uri = [Uri]$session.url
        if ($uri.Host -ne '127.0.0.1' -or $uri.Scheme -ne 'http') { return $false }
        $health = Invoke-RestMethod -Uri ($session.url + '/api/health') -TimeoutSec 2
        return $health.application -eq 'vidhivat-admin' -and $health.workspace -eq $projectRoot
    } catch { return $false }
}

if (Test-Path -LiteralPath $sessionPath) {
    try {
        $session = Get-Content -LiteralPath $sessionPath -Raw | ConvertFrom-Json
        if (Test-AdminSession $session) {
            if (-not $NoBrowser) { Start-Process $session.url }
            Write-Output $session.url
            exit 0
        }
    } catch { }
}

$exe = Join-Path $PSScriptRoot 'build\vidhivat-admin.exe'
if (-not (Test-Path -LiteralPath $exe)) {
    throw 'Admin executable missing. In admin/, run: dart pub get; dart compile exe bin/admin.dart -o build/vidhivat-admin.exe'
}
$arguments = @('--workspace', ('"' + $projectRoot + '"'))
$adminProcess = Start-Process -FilePath $exe -ArgumentList $arguments -WorkingDirectory $PSScriptRoot -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $runtimeDir 'server-out.log') -RedirectStandardError (Join-Path $runtimeDir 'server-error.log')
for ($attempt = 0; $attempt -lt 40; $attempt++) {
    Start-Sleep -Milliseconds 300
    if ($adminProcess.HasExited) { throw 'The local panel did not start. See admin/.runtime/server-error.log.' }
    if (Test-Path -LiteralPath $sessionPath) {
        try {
            $session = Get-Content -LiteralPath $sessionPath -Raw | ConvertFrom-Json
            if ($session.pid -eq $adminProcess.Id -and (Test-AdminSession $session)) {
                if (-not $NoBrowser) { Start-Process $session.url }
                Write-Output $session.url
                exit 0
            }
        } catch { }
    }
}
throw 'Admin startup timed out. See admin/.runtime/server-error.log.'
