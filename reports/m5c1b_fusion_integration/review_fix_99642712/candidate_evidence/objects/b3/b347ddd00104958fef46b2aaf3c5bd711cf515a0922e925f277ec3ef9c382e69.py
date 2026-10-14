from pathlib import Path
import subprocess,sys,json,time
R=Path.cwd();F=R/'reports/m5c1b_fusion_integration/review_fix_99642712';D=F/'resource_area_experiment/alias_diagnostic';start=time.time();timeout=False
with (D/'SESSION_FAULT_SAT.log').open('wb') as log:
 p=subprocess.Popen([sys.executable,'-B',str(F/'resource_diagnostic/run_local_abc.py')],stdout=log,stderr=subprocess.STDOUT);(D/'SESSION_FAULT_SAT_OWNER.json').write_text(json.dumps(dict(pid=p.pid,start=start,command=[sys.executable,'-B',str(F/'resource_diagnostic/run_local_abc.py')]),indent=2))
 try:code=p.wait(timeout=120)
 except subprocess.TimeoutExpired:
  timeout=True;subprocess.run(['taskkill','/PID',str(p.pid),'/T','/F'],stdout=log,stderr=subprocess.STDOUT);code=p.wait(timeout=30)
(D/'SESSION_FAULT_SAT_EXIT.json').write_text(json.dumps(dict(exit=code,timeout=timeout,seconds=time.time()-start),indent=2));print(code,timeout);print((D/'SESSION_FAULT_SAT.log').read_text(errors='replace'))
