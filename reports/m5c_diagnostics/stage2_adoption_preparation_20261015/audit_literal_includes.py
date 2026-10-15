from pathlib import Path,PurePosixPath
import json,gzip,re,posixpath
R=Path(__file__).resolve().parents[3];D=R/'reports/m5c_diagnostics/candidate_evidence_stage2_20261015'
rows=json.loads((D/'VERSION_MAPPING.json').read_text())['mapping'];available={x['original_path'].replace('\\','/').lower() for x in rows}
refs=[];missing=[]
for row in rows:
 name=row['original_path'].replace('\\','/')
 if not name.lower().endswith(('.sv','.v','.vh','.svh')):continue
 text=gzip.decompress((R/row['object']).read_bytes()).decode(errors='replace')
 for inc in re.findall(r'^\s*`include\s+"([^"]+)"',text,re.M):
  resolved=posixpath.normpath(str(PurePosixPath(name).parent/ inc.replace('\\','/')))
  exists=resolved.lower() in available;item=dict(source=name,include=inc,resolved=resolved,transport_path_present=exists);refs.append(item)
  if not exists:missing.append(item)
(D/'LITERAL_INCLUDE_AUDIT.json').write_text(json.dumps(dict(status='LITERAL_SAME_DIRECTORY_INCLUDE_AUDIT',references=refs,missing=missing,boundary='Literal include strings only. Compiler include directories and flattened snapshots may need separately mapped original sources; no unknown is silently PASS.'),indent=2))
print(json.dumps(dict(refs=len(refs),missing=len(missing))))
