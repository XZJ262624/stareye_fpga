from pathlib import Path
import json,hashlib,subprocess,re,difflib,shutil,datetime
R=Path(__file__).resolve().parents[1];P=R/'reports/m5c1b_fusion_integration/review_fix_99642712/finite64';O=R/'reports/m5c_diagnostics'/('stage2_finite_'+datetime.datetime.now().strftime('%Y%m%d_%H%M%S'));O.mkdir()
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
cases=json.loads((P/'CASES.json').read_text());der=[];replacements={}
for c in cases:
 for name in c['sources']:
  p=R/name
  if 'mutant' not in p.name or name in replacements:continue
  oldmut=p.read_text();module=re.search(r'module\s+(\w+)',oldmut)[1];current=R/'rtl/m5c_fusion'/(module+'.sv')
  if not current.exists():
   assert module=='m5c_fusion_display_control';continue
  head=subprocess.check_output(['git','-c','safe.directory='+R.as_posix(),'show','3b49a1f701798a817fed42b8097f724cbc9d6160:'+current.relative_to(R).as_posix()],cwd=R).decode().replace("\r\n","\n").splitlines(keepends=True)
  target=oldmut.splitlines(keepends=True);base=current.read_text();derived=base;edits=[]
  for op,a,b,x,y in difflib.SequenceMatcher(None,head,target,autojunk=False).get_opcodes():
   if op=='equal':continue
   before=''.join(head[a:b]);after=''.join(target[x:y])
   if not before or derived.count(before)!=1:before=''.join(head[max(0,a-1):b+1]);after=''.join(head[max(0,a-1):a])+after+''.join(head[b:b+1])
   assert derived.count(before)==1,(p.name,op,before)
   offset=derived.index(before);derived=derived.replace(before,after,1);edits.append(dict(offset=offset,before=before,after=after))
  restored=derived
  for e in reversed(edits):i=e['offset'];assert restored[i:i+len(e['after'])]==e['after'];restored=restored[:i]+e['before']+restored[i+len(e['after']):]
  assert restored==base
  q=O/p.name;q.write_text(derived);replacements[name]=q.relative_to(R).as_posix();der.append(dict(previous=rec(p),current_parent=rec(current),derived=rec(q),edits=edits,inverse_exact=True))
for c in cases:
 c['sources']=[replacements.get(p,p) for p in c['sources']]
 assert not any(a.lower().startswith(('+out=','-l','-wlf','+vcd=')) for a in c['args']),c['name']
 for ck in c['checkers']:shutil.copyfile(P/ck[0],O/ck[0])
shutil.copyfile(P/'check_trace.py',O/'check_trace.py')
s=(P/'run_replay_v3.py').read_text().replace('R=O.parents[3]','R=O.parents[2]');(O/'run_replay.py').write_text(s)
(O/'CASES.json').write_text(json.dumps(cases,indent=2));(O/'DERIVATION.json').write_text(json.dumps(dict(parent_cases=rec(P/'CASES.json'),parent_runner=rec(P/'run_replay_v3.py'),current_runner=rec(O/'run_replay.py'),cases=len(cases),mutants=der,output_policy='All native CWD/work/transcript/software outputs new per-case directory; no OUT/log/VCD output arguments inherited; read-only source dependencies remain bound.',scope='Current production original regressions with DIAGNOSTICS default0; Stage2 enabled behavior covered by separate coupled/slot/bridge/mixed tests, not inferred here.'),indent=2))
deps={p for c in cases for p in c['sources']};(O/'SOURCE_BINDINGS.json').write_text(json.dumps([rec(R/p) for p in sorted(deps)],indent=2));print(O)


