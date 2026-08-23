#!/usr/bin/env bash
# Launch feishu-mcp (stdio) for Cursor MCP.
set -euo pipefail

import_dotenv() {
  local file="$1"
  [[ -f "$file" ]] || return 1
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%#*}"
    line="$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    [[ -z "$line" || "$line" != *"="* ]] && continue
    key="${line%%=*}"
    val="${line#*=}"
    val="${val%\"}"; val="${val#\"}"
    val="${val%\'}"; val="${val#\'}"
    export "$key=$val"
  done < "$file"
}

CONFIG_PATH="${FEISHU_MCP_CONFIG:-$HOME/.feishu-mcp/config.env}"
if ! import_dotenv "$CONFIG_PATH"; then
  if [[ -f ".env.feishu" ]]; then
    import_dotenv ".env.feishu"
  fi
fi

if [[ -z "${FEISHU_APP_ID:-}" || -z "${FEISHU_APP_SECRET:-}" ]]; then
  echo "[feishu-mcp] Missing FEISHU_APP_ID or FEISHU_APP_SECRET." >&2
  echo "Create $CONFIG_PATH (run: bash scripts/install.sh)" >&2
  exit 1
fi

AUTH_TYPE="${FEISHU_AUTH_TYPE:-tenant}"
MODULES="${FEISHU_ENABLED_MODULES:-document}"
USER_KEY="${FEISHU_USER_KEY:-stdio}"

ARGS=(
  -y feishu-mcp@latest
  --stdio
  "--feishu-app-id=${FEISHU_APP_ID}"
  "--feishu-app-secret=${FEISHU_APP_SECRET}"
  "--feishu-auth-type=${AUTH_TYPE}"
  "--enabled-modules=${MODULES}"
  "--user-key=${USER_KEY}"
)

if [[ "${FEISHU_SCOPE_VALIDATION:-}" == "false" ]]; then
  ARGS+=(--feishu-scope-validation=false)
fi

exec npx "${ARGS[@]}"
