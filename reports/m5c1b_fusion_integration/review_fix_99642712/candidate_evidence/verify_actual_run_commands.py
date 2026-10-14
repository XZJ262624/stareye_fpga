from pathlib import Path
import json,hashlib,re,collections
E=Path(__file__).resolve().parent;F=E.parent;R=F.parents[2];m=json.loads((E/'SOURCE_PACKAGE_MAPPING_V2.json').read_text());bysha={x['package']['sha256']:x['package'] for x in m['records']};cache={}
def rec(p):
 p=p.resolve()
 if p not in cache:
  b=p.read_bytes();cache[p]=dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
 return cache[p]
old=json.loads((E/'ACTUAL_COMMAND_CLOSURE_V2.json').read_text());rows=[];gaps=[];include_rows=[]
for case in old['results']:
 parent=Path(case['result']['path']).parent;records=[x for x in m['records'] if Path(x['original']['path']).parent==parent and (Path(x['original']['path']).name.endswith('_OWNER.json') or Path(x['original']['path']).name in ['RESULT.json','OWNER.json'])];commands={}
 def visit(v,origin):
  if isinstance(v,dict):
   cmd=v.get('command')
   if isinstance(cmd,list):commands.setdefault(json.dumps(cmd),dict(command=cmd,cwd=v.get('cwd',str(R/parent)),receipt=origin))
   for z in v.values():visit(z,origin)
  elif isinstance(v,list):
   for z in v:visit(z,origin)
 for x in records:visit(json.loads((R/x['package']['path']).read_text()),x['original'])
 files=[];src=[];include_dirs=[]
 for cmditem in commands.values():
  cmd=cmditem['command'];cwd=Path(cmditem['cwd']);cwd=cwd if cwd.is_absolute() else R/cwd
  iscompile=bool(cmd and Path(cmd[0]).name.lower()=='vlog.exe')
  inc=[]
  for token in cmd:
   if not isinstance(token,str):continue
   if token.startswith('+incdir+'):
    inc += [Path(d) if Path(d).is_absolute() else cwd/d for d in token[len('+incdir+'):].split('+')];continue
   value=token.split('=',1)[1] if token.startswith('+') and '=' in token else token;p=Path(value)
   if not p.is_absolute():p=cwd/p
   if not p.is_relative_to(R) or not p.is_file() or p.suffix.lower() in ['.exe','.dll','.wlf','.vdb']:continue
   z=rec(p);q=bysha.get(z['sha256'])
   if q is None:gaps.append(dict(case=case['result']['path'],record=z,token=token))
   files.append(dict(file=z,package=q,token=token))
   if iscompile and p.suffix.lower() in ['.v','.sv']:src.append((p,cwd,inc))
  include_dirs+=inc
 seen=set()
 def check_include(p,cwd,inc):
  if p in seen:return
  seen.add(p)
  for name in re.findall(r'^\s*`include\s+"([^"]+)"',p.read_text(errors='replace'),re.M):
   candidates=[]
   for d in [p.parent,cwd]+inc:
    q=(d/name).resolve()
    if q.is_file() and q not in candidates:candidates.append(q)
   versions={rec(q)['sha256'] for q in candidates if q.is_relative_to(R)}
   if not candidates or len(versions)!=1:gaps.append(dict(case=case['result']['path'],include=name,source=str(p),candidates=[str(q) for q in candidates]));continue
   q=candidates[0];z=rec(q);pkg=bysha.get(z['sha256'])
   if pkg is None:gaps.append(dict(case=case['result']['path'],include=z))
   include_rows.append(dict(case=case['result']['path'],source=rec(p),include=name,actual_candidates=[rec(q) for q in candidates],single_byte_identity=True,package=pkg));check_include(q,cwd,inc)
 for p,cwd,inc in src:check_include(p,cwd,inc)
 rows.append(dict(result=case['result'],commands=list(commands.values()),files=files,compiled_source_count=len(src)))
assert len(rows)==135
missing_commands=[x['result']['path'] for x in rows if not x['commands']]
p=E/'ACTUAL_RUN_COMMAND_CLOSURE_V3.json';assert not p.exists();p.write_text(json.dumps(dict(status='PASS_CURRENT135_RUN_COMMAND_FILE_INCLUDE_CLOSURE' if not gaps and not missing_commands else 'GAPS_REQUIRE_EXACT_INPUT_COMPLETION',runs=rows,run_count=len(rows),command_count=sum(len(x['commands']) for x in rows),missing_commands=missing_commands,gaps=gaps,include_records=include_rows,source_mapping=rec(E/'SOURCE_PACKAGE_MAPPING_V2.json'),generator=rec(Path(__file__)),boundary='Extends prior RESULT-only survey using actual same-run OWNER receipts. Current compiled HDL/static include and file-valued plusargs are bound to package or inherited parent bytes. Installed executables external; no arbitrary dynamic import inference.'),indent=2));print('COMMAND_CLOSURE',len(rows),sum(len(x['commands']) for x in rows),'gaps',len(gaps),'missingcommands',len(missing_commands),'includes',len(include_rows))
