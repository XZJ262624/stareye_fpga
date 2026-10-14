from pathlib import Path
import argparse,json,hashlib,re,subprocess,time,sys,shutil
F=Path(__file__).resolve().parent;O=F.parent;M=O.parent;R=M.parents[2];N=Path('E:/Modelsim_10.1c/win64')
a=argparse.ArgumentParser();a.add_argument('--kind',choices=['normal','nonzero','aba','mixed','faults','starvation','cold'],required=True);a.add_argument('--seed',type=int,required=True);a.add_argument('--healthy',type=int,required=True);a.add_argument('--scenario',type=int,default=0);a.add_argument('--label',required=True);a.add_argument('--compile-only',action='store_true');a.add_argument('--mutant',action='store_true');args=a.parse_args();assert args.kind=='aba' and args.seed==71 and args.scenario==5 and args.healthy==3 and not args.mutant and not args.compile_only
assert (args.kind!='faults' or args.scenario in [1,2,6,8]) and (args.kind!='cold' or args.scenario==4) and (args.kind!='starvation' or args.scenario==7)
assert not args.mutant or args.kind=='aba'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
identity=R/'reports/m5c1b_fusion_integration/final_source_selection_20261013_063600/SELECTED_SOURCE_IDENTITY.json';selected=json.loads(identity.read_text())['records']
def check_selected():assert all(rec(R/x['adopted']['path'])==x['adopted'] for x in selected)
check_selected();deriv=json.loads((O/'DERIVATION.json').read_text())
for x in deriv['common']:assert rec(R/x['derived']['path'])==x['derived']
case=next(x for x in deriv['cases'] if x['kind']==args.kind);assert rec(R/case['derived']['path'])==case['derived']
rtl=R/'rtl/m5c_fusion';sources=sorted(rtl.glob('*.sv'))+sorted((rtl/'m5a_copy').glob('*.v'))+[F/'tb_aba_two_fence_v3.sv']
model=M/'nonzero_reject/selected_nonzero_ddr_model.sv' if args.kind=='nonzero' else M/'remaining_cases_v1/selected_fault_ddr_model_v9.sv' if args.kind in ['faults','cold','starvation'] else R/'tb/m5c_fusion/m5c1b_ddr_service_model.sv'
sources += [model,R/'efinity/m5c_fusion_i3/src/lcd_driver.v',R/'reports/m5c1b_fusion_integration/osd_reference/m5a_osd_baseline_reference.v']
if args.mutant:
 witness=O/'ABA_POSITIVE_GENUINE_EVENT.json';assert witness.exists(),'Actual new A1/A3 evidence must be approved before mutant'
 sources=[M/'aba_current_v8/mutant_generation_gate.sv' if p.name=='m5c_display_session.sv' else p for p in sources]
gold=R/'reports/m5c1b_fusion_integration/golden_v2';goldB=R/'reports/m5c1b_fusion_integration/fault_inputs_v5/pixels_high80.hex'
extra=[R/x['parent']['path'] for x in deriv['cases'] if x['kind']==args.kind]+[R/x['parent']['path'] for x in deriv['common']]
parents={'normal':M/'SYSTEM_DERIVATION.json','nonzero':M/'nonzero_reject/DERIVATION.json','aba':M/'aba_current_v8/DERIVATION.json','mixed':M/'mixed_type1_v1/DERIVATION_V2.json','faults':M/'remaining_cases_v1/DERIVATION.json','cold':M/'remaining_cases_v1/DERIVATION.json','starvation':M/'queued_starvation_v10/DERIVATION_V11.json'}
deps=sources+extra+[parents[args.kind],identity,Path(__file__),O/'DERIVATION.json',R/deriv['generator']['path'],M/'REPLAY_DERIVATION_PLAN_1009.json',M.parent/'REPLAY_END_V2_EXECUTION_FREEZE.md',R/'efinity/m5c_fusion_i3/src/lcd_para.v',gold/'pixels.hex',gold/'class.bin',gold/'mask.bin',M/'check_smoke_uart.py',M/'check_trace.py',O/'common/end_protocol.svh',O/'common/end_declarations.svh',O/'common/check_end_protocol.py']
if args.kind=='aba':deps += [goldB,M/'aba_current_v8/mutant_generation_gate.sv']
if args.kind=='nonzero':deps += [M/'nonzero_reject/check_nonzero_wire.py',M.parent/'NONZERO_REJECT_EXECUTION_FREEZE.md']
if args.kind=='mixed':deps += [M/'mixed_type1_v1/check_type1_wire.py',M/'mixed_type1_v1/TYPE1_FIELD_CONTRACT_V2.json',M.parent/'TYPE1_INDEPENDENT_ORACLE_FREEZE.md']
admission=F/'LONG_ADMISSION.json';ad=json.loads(admission.read_text());assert ad['status']=='PASS_GUARD_PREFLIGHT_ADMIT_V3_POSITIVE_ONLY'
for x in ad['records']:assert rec(R/x['path'])==x
for x in json.loads((O/'aba_two_fence_1821/MANIFEST.json').read_text())['records']:assert rec(R/x['path'])==x
for x in json.loads((F/'DERIVATION.json').read_text())['derived']:assert rec(R/x['path'])==x
deps += [admission]+[R/x['path'] for x in ad['records']]
deps=list(dict.fromkeys(deps));inputs=[rec(p) for p in deps]
W=O/'runs'/(args.label+'_'+time.strftime('%H%M%S'));W.mkdir(parents=True);(W/'INPUTS.json').write_text(json.dumps(inputs,indent=2));snaps=[]
for i,p in enumerate(deps):
 q=W/'source_snapshot'/(str(i).zfill(3)+'_'+p.name);q.parent.mkdir(exist_ok=True);shutil.copyfile(p,q);snaps.append(dict(input=rec(p),actual_compiled_path=str(p) if p in sources else None,snapshot=rec(q)))
