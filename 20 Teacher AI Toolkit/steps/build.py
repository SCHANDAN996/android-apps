"""Step 3 — catalog + asli outputs se book banao (HTML, phir PDF), aur QC chalao."""

from __future__ import annotations

import html
import json
import re
from typing import Dict, List

import config
from steps.keys import prompt_key, workflow_key

# ------------------------------------------------------------------ markdown
_BOLD = re.compile(r"\*\*(.+?)\*\*")
_ITAL = re.compile(r"(?<!\*)\*([^*\n]+?)\*(?!\*)")
_CODE = re.compile(r"`([^`\n]+?)`")


def _inline(text: str) -> str:
    out = html.escape(text)
    out = _BOLD.sub(r"<strong>\1</strong>", out)
    out = _ITAL.sub(r"<em>\1</em>", out)
    out = _CODE.sub(r"<code>\1</code>", out)
    return out


def _md(text: str) -> str:
    """Chhota markdown renderer — headings, lists, paragraphs. Koi dependency nahi."""
    lines, parts, buf, list_tag = text.split("\n"), [], [], None

    def flush_para():
        if buf:
            parts.append(f"<p>{_inline(' '.join(buf))}</p>")
            buf.clear()

    def close_list():
        nonlocal list_tag
        if list_tag:
            parts.append(f"</{list_tag}>")
            list_tag = None

    for raw in lines:
        line = raw.rstrip()
        stripped = line.strip()

        if not stripped:
            flush_para()
            close_list()
            continue

        m = re.match(r"^(#{1,6})\s+(.*)$", stripped)
        if m:
            flush_para()
            close_list()
            level = min(len(m.group(1)) + 2, 6)
            parts.append(f"<h{level}>{_inline(m.group(2))}</h{level}>")
            continue

        m = re.match(r"^[-*+]\s+(.*)$", stripped)
        if m:
            flush_para()
            if list_tag != "ul":
                close_list()
                parts.append("<ul>")
                list_tag = "ul"
            parts.append(f"<li>{_inline(m.group(1))}</li>")
            continue

        m = re.match(r"^(\d+)[.)]\s+(.*)$", stripped)
        if m:
            flush_para()
            if list_tag != "ol":
                close_list()
                parts.append("<ol>")
                list_tag = "ol"
            parts.append(f"<li>{_inline(m.group(2))}</li>")
            continue

        if stripped.startswith("|") or set(stripped) <= set("-|: "):
            flush_para()
            close_list()
            parts.append(f'<div class="raw">{html.escape(line)}</div>')
            continue

        close_list()
        buf.append(stripped)

    flush_para()
    close_list()
    return "\n".join(parts)


def _trim(text: str) -> tuple[str, bool]:
    limit = config.MAX_OUTPUT_CHARS
    if not limit or len(text) <= limit:
        return text, False
    cut = text[:limit]
    nl = cut.rfind("\n")
    return (cut[:nl] if nl > limit * 0.6 else cut), True


# ------------------------------------------------------------------ css
CSS = """
@page { size: A4; margin: 18mm 16mm 20mm 16mm; }
* { box-sizing: border-box; }
body { font: 10.5pt/1.55 "Segoe UI", -apple-system, Helvetica, Arial, sans-serif;
       color: #1b1f24; margin: 0; }
code { font-family: "SF Mono", Menlo, Consolas, monospace; font-size: 0.9em;
       background: #eef1f4; padding: 1px 4px; border-radius: 3px; }

.cover { height: 245mm; display: flex; flex-direction: column;
         justify-content: center; page-break-after: always; }
.cover h1 { font-size: 34pt; line-height: 1.1; margin: 0 0 10mm; letter-spacing: -0.5pt; }
.cover .sub { font-size: 14pt; color: #47515c; margin-bottom: 22mm; }
.cover .promise { font-size: 11pt; border-left: 3px solid #1b1f24;
                  padding-left: 6mm; color: #2b333c; max-width: 120mm; }

h2.section { font-size: 20pt; margin: 0 0 2mm; page-break-before: always;
             page-break-after: avoid; letter-spacing: -0.3pt; }
h2.section + .sectionnote { color: #6b7580; font-size: 9.5pt; margin: 0 0 8mm; }

.card { page-break-inside: avoid; margin: 0 0 9mm; padding-bottom: 6mm;
        border-bottom: 1px solid #e3e7eb; }
.card h3 { font-size: 12.5pt; margin: 0 0 1.5mm; }
.meta { font-size: 8.5pt; color: #6b7580; margin: 0 0 3mm; }
.meta span { display: inline-block; border: 1px solid #d5dae0; border-radius: 3px;
             padding: 0.5mm 2mm; margin-right: 2mm; }
.use { font-size: 9.5pt; color: #3d4650; margin: 0 0 4mm; }

.label { font-size: 8pt; letter-spacing: 0.9pt; text-transform: uppercase;
         color: #6b7580; margin: 0 0 1.5mm; }
.prompt { background: #f5f7f9; border: 1px solid #e3e7eb; border-radius: 4px;
          padding: 4mm; white-space: pre-wrap; font-size: 9.5pt;
          font-family: "SF Mono", Menlo, Consolas, monospace; }
.output { border-left: 3px solid #cfd6dd; padding: 0 0 0 5mm; margin-top: 5mm; }
.output h4, .output h5, .output h6 { font-size: 10.5pt; margin: 4mm 0 1.5mm; }
.output p, .output li { font-size: 9.5pt; }
.output ul, .output ol { margin: 1.5mm 0 1.5mm 5mm; padding: 0; }
.raw { font-family: "SF Mono", Menlo, Consolas, monospace; font-size: 8.5pt;
       white-space: pre-wrap; color: #3d4650; }
.trimmed { font-size: 8.5pt; color: #6b7580; font-style: italic; margin-top: 2mm; }
.missing { font-size: 9pt; color: #9aa3ac; font-style: italic; }

.note { background: #fbf7ec; border: 1px solid #e8dcc0; border-radius: 4px;
        padding: 4mm; font-size: 9pt; margin: 0 0 8mm; }
.toc { page-break-after: always; }
.toc li { margin-bottom: 1.5mm; }
.wf { page-break-inside: avoid; margin-bottom: 9mm; }
.wf .step { margin: 4mm 0 0 5mm; padding-left: 4mm; border-left: 2px solid #e3e7eb; }
footer { margin-top: 14mm; padding-top: 4mm; border-top: 1px solid #e3e7eb;
         font-size: 8.5pt; color: #6b7580; }
"""


