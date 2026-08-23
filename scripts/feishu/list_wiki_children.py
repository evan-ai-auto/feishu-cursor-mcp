#!/usr/bin/env python3
"""List wiki child nodes under configured or given parent."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from _feishu_client import (
    config_hint,
    feishu_request,
    get_tenant_access_token,
    load_dotenv,
    wiki_defaults,
)


def list_children(space_id: str, parent_token: str, token: str) -> list[dict]:
    body = feishu_request(
        "GET",
        f"/wiki/v2/spaces/{space_id}/nodes",
        token,
        query=f"parent_node_token={parent_token}&page_size=50",
    )
    if body.get("code") != 0:
        raise RuntimeError(f"list nodes failed: {body.get('msg')}")
    return (body.get("data") or {}).get("items") or []


def main() -> int:
    parser = argparse.ArgumentParser(description="List Feishu wiki child nodes")
    parser.add_argument("--space-id", help="wiki space_id; default from config")
    parser.add_argument("--parent", help="parent node_token; default wiki root from config")
    parser.add_argument("--json", action="store_true", help="raw JSON output")
    args = parser.parse_args()

    env = load_dotenv()
    defaults = wiki_defaults(env)
    space_id = (args.space_id or defaults["space_id"]).strip()
    parent = (args.parent or defaults["parent_node_token"]).strip()

    app_id = (env.get("FEISHU_APP_ID") or "").strip()
    app_secret = (env.get("FEISHU_APP_SECRET") or "").strip()
    if not app_id or not app_secret:
        print(f"Missing credentials. {config_hint()}", file=sys.stderr)
        return 1
    if not space_id or not parent:
        print(
            "Set FEISHU_WIKI_SPACE_ID and FEISHU_WIKI_ROOT_NODE_TOKEN in config, "
            "or pass --space-id / --parent",
            file=sys.stderr,
        )
        return 1

    try:
        tenant = get_tenant_access_token(app_id, app_secret)
        nodes = list_children(space_id, parent, tenant)
    except Exception as exc:  # noqa: BLE001
        print(json.dumps({"ok": False, "error": str(exc)}, ensure_ascii=False), file=sys.stderr)
        return 1

    if args.json:
        print(json.dumps({"ok": True, "nodes": nodes}, ensure_ascii=False, indent=2))
        return 0

    print(f"Wiki children ({len(nodes)}) under parent {parent}:")
    for node in nodes:
        title = node.get("title") or "(untitled)"
        nt = node.get("node_token", "")
        child = " [+]" if node.get("has_child") else ""
        print(f"  - {title}{child}  ({nt})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
