"""Independent acceptance checks; writes text evidence only, never compiles/programs/stages."""
from pathlib import Path
from datetime import datetime, timezone
import argparse
from m1_hdmi_i3_evidence import standard_timing, path_report, coverage, binding, flow_status, require
import ast
import hashlib
import json
import re
import subprocess
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
REPORT = ROOT / 'reports/m1_hdmi_i3'
WORK = ROOT / 'efinity/m1_hdmi_i3'
OUT = WORK / 'outflow'
SOURCE = ROOT / ('document/' + 'VF-Ti60F225_HDK_V2.1_20251009/' * 3 +
                 '06-FPGA_HDL_Basic-2023.2/07_Ti60_HDMI_1080P_Lvds_Test')
BASE = 'a8c39c93a06eeb0686cbb5c13fd44717d49195fa'

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()

def git(*args):
    result = subprocess.run(['git', '--no-optional-locks', '-c',
                             f'safe.directory={ROOT.as_posix()}', *args],
                            cwd=ROOT, capture_output=True, check=True)
    return result.stdout.decode('utf-8').strip()

def active_sdc(path):
    return [line.strip() for line in path.read_text().splitlines()
            if line.strip() and not line.lstrip().startswith('#')]

parser=argparse.ArgumentParser()
parser.add_argument('--precommit', action='store_true', help='also require historical M0 HEAD and empty index before staging')
args=parser.parse_args()
flow_status((REPORT/'compile.log').read_text(), ['map','interface','pnr','pgm'])
flow_status((REPORT/'timing_audit.log').read_text(), ['pnr','pgm'])
outer=json.loads((REPORT/'stage_exitcodes.json').read_text())
require(all(type(outer.get(k)) is int and outer[k]==0 for k in ('configure','compile','timing_audit_and_restore')), 'outer flow failure')
standard_timing((OUT/'Ti60_HDMI_1080P_Test.timing.rpt').read_text())
for group in ('internal','serializer'):
    for kind in ('setup','hold'):
        path_report((REPORT/f'm1_hdmi_i3_{group}_{kind}.rpt').read_text(),kind,group=='serializer')
coverage((REPORT/'m1_hdmi_i3_check_timing.rpt').read_text())
binding(json.loads((REPORT/'final_implementation_binding.json').read_text()),ROOT)
before = json.loads((REPORT / 'original_before.json').read_text(encoding='utf-8-sig'))
actual_paths = {x.relative_to(SOURCE).as_posix() for x in SOURCE.rglob('*') if x.is_file()}
source_checks = []
for row in before:
    path = SOURCE / row['path']
    stamp = row['mtime_utc']
    whole, fraction = stamp.rstrip('Z').split('.')
    epoch = datetime.fromisoformat(whole).replace(tzinfo=timezone.utc)
    expected_ns = int(epoch.timestamp()) * 1_000_000_000 + int(fraction.ljust(9, '0'))
    source_checks.append(path.stat().st_size == row['bytes'] and
                         path.stat().st_mtime_ns == expected_ns and sha(path) == row['sha256'])

project = ET.parse(WORK / 'Ti60_HDMI_1080P_Test.xml').getroot()
device = next(x for x in project.iter() if x.tag.split('}')[-1] == 'device_info')
device_fields = {x.tag.split('}')[-1]: x.get('name') for x in device}
debug = next(x for x in project.iter() if x.tag.split('}')[-1] == 'debugger')
debug_off = any(x.get('name') == 'auto_instantiation' and x.get('value') == 'off'
                for x in debug.iter())
bit = OUT / 'Ti60_HDMI_1080P_Test.bit'
bit_record = json.loads((REPORT / 'bitstream.json').read_text())
timing = (OUT / 'Ti60_HDMI_1080P_Test.timing.rpt').read_text()
audits = [(REPORT / f'm1_hdmi_i3_serializer_{kind}.rpt').read_text()
          for kind in ('setup', 'hold')]
endpoint_sets = [set(re.findall(r'\|\s*(tmds_lvds_tx_data[012]\[\d\])\s*\|', text))
                 for text in audits]
