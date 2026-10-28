from common import *
W=R/json.loads((O/'ACTIVE_PHYSICAL.json').read_text())['path'];final=W/'FINAL_RESULT.json'
binding=json.loads((W/'EXACT_CDC_BINDING.json').read_text());assert rec(P/'Ti60_Demo_I3.sdc')==binding['sdc']
watch(W,'shape_replay_physical_retry',final)
sources=[rec(p) for d in (T,P) for p in sorted(d.rglob('*')) if p.is_file() and not any(x.startswith(('work_','outflow')) for x in p.relative_to(d).parts)]
save(W/'PRODUCTION_INPUTS.json',sources)
prefix='call E:\\Efinity\\2025.1\\bin\\setup.bat && '
pnr='E:\\Efinity\\2025.1\\python311\\bin\\python.exe -B E:\\Efinity\\2025.1\\scripts\\efx_run_pnr.py Ti60_Demo --prj --family Titanium --device Ti60F225 --timing_model I3 '
try:
 for stage,opt,marker in [('place','pack place','Post-placement primitive-level checks is successful'),('route','route','Ending stage final timing analysis')]:
  execute(W/stage,stage,['cmd.exe','/d','/c',prefix+pnr+'--work_dir work_pnr --output_dir outflow --opt '+opt+' timing_analysis=on seed=1 max_threads=32 sdc_file=Ti60_Demo_I3.sdc'],marker,cwd=P)
  txt=(W/stage/(stage+'.log')).read_text(errors='replace');assert 'REPLAY_EXACT_MISSING' not in txt
  first=(P/'Ti60_Demo_I3.sdc').read_text().splitlines().index('# REPLAY_EXACT_CDC_INSERT')+1
  warnings=[l for l in txt.splitlines() if 'WARNING' in l and (m:=re.search(r'\[SDC .*?:(\d+)\]',l)) and int(m[1])>=first];assert not warnings,warnings
 rpt=P/'outflow/Ti60_Demo.route.rpt';txt=rpt.read_text();resource={k:int(re.search(v,txt)[1]) for k,v in dict(XLR=r'XLRs:\s*(\d+)',RAM=r'Memory Blocks:\s*(\d+)',DSP=r'DSP Blocks:\s*(\d+)').items()};assert resource['XLR']<=51680 and resource['RAM']<=204
 body='set_timing_model I3\nif {[get_timing_model] ne "I3"} {error WRONG_TIMING_MODEL}\n'
 for g in binding['groups']:
  for pin in g['pins']:body+='set one [get_pins -regexp {'+'^'+re.escape(pin)+'$'+'}]\nif {[llength $one]!=1} {error REPLAY_NATIVE_EXACT_PIN_MISSING}\n'
 for mode in ('setup','hold'):body+=f'report_timing -{mode} -npaths 200 -nworst 1 -detail full_path -file replay_normal_{mode}.rpt\n'
 body+='check_timing -verbose -file replay_check.rpt\nreport_clocks -file replay_clocks.rpt\nputs {REPLAY_BASIC_STA_COMPLETE}\n';put(W/'basic_sta.tcl',body)
 execute(W/'sta','sta',['cmd.exe','/d','/c',prefix+'E:\\Efinity\\2025.1\\bin\\efx_sta.exe --prj Ti60_Demo --output_dir outflow --tclsh '+(W/'basic_sta.tcl').as_posix()],'REPLAY_BASIC_STA_COMPLETE',cwd=P)
 normal={m:[float(v) for v in re.findall(r'^Slack\s*:\s*([-\d.]+)',(P/f'outflow/replay_normal_{m}.rpt').read_text(),re.M)] for m in ('setup','hold')};assert all(v and min(v)>=0 for v in normal.values()),normal
 counts={k:int(v) for k,v in re.findall(r'checking (\w+) \((\d+)\)',(P/'outflow/replay_check.rpt').read_text())};assert all(counts.get(k)==0 for k in ('no_clock','unconstrained_internal_endpoints','multiple_clock')),counts
 save(W/'STA_RESULT.json',dict(passed=True,resource=resource,minimum={k:min(v) for k,v in normal.items()},counts=counts,report=rec(rpt)))
 db=[rec(p) for p in sorted((P/'work_pnr').rglob('*')) if p.is_file()];save(W/'BIT_INPUTS.json',db)
 execute(W/'bitgen','bitgen',['cmd.exe','/d','/c',prefix+'call E:\\Efinity\\2025.1\\bin\\efx_run.bat Ti60_Demo.xml --flow pgm'],None,cwd=P)
 assert re.search(r'\bpgm\s*:\s*PASS\b',(W/'bitgen/bitgen.log').read_text(errors='replace'))
 verify(db);bit=P/'outflow/Ti60_Demo.bit';dst=O/'artifacts/StarEye_Shape_Replay.bit';dst.parent.mkdir(exist_ok=True);dst.write_bytes(bit.read_bytes())
 verify(json.loads((O/'PROTECTED_PARENTS.json').read_text()))
 save(final,dict(passed=True,status='PASS_PHYSICAL',running=False,sta=json.loads((W/'STA_RESULT.json').read_text()),bit=rec(dst),native_bit=rec(bit),hardware=False));time.sleep(12)
except Exception as e:
 save(final,dict(passed=False,status='FAIL_PHYSICAL',running=False,error=str(e)));time.sleep(12);raise
print('PHYSICAL_PASS',flush=True)
