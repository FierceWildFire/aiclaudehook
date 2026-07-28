#!/bin/bash
# scripts/notify-stop.sh - Stop hook: shows a non-blocking Windows balloon
# notification when Claude finishes responding. The notification runs in a
# detached PowerShell process (notify-stop.ps1) so this hook returns
# immediately and never blocks Claude Code waiting on a click.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PS1_PATH="$(cygpath -w "$SCRIPT_DIR/notify-stop.ps1")"

powershell.exe -NoProfile -WindowStyle Hidden -Command \
  "Start-Process powershell.exe -WindowStyle Hidden -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File','$PS1_PATH'" \
  >/dev/null 2>&1

exit 0
