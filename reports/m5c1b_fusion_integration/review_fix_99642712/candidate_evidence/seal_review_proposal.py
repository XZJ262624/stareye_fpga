"""Seal selected proposal only; never stage, commit, or execute native tools."""
from pathlib import Path
import hashlib,json,subprocess,datetime
E=Path(__file__).resolve().parent;R=E.parents[3]
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def put(n,o):
 p=E/n;assert not p.exists();p.write_text(json.dumps(o,indent=2)+'\n');return rec(p)
def git(*args):
 return subprocess.check_output(['git','-c','safe.directory='+R.as_posix(),*args],cwd=R,text=True).strip()
m=json.loads((E/'SOURCE_PACKAGE_MAPPING_V2.json').read_text());v=json.loads((E/'ACTUAL_RUN_COMMAND_CLOSURE_V3.json').read_text())
assert v['status']=='PASS_CURRENT135_RUN_COMMAND_FILE_INCLUDE_CLOSURE' and not v['gaps'] and not v['missing_commands']
checked={}
for x in m['records']:
 q=x['package'];p=R/q['path']
 if q['path'] not in checked:assert rec(p)==q;checked[q['path']]=q
 assert (q['sha256'],q['bytes'])==(x['original']['sha256'],x['original']['bytes'])
for q in m['direct']:assert rec(R/q['path'])==q
head=git('rev-parse','HEAD');assert head=='99642712cfb912f484006f4cd74aba4bdaa8d57b'
limits=json.loads((E/'KNOWN_LIMITS.json').read_text())
limits['supersedes_preparation_limits']=rec(E/'KNOWN_LIMITS.json')
limits['limits']=[s.replace('No Git staging/commit or hardware. Bit files excluded; metadata only.','At preparation time no Git staging/commit was performed; this historical statement does not describe a later fixed candidate. No hardware used. Bit files excluded; metadata only.') for s in limits['limits']]
limits['limits']+=['Default class+mask payload345600 bytes at460800 baud8N1 requires at least7.5 seconds, exceeding approximately2-second sourceTTL. First usable fusion may require subsequent publication. This is source/arithmetic inference, not measured startup latency.','External timing boundaries:7 inputs/135 outputs. Internal no_clock/unconstrained/multiple_clock0/0/0; external classification is not internal timing coverage.','Warm reset/hot recovery, cross-PVT operation and physical board behavior remain unqualified. Cold hard-stop evidence is not warm recovery.','verify_and_restore_selected.py without --restore is read-only and creates no reconstruction. Optional restore only reconstructs selected manifest bytes in a new external directory, without tool execution.']
limits['pending_command_gaps']=v['gaps'];limits['pending_include_gaps']=v['gaps'];limits['final_command_closure']=rec(E/'ACTUAL_RUN_COMMAND_CLOSURE_V3.json')
put('KNOWN_LIMITS_V3.json',limits)
assert not git('diff','--cached','--name-only')
changed=git('diff','--name-only').splitlines();assert set(changed)=={q['path'] for q in m['direct']}
run=subprocess.run(['C:/Users/kqojp/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe','-B',str(E/'verify_and_restore_selected.py')],cwd=R,capture_output=True,text=True)
assert run.returncode==0,run.stderr
validation=put('FINAL_VALIDATION_V3.json',dict(status='PASS_SELECTED_PROPOSAL_BYTES_AND_COMMAND_CLOSURE',time=datetime.datetime.now().isoformat(),source_mapping=rec(E/'SOURCE_PACKAGE_MAPPING_V2.json'),actual_command_closure=rec(E/'ACTUAL_RUN_COMMAND_CLOSURE_V3.json'),mapped_records=len(m['records']),unique_package_objects=len(checked),scoped_gates=135,command_count=v['command_count'],static_include_records=len(v['include_records']),external=m['external'],verification_command=run.args,verification_exit=run.returncode,verification_stdout=run.stdout,verification_stderr=run.stderr,branch=git('branch','--show-current'),head=head,parent=git('rev-parse','HEAD^'),index_empty=True,tracked_changes=changed,limits='135 grouped gates, not independent full-system scenarios. Static compile/include/file-valued arguments checked; installed tools and dynamic Python packages external. Versioned source records are historical, not all equal to current live paths.'))
exclude={'FINAL_REVIEW_ALLOWLIST_V3.json','PREPARATION_HANDBACK_V3.json'}
files=m['direct']+[rec(p) for p in E.rglob('*') if p.is_file() and p.name not in exclude]
assert len(files)==len({q['path'] for q in files})
for q in files:
 assert Path(q['path']).suffix.lower() not in {'.bit','.bin','.exe','.dll','.vdb','.lbf','.wlf','.troutingtraces'},q
allow=put('FINAL_REVIEW_ALLOWLIST_V3.json',dict(status='EXACT_REVIEW_PROPOSAL_NOT_STAGED',records=files,count=len(files),bytes=sum(q['bytes'] for q in files),largest=sorted(files,key=lambda q:q['bytes'],reverse=True)[:30],direct_tracked_count=len(m['direct']),validation=validation,metadata_boundary='This allowlist and subsequent handback are separate exact metadata additions for Work scope freeze; no self-hash cycle. Earlier allowlists remain historical drafts. Inherited parent objects are dependencies, not re-added files.'))
put('PREPARATION_HANDBACK_V3.json',dict(status='READY_FOR_WORK_EXACT_SCOPE_REVIEW_NO_COMMIT_AUTHORIZATION',allowlist=allow,validation=validation,branch=git('branch','--show-current'),repair_baseline=head,required_next_candidate_parent=head,candidate=None,index_empty=True,proposed_files=len(files),proposed_bytes=sum(q['bytes'] for q in files),scoped_gates=dict(focused=7,long_and_default=18,finite=64,legacy=46,total=135),physical=dict(xlr=48007,ram10=192,dsp=1,model='I3 only',setup_ns=.191,hold_ns=.026,bundled_endpoints=1487,max_cq_data_ns=2.632,max_skew_ns=2.339,raw_timing_reports=97,structural_endpoints=61048),bit=dict(sha256='790bd6fdc013cc62ac0ca3383c9667cafe794cedfb48c22096febf02834892e8',bytes=2998245,excluded=True,hardware_used=False),boundaries=rec(E/'KNOWN_LIMITS.json'),next='Work verifies exact proposal and freezes commit scope. No staging, commit, build, or hardware performed by this preparation.'))
print('SEALED_PROPOSAL',len(files),sum(q['bytes'] for q in files),allow['sha256'])
