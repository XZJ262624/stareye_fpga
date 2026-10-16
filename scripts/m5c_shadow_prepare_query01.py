from pathlib import Path
import sys,json,hashlib,re,difflib
R=Path(__file__).resolve().parents[1];B=Path(sys.argv[1]).resolve();O=R/'reports/m5c1b_fusion_integration/review_fix_99642712/resource_area_bound'
assert B.is_relative_to(R/'reports/m5c_shadow_stats_20261016')
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
g=json.loads((B/'EXACT_SELECTOR_GATE.json').read_text());assert g['status']=='PASS_EXACT_MAPPED_SELECTORS'
groups=g['groups'];assert len(groups)==60
dest=[x for x in groups if x['name'].endswith('_destination')];assert len(dest)==25 and sum(len(x['pins']) for x in dest)==1552
by={x['name']:x for x in groups};name='01_bundle_global_Dsetup'
parent=O/'queries'/f'{name}.tcl';old=parent.read_text();head=old[:old.index('set m5b1_video_camera_fifo_rgs1_source')]
t=[head]
for x in groups:
 t.append('set '+x['name']+' [exact '+x['name']+' {\n')
 for p in x['pins']:t.append(' {^'+re.escape(p)+'$}\n')
 t.append('}]\n')
ix=0
for d in dest:
 source=d['name'].removesuffix('_destination')+'_source';assert source in by
 for mode in ['setup','hold']:
  ix+=1;t.extend([f'puts "FRESH_REPORT_BEGIN {name} {ix}"\n',f'report_timing -{mode} -from ${source} -to ${d["name"]} -npaths {len(d["pins"])} -nworst 1 -detail full_path -file bundle_{d["name"]}_{mode}.rpt\n',f'puts "FRESH_REPORT_END {name} {ix}"\n'])
tail=old[old.index('puts "FRESH_REPORT_BEGIN 01_bundle_global_Dsetup 49"'):]
tail=re.sub(r'(FRESH_REPORT_(?:BEGIN|END) 01_bundle_global_Dsetup )(49|50|51)(")',lambda m:m[1]+str(int(m[2])+2)+m[3],tail)
t.append(tail);Q=B/'queries';Q.mkdir(exist_ok=True);q=Q/parent.name;assert not q.exists();q.write_text(''.join(t))
(B/'QUERY_EXPECTATIONS.json').write_text(json.dumps(dict(groups=groups,selector_gate=rec(B/'EXACT_SELECTOR_GATE.json'),boundary='Current mapped/native-bound 25 bundled groups,1552 destinations; new64 physical RAM WDATA and one existing held valid bit included. Ordinary CE/SR/address timing not cut.'),indent=2))
(B/'QUERY_DERIVATION.json').write_text(json.dumps(dict(queries=[dict(name=name,query=rec(q),reports=53)],parent=rec(parent),generator=rec(Path(__file__)),selector_gate=rec(B/'EXACT_SELECTOR_GATE.json'),scope='Prepared only. Fresh actual I3 per-endpoint CQ+data/skew<=5ns; normal setup/hold>=0; internal check0/0/0. Later D/CE/SR/RAM/DSP/control/connection reconciliation mandatory.'),indent=2))
src=O/'run_query01.py';s=src.read_text();out=s.replace('R=F.parents[3]','R=F.parents[2]').replace('assert len(bundle)==24 and sum(x[\'count\'] for x in bundle)==1487','assert len(bundle)==25 and sum(x[\'count\'] for x in bundle)==1552')
assert out!=s and '==1487' not in out
dst=B/'run_query01.py';assert not dst.exists();dst.write_text(out)
diff=B/'QUERY01_RUNNER_DIFF.txt';diff.write_text(''.join(difflib.unified_diff(s.splitlines(True),out.splitlines(True),fromfile=str(src),tofile=str(dst))))
(B/'QUERY01_RUNNER_DERIVATION.json').write_text(json.dumps(dict(records=[rec(src),rec(dst),rec(diff)],changes=['workspace ancestor only','actual25 bundled groups1552 endpoints, rather than historical24/1487; physical thresholds and all validation unchanged']),indent=2))
print('PREPARED_NOT_EXECUTED',len(dest),sum(len(x['pins']) for x in dest))
