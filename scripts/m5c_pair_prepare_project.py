from pathlib import Path
import hashlib,json,subprocess,xml.etree.ElementTree as ET
R=Path(__file__).resolve().parents[1];O=R/'reports/m5c_pair_capture_20261016';old=R/'efinity/m5c_fusion_i3';new=R/'efinity/m5c_pair_diag_i3'
def rec(p):b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
xml=ET.parse(old/'Ti60_Demo.xml');files=set()
for n in xml.iter():
 if n.tag.endswith('design_file'):files.add((old/n.attrib['name']).resolve())
for base in [old/'src',old/'ip']:
 for p in base.rglob('*'):
  if p.is_file() and p.suffix.lower() in ('.v','.sv','.vh','.svh','.json','.bin','.mem','.hex'):files.add(p.resolve())
for name in ['Ti60_Demo.xml','Ti60_Demo_I3.sdc','Ti60_Demo.peri.xml','Ti60_Demo.pt.sdc']:files.add(old/name)
records=[];copies=[]
for p in sorted(files):
 records.append(rec(p))
 if p.is_relative_to(old):
  q=new/p.relative_to(old);q.parent.mkdir(parents=True,exist_ok=True);assert not q.exists(),str(q)
  b=p.read_bytes();q.write_bytes(b);copies.append(dict(original=rec(p),copy=rec(q)))
git=['git','-c','safe.directory=F:/Projects/stareye_fpga']
status=subprocess.check_output(git+['status','--porcelain=v1','-z'],cwd=R);(O/'BASELINE_GIT_STATUS.nul').write_bytes(status)
(O/'BASELINE_INPUTS.json').write_text(json.dumps(dict(source=records,copies=copies,head=subprocess.check_output(git+['rev-parse','HEAD','HEAD^'],cwd=R,text=True).splitlines(),status_sha256=hashlib.sha256(status).hexdigest(),note='Initial isolated copies before rename/connection/settings rebase; not native-ready inputs; no old outflow/work_pnr/db/bit copied'),indent=2)+'\n')
print('BASELINE',len(records),'project copies',len(copies))
