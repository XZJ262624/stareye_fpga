from pathlib import Path
import json,hashlib,subprocess,sys,shutil,re
R=Path(__file__).resolve().parents[1];A=R/'reports/m5c_shadow_stats_20261016/differential_20261016_135931';W=A/'software_closure';assert not W.exists();W.mkdir()
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
z=json.loads((A/'RESULT.json').read_bytes());assert z['status']=='PASS_SIM_PENDING_SOFTWARE' and z['inputs_unchanged']
bindings=[]
for x in json.loads((A/'INPUTS.json').read_bytes()):
 p=Path(x['path']);v=rec(p);assert v['bytes']==x['bytes'] and v['sha256']==x['sha256'];bindings.append(v)
for s in z['steps']:
 assert s['exit']==0 and not s['timeout'];p=Path(s['log']['path']);v=rec(p);assert v['bytes']==s['log']['bytes'] and v['sha256']==s['log']['sha256'];bindings.append(v)
log=(A/'step2.log').read_text();assert log.count('BASELINE178_DIFF_PASS pixels=921600 modes=7 enable_states=2')==1 and not re.search(r'\*\* (Fatal|Error):',log)
for n in ['wire.hex','sim.log']:shutil.copyfile(A/n,W/n)
cmd=[sys.executable,'-B',str(R/'scripts/m5c_shadow_check_coupled.py'),str(W)]
p=subprocess.run(cmd,cwd=R,capture_output=True);(W/'software.log').write_bytes(p.stdout+p.stderr);assert p.returncode==0
new=json.loads((W/'SOFTWARE_ORACLE.json').read_bytes());old=json.loads((A/'SOFTWARE_ORACLE.json').read_bytes());assert new==old and new['status']=='PASS_COMPLETE_324B_COUPLED'
bindings += [rec(A/'RESULT.json'),rec(A/'SOFTWARE_ORACLE.json'),rec(W/'SOFTWARE_ORACLE.json'),rec(W/'software.log'),rec(R/'scripts/m5c_shadow_check_coupled.py'),rec(Path(__file__)),rec(A.parent/'differential_fixture_v2/DERIVATION.json')]
(W/'GATE_HANDBACK.json').write_text(json.dumps(dict(status='PASS_BASELINE178_720P_14_PAIRS_AND_COMPLETE_WIRE_ORACLE',pixels=921600,modes=7,enable_states=2,native_status_preserved='PASS_SIM_PENDING_SOFTWARE',software_exit=p.returncode,command=cmd,bindings=bindings,scope='All original display outputs plus separate OSD compare every edge. Shared real reference service; not two complete backend instances. Partial-header fixture formatter is exact, strict legal-header transport separately proven in headercoupled. No native rerun or historical receipt modification.'),indent=2))
print('DIFFERENTIAL_CLOSURE_PASS',rec(W/'GATE_HANDBACK.json'))
