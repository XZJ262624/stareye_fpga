from pathlib import Path
import subprocess,json,hashlib,time,sys,xml.etree.ElementTree as ET,re,shutil
F=Path(__file__).resolve().parent;R=F.parents[3];C=F/'mirror';P=C/'efinity/m5c_fusion_i3';stage=sys.argv[1];assert stage in ['map','interface','place','route'];W=F/stage;W.mkdir(exist_ok=False)
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def archive(label):
 rows=[]
 # Every project file, including XML/settings and every output/work DB, not a suffix whitelist.
 for p in sorted(P.rglob('*')):
  if not p.is_file():continue
  a=rec(p);q=F/'content_archive'/a['sha256'][:2]/a['sha256'];q.parent.mkdir(parents=True,exist_ok=True)
  if not q.exists():shutil.copyfile(p,q)
  z=rec(q);assert (a['bytes'],a['sha256'])==(z['bytes'],z['sha256']);rows.append(dict(original=a,archive=z))
 for p in sorted(W.iterdir()):
  if p.is_file() and p.name not in [label+'.json']:
   a=rec(p);q=F/'content_archive'/a['sha256'][:2]/a['sha256'];q.parent.mkdir(parents=True,exist_ok=True)
   if not q.exists():shutil.copyfile(p,q)
   z=rec(q);assert a['sha256']==z['sha256'];rows.append(dict(original=a,archive=z))
 fn=W/(label+'.json');assert not fn.exists();fn.write_text(json.dumps(dict(records=rows),indent=2));return rec(fn)
def verify_archive(path,live):
 for x in json.loads(path.read_text())['records']:
  assert rec(R/x['archive']['path'])==x['archive']
  if live and x['original']['path'].startswith(P.relative_to(R).as_posix()+'/'):assert rec(R/x['original']['path'])==x['original']
m=json.loads((F/'COPY_MANIFEST.json').read_text());assert json.loads((F/'PREFLIGHT.json').read_text())['status']=='PASS_INPUT_ADMISSION_ONLY'
for x in m['records']:assert rec(R/x['source']['path'])==x['source']
prev={'interface':'map','place':'interface','route':'place'}.get(stage)
if prev:
 rr=json.loads((F/prev/'RESULT.json').read_text());assert rr['status']=='PASS_STAGE';verify_archive(R/rr['output_archive']['path'],True)
if stage=='interface':
 gate=json.loads((F/'MAPPED_AUDIT_GATE.json').read_text());assert gate['status']=='PASS_STRUCTURAL_EXACT_SELECTORS';assert gate['map_sha256']==rec(P/'outflow/Ti60_Demo.map.v')['sha256'];assert gate['sdc_sha256']==rec(P/'Ti60_Demo_I3.sdc')['sha256']
if stage=='route':assert json.loads((F/'place/RESULT.json').read_text())['resources']['pass']
paths=[R/x['copy']['path'] for x in m['records']];before=[rec(p) for p in paths];xml=(P/'Ti60_Demo.xml').read_bytes();(W/'xml_before.xml').write_bytes(xml)
commands={'map':'call E:\\Efinity\\2025.1\\bin\\efx_run.bat Ti60_Demo.xml --flow map','interface':'call E:\\Efinity\\2025.1\\bin\\efx_run.bat Ti60_Demo.xml --flow interface'}
if stage in ['place','route']:
 opt='pack place' if stage=='place' else 'route';commands[stage]='E:\\Efinity\\2025.1\\python311\\bin\\python.exe -B E:\\Efinity\\2025.1\\scripts\\efx_run_pnr.py Ti60_Demo --prj --family Titanium --device Ti60F225 --timing_model I3 --work_dir work_pnr --output_dir outflow --opt '+opt+' timing_analysis=on seed=1 max_threads=32 sdc_file=Ti60_Demo_I3.sdc'
