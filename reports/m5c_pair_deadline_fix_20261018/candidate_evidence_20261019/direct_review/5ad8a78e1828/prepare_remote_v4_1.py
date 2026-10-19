from pathlib import Path
import json,hashlib,difflib
D=Path(__file__).resolve().parent;B=D/'remote_v4/package';N=D/'remote_v4_1';P=N/'package';P.mkdir(parents=True,exist_ok=False)
def rec(p):
 b=p.read_bytes();return dict(size=len(b),sha256=hashlib.sha256(b).hexdigest())
m=json.loads((B/'manifest.json').read_text())
for n,r in m['files'].items():
 assert rec(B/n)==r
 p=P/n;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes((B/n).read_bytes())
p=P/'portable/stage.py';old=p.read_text();a='from current_inputs import capture';b="# Resolve this package's helper even with isolated/embeddable Python search paths.\nsys.path.insert(0,str(Path(__file__).resolve().parent))\nfrom current_inputs import capture"
assert old.count(a)==1;new=old.replace(a,b);p.write_text(new)
(N/'STAGE_IMPORT.diff').write_text(''.join(difflib.unified_diff(old.splitlines(True),new.splitlines(True),fromfile='V4',tofile='V4.1')))
m['version']='pack5_deadline_20261018_v4_1_import';m['files']={n:rec(P/n) for n in m['files']}
(P/'manifest.json').write_text(json.dumps(m,indent=2))
changed=[n for n in m['files'] if (P/n).read_bytes()!=(B/n).read_bytes()];assert changed==['portable/stage.py']
(N/'DERIVATION.json').write_text(json.dumps(dict(parent_manifest=rec(B/'manifest.json'),current_manifest=rec(P/'manifest.json'),changed_files=changed,unchanged_files=len(m['files'])-1,rtl_changes=0,workload_changes=0,timeout_changes=0,markers='V4 marker strings intentionally retained; distinct manifest/version bind V4.1',scope='Only explicit local helper import. README original V4 technical contract retained. Remote embeddable3.13.16 not locally available; -I is a bounded analogous import test.'),indent=2))
print(N)
