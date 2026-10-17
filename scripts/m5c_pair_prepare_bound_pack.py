from pathlib import Path
import json,re,hashlib,runpy,datetime
R=Path.cwd();O=R/'reports/m5c_pair_capture_20261016';D=O/'physical_discovery_185129'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
p=json.loads((D/'NEW_ALIAS_PROOF.json').read_text());old=(O/'physical_discovery_183700/PAIR_EXACT_CANDIDATE_SID.sdc').read_bytes();new=old
pairs=[]
for row in p['rows']:
 a=('^'+re.escape(row['old']+'|CLK')+'$').encode();b=('^'+re.escape(row['new']+'|CLK')+'$').encode()
 assert new.count(a)==1,(a,new.count(a));assert new.count(b)==0
 new=new.replace(a,b);pairs.append((a,b))
inv=new
for a,b in reversed(pairs):inv=inv.replace(b,a)
assert inv==old
candidate=D/'PAIR_EXACT_CANDIDATE_LATEST.sdc';assert candidate.read_bytes()==new
runpy.run_path(str(R/'scripts/m5c_pair_prepare_map.py'),run_name='__main__')
F=Path(json.loads((O/'LATEST_PHYSICAL.json').read_text())['directory']);q=F/'mirror/efinity/m5c_pair_diag_i3/Ti60_Demo_I3.sdc';before=q.read_bytes();q.write_bytes(new)
m=json.loads((F/'COPY_MANIFEST.json').read_text())
for x in m['records']:
 if x['copy']['path']==q.relative_to(R).as_posix():x['original_project_source']=x['source'];x['source']=rec(candidate);x['copy']=rec(q);x['configuration_change']={'kind':'APPROVED_EXACT65_CANONICAL_SOURCE_NAMES_ONLY','proof':rec(D/'NEW_ALIAS_PROOF.json')}
(F/'COPY_MANIFEST.json').write_text(json.dumps(m,indent=2));(F/'SDC_BEFORE.sdc').write_bytes(before)
(F/'BOUND_DERIVATION.json').write_text(json.dumps(dict(candidate=rec(candidate),proof=rec(D/'NEW_ALIAS_PROOF.json'),replacements=65,inverse_byte_exact=True,groups=68,semantics='same5ns/hold; normalCE/SR unchanged',root_sdc_unchanged=True),indent=2))
x=json.loads((O/'WORK_PROGRESS.json').read_text());x.update(stage='G1_LATEST_DESCRIPTOR_BOUND_PREPARED',native_processes=[],resource_result='184157 actualplace53319/200/1 NO_GO;185129 latest map36897LUT20008FF200RAM,notplacement',updated=datetime.datetime.now().astimezone().isoformat(),physical=str(F),blocked_on=None);(O/'WORK_PROGRESS.json').write_text(json.dumps(x,indent=2));print('BOUND',F)
