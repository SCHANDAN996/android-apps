# Teacher AI Toolkit — build pipeline

Ye wo script hai jo `00.2 MARKET RESEARCH` wale plan ka product banati hai:
**300 copy-paste prompts + 12 workflows, aur har prompt ke saath uska ASLI output.**

Wahi ek cheez product ko Amazon ki $4.99 wali prompt-list books se alag karti hai —
aur wahi cheez unke liye haath se karna namumkin hai.

---

## Setup

```bash
cd "20 Teacher AI Toolkit"
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt

export ANTHROPIC_API_KEY=sk-ant-...      # ya:  ant auth login
```

## Chalao

```bash
python run.py estimate     # kitna paisa lagega — pehle ye dekho
python run.py catalog      # step 1: prompts likhwao        (~10-20 min)
python run.py outputs      # step 2: sab chala kar output    (~1 ghanta)
python run.py build        # step 3: HTML + PDF + QC         (seconds)

python run.py status       # kabhi bhi — bina kharche ke progress
python run.py all -y       # teeno ek saath, bina puchhe
```

Sab kuch `build/` mein aata hai:

| File | Kya hai |
|---|---|
| `catalog.json` | 300 prompts + 12 workflows |
| `outputs.json` | Har prompt ka asli output |
| `teacher-ai-toolkit.html` | Book (browser mein khol kar dekho) |
| `teacher-ai-toolkit.pdf` | Book (bechne wali file) |

---

## Design ki 3 baatein

**1. Har step resume hota hai.** Beech mein Ctrl+C dabao ya net chala jaaye — kuch
nahi khota. Har chunk ke baad disk par likha jaata hai, aur dobara chalane par sirf
bacha hua kaam hota hai. 300 prompts ke job mein ye zaroori hai, luxury nahi.

**2. Step 2 Batch API par chalta hai.** 300 sample outputs latency-sensitive nahi
hain, aur batch par **50% chhoot** milti hai. Batch ka id disk par save hota hai —
agar batch chalte waqt aap script band kar do, agli baar wo dobara paisa kharch
nahi karega, sirf usi batch ka nateeja uthayega.

**3. Prompts chunk mein bante hain.** 60 prompts ek hi request mein maangne par
output `max_tokens` se bahar nikal kar **kat jaata hai** — aur pata bhi nahi chalta.
Isliye 15-15 ke chunk, aur har chunk ko pichhle prompts ki list di jaati hai taaki
duplicate na bane.

---

## QC

`python run.py build` har baar ye check karta hai:

- kitne prompts ke output missing hain
- kaun se output shak ke layak chhote hain (< 400 chars)
- kis prompt mein `[PLACEHOLDER]` bhara nahi gaya
- duplicate slug
- grade band ka balance (sab K-2 par to nahi hai?)
- PDF 25 MB se bada to nahi

**Ye poora QC nahi hai.** Strategy doc ke checklist mein jo cheezein haath se karni
hain — prompts ko ChatGPT/Gemini par bhi test karna, differentiation section ko
padhna — wo script nahi kar sakti. Wo bhi karo.

---

## Naya product banana (Realtor / HR kit)

Poori script niche-agnostic hai. `config.py` mein sirf teen cheezein badlo:

1. `PRODUCT` — title, subtitle, audience
2. `SECTIONS` — sections aur counts
3. `WORKFLOW_BRIEF`

Aur `steps/catalog.py` ka `SYSTEM` prompt naye audience ke hisaab se. Bas.
**Ye "factory" hai — pehla product 4 din, doosra 1 din.**

---

## Kharche ka control

`config.py` mein:

| Setting | Asar |
|---|---|
| `OUTPUT_EFFORT` | `"medium"` default. `"low"` sasta, `"high"` behtar |
| `OUTPUT_MAX_TOKENS` | Sample output ki upper limit |
| `SECTIONS[*]["count"]` | Kam prompts = kam kharcha |
| `MAX_OUTPUT_CHARS` | Book mein output kitna chhape (PDF size) |

`python run.py estimate` har badlav ke baad dobara chala kar dekh lo.

---

## Zaroori: ye script product **banati** hai, **verify** nahi karti

Book bikne se pehle wo cheez karo jo koi script nahi kar sakti — kuch prompts khud
chala kar dekho, aur `build/teacher-ai-toolkit.html` ko poora ek baar padho. Agar
prompt kaam nahi karta to refund aur bura review aata hai, aur wahi is niche mein
sabse bada risk hai.
