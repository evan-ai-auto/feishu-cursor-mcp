#!/usr/bin/env bash
# Link feishu-mcp kit to any Cursor project.
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 /path/to/project"
  exit 1
fi

KIT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_PATH="$(cd "$1" && pwd)"
LAUNCHER="$KIT_ROOT/scripts/feishu-mcp-stdio.sh"
CURSOR_DIR="$PROJECT_PATH/.cursor"
RULE_TARGET="$CURSOR_DIR/rules/feishu-docs.mdc"
MCP_TARGET="$CURSOR_DIR/mcp.json"
FEISHU_SCRIPTS="$PROJECT_PATH/scripts/feishu"
LINK_META="$PROJECT_PATH/.feishu-mcp.json"

echo "== link feishu-mcp to project =="
echo "Kit:     $KIT_ROOT"
echo "Project: $PROJECT_PATH"

mkdir -p "$CURSOR_DIR/rules"
cp "$KIT_ROOT/templates/cursor-rule-feishu-docs.mdc" "$RULE_TARGET"
mkdir -p "$FEISHU_SCRIPTS"
cp "$KIT_ROOT/scripts/feishu/"*.py "$FEISHU_SCRIPTS/"

python3 - <<PY
import json
from pathlib import Path

mcp_path = Path("$MCP_TARGET")
launcher = "$LAUNCHER"
entry = {"command": "bash", "args": [launcher]}
if mcp_path.exists():
    data = json.loads(mcp_path.read_text(encoding="utf-8"))
    servers = data.setdefault("mcpServers", {})
    servers["feishu-mcp"] = entry
else:
    data = {"mcpServers": {"feishu-mcp": entry}}
mcp_path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print(f"Updated {mcp_path}")
PY

cat > "$LINK_META" <<EOF
{
  "kit_path": "$KIT_ROOT",
  "linked_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "config": "$HOME/.feishu-mcp/config.env"
}
EOF

echo "Copied scripts to $FEISHU_SCRIPTS"
echo "Restart Cursor -> Tools & MCP -> feishu-mcp"
