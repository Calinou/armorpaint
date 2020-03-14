#!/usr/bin/env python3

import fnmatch
import json
import os
import sys
from typing import List
from typing_extensions import Final

# Change to the directory where the script is located,
# so that the script can be run from any location.
os.chdir(os.path.dirname(os.path.realpath(__file__)))

if not os.path.exists("Sources"):
    sys.exit(
        "ERROR: Couldn't find the Sources folder in the folder where this script is located."
    )

matches = []
for root, dirnames, filenames in os.walk("Sources"):
    dirnames[:] = [d for d in dirnames]
    for filename in fnmatch.filter(filenames, "*.hx"):
        matches.append(os.path.join(root, filename))
matches.sort()

unique_str: List[str] = []
template_data = {}


def process_file(f, fname):

    line = f.readline()
    lc = 1
    while line:

        patterns = ['tr("']
        idx = 0
        pos = 0
        while pos >= 0:
            pos = line.find(patterns[idx], pos)
            if pos == -1:
                if idx < len(patterns) - 1:
                    idx += 1
                    pos = 0
                continue
            pos += len(patterns[idx])

            msg = ""
            while pos < len(line) and (line[pos] != '"' or line[pos - 1] == "\\"):
                msg += line[pos]
                pos += 1

            # Only add each unique string once.
            if msg not in unique_str:
                # Empty keys are considered untranslated by the i18n library.
                # Fix newlines so they're not escaped anymore. Otherwise,
                # they won't match the source strings.
                template_data[msg.replace("\\n", "\n")] = ""
                unique_str.append(msg)

        line = f.readline()
        lc += 1


OUTPUT_PATH: Final = "Assets/locale/_template.json"

print(f'Updating the translation template at "{OUTPUT_PATH}"...')

for fname in matches:
    with open(fname, "r") as f:
        process_file(f, fname)

with open(OUTPUT_PATH, "w") as f:
    json.dump(template_data, f, ensure_ascii=False, indent=4)
