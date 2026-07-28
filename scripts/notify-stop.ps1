Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$icon = New-Object System.Windows.Forms.NotifyIcon
$icon.Icon = [System.Drawing.SystemIcons]::Information
$icon.Visible = $true
$icon.BalloonTipTitle = 'Claude Code'
$icon.BalloonTipText = 'Claude finished!'
$icon.ShowBalloonTip(4000)

Start-Sleep -Seconds 5
$icon.Dispose()
