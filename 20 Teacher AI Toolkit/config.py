"""Teacher AI Toolkit — build configuration.

Sab kuch yahan se control hota hai. Naya product (Realtor / HR kit) banane ke liye
sirf PRODUCT, SECTIONS aur WORKFLOW_BRIEF badlo — baaki pipeline waisa hi chalega.
"""

from pathlib import Path

# ---------------------------------------------------------------- paths
ROOT = Path(__file__).parent
BUILD = ROOT / "build"
CATALOG_JSON = BUILD / "catalog.json"
OUTPUTS_JSON = BUILD / "outputs.json"
BATCH_STATE = BUILD / "batch_state.json"
BOOK_HTML = BUILD / "teacher-ai-toolkit.html"
BOOK_PDF = BUILD / "teacher-ai-toolkit.pdf"

# ---------------------------------------------------------------- model
MODEL = "claude-opus-5"

# Catalog step: prompts likhna — sochne wala kaam, default effort (high) theek hai.
CATALOG_MAX_TOKENS = 16000
CATALOG_EFFORT = None  # None = API default (high)

# Ek request mein kitne prompts maange jaayein.
# 60 prompts ek saath maangoge to output max_tokens se bahar nikal kar kat jaayega.
# Chhote chunk = reliable schema + beech se resume.
CATALOG_CHUNK = 15
WORKFLOW_CHUNK = 4

# Outputs step: 300 sample outputs banana — bulk kaam.
# "medium" yahan kaafi hai aur kharcha kaafi kam kar deta hai.
# Agar output ki quality kam lage to "high" kar do.
OUTPUT_MAX_TOKENS = 12000
OUTPUT_EFFORT = "medium"

# Pricing ($ per 1M tokens) — estimate ke liye. Batch API par 50% chhoot hai.
PRICE_IN_PER_MTOK = 5.00
PRICE_OUT_PER_MTOK = 25.00
BATCH_DISCOUNT = 0.5

# ---------------------------------------------------------------- product
PRODUCT = {
    "title": "The Teacher AI Toolkit",
    "subtitle": "300 copy-paste prompts and 12 done-for-you workflows",
    "promise": "Every prompt in this book is shown with the real output it produced.",
    "audience": "K-12 classroom teachers",
    "support_email": "CHANGE_ME@example.com",
}

GRADE_BANDS = ["K-2", "3-5", "6-8", "9-12"]

# Prompt sections. `count` ka total 300 hona chahiye (run.py check karta hai).
# `sensitive` wale sections ki har page par professional disclaimer aata hai.
SECTIONS = [
    {
        "id": "lesson-planning",
        "title": "Lesson Planning",
        "count": 60,
        "brief": "Full lesson plans, unit plans, standards alignment, objectives, "
                 "warm-ups, exit tickets, sub plans, pacing guides. Spread across all "
                 "four grade bands and the core subjects.",
    },
    {
        "id": "worksheets",
        "title": "Worksheets & Activities",
        "count": 40,
        "brief": "Practice worksheets, station activities, group tasks, review games, "
                 "project briefs, bell ringers, homework sets.",
    },
    {
        "id": "assessment",
        "title": "Assessment, Rubrics & Quizzes",
        "count": 40,
        "brief": "Quizzes, tests, answer keys, single-point and analytic rubrics, "
                 "exit tickets, formative checks, standards-based grading scales.",
    },
    {
        "id": "differentiation",
        "title": "Differentiation & Mixed Ability",
        "count": 35,
        "sensitive": True,
        "brief": "Tiered versions of a task, scaffolds, extension work for early "
                 "finishers, ELL/multilingual supports, reading-level rewrites, "
                 "accommodations phrased as classroom supports.",
    },
    {
        "id": "parent-communication",
        "title": "Parent Communication",
        "count": 30,
        "brief": "Progress emails, positive notes home, concern emails, conference "
                 "prep, newsletters, permission notes, difficult-conversation scripts.",
    },
    {
        "id": "report-cards",
        "title": "Report Card Comments",
        "count": 30,
        "brief": "Comment banks by grade band and subject, strengths-plus-next-step "
                 "framing, tone variants, bulk comment generation from a score list.",
    },
    {
        "id": "classroom-management",
        "title": "Classroom Management & SEL",
        "count": 25,
        "sensitive": True,
        "brief": "Routines, seating plans, behaviour reset scripts, restorative "
                 "conversation openers, morning meeting and SEL prompts, transitions.",
    },
    {
        "id": "teacher-admin",
        "title": "Teacher Admin & Paperwork",
        "count": 25,
        "brief": "Staff emails, meeting agendas, professional goals, observation "
                 "reflections, field trip logistics, club and duty plans, grant blurbs.",
    },
    {
        "id": "subject-specific",
        "title": "Subject Deep Dives",
        "count": 15,
        "brief": "Math word problem sets, ELA close-reading passages, science lab "
                 "write-ups, primary-source history questions.",
    },
]

WORKFLOW_COUNT = 12
WORKFLOW_BRIEF = (
    "Multi-step chains where the output of one prompt feeds the next. Examples: "
    "'blank page to a full graded unit', 'a stack of scores to 28 finished report "
    "card comments', 'an incident to a documented parent conversation'. Each "
    "workflow has 3-6 steps and states the hours it replaces."
)

# Har prompt ke saath jo asli output dikhta hai, use itne characters par kaato
# (layout sane rakhne ke liye). None = kabhi mat kaato.
MAX_OUTPUT_CHARS = 6000

DISCLAIMER = (
    "These prompts are planning aids. They do not replace your professional "
    "judgement, your school's policies, or any legally required process. Review "
    "everything before it reaches a student, a family, or a permanent record. "
    "Never paste a student's name, ID, or other identifying details into an AI tool."
)