expected_endpoints = {f'tmds_lvds_tx_data{lane}[{i}]' for lane in range(3) for i in range(10)}
slack_lists = [[float(x) for x in re.findall(r'^Slack\s*:\s*([-\d.]+)', text, re.M)]
               for text in audits]
py_files = list((ROOT / 'scripts').glob('m1_hdmi_i3_*.py'))
for path in py_files:
    ast.parse(path.read_text())
ignored = git('check-ignore', '-v', bit.as_posix(),
              'efinity/m1_hdmi_i3/work_pnr/', 'efinity/m1_hdmi_i3/outflow/',
              'efinity/m1_hdmi_i3/example.lock', 'efinity/m1_hdmi_i3/__pycache__/')
checks = {
    'source_69_current_files_unchanged': len(before) == 69 and all(source_checks) and
        actual_paths == {row['path'] for row in before},
    'six_rtl_bytes_match_original': all(sha(SOURCE / x['path']) == sha(WORK / x['path'])
        for x in json.loads((REPORT / 'rtl_integrity.json').read_text())),
    'project_I3_Titanium_Ti60F225': device_fields ==
        {'family': 'Titanium', 'device': 'Ti60F225', 'timing_model': 'I3'},
    'debug_auto_off': debug_off,
    'final_version_I3': 'Timing Model: I3' in timing and 'Version: 2025.1.110.5.9' in timing,
    'final_report_archive_matches': sha(OUT / 'Ti60_HDMI_1080P_Test.timing.rpt') ==
        sha(REPORT / 'Ti60_HDMI_1080P_Test.timing.rpt'),
    'active_sdc_matches_official': active_sdc(WORK / 'Ti60_HDMI_1080P_Test_I3.sdc') ==
        active_sdc(OUT / 'Ti60_HDMI_1080P_Test.pt.sdc'),
    'both_audits_all_30_endpoints': all(x == expected_endpoints for x in endpoint_sets),
    'audits_positive_slack': all(len(x) == 30 and min(x) > 0 for x in slack_lists),
    'bit_size_hash_matches': sha(bit) == bit_record['sha256'] and bit.stat().st_size == bit_record['bytes'],
    'main_branch': git('branch', '--show-current') == 'main',
    'M0_tracked_files_unchanged': not git('diff', '--name-only', '--', 'efinity/m0_led_i3',
                                        'reports/m0_led_i3', 'scripts/m0_led_i3*'),
    'M0_bit_unchanged': sha(ROOT / 'efinity/m0_led_i3/outflow/LED_8bit_Test.bit') ==
        '46AC52D70DF7330864C7F2531361D9383E22475EDAC80FD3635EA2C2F43FF2B0',
    'AGENTS_unchanged': sha(ROOT / 'AGENTS.md') ==
        'EBEE0F615170A818A504618D943F774FB3BAF34E0925EF424EC1EC78F937EAAF',
    'original_plan_unchanged': sha(ROOT / 'docs/AI_COLLABORATION_PLAN.md') ==
        'FAF0766E27756554DFC6C000F0E54D40CCF246D95E6C2B0A680AF62923D59695',
}
if args.precommit:
    checks['precommit_M0_HEAD']=git('rev-parse','HEAD') == BASE
    checks['precommit_index_empty']=not git('diff','--cached','--name-only')
result = {'checks': checks, 'bit': bit_record, 'serializer_min_slack_ns': [min(x) for x in slack_lists],
          'python_AST_checked': len(py_files), 'ignore_rules': ignored.splitlines(),
          'git_status_short': git('status', '--short').splitlines(),
          'agent_did_not_program': True, 'user_reported_M1_JTAG_PASS': True, 'selected_download_path_hash_verified': False, 'precommit_checks_requested':args.precommit}
(REPORT / 'root_review.json').write_text(json.dumps(result, indent=2), encoding='utf-8')
print(json.dumps(result, indent=2))
require(all(checks.values()), str(checks))
