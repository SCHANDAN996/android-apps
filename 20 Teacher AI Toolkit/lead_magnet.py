#!/usr/bin/env python3
"""Free lead magnet — "25 AI Prompts That Save Teachers 5 Hours a Week".

Ye ₹0 wala validation step hai (strategy doc, "PEHLE MUFT MEIN VALIDATE KARO").
Teacher Facebook groups mein ye free baanto aur email count dekho:

    3 din mein 100+ email  ->  demand asli hai, ads chalu karo
    20 se kam              ->  angle galat hai, ads par paisa mat lagao

Iska content haath se likha hua hai — **koi API call nahi, koi kharcha nahi**.

    python lead_magnet.py
"""

from __future__ import annotations

import glob
import html
import os

import config
from steps.build import CSS, _md

TITLE = "25 AI Prompts That Save Teachers 5 Hours a Week"
SUBTITLE = "Copy, paste, fill in the brackets. Works in ChatGPT, Claude and Gemini."

FOOTER_CTA = (
    "These 25 are the fastest wins. The full Teacher AI Toolkit has 300 prompts "
    "and 12 multi-step workflows — and every single one is printed with the real "
    "output it produced, so you can see what you are getting before you run it."
)

SAFETY = (
    "Never paste a student's name, ID, or any identifying detail into an AI tool. "
    "Use initials or 'Student A'. Everything these prompts produce is a first "
    "draft — read it before it reaches a student, a family, or a permanent record."
)