batch=W/'run.bat';batch.write_text('@echo off\ncall E:\\Efinity\\2025.1\\bin\\setup.bat\nif errorlevel 1 exit /b %errorlevel%\n'+commands[stage]+'\nexit /b %errorlevel%\n')
(W/'INPUTS.json').write_text(json.dumps(dict(inputs=before,runner=rec(Path(__file__)),batch=rec(batch),preflight=rec(F/'PREFLIGHT.json'),copy=rec(F/'COPY_MANIFEST.json')),indent=2));prearchive=archive('PRE_NATIVE_ARCHIVE');verify_archive(R/prearchive['path'],True)
t=time.time();timed=False
with (W/'tool.log').open('wb') as f:
 p=subprocess.Popen(['cmd','/c',str(batch)],cwd=P,stdout=f,stderr=subprocess.STDOUT);owner=dict(pid=p.pid,started_unix=t,command=['cmd','/c',str(batch)],cwd=str(P));(W/'OWNER.json').write_text(json.dumps(owner,indent=2));print('OWNED',stage,owner,flush=True)
 ps='Get-CimInstance Win32_Process -Filter "ProcessId = '+str(p.pid)+'" | Select-Object ProcessId,ParentProcessId,CreationDate,Name,CommandLine | ConvertTo-Json -Depth 4'
 ci=subprocess.run(['powershell','-NoProfile','-Command',ps],capture_output=True);(W/'OWNER_CIM.json').write_bytes(ci.stdout);(W/'OWNER_CIM.stderr').write_bytes(ci.stderr)
 try:code=p.wait(timeout=3600)
 except subprocess.TimeoutExpired:
  timed=True
  if p.poll() is None:subprocess.run(['taskkill','/PID',str(p.pid),'/T','/F'],stdout=f,stderr=subprocess.STDOUT)
  code=p.wait(timeout=30)
after=[rec(p) for p in paths];changes=[dict(before=a,after=b) for a,b in zip(before,after) if a!=b];equiv=not changes
attrs=['last_change','last_run_flow','last_run_state','config_result_in_sync','design_ood','place_ood','route_ood'];metadata={}
if changes and all(x['before']['path'].endswith('/Ti60_Demo.xml') for x in changes):
 a=ET.fromstring(xml);b=ET.parse(P/'Ti60_Demo.xml').getroot();metadata={n:dict(before=a.attrib.get(n),after=b.attrib.get(n)) for n in attrs if a.attrib.get(n)!=b.attrib.get(n)}
 for n in attrs:a.attrib.pop(n,None);b.attrib.pop(n,None)
 equiv=ET.tostring(a)==ET.tostring(b)
unchanged=all(rec(R/x['source']['path'])==x['source'] for x in m['records']);outputs=[rec(p) for root in ['outflow','work_pnr'] for p in sorted((P/root).rglob('*')) if p.is_file()];forbidden=[x for x in outputs if x['path'].endswith(('.bit','.bit.bin','.hex','.hex.bin','.pgm'))];txt=(W/'tool.log').read_text(errors='replace');resources=None
if stage in ['place','route'] and code==0:
 rpt=P/('outflow/Ti60_Demo.'+stage+'.rpt');s=rpt.read_text();xlr=int(re.search(r'XLRs:\s*(\d+)',s)[1]);ram=int(re.search(r'Memory Blocks:\s*(\d+)',s)[1]);dsp=int(re.search(r'DSP Blocks:\s*(\d+)',s)[1]);routing=int(re.search(r'XLRs needed for Routing:\s*(\d+)',s)[1]);resources=dict(XLR=xlr,RAM10=ram,DSP=dsp,routing=routing,pass_=xlr<=48640 and ram<=204 and dsp<=128);resources['pass']=resources.pop('pass_')
ok=code==0 and not timed and equiv and unchanged and not forbidden and (resources is None or resources['pass'])
# Archive before writing result / allowing any later native stage, including failed stage outputs.
post=archive('POST_NATIVE_ARCHIVE');verify_archive(R/post['path'],True)
r=dict(status='PASS_STAGE' if ok else 'FAIL_STAGE_BLOCK_DESCENDANTS',stage=stage,exit=code,timeout=timed,seconds=time.time()-t,source_equivalent=equiv,production_unchanged=unchanged,changes=changes,xml_metadata_exception=metadata,resources=resources,forbidden=forbidden,outputs=outputs,input_archive=prearchive,output_archive=post,log=rec(W/'tool.log'),boundary='No programming output; actual I3 timing qualification pending full native queries.')
(W/'RESULT.json').write_text(json.dumps(r,indent=2));print('DONE',stage,r['status'],resources,flush=True);sys.exit(0 if ok else 1)