(W/'SNAPSHOTS.json').write_text(json.dumps(snaps,indent=2))
params=[f'-gHEALTHY_FRAMES={args.healthy}','-gBG_REQUEST_CYCLES=96000000','-gSERVICE_CYCLES=384','-gCAMERA_BLANK_CYCLES=478667','-gFUS_ENABLE=1',f'-gSCENARIO={args.scenario}',f'+SEED={args.seed}','+GOLD='+str(gold/'pixels.hex')]
if args.kind=='aba':params+=['+GOLD_B='+str(goldB)]
budget=43200 if args.kind=='aba' else 21600
(W/'PARAMETERS.json').write_text(json.dumps(dict(arguments=vars(args),native=params,cam_phase_ns=.1+(args.seed%97)/10,pix_phase_ns=.2+(args.seed%79)/10,sim_watchdog_ns=8000000000 if args.kind=='aba' else 4000000000,wall_timeout=budget,uart_clock_hz=960000,baud=460800),indent=2))
commands=[('vlib',[N/'vlib.exe','work']),('compile',[N/'vlog.exe','-sv','-work','work','+incdir+'+str(rtl),'+incdir+'+str(O/'common'),'+incdir+'+str(R/'efinity/m5c_fusion_i3/src'),*sources])]
if not args.compile_only:commands+=[('sim',[N/'vsim.exe','-c','-novopt','-onfinish','stop','work.tb_aba_two_fence_v3',*params,'-do','onbreak {quit -code 1}; onerror {quit -code 2}; run -all; quit -code 0'])]
steps=[];ok=True;expected_negative=False
for stage,cmd in commands:
 cmd=list(map(str,cmd));t=time.time();timed=False;log=W/(stage+'.log')
 with log.open('wb') as f:
  p=subprocess.Popen(cmd,cwd=W,stdout=f,stderr=subprocess.STDOUT);owner=dict(pid=p.pid,command=cmd,cwd=str(W),started_unix=t);(W/(stage+'_OWNER.json')).write_text(json.dumps(owner,indent=2));print('OWNED',args.label,stage,p.pid,W,flush=True)
  try:code=p.wait(timeout=budget if stage=='sim' else 180)
  except subprocess.TimeoutExpired:
   timed=True
   if p.poll() is None:subprocess.run(['taskkill','/PID',str(p.pid),'/T','/F'],stdout=f,stderr=subprocess.STDOUT)
   code=p.wait(timeout=30)
 txt=log.read_text(errors='replace');steps.append(dict(stage=stage,exit=code,timed_out=timed,seconds=time.time()-t,owner=owner,log=rec(log)))
 if stage=='sim' and args.mutant:
  fs=re.findall(r'\*\* Fatal: ([^\r\n]+)',txt);expected_negative=not timed and len(fs)==1 and fs[0].startswith('SYSTEM_UI_SIGNATURE_REJECT_ACQUIRE');ok=expected_negative
 else:ok=not timed and code==0 and not re.search(r'\*\* (Error|Fatal):',txt) and (stage!='sim' or 'M5C1B_PASS ' in txt)
 if not ok:break
unchanged=inputs==[rec(p) for p in deps];check_selected();result=dict(status=('PASS_COMPILE_ONLY_NOT_SIMULATED' if args.compile_only else 'PASS_EXPECTED_ABA_WRONGFUL_ACQUIRE_FATAL' if expected_negative else 'PASS_COLD_TERMINAL_ONLY_UART_ABORT_SCOPED' if args.kind=='cold' else 'PASS_SIM_PENDING_INDEPENDENT_SOFTWARE') if ok and unchanged else 'FAIL',source_unchanged=unchanged,steps=steps,args=params,selected_checked=101)
(W/'RESULT.json').write_text(json.dumps(result,indent=2));print('DONE',result['status'],W,flush=True);sys.exit(0 if ok and unchanged else 1)
