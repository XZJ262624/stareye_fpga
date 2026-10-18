from pathlib import Path
import json,hashlib,datetime,shutil,xml.etree.ElementTree as ET
R=Path.cwd();O=R/'reports/m5c_pair_admission_20261018';F=O/('physical_latest_'+datetime.datetime.now().strftime('%H%M%S'));C=F/'mirror';P=R/'efinity/m5c_pair_diag_i3'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
files=set()
for e in ET.parse(P/'Ti60_Demo.xml').iter():
 if e.tag.endswith('design_file'):files.add((P/e.attrib['name']).resolve())
for p in P.rglob('*'):
 if p.is_file() and p.suffix.lower() in ['.v','.sv','.vh','.svh','.json','.bin','.mem','.hex','.xml','.sdc']:files.add(p.resolve())
assert len(files)==107,len(files)
rows=[]
for p in sorted(files):
 q=C/p.relative_to(R);q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,q);change=None
 if p.name=='settings.json':
  d=json.loads(p.read_text());args=d.get('args',[])
  if '--base_path' in args:
   i=args.index('--base_path')+1;a=args[i];z=str(C/'efinity/m5c_pair_diag_i3/ip').replace('\\','/')
   old=q.read_bytes();new=old.replace(json.dumps(a).encode(),json.dumps(z).encode());assert new!=old and new.replace(json.dumps(z).encode(),json.dumps(a).encode())==old
   q.write_bytes(new);check=json.loads(new);check['args'][i]=a;assert check==d
   change=dict(field='args[--base_path]',before=a,after=z,inverse_byte_exact=True)
 rows.append(dict(source=rec(p),copy=rec(q),configuration_change=change))
(F/'COPY_MANIFEST.json').write_text(json.dumps(dict(records=rows),indent=2));(F/'PREFLIGHT.json').write_text(json.dumps(dict(status='PREPARED_NOT_STARTED',scope='fresh map then current actual selector/newlatest control inventory; resource and STA pending',design_files=len(files)),indent=2))
s=(R/'reports/m5c_shadow_stats_20261016/physical_133645/run_stage.py').read_text().replace("P=C/'efinity/m5c_fusion_i3'","P=C/'efinity/m5c_pair_diag_i3'")
a=s.index(" ps='Get-CimInstance");b=s.index('\nafter=[rec',a)
s=s[:a]+''' while p.poll() is None:
  (W/'HEARTBEAT.json').write_text(json.dumps(dict(status='NATIVE_RUNNING',pid=p.pid,elapsed=time.time()-t)))
  time.sleep(10)
 code=p.returncode
'''+s[b:]
s=s.replace('max_threads=32','max_threads=8')
(F/'run_stage.py').write_text(s)
(O/'LATEST_PHYSICAL.json').write_text(json.dumps(dict(directory=str(F),status='PREPARED_NOT_STARTED'),indent=2));print(F)
