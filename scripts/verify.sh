#!/usr/bin/env bash
set -euo pipefail

KIT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_FILE="$HOME/.feishu-mcp/config.env"
PY="$KIT_ROOT/scripts/feishu"

[[ -f "$CONFIG_FILE" ]] || { echo "Missing $CONFIG_FILE — run scripts/install.sh"; exit 1; }

set -a
# shellcheck disable=SC1090
source <(grep -v '^\s*#' "$CONFIG_FILE" | grep -v '^\s*$' | sed 's/\r$//')
set +a

echo "== verify feishu-cursor-mcp =="
echo "Config: $CONFIG_FILE"

npx -y feishu-mcp@latest --version | tail -n 1

python3 - <<PY
import json, urllib.request, os
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

if [[ -n "${FEISHU_COLLABORATOR_MOBILE:-}" || -n "${FEISHU_COLLABORATOR_EMAIL:-}" ]]; then
  python3 "$PY/resolve_feishu_open_id.py"
elif [[ -n "${FEISHU_COLLABORATOR_OPEN_ID:-}" ]]; then
  echo "FEISHU_COLLABORATOR_OPEN_ID is set"
else
  echo "WARN: set FEISHU_COLLABORATOR_OPEN_ID for auto grant"
fi

python3 "$PY/smoke_test.py"
echo "OK"
