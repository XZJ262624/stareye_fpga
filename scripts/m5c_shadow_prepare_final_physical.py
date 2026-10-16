from pathlib import Path
import hashlib,json,difflib
R=Path(__file__).resolve().parents[1]
A=R/'reports/m5c_shadow_stats_20261016/physical_133645'
O=R/'reports/m5c_diagnostics/stage2_resource_bound_v3_20261015_181411'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
rows=[]
for name in ['seal_physical_current.py','prepare_offline_plan_current.py','prepare_offline_artifact_current.py']:
 p=O/name;s=p.read_text();t=s
 if name=='seal_physical_current.py':
  t=t.replace("load('CURRENT_QUERY_CHAIN_STATE.json','ALL7_EXECUTED_PENDING_FULL_RECONCILIATION')\nload('SUPPLEMENT_CHAIN_STATE.json','EXECUTED_PENDING_COMPLETE_CONTROL_RECONCILIATION')", "load('CURRENT_QUERY_CHAIN_STATE.json','ALL9_EXECUTED_PENDING_FULL_RECONCILIATION')\nload('ROW_SHADOW_TIMING_AUDIT.json','PASS_CURRENT_88_SHADOW_FF_264_PINS_ALL_SETUP_HOLD_NORMALLY_TIMED')")
  t=t.replace("policy=load('POLICY_REASSESSMENT_85.json','PASS_RESOURCE_POLICY85_ONLY')", "# Current build used the already-frozen 85% policy at every stage; no historical policy reassessment.")
  t=t.replace("elif name=='place':assert z['status']=='FAIL_STAGE_BLOCK_DESCENDANTS' and z['source_equivalent'] and z['production_unchanged'] and not z['forbidden']", "elif name=='place':assert z['status']=='PASS_STAGE' and z['resources']['pass'] and z['source_equivalent'] and z['production_unchanged'] and not z['forbidden']")
  t=t.replace('policy_change_not_resource_optimization=True','policy_change_not_resource_optimization=False')
 elif name=='prepare_offline_artifact_current.py':
  t=t.replace("'stage2_offline_parent_'", "'offline_shadow_'")
 d=A/(name.removesuffix('.py')+'_shadow.py');assert not d.exists();d.write_text(t)
 rows.append(dict(parent=rec(p),derived=rec(d),diff=''.join(difflib.unified_diff(s.splitlines(True),t.splitlines(True)))))
p=A/'FINAL_PHYSICAL_HELPER_DERIVATION.json';assert not p.exists()
p.write_text(json.dumps(dict(status='PREPARED_NOT_EXECUTED',records=rows,generator=rec(Path(__file__)),boundary='Current ALL9 chain, current PASS placement, explicit row-shadow normal timing. All qualification gates remain. No source/constraint changes or conversion executed.'),indent=2))
print('PREPARED_FINAL_PHYSICAL_HELPERS',len(rows))
