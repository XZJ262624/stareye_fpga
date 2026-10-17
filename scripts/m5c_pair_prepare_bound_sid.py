from pathlib import Path
import runpy,json,hashlib
R=Path.cwd();O=R/'reports/m5c_pair_capture_20261016';D=O/'physical_discovery_183700';candidate=D/'PAIR_EXACT_CANDIDATE_SID.sdc'
assert json.loads((D/'PAIR_EXACT_SID_PLAN.json').read_text())['groups']==68
runpy.run_path(str(R/'scripts/m5c_pair_prepare_map.py'),run_name='__main__');F=Path(json.loads((O/'LATEST_PHYSICAL.json').read_text())['directory']);p=F/'mirror/efinity/m5c_pair_diag_i3/Ti60_Demo_I3.sdc';before=p.read_bytes();p.write_bytes(candidate.read_bytes())
def rec(q):b=q.read_bytes();return dict(path=q.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
m=json.loads((F/'COPY_MANIFEST.json').read_text())
for row in m['records']:
 if row['copy']['path']==p.relative_to(R).as_posix():row['original_project_source']=row['source'];row['source']=rec(candidate);row['copy']=rec(p);row['configuration_change']=dict(kind='EXACT64SID_BUNDLE5NS',plan=rec(D/'PAIR_EXACT_SID_PLAN.json'))
(F/'COPY_MANIFEST.json').write_text(json.dumps(m,indent=2));(F/'SDC_BEFORE.sdc').write_bytes(before);(F/'BOUND_DERIVATION.json').write_text(json.dumps(dict(candidate=rec(candidate),plan=rec(D/'PAIR_EXACT_SID_PLAN.json'),root_sdc_unchanged=True,source_rtl_unchanged=True),indent=2));print('BOUND',F)
