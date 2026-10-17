from pathlib import Path
import json,hashlib
R=Path.cwd();P=R/'efinity/m5c_pair_diag_i3';O=R/'reports/m5c_pair_capture_20261016/settings_path_revision';O.mkdir(exist_ok=False);rows=[]
for p in P.rglob('settings.json'):
 b=p.read_bytes();d=json.loads(b);a=d.get('args',[])
 if '--base_path' not in a:continue
 i=a.index('--base_path')+1;old=a[i];new=str(P/'ip').replace('\\','/')
 z=b.replace(json.dumps(old).encode(),json.dumps(new).encode());assert z.replace(json.dumps(new).encode(),json.dumps(old).encode())==b
 e=json.loads(z);e['args'][i]=old;assert e==d
 q=O/('before_'+str(len(rows))+'.json');q.write_bytes(b);p.write_bytes(z)
 rows.append(dict(path=str(p.relative_to(R)),before_snapshot=str(q.relative_to(R)),old=old,new=new,before_sha256=hashlib.sha256(b).hexdigest(),after_sha256=hashlib.sha256(z).hexdigest(),inverse_byte_exact=True))
(O/'RECEIPT.json').write_text(json.dumps(dict(scope='New project settings only; exact args base_path string replacement; all conf parameters unchanged. Existing mirrors immutable. No IP generator executed.',records=rows),indent=2));print('rebased',len(rows))
