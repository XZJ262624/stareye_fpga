from pathlib import Path
import json,hashlib
R=Path(__file__).resolve().parents[3];O=Path(__file__).resolve().parent;D=R/'reports/m5c_diagnostics/candidate_evidence_stage2_20261015'
parent={}
for row in (O/'PARENT_TREE.raw').read_bytes().split(b'\0'):
 if row:
  info,path=row.split(b'\t',1);parent[path.decode()]=info.split()[2].decode()
def record(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest(),git_blob=hashlib.sha1(b'blob '+str(len(b)).encode()+b'\0'+b).hexdigest())
mapping=json.loads((D/'VERSION_MAPPING.json').read_text())['mapping'];direct={}
for x in mapping:
 name=x['original_path'];p=R/name
 if name.startswith(('rtl/','tb/','scripts/')) and p.is_file() and hashlib.sha256(p.read_bytes()).hexdigest()==x['original_sha256']:direct[name]=record(p)
adopt=json.loads((O/'ROOT_ADOPTION_RECEIPT.json').read_text())
for x in adopt['inputs']:
 p=R/x['root']['path'];direct[p.relative_to(R).as_posix()]=record(p)
package=[record(p) for p in D.rglob('*') if p.is_file() and p.name not in ['TECHNICAL_ALLOWLIST_DRAFT.json','TECHNICAL_SNAPSHOT_DRAFT.json']]
helpers=[record(O/name) for name in ['prepare_transport.py','index_evidence_scope.py','apply_approved.py','prepare_allowlist_draft.py','add_golden_closure.py','audit_command_closure.py','audit_literal_includes.py','ROOT_ADOPTION_RECEIPT.json','WORK_ADOPTION_APPROVAL.json','WORK_CANDIDATE_PREPARATION_FREEZE.md','CONFIGURATION_CLASSIFICATION.json']]
allfiles={x['path']:x for x in [*direct.values(),*package,*helpers]}
changed=[];inherited=[]
for name,x in sorted(allfiles.items()):
 x['parent_blob']=parent.get(name)
 if x['git_blob']==parent.get(name):inherited.append(x)
 else:changed.append(x)
(D/'TECHNICAL_ALLOWLIST_DRAFT.json').write_text(json.dumps(dict(status='DRAFT_NOT_STAGE_AUTHORIZATION',parent='3b49a1f701798a817fed42b8097f724cbc9d6160',records=changed,count=len(changed),bytes=sum(x['bytes'] for x in changed),management_docs='Work freeze pending; not silently included',scope='Exact changed technical inputs/current test helpers and selected evidence transport. No native artifacts.'),indent=2))
(D/'TECHNICAL_SNAPSHOT_DRAFT.json').write_text(json.dumps(dict(current=changed,inherited_parent=inherited,boundary='Inherited files remain required for review/reproduction despite not changing in this candidate.'),indent=2))
print(json.dumps(dict(changed=len(changed),inherited=len(inherited),bytes=sum(x['bytes'] for x in changed))))
