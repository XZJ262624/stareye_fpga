from pathlib import Path
import json,hashlib,datetime,shutil,xml.etree.ElementTree as ET
R=Path(__file__).resolve().parents[1];P=R/'reports/m5c_diagnostics/stage2_resource_bound_v3_20261015_181411'
O=R/'reports/m5c_shadow_stats_20261016'/('physical_'+datetime.datetime.now().strftime('%H%M%S'));C=O/'mirror';C.mkdir(parents=True)
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
assert json.loads((R/'reports/m5c_shadow_stats_20261016/coupled_20261016_133316/SOFTWARE_ORACLE.json').read_text())['status']=='PASS_COMPLETE_324B_COUPLED'
assert json.loads((R/'reports/m5c_shadow_stats_20261016/observer_20261016_133522/SUMMARY.json').read_text())['all_pass']
paths=[x['copy']['path'].split('/mirror/')[1].replace('m5c_diag_observer_v2.sv','m5c_diag_observer_v3.sv') for x in json.loads((P/'COPY_MANIFEST.json').read_text())['records']];assert len(paths)==len(set(paths))==104
rows=[];settings=[]
for name in paths:
 src=R/name;dst=C/name;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(src,dst)
 if src.name=='settings.json':
  before=json.loads(src.read_text());after=json.loads(src.read_text());i=before['args'].index('--base_path')+1;old=Path(before['args'][i]);assert old.is_relative_to(R)
  after['args'][i]=str(C/old.relative_to(R));dst.write_text(json.dumps(after,indent=2));check=json.loads(dst.read_text());check['args'][i]=before['args'][i];assert check==before;settings.append(dict(path=name,before=before['args'][i],after=after['args'][i]))
 rows.append(dict(source=rec(src),copy=rec(dst)))
project=C/'efinity/m5c_fusion_i3';refs=[]
for n in ET.parse(project/'Ti60_Demo.xml').iter():
 if n.tag.endswith('design_file'):
  q=(project/n.attrib['name']).resolve();assert q.is_relative_to(C) and q.is_file();refs.append(rec(q))
assert len(settings)==11
(O/'COPY_MANIFEST.json').write_text(json.dumps(dict(records=rows),indent=2));(O/'PREFLIGHT.json').write_text(json.dumps(dict(status='PASS_INPUT_ADMISSION_ONLY',inputs=104,source_entries=refs,settings_rebases=settings,scope='Fresh schema2 map only. Current native aliases/CDC/physical source identity must be reaudited; no prior qualification inherited.'),indent=2))
s=(P/'run_stage.py').read_text().replace('xlr<=48640','xlr<=51680');(O/'run_stage.py').write_text(s)
(O/'DERIVATION.json').write_text(json.dumps(dict(parent=rec(P/'run_stage.py'),derived=rec(O/'run_stage.py'),change='85percent XLR policy51680; otherwise unchanged discovery-only stage/archive/inputs gate',production_copy_records=104),indent=2));print(O,flush=True)
