#!/usr/bin/env bash
# Link feishu-mcp kit to any Cursor project.
# Usage: link-project.sh /path/to/project [/path/to/config.env]
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 /path/to/project [/path/to/config.env]"
  exit 1
fi

KIT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_PATH="$(cd "$1" && pwd)"
CONFIG_PATH="${2:-${FEISHU_MCP_CONFIG:-}}"
LAUNCHER="$KIT_ROOT/scripts/feishu-mcp-stdio.sh"
CURSOR_DIR="$PROJECT_PATH/.cursor"
RULE_TARGET="$CURSOR_DIR/rules/feishu-docs.mdc"
MCP_TARGET="$CURSOR_DIR/mcp.json"
FEISHU_SCRIPTS="$PROJECT_PATH/scripts/feishu"
LINK_META="$PROJECT_PATH/.feishu-mcp.json"
DEFAULT_CONFIG="$HOME/.feishu-mcp/config.env"

if [[ -n "$CONFIG_PATH" ]]; then
  CONFIG_PATH="$(cd "$(dirname "$CONFIG_PATH")" && pwd)/$(basename "$CONFIG_PATH")"
fi

echo "== link feishu-mcp to project =="
echo "Kit:     $KIT_ROOT"
echo "Project: $PROJECT_PATH"
if [[ -n "$CONFIG_PATH" ]]; then
  echo "Config:  $CONFIG_PATH (via FEISHU_MCP_CONFIG in mcp.json)"
fi

mkdir -p "$CURSOR_DIR/rules"
cp "$KIT_ROOT/templates/cursor-rule-feishu-docs.mdc" "$RULE_TARGET"
mkdir -p "$FEISHU_SCRIPTS"
cp "$KIT_ROOT/scripts/feishu/"*.py "$FEISHU_SCRIPTS/"

python3 - <<PY
import json
from pathlib import Path

mcp_path = Path("$MCP_TARGET")
launcher = "$LAUNCHER"
config_path = "$CONFIG_PATH"
entry = {"command": "bash", "args": [launcher]}
if config_path:
    entry["env"] = {"FEISHU_MCP_CONFIG": config_path}
if mcp_path.exists():
    data = json.loads(mcp_path.read_text(encoding="utf-8"))
    servers = data.setdefault("mcpServers", {})
    servers["feishu-mcp"] = entry
else:
    data = {"mcpServers": {"feishu-mcp": entry}}
mcp_path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print(f"Updated {mcp_path}")
PY

META_CONFIG="${CONFIG_PATH:-$DEFAULT_CONFIG}"
python3 - <<PY
import json
from datetime import datetime, timezone
from pathlib import Path

config_path = """$CONFIG_PATH"""
meta = {
    "kit_path": "$KIT_ROOT",
    "linked_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "config": config_path or "$DEFAULT_CONFIG",
}
if config_path:
    meta["feishu_mcp_config_env"] = config_path
Path("$LINK_META").write_text(json.dumps(meta, indent=2) + "\n", encoding="utf-8")
PY

echo "Copied scripts to $FEISHU_SCRIPTS"
echo "Restart Cursor -> Tools & MCP -> feishu-mcp"
