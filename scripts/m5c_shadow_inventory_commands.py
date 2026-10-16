"""Audit selected completed-run command/source/include closure without running HDL."""
from pathlib import Path
import gzip,hashlib,json,re
R=Path(__file__).resolve().parents[1];A=R/'reports/m5c_shadow_stats_20261016';O=A/'candidate_evidence'
pack=json.loads((O/'STABLE_OBJECTS_V2.json').read_bytes())
closure=json.loads((O/'SHORT_INPUT_CLOSURE.json').read_bytes())
byhash={x['original']['sha256']:x['object'] for x in pack['mapping']}
byhash.update({x['declared_input']['sha256']:x['object'] for x in closure['records']})
def norm(s):
 p=Path(s);p=p if p.is_absolute() else R/p
 return str(p.resolve()).lower()
def read(m):return gzip.decompress((R/m['object']['path']).read_bytes())
def visit(v):
 if isinstance(v,dict):
  if {'path','bytes','sha256'}<=set(v):yield v
  else:
   for x in v.values():yield from visit(x)
 elif isinstance(v,list):
  for x in v:yield from visit(x)
inputs={};owners=[]
for m in pack['mapping']:
 p=Path(m['original']['path'])
 if p.name=='INPUTS.json':inputs[norm(p.parent)]={norm(x['path']):x for x in visit(json.loads(read(m)))}
 if p.name.startswith('OWNER') and p.suffix=='.json':owners.append(m)
rows=[];gaps=[];includes=[]
for m in owners:
 z=json.loads(read(m));cmd=z.get('cmd',z.get('command'))
 if not isinstance(cmd,list):continue
 cwd=Path(z.get('cwd',Path(m['original']['path']).parent));cwd=cwd if cwd.is_absolute() else R/cwd
 bound=inputs.get(norm(Path(m['original']['path']).parent),{})
 incdirs=[Path(x.split('+incdir+',1)[1]) for x in cmd if x.startswith('+incdir+')]
 deps=[]
 for arg in cmd[1:]:
  val=arg
  if val.startswith('+') and '=' in val:
   key,val=val.split('=',1)
   if key.upper() not in ['+GOLD','+GOLD_B','+INPUT','+PIXELS','+CASES','+EXPECT']:continue
  elif val.startswith(('+','-')) or Path(val).suffix.lower() not in ['.sv','.v','.svh','.vh']:continue
  p=Path(val);p=p if p.is_absolute() else cwd/p
  x=bound.get(norm(p))
  if x is None:gaps.append(dict(owner=m['original']['path'],argument=arg,reason='NO_EXACT_RUN_INPUT_BINDING'));continue
  obj=byhash.get(x['sha256'])
  if obj is None:gaps.append(dict(owner=m['original']['path'],argument=arg,reason='NO_TRANSPORT_OBJECT'));continue
  deps.append(dict(input=x,object=obj))
  if p.suffix.lower() not in ['.sv','.v','.svh','.vh']:continue
  raw=gzip.decompress((R/obj['path']).read_bytes()).decode(errors='strict')
  for name in re.findall(r'`include\s+"([^"]+)"',raw):
   candidates=[p.parent/name]+[d/name for d in incdirs]+[cwd/name]
   found=next((bound[norm(c)] for c in candidates if norm(c) in bound),None)
   if found and found['sha256'] in byhash:includes.append(dict(source=x,include=name,input=found,object=byhash[found['sha256']]))
   else:gaps.append(dict(owner=m['original']['path'],source=x['path'],include=name,reason='INCLUDE_NOT_EXPLICITLY_BOUND'))
 rows.append(dict(owner=m['original'],command=cmd,cwd=str(cwd),dependencies=deps))
out=O/'SHORT_COMMAND_INVENTORY.json';assert not out.exists()
out.write_text(json.dumps(dict(status='PASS_EXPLICIT_COMMAND_DEPENDENCIES' if not gaps else 'COMMAND_DEPENDENCY_GAPS',commands=rows,includes=includes,gaps=gaps,boundary='Explicit selected OWNER commands and lexical HDL includes only. This is not a claim about implicit Python imports, vendor tool installations, or final enabled-system inputs.'),indent=2))
print('COMMANDS',len(rows),'INCLUDES',len(includes),'GAPS',len(gaps));print(gaps[:10])
