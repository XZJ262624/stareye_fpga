"""Real CLI corrupt-evidence controls; production evidence never modified."""
from pathlib import Path
import json,copy,subprocess,sys,hashlib,re
from m32_median_integration_validate import collect,R,ROOT,V
O=R/'negative_cases';O.mkdir(parents=True,exist_ok=True);base=collect();cases=[];v=V[0]
def add(n,f):
 b=copy.deepcopy(base);f(b);cases.append((n,b))
add('variant_missing',lambda b:b['variants'].pop(V[1]))
add('sim_exit',lambda b:b['sim']['commands'][0].update(exit_code=1))
add('sim_missing_pixels',lambda b:b['sim']['cases'][1].update(de_pixels=1))
add('sim_source_changed',lambda b:b['sim']['sources_after'][0].update(sha256='0'*64))
add('sim_false_pass',lambda b:b['sim'].update(status='FAIL'))
add('build_exit',lambda b:b['variants'][v]['build'].update(exit_code=1))
add('input_missing',lambda b:b['variants'][v]['after'].pop())
add('input_changed',lambda b:b['variants'][v]['after'][0].update(sha256='0'*64))
add('audit_exit',lambda b:b['variants'][v]['audit'].update(exit_code=1))
add('audit_changed_db',lambda b:b['variants'][v]['audit'].update(original_unchanged=False))
add('missing_report',lambda b:b['variants'][v]['audit']['reports'].pop())
add('wrong_sdc',lambda b:b['variants'][v]['audit'].update(sdc_sha256='0'*64))
add('wrong_tcl',lambda b:b['variants'][v]['audit'].update(tcl_sha256='0'*64))
add('stale_bit',lambda b:next(x for x in b['variants'][v]['build']['outputs'] if x['path'].endswith('/Ti60_Demo.bit')).update(sha256='0'*64))
rows=[]
for name,b in [('positive',base)]+cases:
 p=O/(name+'.json');p.write_text(json.dumps(b));cmd=[sys.executable,'-B',str(ROOT/'scripts/m32_median_integration_validate.py'),'--bundle',str(p)];x=subprocess.run(cmd,capture_output=True,text=True);expected=0 if name=='positive' else 1
 assert x.returncode==expected and ('M32_ACCEPTANCE_PASS' if expected==0 else 'M32_ACCEPTANCE_FAIL') in x.stdout,(name,x.stdout,x.stderr)
 rows.append(dict(name=name,exit_code=x.returncode,diagnostic=x.stdout.strip(),command=cmd))
text=(R/V[0]/'final_audit/m32_setup.rpt').read_text()
for name,t in [('negative_slack',re.sub(r'(^Slack\s*:\s*)\S+',r'\g<1>-0.001',text,count=1,flags=re.M)),('wrong_model',text.replace('Timing Model: I3','Timing Model: C4')),('empty_timing','')]:
 p=O/(name+'.txt');p.write_text(t);cmd=[sys.executable,'-B','-c',"import pathlib,sys;from m3_sobel_core_validate import parse_timing;parse_timing(pathlib.Path(sys.argv[1]).read_text(),'setup')",str(p)];x=subprocess.run(cmd,cwd=ROOT/'scripts',capture_output=True,text=True);assert x.returncode!=0,name;rows.append(dict(name=name,exit_code=x.returncode,diagnostic=x.stderr.strip().splitlines()[-1],command=cmd))
(R/'negative_acceptance.json').write_text(json.dumps(rows,indent=2))
def rec(p):return dict(path=p.relative_to(ROOT).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
(R/'negative_binding.json').write_text(json.dumps(dict(sources=[rec(Path(__file__)),rec(ROOT/'scripts/m32_median_integration_validate.py'),rec(ROOT/'scripts/m3_sobel_core_validate.py')],artifacts=[rec(R/'negative_acceptance.json')]),indent=2))
print('M32_NEGATIVES_PASS positive=1 negatives='+str(len(rows)-1))
