from pathlib import Path
import json,hashlib,time,subprocess,shutil,re,sys,argparse
O=Path(__file__).resolve().parent;R=O.parents[3];a=argparse.ArgumentParser();a.add_argument('--mutant',action='store_true');a.add_argument('--label',required=True);a.add_argument('--healthy',type=int,required=True);a.add_argument('--seed',type=int,required=True);a.add_argument('--fus',type=int,default=1);a.add_argument('--service',type=int,default=384);a.add_argument('--scenario',type=int,default=0);args=a.parse_args();W=O/(args.label+'_'+time.strftime('%H%M%S'));W.mkdir();M=Path('E:/Modelsim_10.1c/win64');rtl=R/'rtl/m5c_fusion';sources=sorted(rtl.glob('*.sv'))+sorted((rtl/'m5a_copy').glob('*.v'))+[O/'tb_selected_nonzero.sv',O/'selected_nonzero_ddr_model.sv',R/'efinity/m5c_fusion_i3/src/lcd_driver.v',R/'reports/m5c1b_fusion_integration/osd_reference/m5a_osd_baseline_reference.v'];sources=[O/'mutant_suppress_rejected.sv' if args.mutant and p.name=='m5c_fusion_display.sv' else p for p in sources];gold=R/'reports/m5c1b_fusion_integration/golden_v2/pixels.hex';deps=sources+[R/'efinity/m5c_fusion_i3/src/lcd_para.v',gold,O/'DERIVATION.json',O.parent/'check_smoke_uart.py',O.parent/'check_trace.py',O/'check_nonzero_wire.py',R/'reports/m5c1b_fusion_integration/golden_v2/class.bin',R/'reports/m5c1b_fusion_integration/golden_v2/mask.bin',O.parent.parent/'NONZERO_REJECT_EXECUTION_FREEZE.md',R/'reports/m5c1b_fusion_integration/final_source_selection_20261013_063600/SELECTED_SOURCE_IDENTITY.json',Path(__file__)]
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
identity=json.loads(deps[-2].read_text());assert all(rec(R/x['adopted']['path'])==x['adopted'] for x in identity['records']);inputs=[rec(p) for p in deps];(W/'INPUTS.json').write_text(json.dumps(inputs,indent=2))
snapshots=[]
for index,p in enumerate(deps):
 q=W/'source_snapshot'/(str(index).zfill(3)+'_'+p.name);q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,q);snapshots.append(dict(input=rec(p),actual_compiled_path=str(p) if p in sources else None,snapshot=rec(q)))
(W/'SNAPSHOTS.json').write_text(json.dumps(snapshots,indent=2))
params=[f'-gHEALTHY_FRAMES={args.healthy}','-gBG_REQUEST_CYCLES=96000000',f'-gSERVICE_CYCLES={args.service}','-gCAMERA_BLANK_CYCLES=478667',f'-gFUS_ENABLE={args.fus}',f'-gSCENARIO={args.scenario}',f'+SEED={args.seed}','+GOLD='+str(gold)];(W/'PARAMETERS.json').write_text(json.dumps(dict(arguments=vars(args),native=params,cam_phase_ns=.1+(args.seed%97)/10,pix_phase_ns=.2+(args.seed%79)/10,sim_watchdog_ns=4000000000,wall_timeout=21600),indent=2));steps=[];success=True
for name,cmd in [('vlib',[M/'vlib.exe','work']),('compile',[M/'vlog.exe','-sv','-work','work','+incdir+'+str(rtl),'+incdir+'+str(R/'efinity/m5c_fusion_i3/src'),*sources]),('sim',[M/'vsim.exe','-c','-novopt','-onfinish','stop','work.tb_selected_nonzero',*params,'-do','onbreak {quit -code 1}; onerror {quit -code 2}; run -all; quit -code 0'])]:
 cmd=list(map(str,cmd));start=time.time();log=W/(name+'.log');timed=False
 with log.open('wb') as f:
  p=subprocess.Popen(cmd,cwd=W,stdout=f,stderr=subprocess.STDOUT);owner=dict(pid=p.pid,command=cmd,cwd=str(W),started_unix=start);(W/(name+'_OWNER.json')).write_text(json.dumps(owner,indent=2));print('OWNED',name,p.pid,W,flush=True)
  try:code=p.wait(timeout=21600)
  except subprocess.TimeoutExpired:
   timed=True
   if p.poll() is None:subprocess.run(['taskkill','/PID',str(p.pid),'/T','/F'],stdout=f,stderr=subprocess.STDOUT)
   code=p.wait(timeout=30)
 txt=log.read_text(errors='replace');steps.append(dict(stage=name,exit=code,timed_out=timed,seconds=time.time()-start,owner=owner,log=rec(log)))
 if code!=0 or re.search(r'\*\* (Error|Fatal):',txt) or (name=='sim' and 'M5C1B_PASS SELECTED_NONZERO' not in txt):success=False;break
unchanged=inputs==[rec(p) for p in deps];expected_negative=args.mutant and steps[-1]['stage']=='sim' and not steps[-1]['timed_out'] and len(re.findall(r'\*\* Fatal:',txt))==1 and re.search(r'\*\* Fatal: NONZERO_REJECT_COUNTER_MISMATCH(?:\s|$)',txt) is not None and all(x['exit']==0 for x in steps[:-1]);success=success or expected_negative;result=dict(status=('PASS_EXPECTED_NONZERO_COUNTER_FATAL' if expected_negative else 'PASS_SIM_PENDING_SOFTWARE_UART') if success and unchanged else 'FAIL',inputs=inputs,source_unchanged=unchanged,steps=steps,args=params);(W/'RESULT.json').write_text(json.dumps(result,indent=2));print('DONE',result['status'],W,flush=True);sys.exit(0 if success and unchanged else 1)