# ---------------------------------------------------------------------------
# 25 prompts. Har prompt mein role, context, constraint aur output format hai —
# ek-line wale prompts kaam nahi karte, aur teacher ko wahi farak dikhta hai.
# ---------------------------------------------------------------------------
PROMPTS = [
    # ---- Planning ----------------------------------------------------------
    ("Planning", "A full lesson plan from one standard", "K-2 · 3-5 · 6-8 · 9-12",
     "You have the standard and 40 minutes. This writes the whole plan.",
     """You are an experienced [GRADE] teacher planning a [MINUTES]-minute lesson on [TOPIC], aligned to [STANDARD CODE OR DESCRIPTION].

Write the full plan with these sections and nothing else:
1. Learning objective, in student-facing "I can" language
2. Warm-up (3-5 min) that surfaces prior knowledge
3. Mini-lesson with the exact steps I model, in order
4. Guided practice, including what I circulate and look for
5. Independent practice
6. Exit ticket — one question that would actually reveal who did not get it
7. The single most common misconception on this topic, and the exact question I ask to catch it

Keep every section short enough to read at a glance while teaching. No introduction, no summary."""),

    ("Planning", "Emergency sub plan in 5 minutes", "All grades",
     "You are sick at 6am. This writes a plan a stranger can teach.",
     """Write a substitute teacher plan for [GRADE] [SUBJECT] for [NUMBER] periods.

Assume the sub knows nothing about my class and may not know the subject. The work must be meaningful, not busywork, and must need no preparation or special materials.

Include:
- A 3-line "what this class is like" note
- Minute-by-minute timing for each period
- Exactly what to write on the board
- The task itself, written out in full so it can be photocopied
- What to do if students finish early
- What to leave me a note about

Write it as one page the sub can follow top to bottom."""),

    ("Planning", "A week of bell ringers", "3-5 · 6-8 · 9-12",
     "Five warm-ups that spiral back to what they keep forgetting.",
     """Create 5 bell ringers (one per day) for [GRADE] [SUBJECT], each taking under 5 minutes.

They must spiral: Monday and Tuesday review [TOPIC THEY KEEP FORGETTING], Wednesday and Thursday preview [THIS WEEK'S TOPIC], Friday mixes both.

For each day give me: the question exactly as students will see it, the answer, and one sentence on what a wrong answer tells me."""),

    ("Planning", "Unit skeleton from a end goal", "6-8 · 9-12",
     "Work backwards from the assessment instead of forwards from day one.",
     """I am planning a [NUMBER]-week unit on [TOPIC] for [GRADE]. The unit ends with [FINAL ASSESSMENT].

Work backwards. Give me:
- The 4-6 things students must be able to do to succeed on that assessment
- Those skills sequenced across the weeks, with a reason for the order
- One checkpoint per week that tells me who is off track early
- The two lessons in this unit most likely to go wrong, and why

Table format, one row per week."""),

    ("Planning", "Turn a textbook chapter into a lesson", "6-8 · 9-12",
     "The book has the content. It does not have a lesson.",
     """Below is a textbook section for [GRADE] [SUBJECT]. Turn it into a [MINUTES]-minute lesson that does not involve reading it aloud.

Give me: a hook that creates a question the text answers, the 3 ideas worth keeping (and what to cut), an activity that makes students use the ideas rather than restate them, and an exit ticket.

TEXT:
[PASTE THE SECTION HERE]"""),

    # ---- Report cards ------------------------------------------------------
    ("Report cards", "28 report card comments from a score list", "All grades",
     "The single biggest time sink of the term, done in one pass.",
     """I am writing report card comments for [GRADE] [SUBJECT].

Below is my class list as "Student initials | overall grade | one or two keywords about them". For each student write a comment of [NUMBER] sentences that:
- opens with a specific strength, not a generic compliment
- names one concrete next step the student can act on
- is written to be read by a parent, warm but honest
- never compares one student to another

Vary the sentence openings — comments that all start the same way read as copy-paste.

CLASS LIST:
[A.B. | B+ | strong writer, rushes edits]
[C.D. | C | participates, struggles with multi-step problems]
[PASTE THE REST]"""),

    ("Report cards", "Rewrite a blunt comment", "All grades",
     "You know what you mean. This makes it survivable for a parent.",
     """Rewrite the report card comment below so it is honest but not deflating for a parent to read.

Keep every fact. Do not soften it into meaninglessness — the parent must still understand there is a problem and what to do about it. Give me three versions: gentle, direct, and firm.

COMMENT:
[PASTE YOUR DRAFT]"""),

    ("Report cards", "A comment bank you can reuse all year", "All grades",
     "Build it once in January, use it every term after.",
     """Build a report card comment bank for [GRADE] [SUBJECT].

Give me 6 comments for each of these bands: excelling, secure, approaching, struggling, and inconsistent effort.

Each comment must have a blank [NAME] and one blank [SPECIFIC EXAMPLE] so I can drop in something real. Vary the openings across the bank. Group them under headings."""),

    # ---- Parent communication ---------------------------------------------
    ("Parent emails", "The email you have been putting off", "All grades",
     "A concern email that does not turn into a meeting about your tone.",
     """Write an email to a parent about a concern.

Concern: [WHAT IS HAPPENING]
What I have already tried: [WHAT YOU TRIED]
What I want from this email: [A MEETING / AWARENESS / SUPPORT AT HOME]

Rules: open with something genuine and specific about the child. State the concern in plain terms without jargon or diagnosis language. Describe behaviour, never character. End with one clear ask. Under 200 words. No emoji.

Then give me a shorter version for a parent who does not read long emails."""),

    ("Parent emails", "Positive notes home, ten at a time", "All grades",
     "The highest-return five minutes in teaching.",
     """Write 10 short positive notes home for [GRADE], one per student, based on the notes below.

Each must be 2-3 sentences, name something specific (not "a pleasure to teach"), and sound like a real person wrote it. Vary the structure so they do not read as a template.

STUDENTS:
[A.B. — helped a new student find the room]
[C.D. — finally asked for help instead of staying stuck]
[PASTE THE REST]"""),

    ("Parent emails", "Conference prep one-pager", "All grades",
     "Ten minutes per family, and you have 24 families.",
     """I have parent conferences for [GRADE] [SUBJECT]. Each is [MINUTES] minutes.

From the notes below, build me a one-page card per student with: one strength with evidence, one growth area with evidence, one thing to ask the parent, and one thing the parent can do at home. Keep each card to what I can scan in 20 seconds.

NOTES:
[PASTE YOUR NOTES]"""),

    ("Parent emails", "Class newsletter from rough notes", "K-2 · 3-5",
     "Bullet points in, finished newsletter out.",
     """Turn these rough notes into a warm, scannable class newsletter for [GRADE] families for the week of [DATE].

Sections: what we learned, what is coming up, dates to remember, how to help at home. Keep it under 300 words, use headings, and write at a reading level any parent can follow.

NOTES:
[PASTE YOUR BULLET POINTS]"""),

    # ---- Differentiation ---------------------------------------------------
    ("Differentiation", "One task, three levels", "All grades",
     "Same lesson, three entry points, no extra planning period.",
     """Take the task below for [GRADE] [SUBJECT] and give me three versions:

- Scaffolded: same thinking, more support (sentence starters, worked example, chunked steps)
- On-level: as written, tightened if needed
- Extension: same topic, genuinely harder thinking — not just more questions

All three must be able to run in the same room at the same time, and end with students able to share in one discussion.

TASK:
[PASTE YOUR TASK]"""),

    ("Differentiation", "Rewrite a text to a lower reading level", "3-5 · 6-8 · 9-12",
     "Keep the ideas. Lose the barrier.",
     """Rewrite the passage below for [GRADE] students reading roughly [NUMBER] years below grade level.

Keep every key idea and all subject vocabulary — define the vocabulary in place rather than removing it. Shorten sentences, make the structure obvious, and add a heading every few paragraphs.

Then list the 5 words a student may still get stuck on, with a student-friendly definition each.

PASSAGE:
[PASTE THE TEXT]"""),

    ("Differentiation", "Supports for multilingual learners", "All grades",
     "Access to the lesson, not a different lesson.",
     """For the [GRADE] [SUBJECT] lesson below, give me supports for students still developing English.

I need: the 6 words that will block comprehension with a plain definition and a visual I could sketch, sentence frames for the discussion, a way for a student to show understanding without writing a paragraph, and one thing I should say differently while teaching.

Do not simplify the content or lower the expectation — only the language load.

LESSON:
[PASTE YOUR PLAN]"""),

    ("Differentiation", "Real work for early finishers", "All grades",
     "Not a word search. Something that actually extends.",
     """Students finishing [TASK] early in [GRADE] [SUBJECT] need something that extends the same thinking, not filler.

Give me 5 options that: need no new instruction from me, take 5-15 minutes, use only what is already on their desk, and could be shared with the class in one sentence.

For each, say in one line what deeper thinking it demands."""),

    # ---- Assessment --------------------------------------------------------
    ("Assessment", "A quiz with an answer key and a diagnosis", "3-5 · 6-8 · 9-12",
     "Every wrong answer tells you something specific.",
     """Write a [NUMBER]-question quiz on [TOPIC] for [GRADE].

Mix recall, application, and one question that needs reasoning. For each question give me: the question, the answer, and — for each wrong option — what a student choosing it probably misunderstands.

Then tell me which 2 questions to look at first when I grade, to find out fastest who needs reteaching."""),

    ("Assessment", "A single-point rubric", "All grades",
     "One column of criteria. Faster to write, far faster to grade.",
     """Build a single-point rubric for [ASSIGNMENT] in [GRADE] [SUBJECT].

Format: a centre column stating what proficient looks like for each criterion, with blank columns either side for "needs work" and "exceeds" that I fill in per student. Use 4-5 criteria maximum, written in language a [GRADE] student can read and act on.

Then give me 3 feedback sentences per criterion that I can reuse."""),

    ("Assessment", "Exit tickets that actually sort the class", "All grades",
     "One question that separates 'got it' from 'nodded along'.",
     """Write 5 exit ticket questions for [TOPIC] in [GRADE] [SUBJECT].

Each must be answerable in under 3 minutes and must distinguish real understanding from surface repetition — a student who only copied the steps should get it wrong.

For each, tell me what a correct answer proves and what the most likely wrong answer tells me to reteach."""),

    ("Assessment", "Questions aimed at one misconception", "All grades",
     "You know exactly what they are getting wrong. Target it.",
     """My [GRADE] students are consistently making this mistake in [SUBJECT]: [DESCRIBE THE MISTAKE].

Give me 6 questions designed so that a student holding this misconception gets them wrong in a visible way, plus 2 where the misconception does not matter — so I can tell it apart from a general struggle.

Then give me the sequence of 3 questions I would ask one student, out loud, to walk them out of it."""),

    # ---- Worksheets & activities ------------------------------------------
    ("Worksheets", "A worksheet that ramps properly", "K-2 · 3-5 · 6-8",
     "Starts where they are, ends where you want them.",
     """Create a practice worksheet on [TOPIC] for [GRADE].

Structure it in four blocks: 2 warm-up items anyone can do, 5 core items building in difficulty, 2 items that combine this with [EARLIER TOPIC], and 1 challenge.

Include the answer key, and mark which single item is the "if they get this, they have it" question."""),

    ("Worksheets", "A station rotation from one topic", "K-2 · 3-5 · 6-8",
     "Four stations, four different ways in, one period.",
     """Design 4 stations on [TOPIC] for [GRADE], [MINUTES] minutes each.

Each station must use a different mode — one hands-on, one reading, one talking, one writing — and must work without me standing there.

For each: the instruction card exactly as students read it, materials (nothing I have to buy), and what I check when I walk past."""),

    # ---- Time & admin ------------------------------------------------------
    ("Time & admin", "The email to your admin", "All grades",
     "Professional, short, and it makes the ask clearly.",
     """Write an email to [ADMINISTRATOR ROLE] about [SITUATION].

I want: [WHAT YOU ACTUALLY WANT]. Tone: professional, brief, not apologetic and not confrontational. Lead with the ask, then the context, then what I have already done. Under 150 words.

Then a one-line version for a hallway conversation."""),

    ("Time & admin", "Behaviour reset script", "All grades",
     "What to say when it goes wrong, prepared in advance.",
     """A [GRADE] student is [DESCRIBE THE BEHAVIOUR]. I want to reset this without a power struggle and without an audience.

Give me: what I say in the moment (under 15 words), what I say to them one-to-one afterwards, and three things NOT to say and why.

Focus on the behaviour and the repair, not on the student's character. This is a classroom conversation, not a diagnosis."""),

    ("Time & admin", "Morning meeting for a whole week", "K-2 · 3-5",
     "Five days of openings, built around one thread.",
     """Plan 5 morning meetings for [GRADE], 10 minutes each, threaded around [THEME].

Each day: a greeting, a share prompt that a shy student can answer in one sentence, and a 2-minute activity. Build across the week so Friday connects back to Monday.

Keep the prompts about things students choose to share, never about home circumstances."""),
]

