# Adds this project's bin\ folder to your user PATH, so the cvdesk command
# works in any new terminal, whichever Node.js version is active. Called by
# setup.bat; does nothing if bin\ is already on PATH.
# The PATH is read and written as stored in the registry, so entries such as
# %USERPROFILE%\... stay as they are and keep working.
$bin = (Resolve-Path "$PSScriptRoot\..\bin").Path

$key = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment', $true)
$current = $key.GetValue('Path', '', 'DoNotExpandEnvironmentNames')
$entries = @($current -split ';' | Where-Object { $_ -ne '' })
if ($entries | Where-Object { $_.TrimEnd('\') -eq $bin.TrimEnd('\') }) {
    Write-Host "$bin is already on your PATH."
    $key.Close()
    exit 0
}
$key.SetValue('Path', (($entries + $bin) -join ';'), 'ExpandString')
$key.Close()

# Tell Windows the environment changed, so new terminal windows see the new PATH.
Add-Type -Namespace Win32 -Name Native -MemberDefinition @'
[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam, uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
'@
$HWND_BROADCAST = [IntPtr]0xffff; $WM_SETTINGCHANGE = 0x1A; $SMTO_ABORTIFHUNG = 2
$result = [UIntPtr]::Zero
[Win32.Native]::SendMessageTimeout($HWND_BROADCAST, $WM_SETTINGCHANGE, [UIntPtr]::Zero, 'Environment', $SMTO_ABORTIFHUNG, 5000, [ref]$result) | Out-Null

Write-Host "Added $bin to your PATH."
