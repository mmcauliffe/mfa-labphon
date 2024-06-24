import os

import pypistats
import subprocess

#stats = pypistats.overall("montreal-forced-aligner")
output = subprocess.check_output(["pypistats", "overall", "montreal-forced-aligner", "--monthly", "-j", '-sd', '2020-12'], env=os.environ)
print(output)