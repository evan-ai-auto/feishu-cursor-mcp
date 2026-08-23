#!/usr/bin/env bash
# One-time setup: create ~/.feishu-mcp/config.env
set -euo pipefail

KIT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_DIR="$HOME/.feishu-mcp"
CONFIG_FILE="$CONFIG_DIR/config.env"
EXAMPLE="$KIT_ROOT/config/config.env.example"

echo "== feishu-cursor-mcp install =="
echo "Kit: $KIT_ROOT"

for cmd in node npx python3; do
  command -v "$cmd" >/dev/null || { echo "Missing: $cmd"; exit 1; }
done

mkdir -p "$CONFIG_DIR"
if [[ ! -f "$CONFIG_FILE" ]]; then
  cp "$EXAMPLE" "$CONFIG_FILE"
  echo "Created $CONFIG_FILE"
else
  echo "Keep existing $CONFIG_FILE"
fi

chmod +x "$KIT_ROOT/scripts/feishu-mcp-stdio.sh"
chmod +x "$KIT_ROOT/scripts/link-project.sh" 2>/dev/null || true
chmod +x "$KIT_ROOT/scripts/verify.sh" 2>/dev/null || true

echo ""
echo "Next:"
echo "  1. Edit $CONFIG_FILE (save as UTF-8 if using Chinese)"
echo "  2. Import templates/feishu-tenant-scopes.json in Feishu console"
echo "  3. bash scripts/verify.sh"
echo "  4. bash scripts/link-project.sh /path/to/your-project"
echo "  5. Restart Cursor"
