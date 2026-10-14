from pathlib import Path
import hashlib,json,subprocess,time,re,sys,shutil
O=Path(__file__).resolve().parent;R=O.parents[2];M=Path('E:/Modelsim_10.1c/win64');B=O/'legacy_current';B.mkdir(exist_ok=False)
cases=[('tb_m5c1b_backend_startup','tb/m5c_fusion/tb_m5c1b_reset_faults.sv','M5C1B_PASS'),('tb_m5c1b_reset_faults','tb/m5c_fusion/tb_m5c1b_reset_faults.sv','M5C1B_PASS'),('tb_m5c1b_reader_fences','tb/m5c_fusion/tb_m5c1b_c2.sv','M5C1B_PASS'),('tb_m5b1_arbiter','tb/m5b1_global_canny/tb_m5b1_arbiter.sv','M5B1_ARBITER_PASS'),('tb_m5b1_capture','tb/m5b1_global_canny/tb_m5b1_capture.sv','M5B1_CAPTURE_PASS'),('tb_m5b1_prefill','tb/m5b1_global_canny/tb_m5b1_prefill.sv','M5B1_PREFILL_PASS'),('tb_m5b1_cdc','tb/m5b1_global_canny/tb_m5b1_cdc.sv','M5B1_CDC_PASS'),('tb_m5c1b_backend_default_wall','tb/m5c_fusion/tb_m5c1b_reset_faults.sv','M5C1B_PASS BACKEND_DEFAULT_WALL')]
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
identity=R/'reports/m5c1b_fusion_integration/final_source_selection_20261013_063600/SELECTED_SOURCE_IDENTITY.json'
assert all(rec(R/x['adopted']['path'])==x['adopted'] for x in json.loads(identity.read_text())['records'])
results=[]
for index,(top,tb,marker) in enumerate(cases):
 W=B/(str(index).zfill(2)+'_'+top);W.mkdir();rtl=R/'rtl/m5c_fusion';sources=sorted(rtl.glob('*.sv'))+sorted((rtl/'m5a_copy').glob('*.v'))+[R/tb];deps=sources+[Path(__file__),identity];inputs=[rec(p) for p in deps];(W/'INPUTS.json').write_text(json.dumps(inputs,indent=2));snaps=[]
 for i,p in enumerate(deps):
  q=W/'source_snapshot'/(str(i).zfill(3)+'_'+p.name);q.parent.mkdir(exist_ok=True);shutil.copyfile(p,q);snaps.append(dict(input=rec(p),actual_compiled_path=str(p) if p in sources else None,snapshot=rec(q)))
 (W/'SNAPSHOTS.json').write_text(json.dumps(snaps,indent=2));steps=[];passed=True
 commands=[('vlib',[M/'vlib.exe','work']),('compile',[M/'vlog.exe','-sv','-work','work','+incdir+'+str(rtl),*sources]),('sim',[M/'vsim.exe','-c','-novopt','-onfinish','stop','work.'+top,'-do','onbreak {quit -code 1}; onerror {quit -code 2}; run -all; quit -code 0'])]
 for stage,command in commands:
  command=list(map(str,command));start=time.time();timed=False;log=W/(stage+'.log')
  with log.open('wb') as f:
   p=subprocess.Popen(command,cwd=W,stdout=f,stderr=subprocess.STDOUT);owner=dict(pid=p.pid,command=command,cwd=str(W),started_unix=start);(W/(stage+'_OWNER.json')).write_text(json.dumps(owner,indent=2));print('OWNED',top,stage,p.pid,str(W),flush=True)
   try:code=p.wait(timeout=7200)
   except subprocess.TimeoutExpired:
    timed=True
    if p.poll() is None:subprocess.run(['taskkill','/PID',str(p.pid),'/T','/F'],stdout=f,stderr=subprocess.STDOUT)
    code=p.wait(timeout=30)
  text=log.read_text(errors='replace');steps.append(dict(stage=stage,exit=code,timeout=timed,seconds=time.time()-start,command=command,log=rec(log)));passed=not timed and code==0 and not re.search(r'\*\* (Error|Fatal):',text) and (stage!='sim' or marker in text)
  if not passed:break
 unchanged=inputs==[rec(p) for p in deps];v=dict(status='PASS_CURRENT_LEGACY' if passed and unchanged else 'FAIL_REQUIRES_DIAGNOSIS',top=top,source_unchanged=unchanged,steps=steps,boundary='Original finite test compiled against selected production source; no inherited PASS. Capture default-wall test retains actual 96000000 timer cycles and no accepted transactions; does not cover engine/export default timeouts.');(W/'RESULT.json').write_text(json.dumps(v,indent=2));results.append(dict(top=top,status=v['status'],result=rec(W/'RESULT.json')));(B/'PROGRESS.json').write_text(json.dumps(results,indent=2));print('DONE',top,v['status'],flush=True)
 if not passed or not unchanged:sys.exit(1)
(B/'RESULT.json').write_text(json.dumps(dict(status='PASS_SELECTED_EIGHT_LEGACY_GATES',runs=results),indent=2))
