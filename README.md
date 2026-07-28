# aiclaudehook

A demo repo showing how [Claude Code](https://claude.com/claude-code) hooks can be wired into a detection-rule authoring workflow: validating rule YAML, blocking edits to sensitive files, and logging activity.

## Layout

```
rules/      Detection rule YAML files (title, description, ATT&CK tags)
scripts/    Hook scripts invoked by .claude/settings.json
.claude/    Claude Code hook configuration
```

## Hooks

Configured in [`.claude/settings.json`](.claude/settings.json):

| Event | Script | Purpose |
|---|---|---|
| `SessionStart` | `check-prereqs.sh` | Warns if `jq` or `python3` are missing (required by other hooks) |
| `PreToolUse` | `check-sensitive.sh` | Blocks tool calls targeting `.env`, `*.key`, `*.pem`, `secrets/`, or `credentials/` paths |
| `PostToolUse` | `log-edit.sh` | Logs edited file paths to `hook-test.log` |
| `PostToolUse` | `validate-rule.sh` | Validates rule YAML under `rules/` — requires `title`, `description`, and an `attack.t<id>` tag |
| `Stop` | `notify-stop.sh` | Shows a Windows balloon notification when Claude finishes responding |

## Rule format

```yaml
title: Demo Rule
description: A simulated rule created to demonstrate the hook chain.
tags:
  - attack.t1059
```

## Requirements

- `bash`
- `jq`
- `python3` with `pyyaml` (`pip install pyyaml`) — used by `validate-rule.sh`
