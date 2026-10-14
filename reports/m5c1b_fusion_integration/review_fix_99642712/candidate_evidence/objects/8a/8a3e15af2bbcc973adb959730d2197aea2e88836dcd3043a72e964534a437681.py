from pathlib import Path
import subprocess,sys,time,json,hashlib,re
R=Path.cwd();F=R/'reports/m5c1b_fusion_integration/review_fix_99642712';D=F/'resource_area_experiment/alias_diagnostic';P=F/'resource_diagnostic';rows=[]
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix() if p.is_relative_to(R) else str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
for name,expect in [('SANITY_SAT','SATISFIABLE'),('SANITY_UNSAT','UNSATISFIABLE'),('SESSION_FAULT_MITER','UNSATISFIABLE')]:
 log=D/(name+'_V4.log');t=time.time();timeout=False
 with log.open('wb') as out:
  cmd=[sys.executable,'-B',str(P/'run_local_abc_v4.py'),name+'.blif'];p=subprocess.Popen(cmd,stdout=out,stderr=subprocess.STDOUT);owner=dict(pid=p.pid,start=t,command=cmd);(D/(name+'_V4_OWNER.json')).write_text(json.dumps(owner,indent=2))
  try:code=p.wait(timeout=120)
  except subprocess.TimeoutExpired:
   timeout=True;subprocess.run(['taskkill','/PID',str(p.pid),'/T','/F'],stdout=out,stderr=subprocess.STDOUT);code=p.wait(timeout=30)
 text=log.read_text(errors='replace');found=re.findall(r'^(UNSATISFIABLE|SATISFIABLE)\s+Time',text,re.M);row=dict(name=name,exit=code,timeout=timeout,seconds=time.time()-t,expected=expect,actual=found,log=rec(log),input=rec(D/(name+'.blif')));rows.append(row);assert code==0 and not timeout and found==[expect],row
p=D/'SESSION_FAULT_SAT_PROOF.json';p.write_text(json.dumps(dict(status='PASS_LOCAL_NEXT_STATE_MITER_UNSAT_WITH_SAT_UNSAT_SANITY',runs=rows,limits='Native sat conflict100000/inspection10000000; installed version has no -T. Outer120seconds perprocess. Prior -T error and boundedBDD failures preserved.',boundary='Two-valued combinational next-state equivalence at named state/interface cutpoints; exact async reset priority, CE/D polarity. Not fullchip formal verification.',bindings=[rec(P/'generate_session_fault_miter.py'),rec(P/'run_local_abc_v4.py'),rec(D/'SESSION_FAULT_SAT_INPUTS.json'),rec(Path('E:/Efinity/2025.1/bin/libabc.dll')),rec(Path('E:/Efinity/2025.1/sim_models/verilog/efx_lut4.v')),rec(Path('E:/Efinity/2025.1/sim_models/verilog/efx_ff.v'))]),indent=2));print(rec(p))
