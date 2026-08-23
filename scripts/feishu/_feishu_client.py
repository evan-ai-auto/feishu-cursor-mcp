"""Shared helpers for Feishu Open API scripts (feishu-cursor-mcp kit)."""

from __future__ import annotations

import json
import os
import platform
import urllib.error
import urllib.request
from pathlib import Path

FEISHU_API_BASE = os.getenv(
    "FEISHU_BASE_URL", "https://open.feishu.cn/open-apis"
).rstrip("/")


def default_config_path() -> Path:
    """User-level unified config: ~/.feishu-mcp/config.env"""
    return Path.home() / ".feishu-mcp" / "config.env"


def resolve_config_path(explicit: Path | None = None) -> Path | None:
    """Resolve config file in priority order."""
    if explicit and explicit.exists():
        return explicit
    env_override = (os.getenv("FEISHU_MCP_CONFIG") or "").strip()
    if env_override:
        path = Path(env_override).expanduser()
        if path.exists():
            return path
    user_cfg = default_config_path()
    if user_cfg.exists():
        return user_cfg
    # Legacy: project-level .env.feishu
    for parent in [Path.cwd(), *Path.cwd().parents]:
        legacy = parent / ".env.feishu"
        if legacy.exists():
            return legacy
    return None


def find_project_root() -> Path:
    here = Path(__file__).resolve()
    for parent in [here.parents[2], here.parents[1], Path.cwd(), *Path.cwd().parents]:
        if (parent / ".git").exists():
            return parent
    return Path.cwd()


def _read_config_text(env_path: Path) -> str:
    """Read config file; tolerate UTF-8 BOM and legacy Windows encodings."""
    for encoding in ("utf-8-sig", "utf-8", "gbk"):
        try:
            return env_path.read_text(encoding=encoding)
        except UnicodeDecodeError:
            continue
    return env_path.read_text(encoding="utf-8", errors="replace")


def load_dotenv(path: Path | None = None) -> dict[str, str]:
    env_path = path or resolve_config_path()
    values: dict[str, str] = {}
    if not env_path or not env_path.exists():
        return values
    for raw in _read_config_text(env_path).splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, val = line.split("=", 1)
        values[key.strip()] = val.strip().strip('"').strip("'")
    return values


def config_hint() -> str:
    return (
        f"Create {default_config_path()} from config/config.env.example, "
        "or set FEISHU_MCP_CONFIG."
    )


def get_tenant_access_token(app_id: str, app_secret: str) -> str:
    payload = json.dumps({"app_id": app_id, "app_secret": app_secret}).encode("utf-8")
    req = urllib.request.Request(
        f"{FEISHU_API_BASE}/auth/v3/tenant_access_token/internal",
        data=payload,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=30) as resp:
        body = json.loads(resp.read().decode("utf-8"))
    if body.get("code") != 0:
        raise RuntimeError(
            f"tenant_access_token failed: code={body.get('code')} msg={body.get('msg')}"
        )
    token = body.get("tenant_access_token")
    if not token:
        raise RuntimeError("tenant_access_token missing in response")
    return token


def feishu_request(
    method: str,
    path: str,
    token: str,
    *,
    query: str = "",
    payload: dict | None = None,
) -> dict:
    url = f"{FEISHU_API_BASE}{path}"
    if query:
        url = f"{url}?{query}"
    data = None
    headers = {"Authorization": f"Bearer {token}"}
    if payload is not None:
        data = json.dumps(payload).encode("utf-8")
        headers["Content-Type"] = "application/json"
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"HTTP {exc.code} {path}: {detail}") from exc


def normalize_mobile(mobile: str) -> str:
    raw = mobile.strip().replace(" ", "").replace("-", "")
    if raw.startswith("+86"):
        return raw
    if raw.startswith("86") and len(raw) > 11:
        return f"+{raw}"
    if raw.isdigit() and len(raw) == 11 and raw.startswith("1"):
        return raw
    if raw.startswith("+"):
        return raw
    return raw


def resolve_open_id_by_mobile(token: str, mobile: str) -> str:
    normalized = normalize_mobile(mobile)
    body = feishu_request(
        "POST",
        "/contact/v3/users/batch_get_id",
        token,
        query="user_id_type=open_id",
        payload={"mobiles": [normalized]},
    )
    if body.get("code") != 0:
        raise RuntimeError(
            f"batch_get_id failed: code={body.get('code')} msg={body.get('msg')}"
        )
    users = (body.get("data") or {}).get("user_list") or []
    for item in users:
        user_open_id = item.get("user_id")
        if not user_open_id:
            continue
        item_mobile = (item.get("mobile") or "").strip()
        if item_mobile == normalized or item_mobile.endswith(normalized.lstrip("+86")):
            return user_open_id
    if len(users) == 1 and users[0].get("user_id"):
        return users[0]["user_id"]
    raise RuntimeError(f"open_id not found for mobile: {mobile}")


def resolve_open_id_by_email(token: str, email: str) -> str:
    body = feishu_request(
        "POST",
        "/contact/v3/users/batch_get_id",
        token,
        query="user_id_type=open_id",
        payload={"emails": [email]},
    )
    if body.get("code") != 0:
        raise RuntimeError(
            f"batch_get_id failed: code={body.get('code')} msg={body.get('msg')}"
        )
    users = (body.get("data") or {}).get("user_list") or []
    for item in users:
        if item.get("email") == email and item.get("user_id"):
            return item["user_id"]
    raise RuntimeError(f"open_id not found for email: {email}")


def wiki_defaults(env: dict[str, str] | None = None) -> dict[str, str]:
    env = env or load_dotenv()
    return {
        "space_id": (env.get("FEISHU_WIKI_SPACE_ID") or "").strip(),
        "parent_node_token": (env.get("FEISHU_WIKI_ROOT_NODE_TOKEN") or "").strip(),
        "title": (env.get("FEISHU_WIKI_ROOT_TITLE") or "文档助手专用").strip(),
    }
