# Downloads the newest version of this project from GitHub and installs it over
# this folder. It takes the latest GitHub release, or the main branch if the
# project has no releases.
#   update.ps1                      (run by ..\update.bat)
#   update.ps1 --from <file>        installs a .zip or .tar.gz you downloaded yourself,
#                                   for example from GitHub's "Download ZIP"
# This file only downloads. The installing is done by scripts\install-update.ps1
# from the version it downloads, so each new version brings its own install
# steps. Keep this file simple: copies of it already out there have to keep
# working with every future version.
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'   # Invoke-WebRequest is much slower with its progress bar
# Windows PowerShell 5.1 may not offer TLS 1.2 by default, which GitHub requires.
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$repo = 'barchart/cv-desktop-api-starter'
$folderInRepo = 'java'
$project = (Resolve-Path "$PSScriptRoot\..").Path
$userAgent = 'cvdesk-update'

function Fail($message) {
    Write-Host $message
    exit 1
}

# GitHub API call; returns $null for "not found" when -Allow404 is given.
function Invoke-GitHub($path, [switch]$Allow404) {
    try {
        $headers = @{ Accept = 'application/vnd.github+json'; 'X-GitHub-Api-Version' = '2022-11-28' }
        $response = Invoke-WebRequest -UseBasicParsing -UserAgent $userAgent -Headers $headers -Uri "https://api.github.com/repos/$repo$path"
        return ConvertFrom-Json $response.Content
    } catch {
        $status = if ($_.Exception.Response) { [int]$_.Exception.Response.StatusCode } else { 0 }
        if ($status -eq 404 -and $Allow404) { return $null }
        if ($status -eq 404) { Fail "Could not find github.com/$repo. Is the project still public?" }
        if ($status -eq 403 -or $status -eq 429) { Fail 'GitHub is limiting update checks from your network right now. Try again in an hour.' }
        if ($status) { Fail "GitHub answered `"$status`". Try again later." }
        Fail "Could not reach GitHub ($($_.Exception.Message)). Check your internet connection and try again."
    }
}

$tmp = Join-Path ([IO.Path]::GetTempPath()) ('cvdesk-update-' + [guid]::NewGuid())
New-Item -ItemType Directory -Path $tmp | Out-Null
try {
    $url = ''
    if ($args.Count -gt 0 -and $args[0] -eq '--from') {
        if ($args.Count -lt 2 -or -not (Test-Path -LiteralPath $args[1] -PathType Leaf)) {
            Fail 'Usage: .\update.bat --from <downloaded .zip or .tar.gz file>'
        }
        $archive = (Resolve-Path -LiteralPath $args[1]).Path
        $version = "file $(Split-Path -Leaf $archive)"
        $name = $args[1]
    } else {
        Write-Host 'Checking for a new version...'
        $release = Invoke-GitHub '/releases/latest' -Allow404
        if ($release) {
            $ref = $release.tag_name
            $version = $ref
            $url = "https://github.com/$repo/releases/tag/$ref"
        } else {
            $ref = (Invoke-GitHub '/commits/HEAD').sha
            $version = "commit $($ref.Substring(0, 7))"
        }
        $manifest = Join-Path $project '.cvdesk-installed'
        if ((Test-Path -LiteralPath $manifest) -and ((Get-Content -LiteralPath $manifest -TotalCount 1) -eq "version $version")) {
            Write-Host "Already up to date ($version)."
            exit 0
        }
        Write-Host "Downloading $version..."
        $archive = Join-Path $tmp 'download.tar.gz'
        # The plain download link, which (unlike the API) doesn't count toward GitHub's hourly limit.
        try {
            Invoke-WebRequest -UseBasicParsing -UserAgent $userAgent -Uri "https://github.com/$repo/archive/$ref.tar.gz" -OutFile $archive
        } catch {
            Fail "Downloading failed ($($_.Exception.Message)). Try again later."
        }
        $name = 'The downloaded version'
    }

    $extracted = Join-Path $tmp 'extracted'
    New-Item -ItemType Directory -Path $extracted | Out-Null
    # Windows' own tar (also reads .zip); another tar earlier on PATH, such as Git's, may not.
    & (Join-Path $env:SystemRoot 'System32\tar.exe') -xf $archive -C $extracted 2>$null
    if ($LASTEXITCODE -ne 0) { Fail "Could not unpack $name." }

    # GitHub's archives hold one folder with the whole project; this one is in $folderInRepo\ inside it.
    $found = $null
    $dirs = @($extracted) + @(Get-ChildItem -LiteralPath $extracted -Directory | ForEach-Object FullName)
    foreach ($dir in $dirs) {
        foreach ($candidate in @($dir, (Join-Path $dir $folderInRepo))) {
            $updateSh = Join-Path $candidate 'scripts\update.sh'
            if ((Test-Path -LiteralPath (Join-Path $candidate 'scripts\install-update.ps1')) -and
                (Test-Path -LiteralPath $updateSh) -and
                (Select-String -LiteralPath $updateSh -Pattern "^FOLDER_IN_REPO=`"$folderInRepo`"$" -Quiet)) {
                $found = $candidate
                break
            }
        }
        if ($found) { break }
    }
    if (-not $found) { Fail "$name doesn't contain this project." }

    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $found 'scripts\install-update.ps1') $found $project $version $url
    exit $LASTEXITCODE
} finally {
    Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
}
