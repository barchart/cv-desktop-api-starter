# The cvdesk command on Windows (bin\cvdesk.cmd runs this file). It does the
# same as bin/cvdesk, the macOS version, which explains the commands: keep the
# two in step. Works with Windows PowerShell 5.1.
$root = (Resolve-Path "$PSScriptRoot\..").Path
$langs = @('typescript', 'python', 'java', 'go', 'csharp')
$names = @{ typescript = 'TypeScript'; python = 'Python'; java = 'Java'; go = 'Go'; csharp = 'C#' }
# The file extensions of each language, in order of preference when one name has several.
$extensions = @{ typescript = @('ts', 'js', 'mjs'); python = @('py'); java = @('java'); go = @('go'); csharp = @('cs') }
$venvPython = Join-Path $root 'python\venv\Scripts\python.exe'

function Fail($message) {
    [Console]::Error.WriteLine($message)
    exit 1
}

function Get-LangOfExt($ext) {
    foreach ($lang in $langs) { if ($extensions[$lang] -contains $ext.ToLower()) { return $lang } }
    return $null
}

function Test-Command($name) { [bool](Get-Command $name -ErrorAction SilentlyContinue) }

# Whether a language is ready to run scripts: its setup ran, or its tools are installed.
function Test-Ready($lang) {
    switch ($lang) {
        'typescript' { return (Test-Path -LiteralPath (Join-Path $root 'typescript\node_modules\tsx\dist\cli.mjs')) -and (Test-Command node) }
        'python' { return Test-Path -LiteralPath $venvPython }
        'java' { return Test-Command java }
        'go' { return Test-Command go }
        'csharp' {
            # Running single .cs files needs .NET 10.
            if (-not (Test-Command dotnet)) { return $false }
            $major = 0
            [void][int]::TryParse(((& dotnet --version 2>$null) -split '\.')[0], [ref]$major)
            return $major -ge 10
        }
    }
}

function Get-NotReady($lang) {
    "$($names[$lang]) isn't set up yet. Run its setup first: $(Join-Path $root "$lang\setup.bat")"
}

function Get-Normalized($name) { ($name -replace '[-_]', '').ToLower() }

# The script in a language's my-scripts\ or examples\ whose name matches (its full path).
function Find-Script($lang, $wanted, $exts) {
    if (-not $exts) { $exts = $extensions[$lang] }
    foreach ($dir in @('my-scripts', 'examples')) {
        $folder = Join-Path $root "$lang\$dir"
        if (-not (Test-Path -LiteralPath $folder)) { continue }
        foreach ($ext in $exts) {
            foreach ($file in @(Get-ChildItem -LiteralPath $folder -File -Filter "*.$ext" | Sort-Object Name)) {
                if ($file.Extension -ne ".$ext") { continue }
                if ((Get-Normalized $file.BaseName) -eq $wanted) { return $file.FullName }
            }
        }
    }
    return $null
}

function Show-Usage {
    $lines = @(
        'Usage: cvdesk <script> [arguments]    runs a script from my-scripts\ or examples\'
        '       cvdesk update                  installs the newest version of every language folder'
        '       cvdesk update <language>       ...of one: typescript, python, java, go or csharp'
    )
    foreach ($lang in $langs) {
        if (-not (Test-Path -LiteralPath (Join-Path $root $lang))) { continue }
        $lines += ''
        if (Test-Ready $lang) { $lines += "$($names[$lang]) ($lang\):" }
        else { $lines += "$($names[$lang]) ($lang\) - not set up yet, run $lang\setup.bat:" }
        foreach ($dir in @('my-scripts', 'examples')) {
            $folder = Join-Path $root "$lang\$dir"
            $found = @()
            if (Test-Path -LiteralPath $folder) {
                foreach ($ext in $extensions[$lang]) {
                    $found += @(Get-ChildItem -LiteralPath $folder -File -Filter "*.$ext" |
                        Where-Object { $_.Extension -eq ".$ext" -and $_.Name -notlike '*.d.ts' } |
                        Sort-Object Name | ForEach-Object Name)
                }
            }
            $list = if ($found.Count -gt 0) { $found -join '  ' } else { '(none yet)' }
            $lines += '  ' + "$dir\".PadRight(12) + '  ' + $list
        }
    }
    foreach ($line in $lines) { [Console]::Error.WriteLine($line) }
}

