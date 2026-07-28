#!/bin/bash
# scripts/check-prereqs.sh - SessionStart check for required tooling.
#
# This repo's hooks (validate-rule.sh, check-sensitive.sh) depend on jq and
# python3 being on PATH. This just warns to stderr if either is missing; it
# never blocks the session from starting.

MISSING=()

command -v jq >/dev/null 2>&1 || MISSING+=("jq")
command -v python3 >/dev/null 2>&1 || MISSING+=("python3")

if [[ ${#MISSING[@]} -gt 0 ]]; then
  {
    echo "Warning: missing prerequisite(s) required by repo hooks: ${MISSING[*]}"
    echo "Install them for validate-rule.sh / check-sensitive.sh to work correctly."
  } >&2
fi

exit 0
