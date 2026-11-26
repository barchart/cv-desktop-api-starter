# Copies the libraries pom.xml lists into lib\, where cvdesk puts them on the
# classpath (and where VS Code's Java support finds them). Run by setup.bat,
# and by cvdesk whenever pom.xml has changed since (after an update).
#   dependencies.ps1               always
#   dependencies.ps1 --if-needed   only if pom.xml changed since the last time
$project = (Resolve-Path "$PSScriptRoot\..").Path
$pom = Join-Path $project 'pom.xml'
$lib = Join-Path $project 'lib'
$copy = Join-Path $lib '.pom.xml'
if ($args -contains '--if-needed' -and (Test-Path -LiteralPath $copy) -and
    (Get-FileHash -LiteralPath $pom).Hash -eq (Get-FileHash -LiteralPath $copy).Hash) {
    exit 0
}
[Console]::Error.WriteLine('Downloading the Java libraries (this may take a minute)...')
if (Test-Path -LiteralPath $lib) { Remove-Item -LiteralPath $lib -Recurse -Force }
Push-Location $project
try {
    # Redirected by cmd: PowerShell has no stdout-to-stderr redirection for programs.
    & cmd.exe /c 'mvnw.cmd -q dependency:copy-dependencies -DoutputDirectory=lib 1>&2'
    $status = $LASTEXITCODE
} finally {
    Pop-Location
}
if ($status -ne 0) {
    [Console]::Error.WriteLine('Downloading the Java libraries failed.')
    exit 1
}
Copy-Item -LiteralPath $pom -Destination $copy
exit 0
