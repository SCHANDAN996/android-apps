"""Read-only release evidence: unchanged inputs, packaged art and native ELF alignment.

Does not prove runtime behaviour. Run bundletool validate/dump and jarsigner too.
"""
from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path
import struct
import zipfile


def elf_loads(data: bytes) -> list[dict]:
    if data[:4] != b'\x7fELF' or data[5] != 1 or data[4] not in (1, 2):
        raise ValueError('Unsupported native ELF format')
    is64 = data[4] == 2
    phoff = struct.unpack_from('<Q' if is64 else '<I', data, 32 if is64 else 28)[0]
    size, count = struct.unpack_from('<HH', data, 54 if is64 else 42)
    loads = []
    for index in range(count):
        start = phoff + index * size
        if struct.unpack_from('<I', data, start)[0] != 1:
            continue
        offset = struct.unpack_from('<Q' if is64 else '<I', data, start + (8 if is64 else 4))[0]
        address = struct.unpack_from('<Q' if is64 else '<I', data, start + (16 if is64 else 8))[0]
        align = struct.unpack_from('<Q' if is64 else '<I', data, start + (48 if is64 else 28))[0]
        loads.append({'alignment': align, 'congruent16k': (address - offset) % 16384 == 0})
    if not loads:
        raise ValueError('No loadable ELF segments')
    return loads


def verify(bundle: Path, inputs: Path, root: Path) -> dict:
    expected = json.loads(inputs.read_text(encoding='utf-8'))
    root = Path(expected.get('root', root))
    changed = [name for name, digest in expected['files'].items()
               if not (root / name).is_file() or hashlib.sha256((root / name).read_bytes()).hexdigest() != digest]
    if changed:
        raise ValueError(f'Release inputs changed: {changed}')
    artwork = []
    libraries = []
    with zipfile.ZipFile(bundle) as archive:
        corrupt = archive.testzip()
        if corrupt:
            raise ValueError(f'Corrupt bundle member: {corrupt}')
        packaged_assets = 0
        for name, digest in expected['files'].items():
            if not name.startswith('app/assets/'):
                continue
            member = 'base/assets/flutter_assets/' + name.removeprefix('app/')
            if hashlib.sha256(archive.read(member)).hexdigest() != digest:
                raise ValueError(f'Stale packaged asset: {name}')
            packaged_assets += 1
        for asset in ('vrat_tulsi_vivah_v1.webp', 'vrat_kartik_purnima_v1.webp',
                      'reading_g_gita_v2.webp', 'home_puja_arrangement_v1.png'):
            key = f'app/assets/images/devotional/{asset}'
            member = f'base/assets/flutter_assets/assets/images/devotional/{asset}'
            payload = archive.read(member)
            if hashlib.sha256(payload).hexdigest() != expected['files'][key]:
                raise ValueError(f'Stale packaged artwork: {asset}')
            artwork.append({'asset': asset, 'bytes': len(payload), 'matchesSource': True})
        for member in archive.namelist():
            if member.startswith('base/lib/') and member.endswith('.so'):
                loads = elf_loads(archive.read(member))
                required = '/arm64-v8a/' in member or '/x86_64/' in member
                valid = all(p['alignment'] >= 16384 and p['congruent16k'] for p in loads)
                if required and not valid:
                    raise ValueError(f'64-bit native library lacks 16KB alignment: {member}')
                libraries.append({'file': member, '64bitRequired': required,
                                  'elf16kAligned': valid, 'loadSegments': loads})
    if not any(r['64bitRequired'] for r in libraries):
        raise ValueError('No 64-bit native libraries inspected')
    return {'sourceCommit': expected['head'], 'inputFilesMatched': len(expected['files']),
            'bundle': str(bundle), 'bytes': bundle.stat().st_size,
            'sha256': hashlib.sha256(bundle.read_bytes()).hexdigest(), 'packagedAssetsMatched': packaged_assets, 'artwork': artwork,
            'nativeLibraries': libraries,
            'limits': 'Static ELF/asset checks only; use bundletool for ZIP alignment/manifest and a real phone for runtime.'}


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('bundle', type=Path)
    parser.add_argument('inputs', type=Path)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    result = verify(args.bundle, args.inputs, Path(__file__).resolve().parents[1])
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding='utf-8')
    print(f"Verified {result['inputFilesMatched']} unchanged inputs, {len(result['artwork'])} packaged images, "
          f"{len(result['nativeLibraries'])} native libraries; {result['bytes']} bytes")
