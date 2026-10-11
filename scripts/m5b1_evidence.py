"""Shared fixed repair evidence locations; historical first-candidate gates remain intact."""
from pathlib import Path
import hashlib,json,subprocess
R=Path(__file__).resolve().parents[1]
B=R/'reports/m5b1_global_canny_i3'
O=B/'review_fix_264962e0'
F=O/'final'
W=R/'efinity/m5b1_global_canny_i3'
P='264962e0c6af61e751c794c5b5f5252d00edbb6c'
BRANCH='codex/m5b1-global-canny-prototype'
BUILD=O/'build_20261010_235246'
GROUPS={'global':'global','system':'system_v4','system_faults':'system_faults_v3','directed':'directed','mutations':'mutations','qos_negative':'qos_negative','tap':'tap'}
SUITES={'core':'review_core_v6.json','negative':'review_negative_v6.json','recovery':'review_recovery_v6.json'}
CASES={'connection_admission':'connection_capture_v4','connection_midloss':'connection_midloss_v4','connection_zero':'connection_zero_v4','default_capture':'default_capture_v4','default_engine':'default_engine_v4','default_export':'default_export_v3'}
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def load(p):return json.loads(p.read_text(encoding='utf-8'))
def git(*a):return subprocess.check_output(['git','-c','safe.directory='+R.as_posix(),*a],cwd=R)
def same(row):
 p=R/row['path'];assert p.is_file() and rec(p)==row,row['path']
def result(path,expected='PASS'):
 d=load(path);assert d['status'].startswith(expected),(path,d.get('status'))
 for row in d.get('sources',[]):same(row)
 if d.get('log'):same(d['log'])
 for c in d.get('cases',d.get('tests',[])):
  if 'log' in c:same(c['log'])
 if d.get('simulator_exit'):
  same(d['simulator_exit']);x=load(R/d['simulator_exit']['path'])
  for k in ('stdout','stderr'):same(x[k])
  assert x['status']=='EXITED'
  if expected=='PASS':assert x['returncode']==0
 return d
