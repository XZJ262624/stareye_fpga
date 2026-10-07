"""Actual fail-closed evidence CLI tests; corrupted bundles never replace production."""
from pathlib import Path
import copy,hashlib,json,re,subprocess,sys
from m5a_streaming_canny_validate import collect,R,ROOT
O=R/'negative_evidence';O.mkdir(exist_ok=True);base=collect();cases=[]
def add(name,fn):
 b=copy.deepcopy(base);fn(b);cases.append((name,b))
add('sim_status',lambda b:b['sim'].update(status='FAIL'))
add('simulation_never_ran',lambda b:b['sim'].update(commands=[]))
add('missing_sim_log',lambda b:b['sim']['commands'][0]['log'].update(path='reports/m5a_streaming_canny_i3/absent.log'))
add('simulation_exit_error',lambda b:b['sim']['commands'][1].update(exit_code=1))
add('short_720p',lambda b:next(x for x in b['sim']['cases'] if x['name']=='720p').update(pixels=921600))
add('legacy_not_compared',lambda b:next(x for x in b['sim']['cases'] if x['name']=='720p').update(legacy_regression=[0]*4))
add('wrong_latency',lambda b:next(x for x in b['sim']['cases'] if x['name']=='720p').update(latency=6625))
add('no_stall_testing',lambda b:next(x for x in b['sim']['cases'] if x['name']=='stall').update(stalls=0))
add('direction_not_exhaustive',lambda b:next(x for x in b['sim']['cases'] if x['name']=='tb_m5a_units').update(summary='PASS'))
add('changed_sim_source',lambda b:b['sim']['sources_after'][0].update(sha256='0'*64))
add('build_failed',lambda b:b['build'].update(exit_code=1))
add('missing_build_input',lambda b:b['after'].pop())
add('changed_build_source',lambda b:b['after'][0].update(sha256='0'*64))
add('stale_bitstream',lambda b:next(x for x in b['build']['outputs'] if x['path'].endswith('/Ti60_Demo.bit')).update(sha256='0'*64))
add('sta_failed',lambda b:b['audit'].update(exit_code=1))
add('sta_missing',lambda b:b['audit']['reports'].pop())
add('sta_changed_implementation',lambda b:b['audit'].update(original_unchanged=False))
add('sta_wrong_database',lambda b:b['audit']['clone_initial_hashes'].update({'work_pnr/Ti60_Demo.lbf':'0'*64}))
add('sta_wrong_sdc',lambda b:b['audit'].update(sdc_sha256='0'*64))
add('sta_wrong_tcl',lambda b:b['audit'].update(tcl_sha256='0'*64))
add('sta_report_hash_mismatch',lambda b:b['audit']['reports'][0].update(sha256='0'*64))
def rec(p):return dict(path=p.relative_to(ROOT).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
results=[]
for name,b in [('positive',base)]+cases:
 p=O/(name+'.json');p.write_text(json.dumps(b));cmd=[sys.executable,'-B',str(ROOT/'scripts/m5a_streaming_canny_validate.py'),'--bundle',str(p)]
 x=subprocess.run(cmd,capture_output=True,text=True);expected=0 if name=='positive' else 1
 assert x.returncode==expected and ('M5A_ACCEPTANCE_PASS' if expected==0 else 'M5A_ACCEPTANCE_FAIL') in x.stdout,(name,x.stdout,x.stderr)
 results.append(dict(name=name,exit_code=x.returncode,expected_exit=expected,diagnostic=x.stdout.strip(),command=cmd,bundle=rec(p)));print('M5A_EVIDENCE_TEST',name,x.returncode,flush=True)
source=(R/'m5a_streaming_canny_i3/final_audit/m5a_setup.rpt').read_text()
for name,text in [('negative_sta_slack',re.sub(r'(^Slack\s*:\s*)\S+',r'\g<1>-0.001',source,count=1,flags=re.M)),('wrong_sta_model',source.replace('Timing Model: I3','Timing Model: C4')),('empty_sta','')]:
 p=O/(name+'.txt');p.write_text(text);cmd=[sys.executable,'-B','-c',"import pathlib,sys;from m3_sobel_core_validate import parse_timing;parse_timing(pathlib.Path(sys.argv[1]).read_text(),'setup')",str(p)]
 x=subprocess.run(cmd,cwd=ROOT/'scripts',capture_output=True,text=True);assert x.returncode!=0
 results.append(dict(name=name,exit_code=x.returncode,expected_exit=1,command=cmd,diagnostic=x.stderr.strip().splitlines()[-1],artifact=rec(p)))
(R/'EVIDENCE_NEGATIVE_RESULTS.json').write_text(json.dumps(dict(status='PASS',negative_count=len(results)-1,cases=results,sources=[rec(Path(__file__)),rec(ROOT/'scripts/m5a_streaming_canny_validate.py'),rec(ROOT/'scripts/m3_sobel_core_validate.py')]),indent=2));print('M5A_EVIDENCE_NEGATIVES_PASS',len(results)-1)
