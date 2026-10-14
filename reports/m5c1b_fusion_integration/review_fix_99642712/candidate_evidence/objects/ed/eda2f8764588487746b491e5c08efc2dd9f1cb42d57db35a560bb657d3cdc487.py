from pathlib import Path
import json,hashlib,shutil,re
F=Path(__file__).resolve().parent;R=F.parents[2];A=F/'resource_area_bound';O=F/'offline_area_artifact';D=F/'root_configuration_adoption'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
assert not D.exists();assert json.loads((O/'FINAL_HANDBACK.json').read_text())['status']=='PASS_OFFLINE_AREA_ARTIFACT_SEALED_BEFORE_ROOT_ADOPTION'
for x in json.loads((O/'HANDBACK_MANIFEST.json').read_text())['records']:assert rec(R/x['path'])==x
old=json.loads((F/'regression/SOURCE101.json').read_text());assert all(rec(R/x['path'])==x for x in old['records'])
proposal=json.loads((A/'root_adoption_proposal/PROPOSAL.json').read_text());assert len(proposal['records'])==2
D.mkdir();rows=[]
for x in proposal['records']:
 p=R/x['root_before']['path'];q=R/x['proposed']['path'];assert rec(p)==x['root_before'] and rec(q)==x['proposed'];b=p.read_bytes();n=q.read_bytes();assert n.replace(x['new_literal'].encode(),x['old_literal'].encode())==b
 archive=D/(p.name+'.before');archive.write_bytes(b);p.write_bytes(n);after=rec(p);assert after['sha256']==x['proposed']['sha256'];rows.append(dict(before=x['root_before'],after=after,before_archive=rec(archive),inverse_byte_exact=True,old_literal=x['old_literal'],new_literal=x['new_literal']))
new=[rec(R/x['path']) for x in old['records']];changed=[dict(before=x,after=y) for x,y in zip(old['records'],new) if x!=y];assert {x['before']['path'] for x in changed}=={x['before']['path'] for x in rows}
sdc=R/'efinity/m5c_fusion_i3/Ti60_Demo_I3.sdc';xml=R/'efinity/m5c_fusion_i3/Ti60_Demo.xml';P=A/'mirror/efinity/m5c_fusion_i3';assert sdc.read_bytes()==(P/sdc.name).read_bytes();norm=lambda b:re.sub(br'last_change="[0-9]+"',b'last_change="NORMALIZED_METADATA"',b);assert norm(xml.read_bytes())==norm((P/xml.name).read_bytes())
(D/'SOURCE101_AFTER_ADOPTION.json').write_text(json.dumps(dict(records=new,historical_source101=rec(F/'regression/SOURCE101.json'),changed=changed,compiled_RTL_changes=[],boundary='New configuration version after all current regressions and offline physical/artifact seal. Historical simulation SOURCE101 remains immutable. Only SDC canonical camera CLK and XML synthesis mode changed; compiled RTL bytes remain identical.'),indent=2))
(D/'APPLICATION_RECEIPT.json').write_text(json.dumps(dict(status='APPLIED_EXACT_TWO_APPROVED_CONFIGURATION_CHANGES',changes=rows,freeze=rec(F/'WORK_AREA_OFFLINE_BIT_AND_ADOPTION_FREEZE.md'),proposal=rec(A/'root_adoption_proposal/PROPOSAL.json'),artifact_manifest=rec(O/'HANDBACK_MANIFEST.json'),source_after=rec(D/'SOURCE101_AFTER_ADOPTION.json'),generator=rec(Path(__file__)),root_settings_changed=False),indent=2));print('ADOPTED_EXACT_TWO',rec(D/'APPLICATION_RECEIPT.json'))