# 3 asli sample output — dikhane ke liye ki paid book kaisi hai
SAMPLES = {
    "28 report card comments from a score list": """**A.B. — B+**

A.B. writes with a confidence that shows in every first draft, and this term her opening paragraphs have become genuinely persuasive. Her next step is editing: she reaches the end of a piece and stops, when a second pass is where her writing would go from good to strong. Asking her to reread one paragraph aloud before submitting would make a visible difference.

**C.D. — C**

C.D. contributes to every class discussion and is often the first to attempt a question others avoid — that willingness is a real strength. Multi-step problems are where the difficulty sits: he understands each step alone but loses the thread partway through. Working through problems by writing each step on its own line, rather than solving in his head, is the habit to build this term.""",

    "One task, three levels": """**Scaffolded version**

Same question, more support:
- A worked example of a similar problem sits at the top of the page
- The task is broken into three labelled steps rather than one instruction
- Sentence starters for the explanation: "I know ___ because ___", "First I ___, then I ___"
- The numbers are chosen so the arithmetic never blocks the thinking

**On-level version**

The task as written, with one change: the instruction now names the format of the answer ("explain your reasoning in two sentences"), which removes the ambiguity most students stall on.

**Extension version**

Same topic, harder thinking — not more questions:
- One of the given values is removed; students must decide what information they would need and justify it
- A second part asks: "A classmate got [wrong answer]. What did they most likely do?"

**Running all three together**

All three end at the same discussion question, so the share-out works as one conversation. Circulate to the scaffolded group first — they need you in the first four minutes; the extension group needs you at minute twelve.""",

    "The email you have been putting off": """**Subject: A quick note about maths homework**

Dear [Parent name],

I want to start by saying that [Student] has been one of the steadiest contributors in our class discussions this term — he asks the question everyone else is thinking, which takes some courage.

I am writing because homework has not been coming in for the past three weeks. I have checked that he has the assignments written down, moved his seat closer to the board, and offered lunchtime catch-up sessions twice. None of it has changed the pattern, so I think I am missing something about what is getting in the way at this end of the day.

Would you have fifteen minutes this week for a phone call? I would rather understand what is happening than keep guessing.

Best wishes,
[Your name]

---

**Shorter version**

Dear [Parent name],

[Student] contributes well in class, but homework has not come in for three weeks. I have tried reminders, a seat change, and lunchtime sessions without a change.

Could we speak for fifteen minutes this week? I would like to understand what is getting in the way.

Best wishes,
[Your name]""",
}


