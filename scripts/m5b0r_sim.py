"""Run reproducible diagnostic/prototype HDL tests; fail closed on simulator errors."""
from pathlib import Path
import subprocess,json,hashlib,re,sys
ROOT=Path(__file__).resolve().parents[1]
TB=ROOT/'tb/m5b0r_ddr_admission';OUT=ROOT/'reports/m5b0r_ddr_admission/sim'
MS=Path('E:/Modelsim_10.1c/win64')
def record(p):return dict(path=p.relative_to(ROOT).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def run(args,name):
 OUT.mkdir(parents=True,exist_ok=True)
 log=OUT/(name+'.log')
 with log.open('wb') as f:p=subprocess.run(list(map(str,args)),cwd=TB,stdout=f,stderr=subprocess.STDOUT,timeout=900)
 s=log.read_text(errors='replace')
 assert p.returncode==0 and not re.search(r'\*\* (Error|Fatal):',s),(name,s[-6000:])
 return s,record(log)
def main():
 mode=sys.argv[1] if len(sys.argv)>1 else 'diagnostic'
 if mode not in ('diagnostic','smoke','arbiter','monitor'):raise SystemExit('invalid mode')
 src=sorted((ROOT/'rtl/m5b0r_ddr_admission').glob('*.sv'))+sorted(TB.glob('*.sv'))
 bindings=src+[TB/'run.do',Path(__file__)]
 before=[record(p) for p in bindings]
 if not(TB/'work').exists():run([MS/'vlib.exe','work'],'vlib')
 run([MS/'vlog.exe','-sv','-work','work',*src],'compile')
 cases=[]
 if mode in ('diagnostic','smoke'):
  jobs=[(0,24,50708)]
  if mode=='diagnostic':jobs += [(f,24,50708+f) for f in range(1,28) if f!=2]+[(2,b,50800+b) for b in range(4,29)]+[(0,24,60401),(0,24,7919)]
  for fault,bit,seed in jobs:
   name=f'diagnostic_f{fault}_b{bit}_s{seed}'
   s,log=run([MS/'vsim.exe','-c','-novopt','-onfinish','exit','work.tb_m5b0r_diagnostic',f'+FAULT={fault}',f'+BIT={bit}',f'+SEED={seed}','-do',TB/'run.do'],name)
   marker=next((x for x in s.splitlines() if 'M5B0R_DIAGNOSTIC_PASS' in x),None)
   assert marker,(name,s[-2000:])
   cases.append(dict(name=name,summary=marker,log=log));print(marker,flush=True)
 elif mode=='monitor':
  s,log=run([MS/'vsim.exe','-c','-novopt','-onfinish','exit','work.tb_m5b0r_monitor','-do',TB/'run.do'],'monitor')
  marker=next((x for x in s.splitlines() if 'M5B0R_MONITOR_PASS' in x),None)
  assert marker,s[-4000:];cases.append(dict(name='monitor',summary=marker,log=log));print(marker,flush=True)
 else:
  for seed in (50708,60401,7919,1009,20261008):
   name=f'arbiter_s{seed}'
   s,log=run([MS/'vsim.exe','-c','-novopt','-onfinish','exit','work.tb_m5b0r_arbiter',f'+SEED={seed}','-do',TB/'run.do'],name)
   marker=next((x for x in s.splitlines() if 'M5B0R_ARBITER_PASS' in x),None)
   assert marker,(name,s[-4000:]);cases.append(dict(name=name,summary=marker,log=log));print(marker,flush=True)
 assert before==[record(p) for p in bindings]
 (OUT/(mode+'_results.json')).write_text(json.dumps(dict(status='PASS_HDL_MODEL_ONLY',sources=before,cases=cases),indent=2))
if __name__=='__main__':main()
