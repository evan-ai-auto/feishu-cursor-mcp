#!/usr/bin/env python3
"""Grant collaborator permission on a Feishu docx document."""

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
    resolve_open_id_by_email,
    resolve_open_id_by_mobile,
)

PERM_ALIASES = {"full": "full_access", "manage": "full_access"}


def normalize_perm(perm: str) -> str:
    value = (perm or "full_access").strip()
    return PERM_ALIASES.get(value, value)


def _resolve_member(env: dict[str, str], token: str) -> tuple[str, str]:
    open_id = (env.get("FEISHU_COLLABORATOR_OPEN_ID") or "").strip()
    if open_id:
        return "openid", open_id

    mobile = (env.get("FEISHU_COLLABORATOR_MOBILE") or "").strip()
    if mobile:
        return "openid", resolve_open_id_by_mobile(token, mobile)

    email = (env.get("FEISHU_COLLABORATOR_EMAIL") or "").strip()
    if email:
        return "openid", resolve_open_id_by_email(token, email)

    raise RuntimeError(
        "Set FEISHU_COLLABORATOR_OPEN_ID, FEISHU_COLLABORATOR_MOBILE, "
        f"or FEISHU_COLLABORATOR_EMAIL in {config_hint()}"
    )


def grant_collaborator(
    *,
    doc_token: str,
    doc_type: str = "docx",
    perm: str = "full_access",
    env: dict[str, str] | None = None,
) -> dict:
    env = env or load_dotenv()
    app_id = (env.get("FEISHU_APP_ID") or "").strip()
    app_secret = (env.get("FEISHU_APP_SECRET") or "").strip()
    if not app_id or not app_secret:
        raise RuntimeError(f"Missing FEISHU_APP_ID / FEISHU_APP_SECRET. {config_hint()}")

    tenant_token = get_tenant_access_token(app_id, app_secret)
    member_type, member_id = _resolve_member(env, tenant_token)
    perm = normalize_perm(perm)

    payload = {
        "member_type": member_type,
        "member_id": member_id,
        "perm": perm,
    }
    body = feishu_request(
        "POST",
        f"/drive/v1/permissions/{doc_token}/members",
        tenant_token,
        query=f"type={doc_type}",
        payload=payload,
    )
    if body.get("code") != 0:
        raise RuntimeError(
            f"grant collaborator failed: code={body.get('code')} msg={body.get('msg')}"
        )
    return {
        "doc_token": doc_token,
        "member_type": member_type,
        "member_id": member_id,
        "perm": perm,
        "response": body.get("data") or {},
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Grant Feishu document collaborator")
    parser.add_argument("--doc-token", required=True, help="docx document token/id")
    parser.add_argument("--type", default="docx", help="document type, default docx")
    parser.add_argument(
        "--perm",
        default=None,
        choices=["view", "edit", "full_access", "full"],
        help="collaborator permission (full -> full_access)",
    )
    args = parser.parse_args()
    env = load_dotenv()
    perm = normalize_perm(
        args.perm or (env.get("FEISHU_COLLABORATOR_PERM") or "full_access")
    )

    try:
        result = grant_collaborator(
            doc_token=args.doc_token,
            doc_type=args.type,
            perm=perm,
            env=env,
        )
    except Exception as exc:  # noqa: BLE001
        print(json.dumps({"ok": False, "error": str(exc)}, ensure_ascii=False), file=sys.stderr)
        return 1

    print(json.dumps({"ok": True, **result}, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
