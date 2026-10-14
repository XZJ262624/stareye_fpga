from pathlib import Path
import argparse,hashlib,json,re,subprocess,sys,time,shutil
O=Path(__file__).resolve().parent;R=O.parents[3];M=Path('E:/Modelsim_10.1c/win64')
a=argparse.ArgumentParser();a.add_argument('--compile-only',action='store_true');a.add_argument('--case');args=a.parse_args()
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
identity=R/'reports/m5c1b_fusion_integration/final_source_selection_20261013_063600/SELECTED_SOURCE_IDENTITY.json'
assert all(rec(R/x['adopted']['path'])==x['adopted'] for x in json.loads(identity.read_text())['records'])
cases=json.loads((O/'CASES.json').read_text());cases=[x for x in cases if args.case is None or x['name']==args.case];assert cases
B=O/(('compile_' if args.compile_only else 'run_')+time.strftime('%H%M%S'));B.mkdir();results=[]
for case in cases:
 W=B/case['name'];W.mkdir();rtl=R/'rtl/m5c_fusion';sources=sorted(rtl.glob('*.sv'))+sorted((rtl/'m5a_copy').glob('*.v'))+[R/case['tb']]
 if case['top']=='tb_m5c1b_capture_identity':sources += [p for d in ['rtl/m3_sobel_core','rtl/m32_median_integration','rtl/m4_color_overlay'] for p in sorted((R/d).glob('*.v'))]
 if case['override']:sources=[R/case['override'] if p.name==Path(case['override']).name else p for p in sources]
 deps=sources+[R/x for x in case['gold']]+[O/'CASES.json',O/'DERIVATION.json',Path(__file__),identity];inputs=[rec(p) for p in deps];(W/'INPUTS.json').write_text(json.dumps(inputs,indent=2));snaps=[]
 for i,p in enumerate(deps):
  q=W/'source_snapshot'/(str(i).zfill(3)+'_'+p.name);q.parent.mkdir(exist_ok=True);shutil.copyfile(p,q);snaps.append(dict(input=rec(p),actual_compiled_path=str(p) if p in sources else None,snapshot=rec(q)))
 (W/'SNAPSHOTS.json').write_text(json.dumps(snaps,indent=2));steps=[];passed=True
 commands=[('vlib',[M/'vlib.exe','work']),('compile',[M/'vlog.exe','-sv','-work','work','+incdir+'+str(rtl),*sources])]
 if not args.compile_only:commands.append(('sim',[M/'vsim.exe','-c','-novopt','-onfinish','stop','work.'+case['top'],*case['args'],'-do','onbreak {quit -code 1}; onerror {quit -code 2}; run -all; quit -code 0']))
 for stage,cmd in commands:
  cmd=list(map(str,cmd));start=time.time();log=W/(stage+'.log');timed=False
  with log.open('wb') as f:
   p=subprocess.Popen(cmd,cwd=W,stdout=f,stderr=subprocess.STDOUT);owner=dict(pid=p.pid,command=cmd,cwd=str(W),started_unix=start);(W/(stage+'_OWNER.json')).write_text(json.dumps(owner,indent=2));print('OWNED',case['name'],stage,p.pid,flush=True)
   try:code=p.wait(timeout=21600 if stage=='sim' else 180)
   except subprocess.TimeoutExpired:
    timed=True
    if p.poll() is None:subprocess.run(['taskkill','/PID',str(p.pid),'/T','/F'],stdout=f,stderr=subprocess.STDOUT)
    code=p.wait(timeout=30)
  txt=log.read_text(errors='replace');steps.append(dict(stage=stage,exit=code,timeout=timed,seconds=time.time()-start,owner=owner,log=rec(log)))
  if stage=='sim' and case['fatal']:
   fatals=re.findall(r'\*\* Fatal: ([^\r\n]+)',txt);passed=not timed and len(fatals)==1 and fatals[0].startswith(case['fatal']) and not re.search(r'\*\* Error:',txt)
  else:passed=not timed and code==0 and not re.search(r'\*\* (Error|Fatal):',txt) and (stage!='sim' or case['marker'] in txt)
  if not passed:break
 unchanged=inputs==[rec(p) for p in deps];status=('PASS_COMPILE_ONLY_NOT_SIMULATED' if args.compile_only else 'PASS_EXPECTED_NAMED_FATAL' if case['fatal'] else 'PASS_CURRENT_LEGACY') if passed and unchanged else 'FAIL_REQUIRES_DIAGNOSIS'
 result=dict(status=status,case=case,source_unchanged=unchanged,steps=steps,boundary='Named negative requires compile exit0 and unique expected fatal; raw simulator exit may be0. Positive compares current source against original independent algorithm/tap/transaction oracle. No prior PASS transferred.');(W/'RESULT.json').write_text(json.dumps(result,indent=2));results.append(dict(name=case['name'],status=status,result=rec(W/'RESULT.json')));(B/'PROGRESS.json').write_text(json.dumps(results,indent=2));print('DONE',case['name'],status,flush=True)
 if not passed or not unchanged:sys.exit(1)
(B/'RESULT.json').write_text(json.dumps(dict(status='PASS_COMPILE_ONLY_NOT_SIMULATED' if args.compile_only else 'PASS_SELECTED_REMAINING_LEGACY',runs=results),indent=2))
