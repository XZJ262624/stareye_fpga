from pathlib import Path
import json,hashlib,shutil,datetime,xml.etree.ElementTree as ET
R=Path(__file__).resolve().parents[1];P=R/'reports/m5c1b_fusion_integration/review_fix_99642712/resource_area_bound';O=R/'reports/m5c_diagnostics'/('stage2_resource_'+datetime.datetime.now().strftime('%Y%m%d_%H%M%S'));C=O/'mirror';C.mkdir(parents=True)
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
paths=[x['source']['path'] for x in json.loads((P/'COPY_MANIFEST.json').read_text())['records']]
paths+=['rtl/m5c_diagnostics/'+n for n in ['m5c_diag_observer_v2.sv','m5c_diag_record_bridge.sv','m5c_diag_slot_guard.sv']]
assert len(paths)==len(set(paths))==104
rows=[];settings=[]
for name in paths:
 src=R/name;dst=C/name;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(src,dst)
 if src.name=='settings.json':
  before=json.loads(src.read_text());after=dict(before);assert 'base_path' in before
  after['base_path']=str(dst.parent);dst.write_text(json.dumps(after,indent=2));check=json.loads(dst.read_text());check['base_path']=before['base_path'];assert check==before
  settings.append(dict(path=name,original_base_path=before['base_path'],mirror_base_path=after['base_path']))
 rows.append(dict(source=rec(src),copy=rec(dst)))
project=C/'efinity/m5c_fusion_i3';xml=ET.parse(project/'Ti60_Demo.xml');refs=[]
for n in xml.iter():
 if n.tag.endswith('design_file'):
  p=(project/n.attrib['name']).resolve();assert p.is_relative_to(C) and p.is_file(),str(p);refs.append(rec(p))
assert len(settings)==11
(O/'COPY_MANIFEST.json').write_text(json.dumps(dict(records=rows),indent=2));(O/'PREFLIGHT.json').write_text(json.dumps(dict(status='PASS_INPUT_ADMISSION_ONLY',inputs=104,source_entries=refs,settings_rebases=settings,scope='Fresh discovery map only until current finite64 and focused gate satisfied; old SDC retained for discovery, new observer CDC not qualified; no inherited timing/resource PASS.'),indent=2))
s=(P/'run_stage_v2.py').read_text().replace('R=F.parents[3]','R=F.parents[2]');s=s.replace("assert stage in ['map','interface','place','route']","assert stage=='map'")
(O/'run_stage.py').write_text(s)
(O/'DERIVATION.json').write_text(json.dumps(dict(parent_runner=rec(P/'run_stage_v2.py'),derived_runner=rec(O/'run_stage.py'),differences=['Root path depth','Restrict invocation to discovery map only'],freeze=rec(R/'reports/m5c_diagnostics/STAGE2_WORK_FREEZE.md')),indent=2));print(O)
