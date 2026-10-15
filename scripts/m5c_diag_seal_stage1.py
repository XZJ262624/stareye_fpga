from pathlib import Path
import hashlib,json,subprocess
R=Path(__file__).resolve().parents[1];D=R/'reports/m5c_diagnostics'
def record(p):
 b=p.read_bytes();return dict(path=str(p.relative_to(R)).replace('\\','/'),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def verify(x):
 p=Path(x['path']);b=p.read_bytes();assert len(b)==x['bytes'] and hashlib.sha256(b).hexdigest()==x['sha256'],x['path']
a=D/'stage1_20261015_143117';b=D/'stage1_20261015_143652';c=D/'stage1_20261015_143838'
runs=[a/f'positive_{i}' for i in range(8)]+[a/'negative_row_gate']+[b/('negative_'+n) for n in ['pre_osd','mode','identity']]+[c/'positive_invalid']
checks=0;gates=[]
for run in runs:
 result=json.loads((run/'RESULT.json').read_text());assert result['status'].startswith('PASS')
 for x in result['inputs']:verify(x);checks+=1
 assert len(result['steps'])==3
 for step in result['steps']:
  assert step['exit']==0 and not step['timeout'];verify(step['log']);checks+=1
 log=(run/'sim.log').read_text(errors='replace');assert '** Error:' not in log
 if result['status']=='PASS_POSITIVE':
  assert '** Fatal:' not in log and 'DIAG_SIM_DONE' in log
  assert result['oracle']['status']=='PASS_INDEPENDENT_OBSERVER_WORDS_AND_PACKET_FORMAT'
 else:assert log.count('** Fatal:')==1
 gates.append(dict(path=str(run.relative_to(R)),status=result['status'],result=record(run/'RESULT.json'),raw_native_exit=result['steps'][-1]['exit']))
cmd=['git','-c','safe.directory=F:/Projects/stareye_fpga']
def git(*args):return subprocess.check_output(cmd+list(args),cwd=R).decode().strip()
changed=git('diff','--name-only').splitlines();allowed={'docs/DECISIONS.md','docs/HANDOFF.md','docs/PROJECT_BRIEF.md','docs/STATUS.md'}
assert set(changed)<=allowed;assert not git('diff','--cached','--name-only')
protection=dict(head=git('rev-parse','HEAD'),branch=git('branch','--show-current'),tracked_changes=changed,allowed_work_management_only=True,index_empty=True,production_tracked_diff_empty=True,scope='Git tracked diff plus exact current run inputs. This is not a new independent verification of every historical protection manifest.')
(D/'PROTECTION.json').write_text(json.dumps(protection,indent=2))
(D/'HISTORY.json').write_text(json.dumps(dict(preserved=[dict(path='stage1_20261015_143031',status='COMPILE_FAIL',cause='Ternary lexical whitespace and reserved weak identifier; fixed before passing inputs.'),dict(path='stage1_20261015_143117',status='8_POSITIVE_1_NEGATIVE_COMPLETE_THEN_GENERATOR_ASSERT',cause='pre_osd global inverse touched an existing P3 string; no pre_osd native started here.'),dict(path='stage1_20261015_143322',status='PRE_NATIVE_RECOVERY_PATH_TYPO',cause='Requested 143107 instead of 143117. FileNotFoundError; no native launched.'),dict(path='stage1_20261015_143652',status='REMAINING_3_NEGATIVE_PASS',cause='Exact changed-line inverse; current RTL/TB/oracle unchanged.'),dict(path='stage1_20261015_143838',status='INVALID_POSITIVE_PASS')]),indent=2))
(D/'STAGE1_GATES.json').write_text(json.dumps(dict(status='PASS_FOCUSED_STANDALONE_ONLY',positive_count=9,named_negative_count=4,checks=checks,gates=gates,production_integration=False,resource_measured=False,uart_simulated=False,raw_negative_exit_zero_disclosed=True),indent=2))
paths=[]
for root in [R/'rtl/m5c_diagnostics',R/'tb/m5c_diagnostics',D]:
 for p in root.rglob('*'):
  if p.is_file() and 'work' not in p.relative_to(root).parts and p.suffix not in {'.wlf','.pyc'} and p.name not in {'MANIFEST.json','HANDBACK.json'}:paths.append(p)
paths+=list((R/'scripts').glob('m5c_diag_*.py'))
paths=sorted(set(paths));records=[record(p) for p in paths]
(D/'MANIFEST.json').write_text(json.dumps(dict(records=records,excluded='ModelSim compiled work libraries and WLF; all text native logs, input snapshots, traces, expected/output data, mutation receipts and scripts retained.'),indent=2))
for x in records:verify(dict(x,path=str(R/x['path'])))
(D/'HANDBACK.json').write_text(json.dumps(dict(status='PASS_FOCUSED_STANDALONE_ONLY',manifest=record(D/'MANIFEST.json'),manifest_records=len(records),manifest_bytes=sum(x['bytes'] for x in records),manifest_mismatches=0,gates=record(D/'STAGE1_GATES.json'),protection=protection,next_gate='Work review exact field/edge contract and production binding/storage/CDC scope before integration; no build/Git/hardware performed.'),indent=2))
print(json.dumps(dict(records=len(records),positive=9,negative=4,status='PASS_FOCUSED_STANDALONE_ONLY')))
