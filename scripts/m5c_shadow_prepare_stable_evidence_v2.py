from pathlib import Path
import json,hashlib,gzip
R=Path(__file__).resolve().parents[1];A=R/'reports/m5c_shadow_stats_20261016';O=A/'candidate_evidence';O.mkdir(exist_ok=True)
names=['bridge_fixture_v2','bridge_regression','bridge_regression_v2','cookie_alias','coupled_20261016_133316','decoder_compatibility','decoder_compatibility_v2','differential_20261016_135855','differential_20261016_135931','differential_fixture','differential_fixture_v2','header_fixture','headercoupled_20261016_140101','integration_sensitivities','observer_20261016_133248','observer_20261016_133522','row_sensitivities','row_sensitivities_v2','rows_133043','recovery_regression']
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
selected=[];excluded=[]
for name in names:
 for p in sorted((A/name).rglob('*')):
  if not p.is_file():continue
  rel=p.relative_to(A/name)
  if any(x in ['work','__pycache__'] for x in rel.parts) or p.name in ['HEARTBEAT.json','transcript'] or p.suffix in ['.wlf','.vcd','.pyc','.db']:
   excluded.append(p.relative_to(R).as_posix());continue
  assert p.suffix not in ['.bit','.bin','.vdb','.lbf','.troutingtraces'],p
  assert p.stat().st_size<30_000_000,(p,'unexpected large short-evidence file')
  selected.append(p)
selected += [R/x['snapshot'] for x in json.loads((A/'BASELINE.json').read_bytes())['technical']]
for n in ['TECHNICAL_BASELINE.json','IMPLEMENTATION_DERIVATION.json','ROW_END_RECONCILIATION.json','OBSERVER_NEGATIVE_ACTUAL_WORDS.json']:
 p=A/n
 if p.exists():selected.append(p)
mapping=[];objects={}
for p in sorted(set(selected)):
 x=rec(p);b=p.read_bytes();q=O/'objects'/x['sha256'][:2]/(x['sha256']+'.gz');q.parent.mkdir(parents=True,exist_ok=True)
 if not q.exists():q.write_bytes(gzip.compress(b,compresslevel=9,mtime=0))
 assert gzip.decompress(q.read_bytes())==b
 z=rec(q);objects[z['path']]=z;mapping.append(dict(original=x,object=z))
direct=[R/p for p in ['rtl/m5c_fusion/m5c_row_fusion.sv','rtl/m5c_fusion/m5c_fusion_display.sv','rtl/m5c_diagnostics/m5c_diag_observer_v3.sv','efinity/m5c_fusion_i3/example_top.v','efinity/m5c_fusion_i3/Ti60_Demo.xml','scripts/.gitattributes','reports/m5c_shadow_stats_20261016/.gitattributes']]
direct+=sorted((R/'scripts').glob('m5c_shadow_*.py'));direct+=sorted((R/'tb/m5c_diagnostics').glob('tb_shadow_*.sv'))
out=dict(status='STABLE_SHORT_EVIDENCE_ONLY_FINAL_SCOPE_NOT_FROZEN',mapping=mapping,objects=list(objects.values()),technical_direct=[rec(p) for p in direct],selected_roots=names,excluded_runtime=excluded,boundary='Exact selected completed short cases and their original failure revisions. No active system/physical outputs included yet. Work review directory, root management/M3, user captures, compiled libraries, maps/DB/bit excluded. Dependency completeness and final candidate scope remain pending; this is not a final reproduction claim.',generator=rec(Path(__file__)))
p=O/'STABLE_OBJECTS_V2.json';assert not p.exists();p.write_text(json.dumps(out,indent=2))
print('STABLE_PACK',len(mapping),len(objects),sum(x['bytes'] for x in objects.values()),rec(p))
