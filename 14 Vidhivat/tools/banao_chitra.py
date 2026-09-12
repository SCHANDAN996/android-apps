"""AI से मिले PNG को ऐप के हल्के, पारदर्शी WebP में बदलता है।"""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image


JAD = Path(__file__).resolve().parents[1]
NIRGAM = JAD / "app" / "assets" / "images" / "devotional"


def _safed_hatao(chitra: Image.Image) -> Image.Image:
    rgba = chitra.convert("RGBA")
    pixels = []
    for laal, hara, neela, alpha in rgba.getdata():
        ujala = min(laal, hara, neela)
        if ujala >= 248:
            alpha = 0
        elif ujala > 224:
            alpha = round(alpha * (248 - ujala) / 24)
        pixels.append((laal, hara, neela, alpha))
    rgba.putdata(pixels)
    return rgba


def _chaukor(chitra: Image.Image) -> Image.Image:
    nap = max(chitra.size)
    canvas = Image.new("RGBA", (nap, nap), (0, 0, 0, 0))
    canvas.alpha_composite(
        chitra,
        ((nap - chitra.width) // 2, (nap - chitra.height) // 2),
    )
    return canvas


def banao(source: Path, naam: str, nap: int) -> Path:
    with Image.open(source) as raw:
        chitra = _safed_hatao(raw) if raw.mode != "RGBA" else raw.convert("RGBA")
    chitra = _chaukor(chitra)
    chitra.thumbnail((nap, nap), Image.Resampling.LANCZOS)

    NIRGAM.mkdir(parents=True, exist_ok=True)
    target = NIRGAM / f"{naam}.webp"
    for quality in (76, 68, 60, 52, 44, 38, 32, 26, 20, 16):
        chitra.save(target, "WEBP", quality=quality, method=4)
        if target.stat().st_size <= 180 * 1024:
            break
    # बहुत महीन alpha-किनारे (ख़ासकर अग्नि) कभी-कभी रंग से भी भारी होते
    # हैं। तब बाहरी नाप 900 ही रखते हुए चित्र को थोड़ा भीतर बैठाते हैं।
    if target.stat().st_size > 180 * 1024:
        for anupat in (0.92, 0.84, 0.76):
            andar = chitra.resize(
                (round(nap * anupat), round(nap * anupat)),
                Image.Resampling.LANCZOS,
            )
            canvas = Image.new("RGBA", (nap, nap), (0, 0, 0, 0))
            canvas.alpha_composite(
                andar,
                ((nap - andar.width) // 2, (nap - andar.height) // 2),
            )
            canvas.save(target, "WEBP", quality=32, method=4)
            if target.stat().st_size <= 180 * 1024:
                break
    if target.stat().st_size > 180 * 1024:
        raise SystemExit(f"चित्र 180 KB से बड़ा है: {target.stat().st_size} bytes")
    return target


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("naam")
    parser.add_argument("nap", type=int, choices=(512, 900))
    args = parser.parse_args()
    print(banao(args.source, args.naam, args.nap))


if __name__ == "__main__":
    main()