# ------------------------------------------------------------------ render
def _card(p: dict, output: str | None) -> str:
    bits = [f'<div class="card">',
            f'<h3>{html.escape(p["title"])}</h3>',
            f'<p class="meta"><span>{html.escape(p.get("grade_band", "All"))}</span>'
            f'<span>{html.escape(p.get("subject", "Any"))}</span></p>',
            f'<p class="use">{html.escape(p.get("use_case", ""))}</p>',
            '<p class="label">The prompt</p>',
            f'<div class="prompt">{html.escape(p["prompt"])}</div>']

    if output:
        text, trimmed = _trim(output)
        bits.append('<div class="output"><p class="label">What it produced</p>')
        bits.append(_md(text))
        if trimmed:
            bits.append('<p class="trimmed">Output continues — trimmed here for length.</p>')
        bits.append("</div>")
    else:
        bits.append('<p class="missing">Sample output not generated yet.</p>')

    bits.append("</div>")
    return "\n".join(bits)


def _workflow(wf: dict, outputs: Dict[str, str]) -> str:
    bits = [f'<div class="wf"><h3>{html.escape(wf["title"])}</h3>',
            f'<p class="use">{html.escape(wf.get("goal", ""))}</p>',
            f'<p class="meta"><span>Replaces {html.escape(wf.get("replaces", "—"))}</span></p>']
    for step in wf.get("steps", []):
        key = workflow_key(wf["slug"], step["step"])
        bits.append(f'<div class="step"><p class="label">Step {step["step"]} — '
                    f'{html.escape(step["title"])}</p>')
        bits.append(f'<div class="prompt">{html.escape(step["prompt"])}</div>')
        out = outputs.get(key)
        if out:
            text, trimmed = _trim(out)
            bits.append('<div class="output"><p class="label">What it produced</p>')
            bits.append(_md(text))
            if trimmed:
                bits.append('<p class="trimmed">Output continues — trimmed for length.</p>')
            bits.append("</div>")
        bits.append("</div>")
    bits.append("</div>")
    return "\n".join(bits)


def render_html(catalog: dict, outputs: Dict[str, str]) -> str:
    p = config.PRODUCT
    parts = [
        "<!doctype html><html><head><meta charset='utf-8'>",
        f"<title>{html.escape(p['title'])}</title>",
        f"<style>{CSS}</style></head><body>",
        f"<div class='cover'><h1>{html.escape(p['title'])}</h1>",
        f"<p class='sub'>{html.escape(p['subtitle'])}</p>",
        f"<p class='promise'>{html.escape(p['promise'])}</p></div>",
        "<div class='toc'><h2 style='page-break-before:auto'>Contents</h2><ol>",
    ]
    for s in config.SECTIONS:
        n = len(catalog["sections"].get(s["id"], []))
        parts.append(f"<li>{html.escape(s['title'])} — {n} prompts</li>")
    parts.append(f"<li>Workflows — {len(catalog.get('workflows', []))}</li></ol>")
    parts.append(f"<div class='note'><strong>Before you start.</strong> "
                 f"{html.escape(config.DISCLAIMER)}</div></div>")

    for s in config.SECTIONS:
        prompts = catalog["sections"].get(s["id"], [])
        parts.append(f"<h2 class='section'>{html.escape(s['title'])}</h2>")
        parts.append(f"<p class='sectionnote'>{len(prompts)} prompts</p>")
        if s.get("sensitive"):
            parts.append(f"<div class='note'>{html.escape(config.DISCLAIMER)}</div>")
        for pr in prompts:
            parts.append(_card(pr, outputs.get(prompt_key(s["id"], pr["slug"]))))

    if catalog.get("workflows"):
        parts.append("<h2 class='section'>Workflows</h2>")
        parts.append("<p class='sectionnote'>Multi-step chains — each step feeds the next.</p>")
        for wf in catalog["workflows"]:
            parts.append(_workflow(wf, outputs))

    parts.append(f"<footer>{html.escape(p['title'])} — support: "
                 f"{html.escape(p['support_email'])}</footer></body></html>")
    return "\n".join(parts)


