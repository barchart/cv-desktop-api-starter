# Puts this project's bin\ folder first on your user PATH, so the cvdesk command
# works in any new terminal, whichever Node.js version is active. Called by setup.bat.
# The copy of this project you last ran setup in wins: entries for other copies
# (folders with the same commands in them) are removed.
# The PATH is read and written as stored in the registry, so entries such as
# %USERPROFILE%\... stay as they are and keep working.
$bin = (Resolve-Path "$PSScriptRoot\..\bin").Path
$commands = @(Get-ChildItem -Path $bin -Filter *.cmd | ForEach-Object Name)

$key = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment', $true)
$current = $key.GetValue('Path', '', 'DoNotExpandEnvironmentNames')
$entries = @($current -split ';' | Where-Object { $_ -ne '' })

function Test-OurEntry($entry) {
    $dir = [Environment]::ExpandEnvironmentVariables($entry).TrimEnd('\')
    if ($dir -eq $bin.TrimEnd('\')) { return $true }
    foreach ($command in $commands) {
        # An entry that isn't a valid path (Windows allows any text in PATH) is never ours.
        try { if (Test-Path -LiteralPath (Join-Path $dir $command)) { return $true } } catch { }
    }
    return $false
}
$others = @($entries | Where-Object { -not (Test-OurEntry $_) })
$updated = (@($bin) + $others) -join ';'

if ($updated -ne $current) {
    $key.SetValue('Path', $updated, 'ExpandString')
    # Tell Windows the environment changed, so new terminal windows see the new PATH.
    Add-Type -Namespace Win32 -Name Native -MemberDefinition @'
[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam, uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
'@
    $HWND_BROADCAST = [IntPtr]0xffff; $WM_SETTINGCHANGE = 0x1A; $SMTO_ABORTIFHUNG = 2
    $result = [UIntPtr]::Zero
    [Win32.Native]::SendMessageTimeout($HWND_BROADCAST, $WM_SETTINGCHANGE, [UIntPtr]::Zero, 'Environment', $SMTO_ABORTIFHUNG, 5000, [ref]$result) | Out-Null
}
$key.Close()

$names = ($commands | ForEach-Object { [IO.Path]::GetFileNameWithoutExtension($_) }) -join ', '
Write-Host "$names now runs from $(Split-Path $bin)"
