from pathlib import Path
import json,hashlib,runpy
R=Path.cwd();base=R/'reports/m5c_pair_capture_20261016';old=base/'physical_discovery_175821';candidate=old/'PAIR_EXACT_CANDIDATE_V2.sdc'
runpy.run_path(str(R/'scripts/m5c_pair_prepare_map.py'),run_name='__main__');F=Path(json.loads((base/'LATEST_PHYSICAL.json').read_text())['directory']);P=F/'mirror/efinity/m5c_pair_diag_i3';sdc=P/'Ti60_Demo_I3.sdc';before=sdc.read_bytes();sdc.write_bytes(candidate.read_bytes())
def rec(p):b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
m=json.loads((F/'COPY_MANIFEST.json').read_text())
for row in m['records']:
 if row['copy']['path']==sdc.relative_to(R).as_posix():row['original_project_source']=row['source'];row['source']=rec(candidate);row['copy']=rec(sdc);row['configuration_change']=dict(kind='APPROVED_EXACT_CANONICAL_AND_NEW_PAIR_CDC',plan=rec(old/'PAIR_EXACT_PLAN_V2.json'))
(F/'COPY_MANIFEST.json').write_text(json.dumps(m,indent=2));(F/'SDC_BEFORE.sdc').write_bytes(before);(F/'BOUND_DERIVATION.json').write_text(json.dumps(dict(status='NEW_BOUND_MAP_REQUIRED',candidate=rec(candidate),source_map=rec(old/'mirror/efinity/m5c_pair_diag_i3/outflow/Ti60_Demo.map.v'),local_alias=rec(old/'LOCAL_ALIAS_PROPOSAL.json'),plan=rec(old/'PAIR_EXACT_PLAN_V2.json'),root_sdc_unchanged=True,rtl_unchanged=True),indent=2));print('BOUND',F)
