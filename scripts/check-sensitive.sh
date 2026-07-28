#!/bin/bash
# scripts/check-sensitive.sh - PreToolUse guard that blocks tool calls
# targeting sensitive file paths: .env files, *.key/*.pem material, or any
# path under a secrets/ or credentials/ directory.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Nothing to check.
[[ -z "$FILE_PATH" ]] && exit 0

# Normalize backslashes to forward slashes for consistent matching.
NORMALIZED="${FILE_PATH//\\//}"
BASENAME="${NORMALIZED##*/}"

is_sensitive=false

case "$BASENAME" in
  .env|.env.*) is_sensitive=true ;;
esac

case "$BASENAME" in
  *.key|*.pem) is_sensitive=true ;;
esac

case "$NORMALIZED" in
  secrets/*|*/secrets/*) is_sensitive=true ;;
esac

case "$NORMALIZED" in
  credentials/*|*/credentials/*) is_sensitive=true ;;
esac

if [[ "$is_sensitive" == true ]]; then
  echo "Blocked: '$FILE_PATH' matches a sensitive file pattern (.env, *.key, *.pem, secrets/, credentials/)." >&2
  exit 2
fi

exit 0
