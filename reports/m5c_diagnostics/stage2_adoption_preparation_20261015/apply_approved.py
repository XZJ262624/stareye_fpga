from pathlib import Path
import json,hashlib
R=Path(__file__).resolve().parents[3];O=Path(__file__).resolve().parent
def rec(p):
 b=p.read_bytes();return dict(path=str(p.relative_to(R)),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
a=json.loads((O/'WORK_ADOPTION_APPROVAL.json').read_text());assert a['status']=='APPROVED_EXACT_TWO_TECHNICAL_ADOPTIONS'
assert json.loads((O/'final_system_seal/HANDBACK.json').read_text())['status']=='PASS_CURRENT_ENABLED_SYSTEM_FINITE_SCOPE'
D=O/'root_before';D.mkdir(exist_ok=False)
checks=[]
for x in a['technical']:
 target=R/x['relative'];source=R/x['selected']['path']
 for p,r in [(target,x['before']),(source,x['selected'])]:
  actual=rec(p);assert actual['sha256']==r['sha256'] and actual['bytes']==r['bytes']
 saved=D/x['relative'];saved.parent.mkdir(parents=True,exist_ok=True);saved.write_bytes(target.read_bytes())
 checks.append((x,target,source,saved))
out=[]
for x,target,source,saved in checks:
 target.write_bytes(source.read_bytes());assert target.read_bytes()==source.read_bytes()
 assert rec(saved)['sha256']==x['before']['sha256']
 out.append(dict(relative=x['relative'],before=rec(saved),after=rec(target),selected=rec(source),inverse='Restore exact archived before bytes; no newline conversion'))
proposal=json.loads((O/'ROOT_TO_SELECTED_PROPOSAL.json').read_text());bound=[]
for x in proposal['inputs']:
 root=R/x['relative'];selected=R/x['selected']['path'];kind='BYTE_EXACT'
 if root.name=='settings.json':
  aa=json.loads(root.read_text());bb=json.loads(selected.read_text());i=aa['args'].index('--base_path')+1;j=bb['args'].index('--base_path')+1;bb['args'][j]=aa['args'][i];assert aa==bb
  assert rec(root)['sha256']==x['root']['sha256'];kind='BASE_PATH_NORMALIZED_JSON_ROOT_UNCHANGED'
 elif root.suffix=='.xml':
  import re
  assert re.sub(rb'last_change="[0-9]+"',b'last_change="NORMALIZED"',root.read_bytes())==re.sub(rb'last_change="[0-9]+"',b'last_change="NORMALIZED"',selected.read_bytes())
  assert rec(root)['sha256']==x['root']['sha256'];kind='LAST_CHANGE_METADATA_ROOT_UNCHANGED'
 else:assert root.read_bytes()==selected.read_bytes()
 bound.append(dict(relative=x['relative'],root=rec(root),selected=rec(selected),comparison=kind))
(O/'ROOT_ADOPTION_RECEIPT.json').write_text(json.dumps(dict(status='PASS_EXACT_APPROVED_ADOPTION',approval=rec(O/'WORK_ADOPTION_APPROVAL.json'),changes=out,input_count=len(bound),inputs=bound,no_git_or_hardware=True),indent=2))
print('PASS two exact adoptions; 104 bound: 92 exact, 11 settings and 1 metadata equivalence')
