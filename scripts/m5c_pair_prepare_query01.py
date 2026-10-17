from pathlib import Path
import sys,json,hashlib,re,difflib
R=Path.cwd();F=Path(sys.argv[1]).resolve();O=R/'reports/m5c_shadow_stats_20261016/physical_133645'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
g=json.loads((F/'G1_MAPPED_OBJECTS.json').read_text());assert g['status']=='PASS_EXACT_CURRENT_OBJECTS_AND_FEATURE_PRESENCE'
groups=g['groups'];dest=[x for x in groups if x['name'].endswith('_destination')];assert len(groups)==68 and len(dest)==29 and sum(x['count'] for x in dest)==1638
parent=O/'queries/01_bundle_global_Dsetup.tcl';old=parent.read_text();head=old[:old.index('set m5b1_video_camera_fifo_rgs1_source')];t=[head];by={x['name']:x for x in groups}
for x in groups:
 t.append('set '+x['name']+' [exact '+x['name']+' {\n')
 for pin in x['pins']:t.append(' {^'+re.escape(pin)+'$}\n')
 t.append('}]\n')
ix=0
for d in dest:
 source=d['name'].removesuffix('_destination')+'_source';assert source in by
 for mode in ['setup','hold']:
  ix+=1;t.append(f'puts "FRESH_REPORT_BEGIN 01_bundle_global_Dsetup {ix}"\nreport_timing -{mode} -from ${source} -to ${d["name"]} -npaths {len(d["pins"])} -nworst 1 -detail full_path -file bundle_{d["name"]}_{mode}.rpt\nputs "FRESH_REPORT_END 01_bundle_global_Dsetup {ix}"\n')
tail=old[old.index('puts "FRESH_REPORT_BEGIN 01_bundle_global_Dsetup 51"'):]
tail=re.sub(r'(FRESH_REPORT_(?:BEGIN|END) 01_bundle_global_Dsetup )(51|52|53)(")',lambda m:m[1]+str(int(m[2])+8)+m[3],tail);t.append(tail)
Q=F/'queries';Q.mkdir(exist_ok=True);q=Q/parent.name;assert not q.exists();q.write_text(''.join(t))
(F/'QUERY_EXPECTATIONS.json').write_text(json.dumps(dict(groups=groups,selector_gate=rec(F/'G1_MAPPED_OBJECTS.json'),boundary='Actual current29 bundled groups1638 endpoints,68exactsets. No previous physical timing borrowed. Ordinary D/CE/SR and FIFO/RAM addresses remain normal timed.'),indent=2))
(F/'QUERY_DERIVATION.json').write_text(json.dumps(dict(queries=[dict(name='01_bundle_global_Dsetup',query=rec(q),reports=61)],parent=rec(parent),generator=rec(Path(__file__)),scope='PREPARED_NOT_RUN: actual I3, per-endpoint5ns CQ+data/skew, nonnegative normal setup/hold, internal0/0/0; subsequent full controls and missing-object classifications required.'),indent=2))
p=O/'run_query01.py';s=p.read_text();n=s.replace('efinity/m5c_fusion_i3','efinity/m5c_pair_diag_i3').replace("len(bundle)==25 and sum(x['count'] for x in bundle)==1552","len(bundle)==29 and sum(x['count'] for x in bundle)==1638")
q=F/'run_query01.py';assert not q.exists();q.write_text(n);(F/'QUERY_RUNNER_DIFF.txt').write_text(''.join(difflib.unified_diff(s.splitlines(True),n.splitlines(True))))
print('PREPARED_NOT_RUN',len(dest),sum(x['count'] for x in dest))
