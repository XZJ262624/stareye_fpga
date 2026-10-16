"""Exact original text for read/glob/grep-only review; generated summaries labeled."""
from pathlib import Path
import hashlib,json,shutil
R=Path(__file__).resolve().parents[1];A=R/'reports/m5c_shadow_stats_20261016';O=A/'candidate_evidence';D=O/'direct_review';P=A/'physical_133645';W=A/'system_134939/run'
def rec(p):
 h=hashlib.sha256();n=0
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b);n+=len(b)
 return dict(path=p.relative_to(R).as_posix(),bytes=n,sha256=h.hexdigest())
def main():
 assert json.loads((W/'final_seal/GATE_HANDBACK.json').read_bytes())['status']=='PASS_CURRENT_SCHEMA2_SYSTEM_FINAL_SEALED'
 assert not D.exists();D.mkdir();paths=set()
 for n in ['FULL_PHYSICAL_QUALIFICATION.json','TIMING_CURRENT_AUDIT.json','COMPLETE_CONTROL_TIMING_AUDIT.json','ROW_SHADOW_TIMING_AUDIT.json','CLOCK_RAM_FINAL_COMPLETION.json','NATIVE_SELECTOR_GATE.json','CURRENT_ROUTED_RAM_DATA_PIN_CHECK.json','CURRENT_BUNDLED_PRELIMINARY.json','MAPPED_AUDIT_GATE_V2.json']:
  paths.add(P/n)
 for n in ['RESULT.json','SOFTWARE_DIAGNOSTIC_SYSTEM.json','end_events.txt','diag_events.txt','sim.log','completion_gate/software.log','strict_schema2_postrun/GATE_HANDBACK.json','final_seal/GATE_HANDBACK.json','original_types_view/END_SOFTWARE_ORACLE.json','original_types_view/SOFTWARE_UART_ORACLE.json']:
  paths.add(W/n)
 for n in ['TECHNICAL_BASELINE.json','BASELINE_FIXED_BLOB_PROOF.json','IMPLEMENTATION_DERIVATION.json','OBSERVER_NEGATIVE_ACTUAL_WORDS.json','ROW_END_RECONCILIATION.json','SYSTEM_WATCHDOG_METADATA_RECONCILIATION.json','UNCHANGED_TRANSPORT_INHERITANCE.json','recovery_regression/GATE_HANDBACK.json','differential_20261016_135931/software_closure/GATE_HANDBACK.json','headercoupled_20261016_140101/STRICT_SCHEMA2_DECODE.json']:
  paths.add(A/n)
 # Each selected short run keeps its original RESULT and compile/simulation log.
 pack=json.loads((O/'STABLE_OBJECTS_V2.json').read_bytes())
 for m in pack['mapping']:
  p=R/m['original']['path']
  if p.name in ['RESULT.json','sim.log','compile.log','step1.log','step2.log'] and m['original']['bytes']<=2_000_000:
   assert rec(p)==m['original'];paths.add(p)
 # Large all_D_setup stays losslessly compressed; B does not review its full contents.
 for p in (P/'mirror/efinity/m5c_fusion_i3/outflow').glob('*.rpt'):
  if p.name.startswith('Ti60_Demo.'):continue
  if p.stat().st_size<=2_000_000:paths.add(p)
 rows=[]
 for i,p in enumerate(sorted(paths)):
  x=rec(p);q=D/(f'{i:04d}_'+p.name);shutil.copyfile(p,q);z=rec(q)
  assert (x['bytes'],x['sha256'])==(z['bytes'],z['sha256'])
  rows.append(dict(original=x,direct=z,transport='ORIGINAL_BYTES_UNCHANGED',meaning='Original native log/report where named; JSON audit/software files are original generated audit results, not native raw timing.'))
 (D/'INDEX.json').write_text(json.dumps(dict(status='PASS_BYTE_EXACT_DIRECT_TEXT_SUBSET',records=rows,boundary='Read/glob/grep accessible original text. This subset does not contain complete netlist/DB or every large report; full selected report objects remain separately bound. Derived WORK_REVIEW_GATE/KNOWN_LIMITS are navigation and interpretation, not raw evidence.'),indent=2));print('DIRECT_TEXT',len(rows),sum(x['direct']['bytes'] for x in rows))
if __name__=='__main__':main()
