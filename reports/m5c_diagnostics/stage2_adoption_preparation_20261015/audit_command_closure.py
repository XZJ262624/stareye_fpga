from pathlib import Path
import json,gzip,re,hashlib
R=Path(__file__).resolve().parents[3];D=R/'reports/m5c_diagnostics/candidate_evidence_stage2_20261015'
rows=json.loads((D/'VERSION_MAPPING.json').read_text())['mapping']+json.loads((D/'GOLDEN_CLOSURE.json').read_text())['mapping']
available={x['original_path'].replace('\\','/').lower() for x in rows};rootstr=str(R).replace('\\','/').lower()+'/'
commands=[];refs=[];unresolved=[]
def walk(v,where):
 if isinstance(v,dict):
  for k,x in v.items():
   if k.lower() in ['cmd','command'] and isinstance(x,list) and all(isinstance(a,str) for a in x):commands.append((where,x))
   else:walk(x,where)
 elif isinstance(v,list):
  for x in v:walk(x,where)
for row in rows:
 if row['original_path'].endswith('.json'):
  try:walk(json.loads(gzip.decompress((R/row['object']).read_bytes())),row['original_path'])
  except (ValueError,UnicodeDecodeError):pass
for origin,cmd in commands:
 for arg in cmd:
  token=arg.split('=',1)[1] if arg.startswith('+') and '=' in arg else arg
  t=token.replace('\\','/');low=t.lower()
  if not low.startswith(rootstr):continue
  rel=t[len(rootstr):]
  if not rel.lower().endswith(('.sv','.v','.svh','.vh','.py','.hex','.sdc','.xml','.bin')):continue
  covered=rel.lower() in available
  item=dict(receipt=origin,argument=arg,relative=rel,transport_path_present=covered)
  refs.append(item)
  if not covered:unresolved.append(item)
out=dict(status='PATH_REFERENCE_AUDIT_NOT_DYNAMIC_IMPORT_PROOF',command_records=len(commands),typed_input_references=len(refs),unresolved_path_references=unresolved,references=refs,
 limits='Matches actual source-bearing argv path strings in transported JSON command/cmd arrays. Does not parse shell strings, tool-internal libraries, dynamically constructed Python imports, or infer output/input roles for arbitrary .hex/.bin; unresolved entries require individual classification. Each original frozen INPUTS binding remains authoritative for exact source versions.')
(D/'COMMAND_PATH_AUDIT.json').write_text(json.dumps(out,indent=2));print(json.dumps(dict(commands=len(commands),refs=len(refs),unresolved=len(unresolved))))
