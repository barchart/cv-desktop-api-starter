# Installs a downloaded version of the whole project over your copy. update.ps1
# (the copy you already have) downloads the new version, then runs this script
# from inside the download - so this is the new version's install step.
#
#   install-update.ps1 <new version's folder> <your project folder> <version name> [<release page URL>]
#
# These arguments are a contract: copies of update.ps1 already out there call
# every future version of this script exactly like this.
#
# - Updates the files at the top of the project (README.md, update.bat, bin\, scripts\).
# - Then runs each language folder's own install step from the download, the same
#   one that folder's own update runs:
#   - TypeScript and Python only if you ran their setup, since their update also
#     updates their dependencies (node_modules, venv).
#   - Java, Go and C# always: they have nothing to set up.
# - Records the version in .cvdesk-installed.
# - Puts the cvdesk command on PATH, if it isn't yet.
$ErrorActionPreference = 'Stop'
$new = (Resolve-Path -LiteralPath $args[0]).Path
$project = (Resolve-Path -LiteralPath $args[1]).Path
$version = $args[2]
$url = if ($args.Count -gt 3) { $args[3] } else { '' }
$updated = @()
$skipped = @()
$failed = @()

function Section($title) {
    Write-Host ''
    Write-Host "=== $title ==="
}

# Runs a language's install step and notes whether it worked.
function Run($name, $exe, $arguments) {
    & $exe @arguments
    if ($LASTEXITCODE -eq 0) { $script:updated += $name } else { $script:failed += $name }
}

function Skip($name, $message) {
    Write-Host $message
    $script:skipped += $name
}

# The files at the top of the project. Nobody edits these, but every one replaced
# is saved in previous-version\ anyway.
Section 'Project files'
$backup = Join-Path $project 'previous-version'
$backedUp = $false
$count = 0
$files = @(Get-ChildItem -LiteralPath $new -File -Force)
foreach ($sub in @('bin', 'scripts')) {
    $subDir = Join-Path $new $sub
    if (Test-Path -LiteralPath $subDir) { $files += @(Get-ChildItem -LiteralPath $subDir -File -Recurse -Force) }
}
foreach ($file in $files) {
    if ($file.Name -eq '.DS_Store' -or $file.Name -eq 'Thumbs.db') { continue }
    $rel = $file.FullName.Substring($new.Length).TrimStart('\', '/')
    $local = Join-Path $project $rel
    if (Test-Path -LiteralPath $local -PathType Leaf) {
        if ((Get-FileHash -LiteralPath $local).Hash -eq (Get-FileHash -LiteralPath $file.FullName).Hash) { continue }
        if (-not $backedUp) {
            if (Test-Path -LiteralPath $backup) { Remove-Item -LiteralPath $backup -Recurse -Force }
            $backedUp = $true
        }
        $saved = Join-Path $backup $rel
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $saved) | Out-Null
        Copy-Item -LiteralPath $local -Destination $saved -Force
    }
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $local) | Out-Null
    Copy-Item -LiteralPath $file.FullName -Destination $local -Force
    $count++
}
if ($count -eq 0) { Write-Host 'Already up to date.' } else { Write-Host "$count file(s) updated." }

$notSetUp = 'Not set up, so not updated. If you start using it, run its setup, then update again.'

Section 'TypeScript'
if (-not (Test-Path -LiteralPath (Join-Path $new 'typescript\scripts\install-update.mjs')) -or
    -not (Test-Path -LiteralPath (Join-Path $project 'typescript'))) {
    Skip 'TypeScript' 'Not in this version.'
} elseif (-not (Test-Path -LiteralPath (Join-Path $project 'typescript\.cvdesk-installed.json'))) {
    Skip 'TypeScript' $notSetUp
} elseif (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Skip 'TypeScript' "Node.js isn't installed, so not updated."
} else {
    Run 'TypeScript' 'node' @((Join-Path $new 'typescript\scripts\install-update.mjs'),
        (Join-Path $new 'typescript'), (Join-Path $project 'typescript'), $version)
}

Section 'Python'
$python = Join-Path $project 'python\venv\Scripts\python.exe'
if (-not (Test-Path -LiteralPath (Join-Path $new 'python\scripts\install_update.py')) -or
    -not (Test-Path -LiteralPath (Join-Path $project 'python'))) {
    Skip 'Python' 'Not in this version.'
} elseif (-not (Test-Path -LiteralPath (Join-Path $project 'python\.cvdesk-installed.json'))) {
    Skip 'Python' $notSetUp
} elseif (-not (Test-Path -LiteralPath $python)) {
    Skip 'Python' 'Its venv is missing, so not updated. Run python\setup.bat, then update again.'
} else {
    Run 'Python' $python @((Join-Path $new 'python\scripts\install_update.py'),
        (Join-Path $new 'python'), (Join-Path $project 'python'), $version)
}

foreach ($lang in @(@('java', 'Java'), @('go', 'Go'), @('csharp', 'C#'))) {
    $folder, $name = $lang
    Section $name
    $install = Join-Path $new "$folder\scripts\install-update.ps1"
    if (-not (Test-Path -LiteralPath $install) -or -not (Test-Path -LiteralPath (Join-Path $project $folder))) {
        Skip $name 'Not in this version.'
    } else {
        Run $name 'powershell.exe' @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $install,
            (Join-Path $new $folder), (Join-Path $project $folder), $version)
    }
}

Write-Host ''
Write-Host '=== Done ==='
if ($updated) { Write-Host "Up to date with ${version}: $($updated -join ', ')." }
if ($skipped) { Write-Host "Skipped: $($skipped -join ', ') (see above)." }
if ($failed) {
    Write-Host "Failed: $($failed -join ', ') (see above). Run .\update.bat again to retry."
    exit 1
}
[IO.File]::WriteAllText((Join-Path $project '.cvdesk-installed'), "version $version`n")
if ($url) { Write-Host "What's new: $url" }
# The cvdesk command, which replaces the cvdesk-py command and the TypeScript-only
# cvdesk of earlier versions: put it on PATH, if it isn't yet.
$addToPath = Join-Path $project 'scripts\add-to-path.ps1'
if (Test-Path -LiteralPath $addToPath) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $addToPath --if-needed
}
exit 0
