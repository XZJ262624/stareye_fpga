from pathlib import Path
import json,hashlib
A=Path(__file__).resolve().parent;F=A.parent;R=A.parents[3];P=A/'mirror/efinity/m5c_fusion_i3'
rows={};checks=0;history=[]
def rec(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b)
 return dict(path=p.relative_to(R).as_posix(),bytes=p.stat().st_size,sha256=h.hexdigest())
def add(x):
 global checks
 assert rec(R/x['path'])==x,x['path'];checks+=1
 if x['path'] in rows:assert rows[x['path']]==x
 rows[x['path']]=x
tim=json.loads((A/'TIMING_CURRENT_AUDIT.json').read_text());assert tim['status']=='PASS_ACTUAL_FRESH_I3_PENDING_FINAL_ARCHIVE_PROTECTION_SEAL'
back=json.loads((A/'BACKEND_CONTROL_TIMING_AUDIT.json').read_text());assert back['status']=='PASS_CURRENT_BACKEND6808FF_D_CE_SR_PHYSICAL_COVERAGE'
extra=json.loads((A/'CLOCK_RAM_FINAL_COMPLETION.json').read_text());assert extra['status']=='PASS_CURRENT_RAM_FULL_MAPPING_AND_ACTUAL_CLOCK_PAIR_PATHS'
assert json.loads((A/'BACKEND_QUERY_STATE.json').read_text())['status']=='EXECUTED_PENDING_PIN_RECONCILIATION'
for x in json.loads((F/'regression/SOURCE101.json').read_text())['records']:add(x)
baseline=json.loads((A/'PROTECTION_BASELINE.json').read_text())['records'];d1={x['path']:x for x in json.loads((F/'work_management_2239/MANAGEMENT_DELTA.json').read_text())['records']};d2={x['path']:x for x in json.loads((F/'work_management_2245/MANAGEMENT_DELTA.json').read_text())['records']}
assert set(d1)==set(d2);protection=[]
for x in baseline:
 actual=rec(R/x['path'])
 if x['path'] in d1:
  one=d1[x['path']];two=d2[x['path']]
  assert x['sha256']==one['before']['sha256'] and x['bytes']==one['before']['bytes']
  assert one['after']['sha256']==two['before_sha256'] and actual['sha256']==two['after_sha256']
  protection.append(dict(before=x,after=actual,classification='EXACT_WORK_MANAGEMENT_DELTA_CHAIN'))
 else:assert actual==x,x['path']
 add(actual)
stages=[]
for name in ['map','interface','place','route','sta_01_bundle_global_Dsetup','sta_02_scoped_D_CE_SR_RAM_DSP_IO','sta_03_connections','sta_04_DSP_config','sta_05_clock_pairs','sta_06_backend_cleanup_controls','sta_07_backend_connections']:
 w=A/name;r=json.loads((w/'RESULT.json').read_text());assert r['exit']==0 and not r['timeout']
 if name.startswith('sta_'):assert r['source_db_unchanged'] and r['status']=='PASS_QUERY_EXECUTION_PENDING_RECONCILIATION'
 else:assert r['source_equivalent'] and r['production_unchanged'] and not r['forbidden'] and r['status']=='PASS_STAGE'
 stages.append(dict(stage=name,result=rec(w/'RESULT.json')))
 for label in ['PRE_NATIVE_ARCHIVE','POST_NATIVE_ARCHIVE']:
  ap=w/(label+'.json');add(rec(ap))
  for x in json.loads(ap.read_text())['records']:
   add(x['archive']);history.append(dict(stage=name,phase=label,original=x['original'],archive=x['archive']))
# Final live bytes are a distinct version; previous stages resolve through immutable archives above.
for p in P.rglob('*'):
 if p.is_file():add(rec(p))
for p in A.rglob('*'):
 if p.is_file() and not any(t in p.relative_to(A).parts for t in ['mirror','content_archive']):add(rec(p))
for n in ['WORK_AREA_ROUTE_STA_FREEZE.md','WORK_NEXT_EVIDENCE_REQUIREMENTS.md','work_management_2239/MANAGEMENT_DELTA.json','work_management_2245/MANAGEMENT_DELTA.json']:add(rec(F/n))
for p in P.rglob('*'):
 if p.is_file():assert not (p.name.endswith(('.bit','.bit.bin','.hex','.hex.bin'))),str(p)
for n,obj in [('PHYSICAL_STAGE_HISTORY.json',dict(records=history)),('PHYSICAL_PROTECTION_FINAL.json',dict(records_checked=len(baseline),unchanged=len(baseline)-len(protection),management_deltas=protection,technical101_unchanged=True))]:
 p=A/n;assert not p.exists();p.write_text(json.dumps(obj,indent=2));add(rec(p))
result=dict(status='PASS_FRESH_AREA_I3_ROUTE_STA_PENDING_WORK_REVIEW_NO_BIT',resources=json.loads((A/'route/RESULT.json').read_text())['resources'],timing=rec(A/'TIMING_CURRENT_AUDIT.json'),backend_coverage=rec(A/'BACKEND_CONTROL_TIMING_AUDIT_AUDIT.json') if (A/'BACKEND_CONTROL_TIMING_AUDIT_AUDIT.json').exists() else rec(A/'BACKEND_CONTROL_TIMING_AUDIT.json'),stages=stages,checks_before_handback=checks,history=rec(A/'PHYSICAL_STAGE_HISTORY.json'),protection=rec(A/'PHYSICAL_PROTECTION_FINAL.json'),boundary='Area seed1 actual I3 only; no cross-PVT or hardware claim. Narrow positive hold remains material. External7/135 boundary, explicit vendor constants, exact current RAM physical mapping differences and opaque-IP limitations retained. No root SDC/XML adoption, programming artifact or Git operation. All historical stage bytes resolve to immutable archives, never to later live database bytes.')
p=A/'PHYSICAL_HANDBACK.json';assert not p.exists();p.write_text(json.dumps(result,indent=2));add(rec(p));p=A/'PHYSICAL_HANDBACK_MANIFEST.json';assert not p.exists();p.write_text(json.dumps(dict(records=list(rows.values()),checks_including_handback=checks),indent=2));print(result['status'],len(rows),checks,rec(p))
