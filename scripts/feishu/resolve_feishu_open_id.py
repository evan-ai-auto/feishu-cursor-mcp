#!/usr/bin/env python3
"""Resolve Feishu open_id from mobile or email."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from _feishu_client import (
    config_hint,
    get_tenant_access_token,
    load_dotenv,
    normalize_mobile,
    resolve_open_id_by_email,
    resolve_open_id_by_mobile,
)


def main() -> int:
    parser = argparse.ArgumentParser(description="Resolve Feishu open_id")
    parser.add_argument("--mobile", help="mobile; default from config")
    parser.add_argument("--email", help="email; default from config")
    args = parser.parse_args()

    env = load_dotenv()
    mobile = (args.mobile or env.get("FEISHU_COLLABORATOR_MOBILE") or "").strip()
    email = (args.email or env.get("FEISHU_COLLABORATOR_EMAIL") or "").strip()
    app_id = (env.get("FEISHU_APP_ID") or "").strip()
    app_secret = (env.get("FEISHU_APP_SECRET") or "").strip()

    if not mobile and not email:
        print(
            "Provide --mobile / --email or set FEISHU_COLLABORATOR_* in config. "
            + config_hint(),
            file=sys.stderr,
        )
        return 1
    if not app_id or not app_secret:
        print(f"Missing FEISHU_APP_ID / FEISHU_APP_SECRET. {config_hint()}", file=sys.stderr)
        return 1

    try:
        token = get_tenant_access_token(app_id, app_secret)
        if mobile:
            open_id = resolve_open_id_by_mobile(token, mobile)
            lookup = {"mobile": normalize_mobile(mobile)}
        else:
            open_id = resolve_open_id_by_email(token, email)
            lookup = {"email": email}
    except Exception as exc:  # noqa: BLE001
        print(json.dumps({"ok": False, "error": str(exc)}, ensure_ascii=False), file=sys.stderr)
        return 1

    cfg = load_dotenv()
    cfg_path = Path.home() / ".feishu-mcp" / "config.env"
    print(
        json.dumps(
            {
                "ok": True,
                **lookup,
                "open_id": open_id,
                "hint": f"Add to {cfg_path}: FEISHU_COLLABORATOR_OPEN_ID={open_id}",
            },
            ensure_ascii=False,
            indent=2,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
