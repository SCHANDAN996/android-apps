"""Run the existing generators only inside the supplied staging tree."""
import importlib
import json
import os
import sys

mode, identifier, root, output = sys.argv[1:]
root = os.path.realpath(root)
output = os.path.realpath(output)
if os.path.commonpath([root, output]) != root:
    raise SystemExit("Output must remain in staging")
sys.path.insert(0, os.path.join(root, 'tools'))
os.makedirs(output, exist_ok=True)
if mode == 'granth':
    importlib.import_module('banao_granth').banao(identifier, dst=output)
elif mode == 'aarti':
    module = importlib.import_module('bharo_aarti')
    blocks = module.padho_txt(os.path.join(root, 'tools', 'aarti_paath', identifier + '.txt'))
    if not blocks:
        raise SystemExit('The source is empty')
    module.bharo(identifier, blocks)
    src = os.path.join(root, 'app', 'assets', 'paath', identifier + '.json')
    with open(src, encoding='utf-8') as source:
        data = json.load(source)
    with open(os.path.join(output, identifier + '.json'), 'w', encoding='utf-8', newline='\n') as target:
        json.dump(data, target, ensure_ascii=False, indent=2)
        target.write('\n')
else:
    raise SystemExit('Unknown staging mode')
