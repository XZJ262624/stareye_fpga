from pathlib import Path
import json,hashlib,runpy,datetime
R=Path.cwd();O=R/'reports/m5c_pair_capture_20261016';D=O/'physical_discovery_192337'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
approval=O/'work_check/ALIAS_192337_CHECK.json'
assert json.loads(approval.read_text())['status']=='PASS_WORK_ALIAS260_LOCAL_AND_SDC_DELTA'
candidate=D/'ALIAS260_CANDIDATE.sdc';proof=D/'ALIAS260_PROOF.json'
runpy.run_path(str(R/'scripts/m5c_pair_prepare_map.py'),run_name='__main__')
F=Path(json.loads((O/'LATEST_PHYSICAL.json').read_text())['directory']);q=F/'mirror/efinity/m5c_pair_diag_i3/Ti60_Demo_I3.sdc'
(F/'SDC_BEFORE.sdc').write_bytes(q.read_bytes());q.write_bytes(candidate.read_bytes())
m=json.loads((F/'COPY_MANIFEST.json').read_text())
for x in m['records']:
 if x['copy']['path']==q.relative_to(R).as_posix():
  x['original_project_source']=x['source'];x['source']=rec(candidate);x['copy']=rec(q);x['configuration_change']=dict(kind='APPROVED_EXACT260_CANONICAL_BINDING',proof=rec(proof),approval=rec(approval))
(F/'COPY_MANIFEST.json').write_text(json.dumps(m,indent=2))
(F/'BOUND_DERIVATION.json').write_text(json.dumps(dict(candidate=rec(candidate),proof=rec(proof),approval=rec(approval),replacements=260,groups=68,semantics='same5ns/hold; normalD/CE/SR unchanged',root_sdc_unchanged=True,current_qualification=rec(O/'current_qualification_revision/DERIVATION.json')),indent=2))
print('PACK5_BOUND',F)
