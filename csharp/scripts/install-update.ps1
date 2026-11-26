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
# - Leaves everything else alone: build output, .env, my-scripts\, files you added.
# - Earlier versions kept the start guide elsewhere (see below). If you had
#   changed it, it is moved into my-scripts\, so cvdesk runs your version.
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

# Earlier versions kept the start guide somewhere else, and you may have added
# your credentials to it there. If you had changed it, move it into my-scripts\
# (with the lines cvdesk needs to run it), so it isn't lost and cvdesk runs it
# instead of the new examples\ version. One that is still as it came is removed.
if (Test-Path -LiteralPath (Join-Path $NewDir 'go.mod')) {
    $oldGuide = 'cmd/start-guide/main.go'; $guide = 'start-guide.go'
    $originals = @('2e2fe9699b2258a3750f6d6fbc119b490275947eb9a737b3db70f648abd2a25e', '84b33f1392f34f78207863ed9b3e9e277b94ce9c5706b51e1c7304394296b2cf', '9287150172055bba56ce4ca21f0345334f587fd56fab19697108422129855612', 'c506deffa889e319a6a8d1f3fdfad1c1cc459d48e7877051b6d495800d1c82f4')
} elseif (Test-Path -LiteralPath (Join-Path $NewDir 'pom.xml')) {
    $oldGuide = 'src/main/java/com/barchart/openfeed/StartGuide.java'; $guide = 'StartGuide.java'
    $originals = @('59c97456380f569e398175167d00b0c1a4aea0a83549cd5b7e0420e18fa7ca4a', '8a02b8902c73f35f986c2b71ae938b2406252ceea797c32364b871e06a49cc4a', 'ad58d993633945cfecaa0770efa2b6372068030ac22d0041cd2a5015d6f9cb2d')
} else {
    $oldGuide = 'OpenFeedStartGuide/Program.cs'; $guide = 'start-guide.cs'
    $originals = @('8d625a534a0374857a92c376cd918bdae97ef1d6c519af54b96e41e160fb4a8b', 'a666961ead9c4fa9ba396d4a64482fad7b24863cba489fd57ca6c24546027b2c', 'c69ce18f809721201659466e7fa003d688a0af558ae824f16e0567070c154690')
}
$movedGuide = ''
$oldGuideFile = Get-Native $ProjectDir $oldGuide
if ((Test-Path -LiteralPath $oldGuideFile -PathType Leaf) -and -not (Test-Path -LiteralPath (Get-Native $NewDir $oldGuide))) {
    # Hashed with Windows line endings too, in case an editor changed them.
    $text = [IO.File]::ReadAllText($oldGuideFile)
    $lf = [Text.Encoding]::UTF8.GetBytes(($text -replace "`r`n", "`n"))
    $lfHash = ([BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash($lf)) -replace '-', '').ToLowerInvariant()
    if ($originals -notcontains (Get-Hash $oldGuideFile) -and $originals -notcontains $lfHash) {
        $myScripts = Join-Path $ProjectDir 'my-scripts'
        New-Item -ItemType Directory -Force -Path $myScripts | Out-Null
        $movedGuide = $guide
        $i = 2
        while (Test-Path -LiteralPath (Join-Path $myScripts $movedGuide)) {
            $movedGuide = [IO.Path]::GetFileNameWithoutExtension($guide) + "-$i" + [IO.Path]::GetExtension($guide)
            $i++
        }
        if ($guide -like '*.go' -and $text -notmatch '(?m)^//go:build') { $text = "//go:build ignore`n`n" + $text }
        if ($guide -like '*.java') { $text = ([regex]'(?m)^package [A-Za-z0-9_.]+;\r?\n').Replace($text, '', 1) }
        if ($guide -like '*.cs' -and $text -notmatch '(?m)^#:package') {
            $text = "#:package openfeed.net@*`n#:property PublishAot=false`n`n" + $text
        }
        [IO.File]::WriteAllText((Join-Path $myScripts $movedGuide), $text)   # UTF-8 without BOM
    }
    Backup-File $oldGuide
    Remove-Item -LiteralPath $oldGuideFile -Force
}

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

if ($movedGuide) {
    Write-Host ''
    Write-Host "You had changed $oldGuide, where earlier versions kept the start guide."
    Write-Host "Your version is now my-scripts\$movedGuide (run it with: cvdesk $movedGuide)."
}
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
