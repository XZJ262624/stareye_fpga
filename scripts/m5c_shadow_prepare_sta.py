from pathlib import Path
import json,hashlib,subprocess,sys,re,difflib
R=Path(__file__).resolve().parents[1];B=R/'reports/m5c_shadow_stats_20261016/physical_133645';O=R/'reports/m5c_diagnostics/stage2_resource_bound_v3_20261015_181411'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
records=[]
gen=R/'scripts/m5c_diag_prepare_query01.py';s=gen.read_text().replace("R/'reports/m5c_diagnostics'","R/'reports/m5c_shadow_stats_20261016'")
g=R/'scripts/m5c_shadow_prepare_query01.py';assert not g.exists();g.write_text(s);subprocess.run([sys.executable,'-B',str(g),str(B)],check=True)
for name in ['prepare_query02_current.py','prepare_query03_current.py','run_query_followon.py','prepare_backend_connections.py','prepare_query06_current.py','derive_physical_inventory.py','prepare_supplemental_controls.py','prepare_complete_connections.py','assemble_full_query_plan.py']:
 a=O/name;b=B/name;assert not b.exists();b.write_bytes(a.read_bytes());records.append(dict(parent=rec(a),derived=rec(b)))
for name in ['run_query01.py','run_query_followon.py']:
 p=B/name;s=p.read_text();(B/(name+'.before_persistent')).write_bytes(p.read_bytes())
 # Preserve all actual exit/source/archive/model checks; no normal wall-clock kill.
 pat=r'(?m)^( +)try:code=p.wait\(timeout=\d+\)\n\1except subprocess.TimeoutExpired:\n\1 timed=True\n\1 if p.poll\(\) is None:subprocess.run\(.*?\n\1 code=p.wait\(timeout=30\)'
 def repl(m):
  i=m[1];return i+"while p.poll() is None:\n"+i+" (W/'HEARTBEAT.json').write_text(json.dumps(dict(pid=p.pid,updated=time.time(),elapsed=time.time()-start,status='RUNNING_NO_NORMAL_TIMEOUT_KILL')));time.sleep(5)\n"+i+'code=p.returncode'
 t,n=re.subn(pat,repl,s);assert n==1,(name,n);p.write_text(t);records.append(dict(parent=rec(B/(name+'.before_persistent')),derived=rec(p),diff=''.join(difflib.unified_diff(s.splitlines(True),t.splitlines(True)))))
cells=json.loads((B/'mapped_inventory/SEQUENTIAL_BOUNDARIES.json').read_text())['cells'];dsp=[c for c in cells if c['kind']=='EFX_DSP48'];assert len(dsp)==1 and dsp[0]['name']=='u_m5b1/fusion/reader/mult_23'
for num,name,count in [(4,'04_DSP_config',8),(5,'05_clock_pairs',2)]:
 a=O/'queries'/(name+'.tcl');b=B/'queries'/a.name;assert not b.exists();b.write_bytes(a.read_bytes());(B/f'QUERY{num:02d}_DERIVATION.json').write_text(json.dumps(dict(queries=[dict(name=name,query=rec(b),reports=count)],parent=rec(a),scope='Query reuse only. Actual current native pin/config and clock sets verified; no old results.'),indent=2))
a=O/'run_current_queries_persistent.py';s=a.read_text().replace("assert time.time()-start<3600,'ROUTE_WAIT_TIMEOUT';",'')
s=s.replace("run('inventory',[A/'inventory_all.py'])","run('inventory',[A/'inventory_all.py']);run('physical_inventory',[A/'derive_physical_inventory.py'])")
s=s.replace("state('ALL7_EXECUTED_PENDING_FULL_RECONCILIATION')", "state('ALL7_EXECUTED_PENDING_FULL_RECONCILIATION')\n run('prepare08',[A/'prepare_supplemental_controls.py']);run('query08',[A/'run_query_followon.py','QUERY08_DERIVATION.json','sta_07_backend_missing_connections'])\n run('prepare09',[A/'prepare_complete_connections.py']);run('query09',[A/'run_query_followon.py','QUERY09_DERIVATION.json','sta_08_complete_backend_diagnostic_controls'])\n state('ALL9_EXECUTED_PENDING_FULL_RECONCILIATION')")
p=B/'run_current_queries_persistent.py';p.write_text(s);records.append(dict(parent=rec(a),derived=rec(p)))
(B/'CURRENT_STA_PREPARATION.json').write_text(json.dumps(dict(status='PREPARED_NOT_EXECUTED',records=records,scope='Fresh25bundles1552endpoints, globalD and all diagnostic/backend controls. Unknown classification and actual I3/slacks reconciliation remain mandatory.'),indent=2));print('PREPARED_CURRENT_STA_CHAIN')
