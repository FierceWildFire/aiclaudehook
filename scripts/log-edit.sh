#!/bin/bash
# scripts/log-edit.sh - for testing that hooks work
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
echo "File modified: $FILE_PATH" >> hook-test.log
