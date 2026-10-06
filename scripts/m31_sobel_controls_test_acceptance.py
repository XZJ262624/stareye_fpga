"""Run real subprocess rejection tests on copied evidence, never production artifacts."""
from pathlib import Path
import copy,hashlib,json,subprocess,sys
from m31_sobel_controls_validate import collect,ROOT,R,W
folder=R/'negative_cases';folder.mkdir(parents=True,exist_ok=True)
def rec(p):return dict(path=p.relative_to(ROOT).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
base=collect();cases=[]
def add(name,mut):
 b=copy.deepcopy(base);mut(b);cases.append((name,b))
add('build_exit',lambda b:b['build'].update(exit_code=1))
add('audit_exit',lambda b:b['audit'].update(exit_code=1))
add('audit_changed',lambda b:b['audit'].update(original_unchanged=False))
add('sim_exit',lambda b:b['sim']['commands'][0].update(exit_code=1))
add('sim_source_changed',lambda b:b['sim']['source_after'][0].update(sha256='0'*64))
add('sim_missing_command',lambda b:b['sim'].update(commands=[]))
add('sim_missing_pixels',lambda b:b['sim'].update(link_checked_cycles=0))
add('sim_missing_frames',lambda b:b['sim'].update(link_frames=8))
add('sim_missing_thresholds',lambda b:b['sim'].update(osd_checked_pixels=1))
add('input_changed',lambda b:b['after'][0].update(sha256='0'*64))
add('missing_input',lambda b:b['after'].pop())
add('missing_report',lambda b:b['audit']['reports'].pop())
add('wrong_tcl',lambda b:b['audit'].update(tcl_sha256='0'*64))
add('wrong_sdc',lambda b:b['audit'].update(sdc_sha256='0'*64))
add('wrong_audit_log',lambda b:b['audit'].update(audit_log_sha256='0'*64))
add('stale_sim_script',lambda b:next(x for x in b['sim']['source_after'] if x['path'].endswith('m31_sobel_controls_sim.py')).update(sha256='0'*64))
for kind,path in [('bit','outflow/Ti60_Demo.bit'),('database','work_pnr/Ti60_Demo.lbf')]:
 add('stale_'+kind,lambda b,path=path:next(x for x in b['build']['outputs'] if x['path'].endswith(path)).update(sha256='0'*64))
add('sim_log_hash',lambda b:b['sim']['artifacts'][0].update(sha256='0'*64))
add('sim_dump_hash',lambda b:next(x for x in b['sim']['artifacts'] if x['path'].endswith('pixels.txt')).update(sha256='0'*64))
# Positive whole-bundle control, then each corrupted bundle must exit exactly 1.
rows=[]
for name,b in [('positive',base)]+cases:
 p=folder/(name+'.json');p.write_text(json.dumps(b))
 command=[sys.executable,'-B',str(ROOT/'scripts/m31_sobel_controls_validate.py'),'--bundle',str(p)]
 proc=subprocess.run(command,capture_output=True,encoding='utf-8',errors='replace')
 expected=0 if name=='positive' else 1
 if proc.returncode!=expected or ('M31_ACCEPTANCE_PASS' if expected==0 else 'M31_ACCEPTANCE_FAIL') not in proc.stdout:raise RuntimeError(name+' '+proc.stdout+proc.stderr)
 rows.append(dict(case=name,exit_code=proc.returncode,diagnostic=proc.stdout.strip(),command=command))
# Timing/coverage/stage parser negatives run in actual subprocesses as well.
fragments=[]
timing=(R/'final_audit/m31_setup.rpt').read_text();coverage=(R/'final_audit/m31_check_timing.rpt').read_text();stages=(R/'build/compile.log').read_text()
import re
for name,text in [('negative_slack',re.sub(r'(^Slack\s*:\s*)\S+',r'\g<1>-0.001',timing,count=1,flags=re.M)),('wrong_model',timing.replace('Timing Model: I3','Timing Model: C4')),('empty_timing','')]:fragments.append((name,'parse_timing',text))
fragments.append(('unconstrained','parse_coverage',coverage.replace('checking no_clock (0)','checking no_clock (1)')))
fragments.append(('stage_fail','parse_stages',re.sub(r'(pnr\s*:\s*)PASS',r'\1FAIL',stages)))
for name,fn,text in fragments:
 p=folder/(name+'.txt');p.write_text(text)
 code='import sys,pathlib;from m31_sobel_controls_validate import '+fn+';'+fn+'(pathlib.Path(sys.argv[1]).read_text()'+(",'setup'" if fn=='parse_timing' else '')+')'
 proc=subprocess.run([sys.executable,'-B','-c',code,str(p)],cwd=ROOT/'scripts',capture_output=True,encoding='utf-8',errors='replace')
 if proc.returncode!=1:raise RuntimeError('fragment accepted '+name)
 rows.append(dict(case=name,exit_code=proc.returncode,diagnostic=proc.stderr.strip().splitlines()[-1]))
out=R/'negative_acceptance.json';out.write_text(json.dumps(rows,indent=2))
(R/'negative_binding.json').write_text(json.dumps(dict(sources=[rec(Path(__file__)),rec(ROOT/'scripts/m31_sobel_controls_validate.py'),rec(ROOT/'scripts/m3_sobel_core_validate.py')],artifacts=[rec(out)]),indent=2))
print('M31_NEGATIVE_PASS',len(rows)-1,'positive=1')