# ------------------------------------------------------------------ QC
def qc(catalog: dict, outputs: Dict[str, str]) -> List[str]:
    """Strategy doc ka QC checklist — jitna automate ho sakta hai."""
    issues, slugs = [], {}
    total = missing = short = leaky = 0

    for s in config.SECTIONS:
        prompts = catalog["sections"].get(s["id"], [])
        if len(prompts) != s["count"]:
            issues.append(f"{s['title']}: {len(prompts)} prompts, expected {s['count']}")
        for pr in prompts:
            total += 1
            key = f"{s['id']}__{pr['slug']}"
            slugs[key] = slugs.get(key, 0) + 1
            out = outputs.get(prompt_key(s["id"], pr["slug"]))
            if not out:
                missing += 1
            elif len(out) < 400:
                short += 1
                issues.append(f"short output ({len(out)} chars): {key}")
            if "[" in pr.get("example_filled_prompt", ""):
                leaky += 1
                issues.append(f"unfilled placeholder in example: {key}")

    for key, n in slugs.items():
        if n > 1:
            issues.append(f"duplicate slug x{n}: {key}")

    bands = {}
    for s in config.SECTIONS:
        for pr in catalog["sections"].get(s["id"], []):
            bands[pr.get("grade_band", "?")] = bands.get(pr.get("grade_band", "?"), 0) + 1

    print(f"\n  Prompts: {total}   with output: {total - missing}   missing: {missing}")
    print(f"  Suspiciously short: {short}   unfilled placeholders: {leaky}")
    print(f"  Grade bands: {dict(sorted(bands.items()))}")
    return issues


# ------------------------------------------------------------------ run
def run() -> None:
    catalog = json.loads(config.CATALOG_JSON.read_text())
    outputs = (json.loads(config.OUTPUTS_JSON.read_text())
               if config.OUTPUTS_JSON.exists() else {})

    config.BUILD.mkdir(parents=True, exist_ok=True)
    config.BOOK_HTML.write_text(render_html(catalog, outputs), encoding="utf-8")
    print(f"  HTML: {config.BOOK_HTML}")

    issues = qc(catalog, outputs)
    if issues:
        print(f"\n  QC ne {len(issues)} baat uthayi hai (pehli 15):")
        for i in issues[:15]:
            print(f"    - {i}")
    else:
        print("\n  QC saaf hai.")

    _pdf()


def _chromium_candidates() -> list:
    """Playwright ka pinned browser na mile to ye raste dekho.
    (Kuch environments mein chromium alag jagah pehle se rakha hota hai.)"""
    import os
    import glob

    found = []
    env = os.environ.get("CHROMIUM_PATH")
    if env:
        found.append(env)
    found += sorted(glob.glob("/opt/pw-browsers/chromium-*/chrome-linux/chrome"))
    found += ["/usr/bin/chromium", "/usr/bin/chromium-browser",
              "/usr/bin/google-chrome"]
    return [f for f in found if os.path.exists(f)]


def _pdf() -> None:
    """HTML se PDF. Ye step fail hone par build fail nahi hota — HTML kaafi hai."""
    try:
        from playwright.sync_api import sync_playwright
    except ImportError:
        print("\n  PDF ke liye:  pip install playwright && playwright install chromium")
        print("  Tab tak HTML ko browser mein khol kar Print -> Save as PDF karo.")
        return

    attempts = [None] + _chromium_candidates()
    last_error = None

    for exe in attempts:
        try:
            with sync_playwright() as pw:
                kwargs = {"executable_path": exe} if exe else {}
                browser = pw.chromium.launch(**kwargs)
                page = browser.new_page()
                page.goto(config.BOOK_HTML.resolve().as_uri(), wait_until="load")
                page.pdf(path=str(config.BOOK_PDF), format="A4", print_background=True)
                browser.close()
            break
        except Exception as exc:  # browser missing / sandbox / launch failure
            last_error = exc
            continue
    else:
        print(f"\n  PDF nahi ban paaya: {type(last_error).__name__}")
        print("  Theek karne ke liye:  playwright install chromium")
        print("  Ya HTML ko browser mein khol kar Print -> Save as PDF karo.")
        print(f"  HTML taiyar hai: {config.BOOK_HTML}")
        return

    mb = config.BOOK_PDF.stat().st_size / 1_048_576
    print(f"  PDF:  {config.BOOK_PDF}  ({mb:.1f} MB)")
    if mb > 25:
        print("  \u26a0 25 MB se bada hai \u2014 config.py mein MAX_OUTPUT_CHARS kam karo.")
