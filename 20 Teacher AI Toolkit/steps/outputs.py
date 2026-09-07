"""Step 2 — har prompt ko sach mein chalao aur uska ASLI output save karo.

Yahi wo cheez hai jo is product ko Amazon ki $4.99 wali prompt-list books se alag
karti hai: book mein har prompt ke neeche uska asli output chhapta hai.

Message Batches API use hoti hai — 300 requests latency-sensitive nahi hain, aur
batch par 50% chhoot milti hai.

Kaam resume hota hai: jo prompts pehle ban chuke hain wo dobara nahi chalte, aur
ek adhoora batch agli baar sirf poll hota hai (dobara paisa nahi lagta).
"""

from __future__ import annotations

import json
import time
from typing import Dict, List

import anthropic
from anthropic.types.message_create_params import MessageCreateParamsNonStreaming
from anthropic.types.messages.batch_create_params import Request

import config
from steps.keys import prompt_key, workflow_key

SYSTEM = (
    "You are the AI assistant a classroom teacher is talking to. Answer the request "
    "directly and completely, in the format asked for. Produce the finished artefact "
    "— the actual lesson plan, the actual worksheet, the actual email — not advice "
    "about how to make one, and no preamble about what you are about to do."
)

def collect_items(catalog: dict) -> List[dict]:
    """Har wo cheez jise chalana hai: {key, prompt}."""
    items: List[dict] = []

    for section in config.SECTIONS:
        for p in catalog["sections"].get(section["id"], []):
            text = p.get("example_filled_prompt") or p.get("prompt", "")
            if text.strip():
                items.append({"key": prompt_key(section["id"], p["slug"]),
                              "prompt": text})

    for wf in catalog.get("workflows", []):
        for step in wf.get("steps", []):
            text = step.get("example_filled_prompt") or step.get("prompt", "")
            if text.strip():
                items.append({"key": workflow_key(wf["slug"], step["step"]),
                              "prompt": text})

    # duplicate keys hata do (dono mein ek hi slug aa sakta hai)
    seen, unique = set(), []
    for it in items:
        if it["key"] not in seen:
            seen.add(it["key"])
            unique.append(it)
    return unique


def _load_outputs() -> Dict[str, str]:
    if config.OUTPUTS_JSON.exists():
        return json.loads(config.OUTPUTS_JSON.read_text())
    return {}


def _save_outputs(outputs: Dict[str, str]) -> None:
    config.BUILD.mkdir(parents=True, exist_ok=True)
    config.OUTPUTS_JSON.write_text(json.dumps(outputs, indent=2, ensure_ascii=False))


def _load_state() -> dict:
    if config.BATCH_STATE.exists():
        return json.loads(config.BATCH_STATE.read_text())
    return {}


def _save_state(state: dict) -> None:
    config.BUILD.mkdir(parents=True, exist_ok=True)
    config.BATCH_STATE.write_text(json.dumps(state, indent=2))


def _params(prompt: str) -> MessageCreateParamsNonStreaming:
    params: dict = {
        "model": config.MODEL,
        "max_tokens": config.OUTPUT_MAX_TOKENS,
        "system": SYSTEM,
        "messages": [{"role": "user", "content": prompt}],
    }
    if config.OUTPUT_EFFORT:
        params["output_config"] = {"effort": config.OUTPUT_EFFORT}
    return MessageCreateParamsNonStreaming(**params)


def _harvest(client: anthropic.Anthropic, batch_id: str,
             outputs: Dict[str, str]) -> Dict[str, int]:
    """Ek khatam ho chuke batch ke results uthao. Results kisi bhi order mein aate
    hain — isliye hamesha custom_id se match karo, position se kabhi nahi."""
    tally = {"succeeded": 0, "errored": 0, "canceled": 0, "expired": 0, "empty": 0}

    for result in client.messages.batches.results(batch_id):
        kind = result.result.type
        if kind != "succeeded":
            tally[kind] = tally.get(kind, 0) + 1
            if kind == "errored":
                print(f"    ! {result.custom_id}: {result.result.error.type}")
            continue

        msg = result.result.message
        text = "\n".join(b.text for b in msg.content if b.type == "text").strip()
        if not text:
            tally["empty"] += 1
            continue
        outputs[result.custom_id] = text
        tally["succeeded"] += 1

    _save_outputs(outputs)
    return tally


def _wait(client: anthropic.Anthropic, batch_id: str, poll_seconds: int = 30):
    while True:
        batch = client.messages.batches.retrieve(batch_id)
        if batch.processing_status == "ended":
            return batch
        counts = batch.request_counts
        print(f"    {batch.processing_status}: {counts.succeeded} done, "
              f"{counts.processing} running, {counts.errored} errored",
              flush=True)
        time.sleep(poll_seconds)


def run(catalog: dict, poll_seconds: int = 30) -> Dict[str, str]:
    client = anthropic.Anthropic()
    outputs = _load_outputs()
    state = _load_state()

    # Pichhli baar ka batch adhoora chhoot gaya tha? Pehle usi ko khatam karo.
    if state.get("batch_id"):
        bid = state["batch_id"]
        print(f"  Pehle se chal raha batch mila: {bid}")
        _wait(client, bid, poll_seconds)
        tally = _harvest(client, bid, outputs)
        print(f"  Uthaya gaya: {tally}")
        _save_state({})

    items = collect_items(catalog)
    todo = [i for i in items if i["key"] not in outputs]
    print(f"  {len(items)} prompts total, {len(items) - len(todo)} pehle se ho chuke, "
          f"{len(todo)} baaki")
    if not todo:
        return outputs

    requests = [Request(custom_id=i["key"], params=_params(i["prompt"])) for i in todo]
    batch = client.messages.batches.create(requests=requests)
    _save_state({"batch_id": batch.id, "count": len(todo)})
    print(f"  Batch bheja: {batch.id} ({len(todo)} requests)")
    print("  Zyadatar batch 1 ghante mein poore hote hain (max 24 ghante).")
    print("  Yahan rukna zaroori nahi — Ctrl+C dabao aur baad mein dobara chalao,")
    print("  ye wahin se uthayega jahan chhoda tha.")

    _wait(client, batch.id, poll_seconds)
    tally = _harvest(client, batch.id, outputs)
    _save_state({})

    print(f"  Nateeja: {tally}")
    if tally["errored"] or tally["expired"]:
        print("  Jo fail hue unhe dobara chalane ke liye ye step phir se chala do.")
    return outputs
