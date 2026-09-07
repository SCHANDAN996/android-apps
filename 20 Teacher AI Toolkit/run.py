#!/usr/bin/env python3
"""Teacher AI Toolkit — build pipeline.

    python run.py status      # kuch kharch kiye bina progress dekho
    python run.py estimate    # kitna paisa lagega, pehle bata do
    python run.py catalog     # step 1: 300 prompts + 12 workflows likhwao
    python run.py outputs     # step 2: har prompt chala kar ASLI output nikalo
    python run.py build       # step 3: HTML + PDF banao, QC chalao
    python run.py all         # teeno, kram se

Har step disk par cache hota hai. Beech mein Ctrl+C dabane par kuch nahi khota —
dobara chalane par wahin se aage badhega.
"""

from __future__ import annotations

import argparse
import json
import math
import sys

import config


# ------------------------------------------------------------------ estimate
# Ye anumaan hain, guarantee nahi. Asli bill isse upar-neeche ho sakta hai.
CATALOG_OUT_TOKENS_PER_CHUNK = 9000   # prompts + thinking
OUTPUT_TOKENS_PER_PROMPT = 2500       # sample output + thinking
INPUT_TOKENS_PER_REQUEST = 900


def _prompt_total() -> int:
    return sum(s["count"] for s in config.SECTIONS)


def _catalog_chunks() -> int:
    n = sum(math.ceil(s["count"] / config.CATALOG_CHUNK) for s in config.SECTIONS)
    return n + math.ceil(config.WORKFLOW_COUNT / config.WORKFLOW_CHUNK)


def _cost(inp: int, out: int, batch: bool) -> float:
    usd = (inp / 1e6) * config.PRICE_IN_PER_MTOK + (out / 1e6) * config.PRICE_OUT_PER_MTOK
    return usd * (config.BATCH_DISCOUNT if batch else 1.0)


def estimate() -> None:
    chunks = _catalog_chunks()
    prompts = _prompt_total()
    wf_steps = config.WORKFLOW_COUNT * 4  # anumaan: 4 steps per workflow
    runs = prompts + wf_steps

    cat = _cost(chunks * INPUT_TOKENS_PER_REQUEST,
                chunks * CATALOG_OUT_TOKENS_PER_CHUNK, batch=False)
    out = _cost(runs * INPUT_TOKENS_PER_REQUEST,
                runs * OUTPUT_TOKENS_PER_PROMPT, batch=True)

    print(f"\n  Model: {config.MODEL}")
    print(f"\n  Step 1 — catalog")
    print(f"    {prompts} prompts + {config.WORKFLOW_COUNT} workflows "
          f"= {chunks} requests")
    print(f"    ~${cat:.2f}")
    print(f"\n  Step 2 — sample outputs (Batch API, 50% chhoot)")
    print(f"    ~{runs} requests")
    print(f"    ~${out:.2f}")
    print(f"\n  KUL ANUMAAN: ~${cat + out:.2f}  (≈ ₹{(cat + out) * 88:.0f})")
    print(f"\n  Ye anumaan hai, guarantee nahi. Asli bill output ki lambai par")
    print(f"  nirbhar karta hai. Kharcha kam karna ho to config.py mein")
    print(f"  OUTPUT_EFFORT = \"low\" kar do, ya section counts ghata do.\n")


# ------------------------------------------------------------------ status
def status() -> None:
    if not config.CATALOG_JSON.exists():
        print("\n  Catalog abhi nahi bana. Shuru karo:  python run.py catalog\n")
        return

    catalog = json.loads(config.CATALOG_JSON.read_text())
    outputs = (json.loads(config.OUTPUTS_JSON.read_text())
               if config.OUTPUTS_JSON.exists() else {})

    print()
    done_total = want_total = 0
    for s in config.SECTIONS:
        have = len(catalog["sections"].get(s["id"], []))
        done_total += have
        want_total += s["count"]
        mark = "✓" if have >= s["count"] else " "
        print(f"  {mark} {s['title']:<32} {have:>3}/{s['count']}")

    wf = len(catalog.get("workflows", []))
    print(f"  {'✓' if wf >= config.WORKFLOW_COUNT else ' '} "
          f"{'Workflows':<32} {wf:>3}/{config.WORKFLOW_COUNT}")
    print(f"\n  Prompts:        {done_total}/{want_total}")
    print(f"  Sample outputs: {len(outputs)}")

    state = (json.loads(config.BATCH_STATE.read_text())
             if config.BATCH_STATE.exists() else {})
    if state.get("batch_id"):
        print(f"  Batch chal raha hai: {state['batch_id']} "
              f"({state.get('count', '?')} requests)")
        print("  Uthane ke liye:  python run.py outputs")
    print()


# ------------------------------------------------------------------ guard
def confirm(step: str, assume_yes: bool) -> bool:
    if assume_yes:
        return True
    print(f"\n  '{step}' asli API calls karega — iska paisa lagega.")
    print("  Pehle `python run.py estimate` chala kar anumaan dekh lo.")
    try:
        return input("  Aage badhein? [y/N] ").strip().lower() in ("y", "yes")
    except (EOFError, KeyboardInterrupt):
        print()
        return False


# ------------------------------------------------------------------ main
def main() -> int:
    ap = argparse.ArgumentParser(description="Teacher AI Toolkit build pipeline")
    ap.add_argument("command",
                    choices=["status", "estimate", "catalog", "outputs", "build", "all"])
    ap.add_argument("-y", "--yes", action="store_true",
                    help="kharche ki puchhtaachh chhodo")
    ap.add_argument("--force", action="store_true",
                    help="catalog: cache hata kar naye sire se banao")
    ap.add_argument("--poll", type=int, default=30,
                    help="outputs: batch kitne second mein check karein (default 30)")
    args = ap.parse_args()

    # counts ka sanity check — chup-chaap galat book mat banao
    total = _prompt_total()
    if total != 300:
        print(f"  Note: config.SECTIONS ka total {total} hai, 300 nahi. "
              f"Jaanbujh kar hai to theek hai.")

    if args.command == "estimate":
        estimate()
        return 0
    if args.command == "status":
        status()
        return 0

    try:
        import anthropic  # noqa: F401
    except ImportError:
        print("  anthropic SDK nahi mila.  pip install -r requirements.txt")
        return 1

    from steps import build, catalog, outputs

    if args.command in ("catalog", "all"):
        if not confirm("catalog", args.yes):
            return 1
        print("\n[1/3] Catalog")
        catalog.run(force=args.force)

    if args.command in ("outputs", "all"):
        if not config.CATALOG_JSON.exists():
            print("  Pehle catalog banao:  python run.py catalog")
            return 1
        if not confirm("outputs", args.yes):
            return 1
        print("\n[2/3] Sample outputs")
        outputs.run(json.loads(config.CATALOG_JSON.read_text()), poll_seconds=args.poll)

    if args.command in ("build", "all"):
        if not config.CATALOG_JSON.exists():
            print("  Pehle catalog banao:  python run.py catalog")
            return 1
        print("\n[3/3] Book")
        build.run()

    print()
    return 0


if __name__ == "__main__":
    sys.exit(main())
