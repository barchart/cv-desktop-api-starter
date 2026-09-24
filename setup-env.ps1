# Shared helper: manages the repo-root .env and syncs a copy into the calling
# language folder, so each app can just read ".env" from its own working
# directory - no cross-directory searching needed.
# Called by each language's setup.bat script from within its own folder
# (e.g. `powershell -File "..\setup-env.ps1"`).

$CallerDir = (Get-Location).Path
Set-Location (Split-Path -Parent $MyInvocation.MyCommand.Path)

$EnvFile = ".env"
$EnvExample = ".env.example"

if (Test-Path $EnvFile) {
    $refresh = Read-Host "Credentials already exist. Set fresh OpenFeed credentials? [y/N]"
} else {
    $refresh = "y"
    Copy-Item $EnvExample $EnvFile
}

if ($refresh -match '^[Yy]') {
    Write-Host ""
    Write-Host "Let's set up your OpenFeed credentials (saved to .env, never committed to git)."
    $user = Read-Host "OpenFeed username"
    $securePass = Read-Host "OpenFeed password" -AsSecureString
    $pass = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePass))
    $port = Read-Host "Desktop API port [9000]"
    if ([string]::IsNullOrWhiteSpace($port)) { $port = "9000" }

    @"
OPENFEED_USERNAME=$user
OPENFEED_PASSWORD=$pass
OPENFEED_WS_URL=ws://localhost:$port
"@ | Set-Content -Path $EnvFile -NoNewline

    Write-Host "Saved credentials to .env"
} else {
    Write-Host "Keeping existing credentials in .env."
}

$CallerEnvFile = Join-Path $CallerDir ".env"
Copy-Item $EnvFile $CallerEnvFile -Force
Write-Host "Synced credentials to $CallerEnvFile"

