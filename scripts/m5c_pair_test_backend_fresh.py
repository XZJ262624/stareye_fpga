from pathlib import Path
import argparse,datetime,hashlib,json,subprocess,time,shutil
R=Path(__file__).resolve().parents[1];F=R/'reports/m5c_pair_capture_20261016';TOOL=Path('E:/Modelsim_10.1c/win64')
a=argparse.ArgumentParser();a.add_argument('--case',type=int,default=0);a.add_argument('--old',action='store_true');a.add_argument('--mutant',action='store_true');a.add_argument('--fence',action='store_true');a.add_argument('--default',action='store_true');args=a.parse_args();assert not args.old and not args.mutant and not args.default
W=F/('backend_paironly_'+('default_' if args.default else 'mutant_' if args.mutant else 'fence_' if args.fence else 'old_' if args.old else 'fixed_')+str(args.case)+'_'+datetime.datetime.now().strftime('%H%M%S'));W.mkdir()
names=['m5b1_backend.sv','m5b1_capture.sv','m5b1_global_engine.sv','m5b1_transfer.sv','m5b1_uart.sv','m5b1_mailbox.sv','m5b1_async_fifo.sv','m5b1_arbiter.sv','m5c_pair_lease.sv'];sources=[R/'rtl/m5c_fusion'/n for n in names]
if args.old:sources[0]=F/'m5b1_backend_candidate99642712.sv'
if args.mutant:sources[0]=F/'mutant_uart_release_missing.sv'
sources[0]=R/'rtl/m5c_pair_diag/m5c_pair_backend.sv'
sources[names.index('m5c_pair_lease.sv')]=R/'rtl/m5c_pair_diag/m5c_pair_diag_lease.sv'
sources.append(R/'rtl/m5c_pair_diag/m5c_pair_controller.sv')
sources.append(R/'tb/m5c_pair_diag/tb_pair_backend_fresh.sv')
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
deps=sources+[Path(__file__),F/'pair_only_revision_v2/FRESH_TEST_DERIVATION.json'];inputs=[rec(p) for p in deps];snap=W/'source_snapshot';snap.mkdir()
for i,p in enumerate(deps):shutil.copyfile(p,snap/f'{i:03d}_{p.name}')
(W/'INPUTS.json').write_text(json.dumps(dict(records=inputs,snapshots=[rec(p) for p in snap.iterdir()]),indent=2));steps=[]
cmds=[('vlib',[str(TOOL/'vlib.exe'),'work'],120),('compile',[str(TOOL/'vlog.exe'),'-sv','-work','work']+[str(p) for p in sources],120),('sim',[str(TOOL/'vsim.exe'),'-c','-novopt','work.tb_pair_backend_fresh',f'-gCASE={args.case}',f'-gFENCE={int(args.fence)}',f'-gEXPORT_LIMIT={960000000 if args.default else 20000000 if args.case==3 else 2000}','-do','run -all; quit -f'],21600 if args.default else 3600)]
for stage,cmd,limit in cmds:
 start=time.time()
 with (W/(stage+'.log')).open('w') as log:
  p=subprocess.Popen(cmd,cwd=W,stdout=log,stderr=subprocess.STDOUT);owner=dict(pid=p.pid,stage=stage,command=cmd,cwd=str(W),started=datetime.datetime.now().astimezone().isoformat());(W/(stage+'_OWNER.json')).write_text(json.dumps(owner,indent=2));print('OWNED',stage,p.pid,str(W),flush=True)
  try:code=p.wait();timeout=False
  except subprocess.TimeoutExpired:subprocess.run(['taskkill','/PID',str(p.pid),'/T','/F'],capture_output=True);code=p.wait();timeout=True
 steps.append(dict(stage=stage,exit=code,timeout=timeout,seconds=time.time()-start,log=rec(W/(stage+'.log')),owner=owner));(W/'STEPS.json').write_text(json.dumps(steps,indent=2))
 if code or timeout:break
unchanged=all(rec(R/x['path'])==x for x in inputs);log=(W/'sim.log').read_text(errors='replace') if (W/'sim.log').exists() else '';fatal=[s for s in log.splitlines() if '** Fatal:' in s];passed=len(steps)==3 and all(x['exit']==0 and not x['timeout'] for x in steps) and unchanged
if args.mutant:passed=passed and len(fatal)==1 and 'UART_CLEANUP_LEASE_NOT_RECLAIMED' in fatal[0]
elif args.old:passed=passed and len(fatal)==1 and 'UART_LEASE_NOT_RECLAIMED' in fatal[0]
else:passed=passed and not fatal and 'PAIR_ONLY_BACKEND_PASS' in log
result=dict(status=('PASS_NAMED_SINGLE_RELEASE_MUTANT' if args.mutant else 'PASS_NAMED_ORIGINAL_LEAK_SENSITIVITY' if args.old else 'PASS_PAIR_ONLY_FRESH_RECOVERY') if passed else 'FAIL',case=args.case,old_candidate=args.old,source_unchanged=unchanged,steps=steps,fatals=fatal,inputs=inputs)
(W/'RESULT.json').write_text(json.dumps(result,indent=2));print(result['status'],str(W),flush=True);raise SystemExit(0 if passed else 1)