function Invoke-Script($lang, $file, $scriptArgs) {
    switch ($lang) {
        'typescript' {
            & node (Join-Path $root 'typescript\node_modules\tsx\dist\cli.mjs') (Join-Path $root 'typescript\scripts\run.ts') $file @scriptArgs
        }
        'python' {
            & $venvPython (Join-Path $root 'python\scripts\run.py') $file @scriptArgs
        }
        'java' {
            # The libraries pom.xml lists, copied into lib\ (again whenever pom.xml changes).
            & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'java\scripts\dependencies.ps1') --if-needed
            if ($LASTEXITCODE -ne 0) { exit 1 }
            $classpath = (Join-Path $root 'java\lib\*') + ';' + (Join-Path $root 'java\resources')
            & java -cp $classpath $file @scriptArgs
        }
        'go' {
            # Built inside the go\ module (for its go.mod), then run from the folder you're in.
            $tmp = Join-Path ([IO.Path]::GetTempPath()) ('cvdesk-go-' + [guid]::NewGuid())
            New-Item -ItemType Directory -Path $tmp | Out-Null
            try {
                $exe = Join-Path $tmp ([IO.Path]::GetFileNameWithoutExtension($file) + '.exe')
                Push-Location (Join-Path $root 'go')
                try { & go build -o $exe $file } finally { Pop-Location }
                if ($LASTEXITCODE -ne 0) { exit 1 }
                & $exe @scriptArgs
                exit $LASTEXITCODE
            } finally {
                Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
        'csharp' {
            # '--' quoted: bare, Windows PowerShell may take it as its own marker and drop it.
            & dotnet run --file $file '--' @scriptArgs
        }
    }
    exit $LASTEXITCODE
}

if ($args.Count -gt 0 -and $args[0] -eq 'update') {
    $rest = @($args | Select-Object -Skip 1)
    $lang = if ($rest.Count -gt 0) { $rest[0] } else { '' }
    $langArgs = @($rest | Select-Object -Skip 1)
    if ($lang -eq '' -or $lang -eq '--from') {
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'scripts\update.ps1') @rest
    } elseif ($lang -eq 'typescript' -or $lang -eq 'ts') {
        if (-not (Test-Command node)) { Fail "Node.js isn't installed." }
        & node (Join-Path $root 'typescript\scripts\update.mjs') @langArgs
    } elseif ($lang -eq 'python' -or $lang -eq 'py') {
        if (-not (Test-Path -LiteralPath $venvPython)) { Fail (Get-NotReady 'python') }
        & $venvPython (Join-Path $root 'python\scripts\update.py') @langArgs
    } elseif (@('java', 'go', 'csharp', 'cs', 'c#') -contains $lang) {
        $folder = if ($lang -eq 'java' -or $lang -eq 'go') { $lang } else { 'csharp' }
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root "$folder\scripts\update.ps1") @langArgs
    } else {
        Fail "Unknown language `"$lang`". Use typescript, python, java, go or csharp, or nothing to update them all."
    }
    exit $LASTEXITCODE
}

if ($args.Count -eq 0) {
    Show-Usage
    exit 1
}
$arg = [string]$args[0]
$scriptArgs = @($args | Select-Object -Skip 1)

# A file path.
if (Test-Path -LiteralPath $arg -PathType Leaf) {
    $lang = Get-LangOfExt ([IO.Path]::GetExtension($arg).TrimStart('.'))
    if (-not $lang) { Fail "cvdesk runs .ts, .js, .mjs, .py, .java, .go and .cs files, and $arg is none of those." }
    if (-not (Test-Ready $lang)) { Fail (Get-NotReady $lang) }
    Invoke-Script $lang (Resolve-Path -LiteralPath $arg).Path $scriptArgs
}
if ($arg -match '[\\/]') { Fail "No file `"$arg`"." }

# A script name, with or without its extension.
$lang = $null
$stem = $arg
$ext = [IO.Path]::GetExtension($arg).TrimStart('.')
if ($ext) {
    $lang = Get-LangOfExt $ext
    if ($lang) { $stem = [IO.Path]::GetFileNameWithoutExtension($arg) }
}
$wanted = Get-Normalized $stem

if ($lang) {
    $file = Find-Script $lang $wanted @($ext.ToLower())
    if (-not $file) {
        [Console]::Error.WriteLine("No script `"$arg`" in $lang\my-scripts\ or $lang\examples\.")
        [Console]::Error.WriteLine('')
        Show-Usage
        exit 1
    }
    if (-not (Test-Ready $lang)) { Fail (Get-NotReady $lang) }
    Invoke-Script $lang $file $scriptArgs
}

# No extension: look in every language.
$found = @()
$foundReady = @()
foreach ($l in $langs) {
    $file = Find-Script $l $wanted
    if (-not $file) { continue }
    $found += , @($l, $file)
    if (Test-Ready $l) { $foundReady += , @($l, $file) }
}
if ($foundReady.Count -eq 1) {
    Invoke-Script $foundReady[0][0] $foundReady[0][1] $scriptArgs
}
if ($found.Count -eq 0) {
    [Console]::Error.WriteLine("No script `"$arg`" in any language's my-scripts\ or examples\.")
    [Console]::Error.WriteLine('')
    Show-Usage
    exit 1
}
if ($foundReady.Count -gt 1) {
    [Console]::Error.WriteLine("`"$arg`" is a script in more than one language. Add its extension to pick one:")
    foreach ($entry in $foundReady) {
        [Console]::Error.WriteLine('  cvdesk ' + (Split-Path -Leaf $entry[1]).PadRight(24) + "($($names[$entry[0]]))")
    }
    exit 1
}
foreach ($entry in $found) {
    [Console]::Error.WriteLine("$(Split-Path -Leaf $entry[1]): $(Get-NotReady $entry[0])")
}
exit 1
