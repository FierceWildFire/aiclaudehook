#!/bin/bash
# scripts/validate-rule.sh - validates detection rule YAML files for required fields.
#
# Reads a Claude Code hook payload from stdin, and if tool_input.file_path
# points at a YAML file under rules/, verifies it has:
#   - a 'title' field
#   - a 'description' field
#   - a 'tags' array containing at least one 'attack.t<id>' entry
#
# Always exits 2 (both on success and failure) with a message on stderr,
# so Claude sees the feedback either way.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Nothing to validate.
[[ -z "$FILE_PATH" ]] && exit 0

# Only validate YAML files under a rules/ directory.
case "$FILE_PATH" in
  *rules/*.yml|*rules/*.yaml|*rules\\*.yml|*rules\\*.yaml) ;;
  *) exit 0 ;;
esac

[[ -f "$FILE_PATH" ]] || exit 0

PYTHON_BIN=python3
command -v python3 >/dev/null 2>&1 || PYTHON_BIN=python

ERRORS=$("$PYTHON_BIN" - "$FILE_PATH" <<'PYEOF'
import re
import sys

try:
    import yaml
except ImportError:
    print("PyYAML is not installed (pip install pyyaml)")
    sys.exit(1)

path = sys.argv[1]
errors = []

try:
    with open(path, "r", encoding="utf-8") as f:
        data = yaml.safe_load(f)
except yaml.YAMLError as e:
    print(f"Invalid YAML: {e}")
    sys.exit(1)

if not isinstance(data, dict):
    print("Rule file does not contain a YAML mapping at the top level")
    sys.exit(1)

if not data.get("title"):
    errors.append("Missing required field: 'title'")

if not data.get("description"):
    errors.append("Missing required field: 'description'")

tags = data.get("tags")
has_attack_tag = isinstance(tags, list) and any(
    isinstance(t, str) and re.match(r"^attack\.t\d", t, re.IGNORECASE) for t in tags
)
if not has_attack_tag:
    errors.append(
        "Missing required tag: 'tags' must include at least one 'attack.t<id>' "
        "entry (e.g. attack.t1059)"
    )

if errors:
    for e in errors:
        print(e)
    sys.exit(1)

sys.exit(0)
PYEOF
)
STATUS=$?

if [[ $STATUS -ne 0 ]]; then
  {
    echo "Rule validation FAILED for $FILE_PATH:"
    echo "$ERRORS"
  } >&2
  exit 2
fi

echo "Rule validation PASSED for $FILE_PATH" >&2
exit 2
