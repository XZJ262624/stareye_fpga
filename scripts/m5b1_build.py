"""Build the isolated M5B1 with official Efinity; bind inputs and all outputs."""
from pathlib import Path
import subprocess,hashlib,json,datetime,time,re
R=Path(__file__).resolve().parents[1];W=R/'efinity/m5b1_global_canny_i3'
O=R/'reports/m5b1_global_canny_i3'/('build_'+datetime.datetime.now().strftime('%Y%m%d_%H%M%S'))
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def inputs():
 return [rec(p) for root in (W,R/'rtl/m5b1_global_canny') for p in sorted(root.rglob('*')) if p.is_file() and p.name!='.lock' and not set(p.relative_to(root).parts)&{'work','work_syn','work_pnr','work_pt','outflow','ipm','cache'}]
O.mkdir(parents=True);before=inputs();(O/'inputs_before.json').write_text(json.dumps(before,indent=2))
cmd=['cmd','/c',str(R/'scripts/m5b1_compile.bat')]
gate=None;started=time.time()
with (O/'compile.log').open('wb') as f:
 x=subprocess.Popen(cmd,cwd=R,stdout=f,stderr=subprocess.STDOUT)
 while x.poll() is None:
  report=W/'outflow/Ti60_Demo.place.rpt'
  if report.exists() and report.stat().st_mtime>=started:
   text=report.read_text(errors='replace');match=re.search(r'XLRs: (\d+) /',text)
   if match and int(match[1])>48640:
    gate=dict(reason='XLR_RESOURCE_GATE',XLR=int(match[1]),limit=48640,owned_process=x.pid)
    subprocess.run(['taskkill','/PID',str(x.pid),'/T','/F'],capture_output=True)
    x.wait();break
  time.sleep(2)

after=inputs();(O/'inputs_after.json').write_text(json.dumps(after,indent=2))
outputs=[rec(p) for d in ('outflow','work_pnr') for p in sorted((W/d).rglob('*')) if p.is_file()]
(O/'result.json').write_text(json.dumps(dict(command=cmd,exit_code=x.returncode,resource_stop=gate,outputs=outputs),indent=2))
print('M5B1_BUILD',O,'exit',x.returncode,flush=True)
raise SystemExit(x.returncode)
