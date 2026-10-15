from pathlib import Path
import sys,json,subprocess,hashlib,time,datetime,shutil
sys.dont_write_bytecode=True
R=Path(__file__).resolve().parents[1];sys.path.insert(0,str(R/'scripts'));from m5c_diag_oracle import check
out=R/'reports/m5c_diagnostics'/('stage2_invalid_'+datetime.datetime.now().strftime('%Y%m%d_%H%M%S'));out.mkdir(parents=True)
rtl=R/'rtl/m5c_diagnostics/m5c_diag_observer_v2.sv';tb=R/'tb/m5c_diagnostics/tb_diag_observer_v2_invalid.sv';osd=R/'rtl/m5c_fusion/m5a_copy/m5a_osd.v';native=Path('E:/Modelsim_10.1c/win64')
def rec(p):
 b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
inputs=[rec(p) for p in [rtl,tb,osd,Path(__file__),R/'scripts/m5c_diag_oracle.py']];(out/'INPUTS.json').write_text(json.dumps(inputs,indent=2))
(out/'input_snapshot').mkdir()
for x in inputs:shutil.copyfile(x['path'],out/'input_snapshot'/Path(x['path']).name)
def run(case,source,label,expected=None,fatal=None):
 p=out/label;p.mkdir();steps=[]
 cmds=[[str(native/'vlib.exe'),'work'],[str(native/'vlog.exe'),'-sv','-work','work',str(source),str(osd),str(tb)],[str(native/'vsim.exe'),'-c','-novopt','-lib','work','tb_diag_observer_v2_invalid',f'-gCASE={case}',f'+OUT={p.as_posix()}','-l','sim.log','-do','run -all; quit -code 0']]
 if expected:cmds[-1]+=[f'+EXPECT={expected.as_posix()}',f'+FATAL_NAME={fatal}']
 for i,cmd in enumerate(cmds):
  start=time.time();proc=subprocess.Popen(cmd,cwd=p,stdout=subprocess.PIPE,stderr=subprocess.STDOUT);(p/f'OWNER_{i}.json').write_text(json.dumps(dict(pid=proc.pid,command=cmd,cwd=str(p),started=start),indent=2));timeout=False
  try:log=proc.communicate(timeout=120)[0]
  except subprocess.TimeoutExpired:
   timeout=True;subprocess.run(['taskkill','/PID',str(proc.pid),'/T','/F'],capture_output=True);log=proc.communicate()[0]
  (p/f'step{i}.log').write_bytes(log);steps.append(dict(command=cmd,exit=proc.returncode,timeout=timeout,seconds=time.time()-start,log=rec(p/f'step{i}.log')))
  if timeout or proc.returncode!=0 or (i==1 and b'** Error:' in log):break
 result=dict(case=case,label=label,inputs=[rec(source),rec(tb),rec(osd)],steps=steps,status='NOT_PASS')
 try:
  assert len(steps)==3 and all(x['exit']==0 and not x['timeout'] for x in steps),'NATIVE_STAGE_FAILURE'
  text=(p/'sim.log').read_text(errors='replace')
  if fatal:
   assert text.count('** Fatal:')==1 and ('** Fatal: '+fatal) in text,'EXPECTED_NAMED_FATAL_MISSING_OR_OTHER_FATAL'
   result['status']='PASS_EXPECTED_NAMED_FATAL';result['raw_native_exit']=steps[-1]['exit']
  else:
   assert f'DIAG_SIM_DONE case={case}' in text and '** Fatal:' not in text,'POSITIVE_SIM_FAILURE'
   result['oracle']=check(p,case);result['status']='PASS_POSITIVE'
 except Exception as e:result['error']=str(e)
 (p/'RESULT.json').write_text(json.dumps(result,indent=2));print(label,result['status'],result.get('error',''),flush=True);return p,result

p,result=run(8,rtl,"positive_invalid")
assert inputs==[rec(Path(x["path"])) for x in inputs]
(out/"SUMMARY.json").write_text(json.dumps(dict(results=[result],all_pass=result["status"]=="PASS_POSITIVE",inputs_unchanged=True),indent=2))
print("OUTPUT",out,flush=True)