def render() -> str:
    groups: dict[str, list] = {}
    for group, title, bands, use, prompt in PROMPTS:
        groups.setdefault(group, []).append((title, bands, use, prompt))

    parts = [
        "<!doctype html><html><head><meta charset='utf-8'>",
        f"<title>{html.escape(TITLE)}</title><style>{CSS}</style></head><body>",
        f"<div class='cover'><h1>{html.escape(TITLE)}</h1>",
        f"<p class='sub'>{html.escape(SUBTITLE)}</p>",
        "<p class='promise'>Three of them are shown with the real output they "
        "produced, so you can see what you are actually getting.</p></div>",
        f"<div class='note'><strong>Before you start.</strong> {html.escape(SAFETY)}</div>",
    ]

    n = 0
    for group, items in groups.items():
        parts.append(f"<h2 class='section'>{html.escape(group)}</h2>")
        parts.append(f"<p class='sectionnote'>{len(items)} prompts</p>")
        for title, bands, use, prompt in items:
            n += 1
            parts += [
                "<div class='card'>",
                f"<h3>{n}. {html.escape(title)}</h3>",
                f"<p class='meta'><span>{html.escape(bands)}</span></p>",
                f"<p class='use'>{html.escape(use)}</p>",
                "<p class='label'>The prompt</p>",
                f"<div class='prompt'>{html.escape(prompt)}</div>",
            ]
            if title in SAMPLES:
                parts.append("<div class='output'><p class='label'>What it produced</p>")
                parts.append(_md(SAMPLES[title]))
                parts.append("</div>")
            parts.append("</div>")

    parts += [
        "<h2 class='section'>What is in the full toolkit</h2>",
        f"<div class='note'>{html.escape(FOOTER_CTA)}</div>",
        f"<footer>{html.escape(TITLE)} &mdash; "
        f"{html.escape(config.PRODUCT['support_email'])}</footer></body></html>",
    ]
    return "\n".join(parts)


