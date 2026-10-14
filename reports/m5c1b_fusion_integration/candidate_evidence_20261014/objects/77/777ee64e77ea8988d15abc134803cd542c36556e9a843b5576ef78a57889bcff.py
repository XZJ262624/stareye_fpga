from pathlib import Path
import json,hashlib,shutil,subprocess,time,datetime,xml.etree.ElementTree as ET
F=Path(__file__).resolve().parent;R=F.parents[2];P=F/'mirror/efinity/m5c_fusion_i3';B=F.parent/'fresh_i3_build_20261014'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def put(n,x):
 p=F/n;assert not p.exists();p.write_text(json.dumps(x,indent=2))
def check(x):
 p=Path(x['path']);p=p if p.is_absolute() else R/p;z=rec(p) if p.is_relative_to(R) else dict(bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest());assert z['bytes']==x['bytes'] and z['sha256']==x['sha256'],p
def archive(name):
 rows=[]
 for p in sorted((F/'mirror').rglob('*')):
  if not p.is_file():continue
  x=rec(p);q=F/'content_archive'/x['sha256'][:2]/x['sha256'];q.parent.mkdir(parents=True,exist_ok=True)
  if not q.exists():shutil.copyfile(p,q)
  z=rec(q);assert z['sha256']==x['sha256'];rows.append(dict(original=x,archive=z))
 put(name,dict(records=rows));return rows
inputs=json.loads((F/'INPUT_WHITELIST.json').read_text());opts=json.loads((F/'ACTUAL_GENERATED_OPTIONS.json').read_text());assert opts['status']=='PASS_CONVERSION_ONLY_NO_NATIVE_EXECUTED'
for x in inputs['source']+inputs['database']:check(x['original']);check(x['copy'])
for x in inputs['tools']:check(x)
assert not list((F/'mirror').rglob('efx_pgm_settings.ini'))
beforexml=ET.parse(P/'Ti60_Demo.xml').getroot();archive('PRE_NATIVE_ARCHIVE.json')
cmd=['cmd','/c',r'call E:\Efinity\2025.1\bin\setup.bat && call E:\Efinity\2025.1\bin\efx_run.bat Ti60_Demo.xml --flow pgm'];start=time.time()
with (F/'tool.log').open('w') as log:
 proc=subprocess.Popen(cmd,cwd=P,stdout=log,stderr=subprocess.STDOUT);put('OWNED_PROCESS.json',dict(pid=proc.pid,started=datetime.datetime.now().astimezone().isoformat(),command=cmd,cwd=str(P)));print('LAUNCH',proc.pid,flush=True)
 try:code=proc.wait(timeout=1200);timeout=False
 except subprocess.TimeoutExpired:
  subprocess.run(['taskkill','/PID',str(proc.pid),'/T','/F'],capture_output=True);code=proc.wait();timeout=True
archive('POST_NATIVE_ARCHIVE.json')
afterxml=ET.parse(P/'Ti60_Demo.xml').getroot();allowed={'last_change','last_run_flow','last_run_state','sw_version','config_result_in_sync','design_ood','place_ood','route_ood'};changes={k:dict(old=beforexml.get(k),new=afterxml.get(k)) for k in set(beforexml.attrib)|set(afterxml.attrib) if beforexml.get(k)!=afterxml.get(k)};assert set(changes)<=allowed
for k in allowed:beforexml.attrib.pop(k,None);afterxml.attrib.pop(k,None)
assert ET.tostring(beforexml)==ET.tostring(afterxml)
for x in inputs['source']+inputs['database']:
 check(x['original'])
 if not x['copy']['path'].endswith('/Ti60_Demo.xml') and not x['copy']['path'].endswith('\\Ti60_Demo.xml'):check(x['copy'])
log=(F/'tool.log').read_text(errors='replace');native=[x for x in log.splitlines() if 'efx_pgm.exe ' in x];assert len(native)==1,native
assert '--source ' in native[0] and '--dest ' in native[0] and not any(t in native[0].split() for t in ['--program','--usb','--jtag','--flash'])
artifacts=[rec(P/'outflow'/('Ti60_Demo'+s)) for s in ['.bit','.bit.bin','.hex','.hex.bin']];assert all(x['bytes']>0 for x in artifacts)
assert code==0 and not timeout
put('RESULT.json',dict(status='PASS_OFFLINE_CONVERSION_ONLY',exit=code,timeout=timeout,seconds=time.time()-start,command=cmd,native_argv=native,artifacts=artifacts,xml_metadata_changes=changes,input_source_database_unchanged=True,warning='Parameter parser emitted cannot find correct IV value with encryption/auth disabled; actual do_security false. No keys supplied/changed and no security operation enabled.'))
print('PASS_OFFLINE_CONVERSION_ONLY',time.time()-start,flush=True)
