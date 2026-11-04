#!/usr/bin/env bash
set -e

# Format script to remove trailing commas inside .copyWith(...) and then run dart format
python3 -c "
import re, glob

pattern = re.compile(r'(\.copyWith\s*\([^\)]*?),\s*(\))', re.MULTILINE | re.DOTALL)

for fpath in glob.glob('lib/**/*.dart', recursive=True) + glob.glob('test/**/*.dart', recursive=True):
    with open(fpath, 'r', encoding='utf-8') as f:
        content = f.read()
    new_content = pattern.sub(r'\1\2', content)
    # repeat in case of nested
    while new_content != content:
        content = new_content
        new_content = pattern.sub(r'\1\2', content)
    with open(fpath, 'w', encoding='utf-8') as f:
        f.write(new_content)
"

dart format lib/ test/
