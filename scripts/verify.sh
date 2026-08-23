#!/usr/bin/env bash
# Verify feishu-cursor-mcp setup. Honors FEISHU_MCP_CONFIG or first arg.
set -euo pipefail

KIT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PY="$KIT_ROOT/scripts/feishu"
CONFIG_FILE="${1:-${FEISHU_MCP_CONFIG:-$HOME/.feishu-mcp/config.env}}"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Missing config: $CONFIG_FILE"
  echo "Run scripts/install.sh or: bash scripts/verify.sh /path/to/config.env"
  exit 1
fi

export FEISHU_MCP_CONFIG="$CONFIG_FILE"

set -a
# shellcheck disable=SC1090
source <(grep -v '^\s*#' "$CONFIG_FILE" | grep -v '^\s*$' | sed 's/\r$//')
set +a

echo "== verify feishu-cursor-mcp =="
echo "Config: $CONFIG_FILE"

npx -y feishu-mcp@latest --version | tail -n 1

python3 - <<PY
import json, os, urllib.request
body = json.dumps({"app_id": os.environ["FEISHU_APP_ID"], "app_secret": os.environ["FEISHU_APP_SECRET"]}).encode()
req = urllib.request.Request(
    "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal",
    data=body, headers={"Content-Type": "application/json"}, method="POST")
with urllib.request.urlopen(req, timeout=30) as resp:
    data = json.loads(resp.read().decode())
if data.get("code") != 0:
    raise SystemExit(f"tenant token failed: {data}")
print(f"tenant_access_token ok, expire={data.get('expire')}s")
PY

if [[ -n "${FEISHU_COLLABORATOR_OPEN_ID:-}" ]]; then
  echo "FEISHU_COLLABORATOR_OPEN_ID is set"
elif [[ -n "${FEISHU_COLLABORATOR_MOBILE:-}" || -n "${FEISHU_COLLABORATOR_EMAIL:-}" ]]; then
  python3 "$PY/resolve_feishu_open_id.py"
else
  echo "WARN: set FEISHU_COLLABORATOR_OPEN_ID for auto grant"
fi

python3 "$PY/smoke_test.py"
echo "OK"
