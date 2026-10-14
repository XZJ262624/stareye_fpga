from pathlib import Path
import subprocess,sys,time,json,hashlib
A=Path(__file__).resolve().parent;R=A.parents[3];start=time.time();rows=[]
def put(status,**kw):
 p=A/'CURRENT_QUERY_CHAIN_STATE.json';tmp=p.with_suffix('.tmp');tmp.write_text(json.dumps(dict(status=status,updated=time.time(),completed=rows,**kw),indent=2));tmp.replace(p)
def run(name,args):
 put('RUNNING',stage=name)
 with (A/('chain_'+name+'.log')).open('wb') as log:
  p=subprocess.Popen([sys.executable,'-B']+[str(x) for x in args],cwd=R,stdout=log,stderr=subprocess.STDOUT);put('RUNNING',stage=name,pid=p.pid);code=p.wait()
 rows.append(dict(stage=name,exit=code));assert code==0,(name,code)
try:
 put('WAIT_ACTUAL_ROUTE_GATE')
 while not (A/'route/RESULT.json').exists():
  assert time.time()-start<3600,'ROUTE_WAIT_TIMEOUT';time.sleep(5)
 r=json.loads((A/'route/RESULT.json').read_text());assert r['status']=='PASS_STAGE' and r['resources']['pass']
 run('query01',[A/'run_query01.py'])
 run('prepare02',[A/'prepare_query02_current.py']);run('query02',[A/'run_query_followon.py','QUERY02_DERIVATION.json','sta_01_bundle_global_Dsetup'])
 run('prepare03',[A/'prepare_query03_current.py']);run('query03',[A/'run_query_followon.py','QUERY03_DERIVATION.json','sta_02_scoped_D_CE_SR_RAM_DSP_IO'])
 run('query04',[A/'run_query_followon.py','QUERY04_DERIVATION.json','sta_03_connections']);run('query05',[A/'run_query_followon.py','QUERY05_DERIVATION.json','sta_04_DSP_config'])
 put('ALL5_EXECUTED_PENDING_FULL_RECONCILIATION')
except BaseException as e:put('FAIL_BLOCKED',error=repr(e));raise
