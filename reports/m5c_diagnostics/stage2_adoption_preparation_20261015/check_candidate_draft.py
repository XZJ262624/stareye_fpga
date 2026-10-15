from pathlib import Path
import json,hashlib
R=Path(__file__).resolve().parents[3];D=R/'reports/m5c_diagnostics/candidate_evidence_stage2_20261015'
draft=json.loads((D/'TECHNICAL_ALLOWLIST_DRAFT.json').read_text());snapshot=json.loads((D/'TECHNICAL_SNAPSHOT_DRAFT.json').read_text());records=draft['records']+snapshot['inherited_parent']
for x in records:
 b=(R/x['path']).read_bytes();assert len(b)==x['bytes'] and hashlib.sha256(b).hexdigest()==x['sha256']
mapping=json.loads((D/'VERSION_MAPPING.json').read_text())['mapping']+json.loads((D/'GOLDEN_CLOSURE.json').read_text())['mapping']
bad=[]
for x in mapping:
 s=x['original_path'].lower();name=Path(s).name
 if name.endswith(('.bit','.bit.bin','.hex.bin','.vdb','.lbf','.wlf','.troutingtraces','.dll','.exe')) or '/hardware_analysis' in s or '/work/' in s or '/.git/' in s or '/.env' in s:bad.append(s)
assert bad==[]
obj=json.loads((D/'OBJECTS.json').read_text())['objects']+json.loads((D/'GOLDEN_CLOSURE.json').read_text())['objects']
result=dict(status='PASS_TECHNICAL_DRAFT_BYTE_AND_EXCLUSION_CHECK_NOT_COMMIT_AUTHORIZATION',changed_count=len(draft['records']),inherited_count=len(snapshot['inherited_parent']),hash_checks=len(records),forbidden_original_paths=bad,objects=len(obj),mappings=len(mapping),unique_original_bytes=sum(x['original_bytes'] for x in obj),compressed_bytes=sum(x['bytes'] for x in obj),largest_changed=sorted(draft['records'],key=lambda x:x['bytes'],reverse=True)[:10],metadata_boundary='Management docs and final scope/allowlist receipt not yet included; no staged/index changes.')
(D/'TECHNICAL_DRAFT_CHECK.json').write_text(json.dumps(result,indent=2));print(json.dumps({k:result[k] for k in ['changed_count','inherited_count','hash_checks','objects','mappings','unique_original_bytes','compressed_bytes']}))
