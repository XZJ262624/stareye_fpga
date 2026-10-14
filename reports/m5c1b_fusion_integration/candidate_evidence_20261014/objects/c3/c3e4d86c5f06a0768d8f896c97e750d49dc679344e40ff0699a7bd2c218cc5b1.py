from pathlib import Path
import json,hashlib,subprocess,sys,time
F=Path(__file__).resolve().parent;R=F.parents[2];P=F/'mirror/efinity/m5c_fusion_i3';D=F/'mapped_inventory';W=F/'audit_stage';W.mkdir(exist_ok=False)
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def run(label,cmd):
 with (W/(label+'.log')).open('wb') as f:p=subprocess.run([str(x) for x in cmd],stdout=f,stderr=subprocess.STDOUT)
 assert p.returncode==0,(label,p.returncode)
mr=json.loads((F/'map/RESULT.json').read_text());assert mr['status']=='PASS_STAGE'
for x in json.loads((R/mr['output_archive']['path']).read_text())['records']:
 assert rec(R/x['archive']['path'])==x['archive']
 if x['original']['path'].startswith(P.relative_to(R).as_posix()+'/'):assert rec(R/x['original']['path'])==x['original']
run('selectors',[sys.executable,'-B',F/'check_exact_selectors.py',P/'outflow/Ti60_Demo.map.v','EXACT_SELECTOR_GATE.json'])
run('inventory',[sys.executable,'-B',F/'audit_current.py','mapped_inventory'])
run('rgb_luts',[sys.executable,'-B',F/'rgb_lut_paths_v2.py',P/'outflow/Ti60_Demo.map.v','mapped_inventory'])
a=json.loads((D/'CANDIDATE_PIN_MANIFEST.json').read_text());b=json.loads((D/'CDC_STRUCTURAL_AUDIT.json').read_text());p=json.loads((D/'RGB_LUT_PATH_WITNESS.json').read_text());l=json.loads((D/'LOGICAL_BIT_DRIVERS.json').read_text())['logical'];rr=json.loads((D/'RGB_REFACTORED_CONE.json').read_text());g=json.loads((F/'EXACT_SELECTOR_GATE.json').read_text())
assert not a['unclassified'] and not a['bad_physical_chains'] and not b['unknown_internal'];assert all(len(v)==16 for v in p['sources'].values())
for k in ['offered_SID','capture_reply_SID','reader_nonce_alias','reference_SID','display_dsession','frame_cookie','UI_active_SID']+[f'row_cookie{i}' for i in range(4)]:assert l[k]['state_counts']=={'ACTIVE':64},k
assert len(rr['key_cells']['u_fusion_display/session'])==64
old=R/'reports/m5c1b_fusion_integration/raster_counter_physical_20261013_061800/cdc_bound/NEW_CDC_CONSTRAINTS_PROPOSED.sdc';assert (D/'NEW_CDC_CONSTRAINTS_PROPOSED.sdc').read_bytes()==old.read_bytes(),'New mapped group structure changed; no silent SDC update'
assert g['status']=='PASS_EXACT_MAPPED_SELECTORS' and len(g['groups'])==56
(F/'MAPPED_AUDIT_GATE.json').write_text(json.dumps(dict(status='PASS_STRUCTURAL_EXACT_SELECTORS',map_sha256=g['map_sha256'],sdc_sha256=g['sdc_sha256'],selector_groups=56,unclassified=0,bad_physical_chains=0,unknown_internal=0,RGB_actual_destinations=16,reference_supplement=rec(old),records=[rec(q) for q in sorted(D.glob('*')) if q.is_file()],boundary='Actual fresh-map structure only, not physical timing PASS; no SDC change.'),indent=2))
print('MAPPED_AUDIT PASS 56 exactsets/16 RGB/nonconstant predicates',flush=True)
for stage in ['interface','place','route']:
 run(stage,[sys.executable,'-B',F/'run_stage.py',stage]);r=json.loads((F/stage/'RESULT.json').read_text());assert r['status']=='PASS_STAGE';print('PASSED',stage,r.get('resources'),flush=True)
 if stage=='place':run('native_selectors',[sys.executable,'-B',F/'verify_native_selectors.py'])
print('ROUTE_COMPLETE_FROZEN_PENDING_SEGMENTED_STA',flush=True)
