#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os, json

OUT = r'C:\Users\calvi\Downloads\SIH_Project_2\ai_saathi\lib\services\localization_service.dart'
DATA = r'C:\Users\calvi\Downloads\SIH_Project_2\ai_saathi\lib\services\_loc_data.json'

with open(DATA, 'r', encoding='utf-8') as f:
    trans = json.load(f)

langs = ['en','hi','mr','gu','bn','ta','te','kn','ml','pa']

lines = []
lines.append("import 'package:flutter/material.dart';")
lines.append("import 'package:provider/provider.dart';")
lines.append("import '../providers/localization_provider.dart';")
lines.append("")
lines.append("extension LocExtension on BuildContext {")
lines.append("  String t(String key) {")
lines.append("    final lang = watch<LocalizationProvider>().currentLanguage;")
lines.append("    return LocalizationService.translate(key, lang);")
lines.append("  }")
lines.append("}")
lines.append("")
lines.append("class LocalizationService {")
lines.append("  static String translate(String key, String lang) {")
lines.append('    return _translations[lang]?[key] ?? _translations["en"]?[key] ?? key;')
lines.append("  }")
lines.append("")
lines.append("  static const Map<String, Map<String, String>> _translations = {")

for lang in langs:
    lines.append(f"    '{lang}': {{")
    d = trans.get(lang, {})
    keys = list(d.keys())
    for i, k in enumerate(keys):
        v = d[k]
        comma = ',' if i < len(keys)-1 else ','
        lines.append(f"      '{k}': '{v}'{comma}")
    lines.append("    },")

lines.append("  };")
lines.append("}")
lines.append("")

content = '\n'.join(lines)
with open(OUT, 'w', encoding='utf-8') as f:
    f.write(content)
print(f"Written {len(content)} bytes to {OUT}")
