# Shared helper: creates the repo-root .env file interactively.
# Called by each language's setup.bat script (e.g. `powershell -File "..\setup-env.ps1"`).

Set-Location (Split-Path -Parent $MyInvocation.MyCommand.Path)

$EnvFile = ".env"
$EnvExample = ".env.example"

if (Test-Path $EnvFile) {
    Write-Host ".env already exists at repo root - leaving your credentials untouched."
    exit 0
}

Copy-Item $EnvExample $EnvFile

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
