from pathlib import Path
import json,hashlib,subprocess,difflib
F=Path(__file__).resolve().parent;R=F.parents[2];OLD=F.parent/'offline_artifact_20261014'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
paths=[]
for d in [OLD,F]:paths += [str((d/'mirror/efinity/m5c_fusion_i3/outflow'/('Ti60_Demo'+s)).relative_to(R)).replace('\\','/') for s in ['.bit','.bit.bin','.hex','.hex.bin']]
result=subprocess.run(['git','-c','safe.directory=F:/Projects/stareye_fpga','check-ignore','-v','--']+paths,cwd=R,text=True,capture_output=True);assert result.returncode==0 and len(result.stdout.splitlines())==8
receipt=dict(status='EXACT8_ARTIFACTS_IGNORED_BY_TWO_LOCAL_SIDECARS',files=[rec(OLD/'.gitignore'),rec(F/'.gitignore')],actual_check_ignore=result.stdout,scope='Work authorized only exact4 paths per package; root ignore and all prior receipt/manifest files unchanged.')
p=F/'IGNORE_SIDECAR_RECEIPT.json';assert not p.exists();p.write_text(json.dumps(receipt,indent=2))
old=(F/'seal.py').read_text();new=old.replace("p=F/n;assert not p.exists();p.write_text(json.dumps(x,indent=2));return rec(p)","p=F/n\n if p.exists():\n  assert n=='RETRY_DERIVATION.json' and json.loads(p.read_text())==x;return rec(p)\n p.write_text(json.dumps(x,indent=2));return rec(p)")
q=F/'seal_v2.py';assert not q.exists();q.write_text(new)
(F/'SEAL_V2_DERIVATION.json').write_text(json.dumps(dict(parent=rec(F/'seal.py'),derived=rec(q),prior_failure='All4 new artifacts untracked but not ignored; exact4 ignore sidecars now authorized and added to both packages. No native failure; no repeat.',diff=''.join(difflib.unified_diff(old.splitlines(True),new.splitlines(True))),scope='Identical prior RETRY_DERIVATION reused by equality; no validation removed.'),indent=2))
