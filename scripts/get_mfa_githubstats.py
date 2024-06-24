import csv
import subprocess
import os
import re
from pathlib import Path
root_dir = Path(__file__).parent.parent
cache_file = root_dir.joinpath("data", "ghstats_mfa_cache.txt")
output_file = str(root_dir.joinpath("data", "mfa_counts.csv"))

if not cache_file.exists():
    subprocess.check_call(["ghstats", '-h'], env=os.environ)
    proc = subprocess.run(["ghstats", "MontrealCorpusTools/Montreal-Forced-Aligner", '-d'], env=os.environ, capture_output=True, encoding='utf8')
    with open(cache_file, 'w', encoding='utf8') as f:
        f.write(proc.stdout)
    ghstats_output = proc.stdout
else:
    with open(cache_file, 'r', encoding='utf8') as f:
        ghstats_output = f.read()

pattern = re.compile(r'Tag:\s+(?P<tag>\S+).*?(?P<count>\d+) Total', flags=re.MULTILINE|re.DOTALL)

download_count = 0
for m in pattern.finditer(ghstats_output):
    tag = m.group('tag')
    count = int(m.group('count'))
    print(tag, count)
    download_count += count

print("TOTAL", download_count)