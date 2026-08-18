"""Play Store ke screenshot par ऊपर एक पंक्ति लिखो.

    python scripts/screenshot_pankti.py            # सब 8
    python scripts/screenshot_pankti.py 1          # सिर्फ़ पहला (जाँच के लिए)

क्यों HTML + Chrome, Pillow क्यों नहीं
──────────────────────────────────────
इस मशीन का Pillow **Raqm/HarfBuzz के बिना** बना है (`features.check('raqm')`
= False)। उसके बिना देवनागरी की मात्राएँ ग़लत जगह बैठती हैं — "किसान" की
इ-मात्रा क के बाद छपती है। ऐसा चित्र न लगाने से भी बुरा है।

Chrome खुद shaping करता है, इसलिए पंक्ति HTML में लिखकर headless Chrome से
छाप लेते हैं। नाप वही रहता है — 1080×1920 (9:16)।
"""
import subprocess, sys, pathlib, shutil, tempfile, html, io

# Windows का console cp1252 है — देवनागरी और "←" उसमें छपते ही नहीं।
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent
SRC = ROOT / 'screenshots' / 'play_ordered'
OUT = ROOT.parent / 'PLAY_STORE_ASSETS' / 'screenshots'

CHROME = pathlib.Path(r'C:\Program Files\Google\Chrome\Application\chrome.exe')

W, H = 1080, 1920
BAND = 330          # ऊपर की हरी पट्टी
SHOT_H = 1550       # अंदर वाली screen की ऊँचाई

# फ़ाइल → उस पर लिखी जाने वाली पंक्ति
PANKTI = [
    ('1_08_khaad_jawab.png',  'कितनी बोरी खाद डालें — सीधा जवाब'),
    ('2_02_doodh.png',        'रोज़ का दूध हिसाब, अपने आप जुड़ता है'),
    ('3_06_mandi.png',        'अपने ज़िले की मंडी का आज का भाव'),
    ('4_10_mere_pashu.png',   'ब्याने की तारीख़ अपने आप निकलती है'),
    ('5_01_ghar.png',         'किसान का सारा काम, एक ऐप में'),
    ('6_04_palan_guide.png',  'गाय, भैंस, बकरी, मुर्गी — पूरी गाइड'),
    ('7_09_mausam.png',       '10 दिन का मौसम, आपके गाँव का'),
    ('8_11_yojana.png',       'सरकारी योजना — पात्रता यहीं जाँचिए'),
]

TEMPLATE = """<!doctype html><html><head><meta charset="utf-8"><style>
  * {{ margin:0; padding:0; box-sizing:border-box; }}
  html,body {{ width:{W}px; height:{H}px; overflow:hidden; }}
  body {{
    background: linear-gradient(160deg, #1B5E20 0%, #2E7D32 55%, #388E3C 100%);
    font-family: 'Nirmala UI', 'Noto Sans Devanagari', sans-serif;
    display:flex; flex-direction:column; align-items:center;
  }}
  .pankti {{
    height:{BAND}px; width:100%;
    display:flex; align-items:center; justify-content:center;
    padding:0 64px; text-align:center;
    color:#fff; font-weight:700; font-size:60px; line-height:1.28;
    letter-spacing:-0.3px;
    text-shadow:0 2px 10px rgba(0,0,0,.28);
  }}
  .phone {{
    height:{SHOT_H}px; border-radius:26px; overflow:hidden;
    box-shadow:0 18px 46px rgba(0,0,0,.42);
    border:2px solid rgba(255,255,255,.16);
  }}
  .phone img {{ height:100%; display:block; }}
</style></head><body>
  <div class="pankti">{TEXT}</div>
  <div class="phone"><img src="{IMG}"></div>
</body></html>"""


def render(shot: pathlib.Path, text: str, dest: pathlib.Path) -> None:
    img_url = shot.resolve().as_uri()
    page = TEMPLATE.format(W=W, H=H, BAND=BAND, SHOT_H=SHOT_H,
                           TEXT=html.escape(text), IMG=img_url)

    with tempfile.TemporaryDirectory() as td:
        tmp = pathlib.Path(td)
        (tmp / 'p.html').write_text(page, encoding='utf-8')
        png = tmp / 'out.png'
        subprocess.run([
            str(CHROME), '--headless', '--disable-gpu', '--hide-scrollbars',
            '--force-device-scale-factor=1',
            f'--screenshot={png}', f'--window-size={W},{H}',
            (tmp / 'p.html').as_uri(),
        ], check=True, capture_output=True, timeout=120)
        if not png.exists():
            raise RuntimeError(f'Chrome ne chitra nahi banaya: {shot.name}')
        shutil.copy(png, dest)


def main() -> None:
    if not CHROME.exists():
        sys.exit(f'Chrome nahi mila: {CHROME}')
    OUT.mkdir(parents=True, exist_ok=True)

    kaam = PANKTI
    if len(sys.argv) > 1:                 # सिर्फ़ n पहली — जाँच के लिए
        kaam = PANKTI[:int(sys.argv[1])]

    for name, text in kaam:
        shot = SRC / name
        if not shot.exists():
            print(f'  ! {name} nahi mili'); continue
        dest = OUT / name
        render(shot, text, dest)
        print(f'  {name}  ←  "{text}"')

    print(f'\n{len(kaam)} chitra bane -> {OUT}')


if __name__ == '__main__':
    main()
