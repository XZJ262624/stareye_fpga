from pathlib import Path
import json,hashlib,subprocess,sys,time
R=Path.cwd();B=R/'reports/m5c_pair_capture_20261016';P=B/'physical_discovery_010353';F=B/'physical_discovery_124300';rows=[]
for name in ['run_route.py','run_route_queries.py','run_queries_persistent.py','run_query_followon.py','prepare_query02_current.py','prepare_query03_current.py','inventory_all.py']:
 p=P/name;q=F/name;q.write_bytes(p.read_bytes());rows.append(dict(source=str(p),copy=str(q),sha256=hashlib.sha256(q.read_bytes()).hexdigest()))
(F/'FOLLOWON_DERIVATION.json').write_text(json.dumps(dict(scope='New current-map inventory/queries and preserved per-stage outputs; old scripts only, no oldresults',copies=rows),indent=2))
with (F/'inventory.log').open('w') as out:
 p=subprocess.Popen([sys.executable,'-B',str(F/'inventory_all.py')],stdout=out,stderr=subprocess.STDOUT,cwd=R);(F/'INVENTORY_OWNER.json').write_text(json.dumps(dict(pid=p.pid,started=time.time())));code=p.wait()
assert code==0
(F/'INVENTORY_RESULT.json').write_text(json.dumps(dict(status='PASS_CURRENT_STRUCTURAL_INVENTORY_EXECUTION',exit=code)))
subprocess.run([sys.executable,'-B',str(R/'scripts/m5c_pair_prepare_query01.py'),str(F)],cwd=R,check=True)
print('current inventory + query preparation complete')
