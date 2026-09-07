"""Stable ids — catalog, batch requests aur book teeno isi se match karte hain.

Alag file isliye hai taaki book build karne ke liye Anthropic SDK ki zaroorat na ho.
"""

import hashlib
import re

_SAFE = re.compile(r"[^A-Za-z0-9_-]")


def custom_id(raw: str) -> str:
    """Batch API custom_id: safe charset, unique, <= 64 chars."""
    cid = _SAFE.sub("-", raw)
    if len(cid) > 64:
        cid = cid[:55] + "-" + hashlib.sha1(raw.encode()).hexdigest()[:8]
    return cid


def prompt_key(section_id: str, slug: str) -> str:
    return custom_id(f"{section_id}__{slug}")


def workflow_key(wf_slug: str, step: int) -> str:
    return custom_id(f"wf__{wf_slug}__s{step}")
