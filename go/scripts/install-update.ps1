# Installs a downloaded version of this project over your copy. update.ps1 (the
# copy you already have) downloads the new version, then runs this script from
# inside the download - so this is the new version's install step.
#
#   install-update.ps1 <new version's folder> <your project folder> <version name> [<release page URL>]
#
# These arguments are a contract: copies of update.ps1 already out there call
# every future version of this script exactly like this.
#
# - Copies every file of the new version over your folder.
# - Removes files an earlier update installed that the new version no longer has.
# - Every file it replaces or removes is saved in previous-version\ first.
# - Leaves everything else alone: build output, .env, files you added.
# - Records what it installed in .cvdesk-installed (the version, then one
#   "sha256  path" line per file), so the next update can tell what you changed.
#   install-update.sh on macOS writes the same format.
param([string]$NewDir, [string]$ProjectDir, [string]$Version, [string]$Url = '')
$ErrorActionPreference = 'Stop'

$NewDir = (Resolve-Path -LiteralPath $NewDir).Path.TrimEnd('\')
$ProjectDir = (Resolve-Path -LiteralPath $ProjectDir).Path.TrimEnd('\')
$manifest = Join-Path $ProjectDir '.cvdesk-installed'
$backup = Join-Path $ProjectDir 'previous-version'

function Get-Hash($file) { (Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToLowerInvariant() }
function Get-Native($root, $rel) { Join-Path $root ($rel -replace '/', '\') }

# What the last update recorded: path -> sha256.
$hadRecord = Test-Path -LiteralPath $manifest
$installed = @{}
if ($hadRecord) {
    Get-Content -LiteralPath $manifest -Encoding UTF8 | Select-Object -Skip 1 | ForEach-Object {
        if ($_.Length -gt 66) { $installed[$_.Substring(66)] = $_.Substring(0, 64) }
    }
}

$script:backedUp = $false
function Backup-File($rel) {
    if (-not $script:backedUp) {
        if (Test-Path -LiteralPath $backup) { Remove-Item -LiteralPath $backup -Recurse -Force }
        $script:backedUp = $true
    }
    $target = Get-Native $backup $rel
    New-Item -ItemType Directory -Force -Path (Split-Path $target) | Out-Null
    Copy-Item -LiteralPath (Get-Native $ProjectDir $rel) -Destination $target -Force
}

$newFiles = @(Get-ChildItem -LiteralPath $NewDir -Recurse -File -Force |
    Where-Object { $_.Name -notin @('.DS_Store', 'Thumbs.db') } |
    ForEach-Object { $_.FullName.Substring($NewDir.Length + 1) -replace '\\', '/' } |
    Sort-Object)

$count = 0
$edited = @()
foreach ($rel in $newFiles) {
    $local = Get-Native $ProjectDir $rel
    $incoming = Get-Native $NewDir $rel
    if (Test-Path -LiteralPath $local -PathType Leaf) {
        $localHash = Get-Hash $local
        if ($localHash -eq (Get-Hash $incoming)) { continue }
        Backup-File $rel
        # Changed since the last update (by you), or no record to compare with.
        if ($installed[$rel] -ne $localHash) { $edited += $rel }
    }
    New-Item -ItemType Directory -Force -Path (Split-Path $local) | Out-Null
    Copy-Item -LiteralPath $incoming -Destination $local -Force
    $count++
}

$stillThere = @{}
foreach ($rel in $newFiles) { $stillThere[$rel] = $true }
foreach ($rel in @($installed.Keys)) {
    $local = Get-Native $ProjectDir $rel
    if ($stillThere.ContainsKey($rel) -or -not (Test-Path -LiteralPath $local -PathType Leaf)) { continue }
    Backup-File $rel
    Remove-Item -LiteralPath $local -Force
    $count++
}

$lines = @("version $Version") + @($newFiles | ForEach-Object { "$(Get-Hash (Get-Native $NewDir $_))  $_" })
[IO.File]::WriteAllLines($manifest, [string[]]$lines)   # UTF-8 without BOM, like the macOS version

if ($count -eq 0) {
    Write-Host "Already up to date ($Version)."
    exit 0
}
Write-Host ''
Write-Host "$count file(s) updated. The previous versions are saved in previous-version\."
if ($edited.Count -gt 0) {
    Write-Host ''
    if ($hadRecord) {
        Write-Host 'You had changed these files. They were replaced; your versions are in previous-version\:'
    } else {
        Write-Host 'These files were different from the new version and were replaced. If you had changed'
        Write-Host 'any of them (for example to add your credentials), your versions are in previous-version\:'
    }
    $edited | ForEach-Object { Write-Host "  $_" }
}
Write-Host ''
Write-Host "Updated to $Version."
if ($Url) { Write-Host "What's new: $Url" }
