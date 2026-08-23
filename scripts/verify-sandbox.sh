#!/usr/bin/env bash
# Sandbox verify: isolated config + link test project. Does not touch ~/.feishu-mcp.
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 /path/to/config.env [sandbox_root] [project_name]"
  exit 1
fi

CONFIG_PATH="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
SANDBOX_ROOT="${2:-$HOME/sandbox}"
PROJECT_NAME="${3:-cursor-mcp-test}"
KIT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KIT_DIR="$SANDBOX_ROOT/feishu-cursor-mcp"
PROJECT_DIR="$SANDBOX_ROOT/$PROJECT_NAME"

echo "== feishu-cursor-mcp sandbox verify =="
echo "Config:  $CONFIG_PATH"
echo "Kit:     $KIT_DIR"
echo "Project: $PROJECT_DIR"

[[ -f "$CONFIG_PATH" ]] || { echo "Config not found: $CONFIG_PATH"; exit 1; }

bash "$KIT_ROOT/scripts/verify.sh" "$CONFIG_PATH"
bash "$KIT_ROOT/scripts/link-project.sh" "$PROJECT_DIR" "$CONFIG_PATH"

echo ""
echo "Sandbox verify CLI: OK"
echo ""
echo "Next: open NEW Cursor window -> $PROJECT_DIR"
echo "See docs/VERIFY_SANDBOX.md"
