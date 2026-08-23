#!/usr/bin/env python3
"""Smoke test: token, wiki list, optional create/delete probe doc."""

from __future__ import annotations

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


def main() -> int:
    env = load_dotenv()
    app_id = (env.get("FEISHU_APP_ID") or "").strip()
    app_secret = (env.get("FEISHU_APP_SECRET") or "").strip()
    if not app_id or not app_secret:
        print(f"FAIL: missing credentials. {config_hint()}", file=sys.stderr)
        return 1

    report: dict = {"steps": []}

    try:
        tenant = get_tenant_access_token(app_id, app_secret)
        report["steps"].append({"tenant_token": "ok"})
    except Exception as exc:  # noqa: BLE001
        report["steps"].append({"tenant_token": f"fail: {exc}"})
        print(json.dumps(report, ensure_ascii=False, indent=2))
        return 1

    wiki = wiki_defaults(env)
    space_id = wiki["space_id"]
    parent = wiki["parent_node_token"]
    if space_id and parent:
        try:
            body = feishu_request(
                "GET",
                f"/wiki/v2/spaces/{space_id}/nodes",
                tenant,
                query=f"parent_node_token={parent}&page_size=5",
            )
            items = (body.get("data") or {}).get("items") or []
            report["steps"].append(
                {
                    "wiki_list": "ok",
                    "root": wiki["title"],
                    "child_count_sample": len(items),
                    "sample_titles": [i.get("title") for i in items[:5]],
                }
            )
        except Exception as exc:  # noqa: BLE001
            report["steps"].append({"wiki_list": f"fail: {exc}"})
    else:
        report["steps"].append(
            {
                "wiki_list": "skipped",
                "hint": "Set FEISHU_WIKI_SPACE_ID and FEISHU_WIKI_ROOT_NODE_TOKEN",
            }
        )

    collab = (env.get("FEISHU_COLLABORATOR_OPEN_ID") or "").strip()
    if collab:
        report["steps"].append({"collaborator_open_id": "configured"})
    else:
        report["steps"].append(
            {"collaborator_open_id": "not set (auto-grant will fail until configured)"}
        )

    report["ok"] = all(
        "fail" not in str(step.values())
        for step in report["steps"]
        if isinstance(step, dict)
    )
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return 0 if report["ok"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
