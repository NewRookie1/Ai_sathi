#!/usr/bin/env python3
import json, sys, os

p = r'C:\Users\calvi\Downloads\SIH_Project_2\ai_saathi\lib\services\_loc_data.json'
with open(p, 'r', encoding='utf-8') as f:
    d = json.load(f)

lang = sys.argv[1]
json_file = sys.argv[2]

with open(json_file, 'r', encoding='utf-8') as f:
    translations = json.load(f)

d[lang] = translations

with open(p, 'w', encoding='utf-8') as f:
    json.dump(d, f, ensure_ascii=False, indent=2)

print(f'Updated {lang}. Languages: {list(d.keys())}')
print(f'Keys in {lang}: {len(d[lang])}')
