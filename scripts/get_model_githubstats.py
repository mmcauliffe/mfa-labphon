import csv
import subprocess
import os
import re
from pathlib import Path
root_dir = Path(__file__).parent.parent
cache_file = root_dir.joinpath("data", "ghstats_cache.txt")
output_file = str(root_dir.joinpath("data", "mfa_model_counts.csv"))

if not cache_file.exists():
    subprocess.check_call(["ghstats", '-h'], env=os.environ)
    proc = subprocess.run(["ghstats", "MontrealCorpusTools/mfa-models", '-d'], env=os.environ, capture_output=True, encoding='utf8')
    with open(cache_file, 'w', encoding='utf8') as f:
        f.write(proc.stdout)
    ghstats_output = proc.stdout
else:
    with open(cache_file, 'r', encoding='utf8') as f:
        ghstats_output = f.read()

pattern = re.compile(r'Tag:\s+(?P<tag>\S+).*?(?P<count>\d+) Total', flags=re.MULTILINE|re.DOTALL)
archive_pattern = re.compile(r'Tag:\s+(?P<tag>\S+archive\S+).*?(?=\d+ Total)', flags=re.MULTILINE|re.DOTALL)
archive_count_pattern = re.compile(r'(?P<count>\d+)\s+(?P<language>\S+).zip', flags=re.MULTILINE|re.DOTALL)

with open(output_file, 'w', encoding='utf8', newline="") as f:
    writer = csv.DictWriter(f, ["model_type", "version", "language", "dialect", "phoneset", "count"])
    writer.writeheader()
    for m in pattern.finditer(ghstats_output):
        tag = m.group('tag')
        if 'archive' in tag:
            continue
        model_type, tag = tag.split('-', maxsplit=1)
        model_name, version = tag.rsplit('-', maxsplit=1)
        if model_type == 'language_model':
            language, phoneset = model_name.split('_', maxsplit=1)
        else:
            language, phoneset = model_name.rsplit('_', maxsplit=1)
        dialect = None
        if '_' in language:
            language, dialect = language.split('_', maxsplit=1)
        writer.writerow({
            "model_type": model_type,
            "version": version,
            "language": language,
            "dialect": dialect,
            "phoneset": phoneset,
            "count": m.group('count')
        })
    for m in archive_pattern.finditer(ghstats_output):
        tag = m.group('tag')
        model_type = tag.split('-', maxsplit=1)[0]
        version = 'v1.0'
        print(tag)
        print(ghstats_output[m.start():m.end()])
        for m2 in archive_count_pattern.finditer(ghstats_output[m.start():m.end()]):
            count = m2.group('count')
            language = m2.group('language').replace('_ipa', '')
            if model_type == 'g2p':
                language = language.replace('_g2p', '')
            phoneset = 'global_phone'
            dialect = None
            if 'prosodylab' in language:
                phoneset = 'prosodylab'
                language = language.replace('_prosodylab', '')
            if 'lexique' in language:
                phoneset = 'lexique'
                language = language.replace('_lexique', '')
            if language == 'french_qc':
                language, dialect = language.split('_')
            elif language == 'english':
                phoneset = 'arpa'
            elif 'mandarin' in language:
                language = 'mandarin'
                phoneset = 'pinyin'
            elif language in {'dine_bizaad_navajo', 'vietnamese_vphon_south', 'wu'}:
                phoneset = None
                continue
            writer.writerow({
                "model_type": model_type,
                "version": version,
                "language": language,
                "dialect": dialect,
                "phoneset": phoneset,
                "count": count
            })
