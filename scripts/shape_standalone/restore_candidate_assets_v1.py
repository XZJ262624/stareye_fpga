"""Restore approved candidate sources/frozen gold into a NEW isolated repo root.
No overwrite, no generator, no golden update. Optional 100us compile only.
"""
from pathlib import Path
import argparse,json,hashlib,zipfile,shutil,subprocess,os,time
R=Path(__file__).resolve().parents[2];O=R/'reports/shape_standalone_20261021';A=O/'candidate_assets'
p=argparse.ArgumentParser();p.add_argument('--destination',required=True);p.add_argument('--probe100us',action='store_true');opt=p.parse_args();dest=Path(opt.destination).resolve();assert not dest.exists(),'Destination must be a new isolated path'
def rec(q):return dict(path=q.relative_to(R).as_posix(),bytes=q.stat().st_size,sha256=hashlib.sha256(q.read_bytes()).hexdigest())
def safe(name):
 q=Path(name);assert not q.is_absolute()and'..'not in q.parts
 target=(dest/q).resolve();assert target.is_relative_to(dest);return target
manifest=json.loads((A/'GOLD_MANIFEST.json').read_text());primary=json.loads((A/'PRIMARY_SOURCE_MANIFEST.json').read_text())['records'];dest.mkdir(parents=True)
for x in primary:
 q=R/x['path'];assert rec(q)==x;qout=safe(x['path']);qout.parent.mkdir(parents=True,exist_ok=True);assert not qout.exists();shutil.copyfile(q,qout)
with zipfile.ZipFile(A/'frozen_test_assets.zip')as z:
 assert z.namelist()==[x['path']for x in manifest['records']]
 for x in manifest['records']:
  q=safe(x['path']);q.parent.mkdir(parents=True,exist_ok=True);assert not q.exists(),q
  with z.open(x['path'])as src,q.open('xb')as output:shutil.copyfileobj(src,output,1024*1024)
  assert q.stat().st_size==x['bytes']and hashlib.sha256(q.read_bytes()).hexdigest()==x['sha256'],q
for x in primary:
 q=safe(x['path']);assert q.stat().st_size==x['bytes']and hashlib.sha256(q.read_bytes()).hexdigest()==x['sha256']
result=dict(passed=True,scope='Actual isolated disk materialization with exact fileSHA; no model/expected regeneration.',destination=str(dest),gold_files=len(manifest['records']),gold_bytes=sum(x['bytes']for x in manifest['records']),primary_files=len(primary),compile100us_executed=False,full72_executed=False,physical_reexecuted=False,hardware_used=False)
if opt.probe100us:
 with(dest/'compile100us.log').open('wb')as f:
  cmd=[os.sys.executable,'-B',str(dest/'scripts/shape_standalone/run_video.py'),'--probe100us'];process=subprocess.Popen(cmd,cwd=dest,stdout=f,stderr=subprocess.STDOUT,creationflags=subprocess.CREATE_NO_WINDOW);print('ISOLATED_COMPILE_PID',process.pid,flush=True);code=process.wait(timeout=300)
 assert code==0,(dest/'compile100us.log').read_text(errors='replace')[-5000:]
 receipt=dest/'reports/shape_standalone_20261021/CURRENT_RUNNER_COMPILE100US_RECEIPT.json';assert json.loads(receipt.read_text())['passed'];result.update(compile100us_executed=True,compile_receipt_sha256=hashlib.sha256(receipt.read_bytes()).hexdigest())
(dest/'RESTORE_RESULT.json').write_text(json.dumps(result,indent=2),encoding='utf8');print(json.dumps(result),flush=True)