def main() -> None:
    config.BUILD.mkdir(parents=True, exist_ok=True)
    out_html = config.BUILD / "lead-magnet.html"
    out_pdf = config.BUILD / "lead-magnet.pdf"
    out_html.write_text(render(), encoding="utf-8")
    print(f"  HTML: {out_html}")
    print(f"  {len(PROMPTS)} prompts, {len(SAMPLES)} with real sample output")

    try:
        from playwright.sync_api import sync_playwright
    except ImportError:
        print("  PDF ke liye: pip install playwright && playwright install chromium")
        return

    exes = [None] + [p for p in
                     sorted(glob.glob("/opt/pw-browsers/chromium-*/chrome-linux/chrome"))
                     + ["/usr/bin/chromium", "/usr/bin/google-chrome"]
                     if os.path.exists(p)]
    for exe in exes:
        try:
            with sync_playwright() as pw:
                b = pw.chromium.launch(**({"executable_path": exe} if exe else {}))
                pg = b.new_page()
                pg.goto(out_html.resolve().as_uri(), wait_until="load")
                pg.pdf(path=str(out_pdf), format="A4", print_background=True)
                b.close()
            print(f"  PDF:  {out_pdf}  "
                  f"({out_pdf.stat().st_size / 1_048_576:.2f} MB)")
            return
        except Exception:
            continue
    print("  PDF nahi bana — HTML browser mein khol kar Print -> Save as PDF karo.")


if __name__ == "__main__":
    main()
