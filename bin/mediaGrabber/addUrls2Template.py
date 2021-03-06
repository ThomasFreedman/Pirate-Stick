#!/usr/bin/env python3
import json
import sys

BASE = sys.argv[1]
URLS = sys.argv[2].split(',')
TEMPLATE = BASE + "/config/psmgTemplate.json"
PSMG_CNF = BASE + "/config/psmgConfig.json"

for url in URLS:
    if not url.lower().startswith("http"):
        #print("URL List Error")
        exit(-1)

with open(TEMPLATE, 'r') as file:
    config = json.load(file)

config["DLbase"] = BASE + "/ytDL/"
config["Grupes"]["PSMG"]["urls"] = URLS

pretty = json.dumps(config, indent=2)
with open(PSMG_CNF, 'w') as out:
    out.write(pretty)
print(PSMG_CNF)
exit(0)

