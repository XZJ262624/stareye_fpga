from common import *
W=R/json.loads((O/'ACTIVE_PHYSICAL.json').read_text())['path']
assert json.loads((O/'ROUTE_RESULT.json').read_text())['passed']
binding=json.loads((O/'EXACT_CDC_BINDING.json').read_text());assert rec(P/'Ti60_Demo_I3.sdc')==binding['sdc']
body='set_timing_model I3\nif {[get_timing_model] ne "I3"} {error WRONG_TIMING_MODEL}\nputs "ACTUAL_TIMING_MODEL [get_timing_model]"\n'
for g in binding['groups']:
 for pin in sorted(set(g['after'])):body+='set one [get_pins -regexp {'+'^'+re.escape(pin)+'$'+'}]\nif {[llength $one]!=1} {error CANNY_NATIVE_EXACT_PIN_MISSING}\n'
for mode in ('setup','hold'):body+=f'report_timing -{mode} -npaths 200 -nworst 1 -detail full_path -file canny_normal_{mode}.rpt\n'
body+='check_timing -verbose -file canny_check.rpt\nreport_clocks -file canny_clocks.rpt\nputs {CANNY_BASIC_STA_COMPLETE}\n'
q=W/'basic_sta.tcl';q.write_text(body)
prefix='call E:\\Efinity\\2025.1\\bin\\setup.bat && '
execute(W/'sta','native',['cmd.exe','/d','/c',prefix+'E:\\Efinity\\2025.1\\bin\\efx_sta.exe --prj Ti60_Demo --output_dir outflow --tclsh '+q.as_posix()],'CANNY_BASIC_STA_COMPLETE',3600,cwd=P)
normal={mode:[float(v) for v in re.findall(r'^Slack\s*:\s*([-\d.]+)',(P/f'outflow/canny_normal_{mode}.rpt').read_text(),re.M)] for mode in ('setup','hold')}
assert all(v and min(v)>=0 for v in normal.values()),normal
counts={k:int(v) for k,v in re.findall(r'checking (\w+) \((\d+)\)',(P/'outflow/canny_check.rpt').read_text())}
assert all(counts.get(k)==0 for k in ('no_clock','unconstrained_internal_endpoints','multiple_clock')),counts
sta=dict(passed=True,status='PASS_BASIC_NORMAL_I3_EXACT_CDC',normal={k:min(v) for k,v in normal.items()},counts=counts,reports=[rec(P/f'outflow/canny_normal_{m}.rpt') for m in ('setup','hold')]+[rec(P/'outflow/canny_check.rpt')],exact_binding=rec(O/'EXACT_CDC_BINDING.json'),limitations='Inherited PLL asynchronous SR untimed;7 external inputs135 outputs; narrow hold/PVT/warm reset not qualified. No exhaustive unchanged FF/metadata audit.')
save(O/'BASIC_STA_RESULT.json',sta);print('BASIC_STA_PASS',sta['normal'],flush=True)
db=[rec(p) for p in sorted((P/'work_pnr').rglob('*')) if p.is_file()];save(W/'BIT_INPUTS.json',dict(db=db,sdc=rec(P/'Ti60_Demo_I3.sdc'),sta=rec(O/'BASIC_STA_RESULT.json')))
execute(W/'bitgen','native',['cmd.exe','/d','/c',prefix+'call E:\\Efinity\\2025.1\\bin\\efx_run.bat Ti60_Demo.xml --flow pgm'],None,1800,cwd=P)
assert re.search(r'\bpgm\s*:\s*PASS\b',(W/'bitgen/native.log').read_text(errors='replace'))
verify(db);bit=P/'outflow/Ti60_Demo.bit';assert bit.stat().st_size>0
art=O/'artifacts';art.mkdir(exist_ok=True);dst=art/'StarEye_Canny_Gaussian_Standalone.bit';dst.write_bytes(bit.read_bytes())
save(O/'BUILD_RESULT.json',dict(passed=True,resource=json.loads((O/'ROUTE_RESOURCE.json').read_text())['resource'],sta=sta,bit=rec(dst),native_bit=rec(bit),physical=W.relative_to(R).as_posix(),hardware=False,git_mutation=False));print('BIT_READY',rec(dst),flush=True)
