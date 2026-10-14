from pathlib import Path
import json,hashlib,shutil,re,collections,subprocess,os
E=Path(__file__).resolve().parent;F=E.parent;R=F.parents[2];A=F/'resource_area_bound';P=A/'mirror/efinity/m5c_fusion_i3';cache={}
def rec(p):
 p=p.resolve()
 if p not in cache:
  b=p.read_bytes();cache[p]=dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
 return cache[p]
def put(n,x):
 p=E/n;assert not p.exists();p.write_text(json.dumps(x,indent=2));return rec(p)
base=json.loads((E/'SOURCE_PACKAGE_MAPPING.json').read_text());mapping={(x['original']['path'],x['original']['sha256']):x for x in base['records']};bysha={x['package']['sha256']:x['package'] for x in mapping.values()};external={(x['original']['path'],x['original']['sha256']):x for x in base['external']}
def add(p,scope):
 x=rec(p);key=(x['path'],x['sha256'])
 if key in mapping:return mapping[key]['package']
 assert p.is_relative_to(R) and p.suffix.lower() not in ['.exe','.dll','.vdb','.lbf','.wlf','.troutingtraces'] and p.name!='Ti60_Demo.map.v'
 q=bysha.get(x['sha256'])
 if q is None:
  dest=E/'objects'/x['sha256'][:2]/(x['sha256']+p.suffix.lower());dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,dest);q=rec(dest);bysha[x['sha256']]=q
 mapping[key]=dict(original=x,resolved_current=x,package=q,scopes=[scope],already_in_parent=False);external.pop(key,None);return q
# Explicitly authorized all_D report is admitted regardless of the draft generic 100MB limit.
add(P/'outflow/all_D_setup.rpt','actual_I3_raw_timing_explicit100531130bytes')
alias=F/'resource_area_experiment/alias_diagnostic'
for p in alias.iterdir():
 if p.is_file() and p.suffix in ['.json','.log','.blif']:add(p,'area65_local_proof_input')
for x in json.loads((alias/'PROPOSAL_MANIFEST.json').read_text())['records']:
 if Path(x['path']).suffix=='.py':
  p=R/x['path'];assert rec(p)==x;add(p,'area65_exact_proof_generator')
for n in ['work_management_2344','work_management_pre_candidate']:
 for p in (F/n).iterdir():
  if p.is_file():add(p,'final_management_exact_delta')
for p in [F/'WORK_MAP_TOP_REBASE_CHECK.json',E/'AREA65_CURRENT_TOP_BINDING.json',E/'prove_area_top_binding.py']:
 if p.exists():add(p,'area65_current_map_version_binding')
# Concrete actual native command file closure, not a recursive sweep of unrelated directories.
results=[];gaps=[];command_count=0;includes=[]
for x in list(mapping.values()):
 path=x['original']['path']
 if not path.startswith(F.relative_to(R).as_posix()+'/') or Path(path).name!='RESULT.json':continue
 if not any(k in path for k in ['/focused_','/regression/runs/','/finite64/','/legacy46_current_220203/']):continue
 obj=json.loads((R/x['package']['path']).read_text());files=[];tools=[];commands=[]
 def walk(v):
  global command_count
  if isinstance(v,dict):
   cmd=v.get('command')
   if isinstance(cmd,list):
    commands.append(cmd);command_count+=1
    for tok in cmd:
     if not isinstance(tok,str):continue
     if tok.startswith('+incdir+'):
      for d in tok[len('+incdir+'):].split('+'):
       pp=Path(d)
       if pp.is_absolute() and pp.is_relative_to(R):includes.append(dict(result=path,directory=str(pp),status='EXACT_INCLUDE_DIRECTORY_REQUIRES_SOURCE_INCLUDE_SCAN'))
      continue
     val=tok.split('=',1)[1] if tok.startswith('+') and '=' in tok else tok;pp=Path(val)
     if not pp.is_absolute():continue
     if not pp.is_relative_to(R):tools.append(val);continue
     if not pp.is_file():continue
     z=rec(pp)
     if pp.suffix.lower() in ['.wlf','.vdb','.dll','.exe']:continue
     pkg=bysha.get(z['sha256'])
     if pkg is None:gaps.append(dict(result=path,dependency=z,token=tok))
     files.append(dict(original=z,package=pkg,token=tok))
   for q in v.values():walk(q)
  elif isinstance(v,list):
   for q in v:walk(q)
 walk(obj);results.append(dict(result=x['original'],commands=commands,files=files,external_tools=sorted(set(tools))))
put('ACTUAL_COMMAND_CLOSURE_V2.json',dict(results=results,result_count=len(results),command_count=command_count,gaps=gaps,include_directories=includes,boundary='Actual current RESULT command arrays only; explicit file/plusarg dependencies hash-resolved. Installed executables external. Directory existence is not by itself include closure. Current source manifests preserve actual compiled snapshots; source include scan is separate.'))
include_refs=[];include_gaps=[]
for x in list(mapping.values()):
 if Path(x['original']['path']).suffix.lower() not in ['.v','.sv','.vh','.svh']:continue
 text=(R/x['package']['path']).read_text(errors='replace')
 for name in re.findall(r'^\s*`include\s+"([^"]+)"',text,re.M):
  candidates=[q for q in mapping.values() if Path(q['original']['path']).name==Path(name).name]
  uniq={q['original']['sha256']:q for q in candidates}
  same=Path(x['original']['path']).parent/name
  exact=[q for q in candidates if q['original']['path']==same.as_posix()]
  selected=exact or list(uniq.values())
  if not selected:include_gaps.append(dict(source=x['original'],include=name))
  include_refs.append(dict(source=x['original'],include=name,candidate_versions=[dict(original=q['original'],package=q['package']) for q in selected],selection='same_original_directory' if exact else 'available_versioned_basename_candidates_not_automatic_choice'))
put('SOURCE_INCLUDE_CLOSURE.json',dict(records=include_refs,missing=include_gaps,boundary='Exact quote include names in packaged HDL. Multiple versioned basename candidates retained and distinguished; actual command incdir/source snapshots determine selection. Macro/dynamic includes not inferred.'))
direct=[]
for n in ['rtl/m5c_fusion/m5b1_backend.sv','efinity/m5c_fusion_i3/Ti60_Demo_I3.sdc','efinity/m5c_fusion_i3/Ti60_Demo.xml','docs/STATUS.md','docs/HANDOFF.md','docs/DECISIONS.md','docs/PROJECT_BRIEF.md']:direct.append(rec(R/n))
put('SOURCE_PACKAGE_MAPPING_V2.json',dict(records=list(mapping.values()),external=list(external.values()),direct=direct,supersedes_mapping_only=rec(E/'SOURCE_PACKAGE_MAPPING.json'),historical_same_paths='Key is original path+SHA, not path alone. Root configuration before/after adoption and old source receipts resolve to their own exact archived or inherited parent bytes.'))
put('KNOWN_LIMITS.json',dict(limits=['97 actual timing reports are one current I3 model, not97 PVT corners. Setup+.191ns/hold+.026ns; narrow hold remains material.','61048-field lossless compact is structural pin/source classification, not a substitute for complete mapped logic/LUTMASKs. Current map and native route DB remain external hash-bound files.','65alias actual top is byteexact after26312 source-comment path rebases; trailing encrypted models differ and are outside that local primitive proof. No wholechip sequential equivalence claim.','827876321-byte cold trace external; extracted actual causal verdict and software supplied, fulltrace oracle requires external bytes.','Licensed installed tool libraries/DLLs are external, never copied into candidate. Proof model hashes and complete bounded miter/leaf inputs retained.','Conditional accelerated fullstream UART proves byte/CRC/lease semantics, notdefault real-time first-fusion latency or hardware. Cold-only fault scope is notwarm recovery.','Historical failures, parser errors and NONPASS remain distinct from accepted final gates. Original absolute paths need isolated reconstruction, not automatic turnkey replay.','No Git staging/commit or hardware. Bit files excluded; metadata only.'],primary_external=list(external.values()),pending_command_gaps=gaps,pending_include_gaps=include_gaps))
files=direct+[rec(p) for p in E.rglob('*') if p.is_file() and p.name!='FINAL_ALLOWLIST.json'];assert len(files)==len({x['path'] for x in files})
put('FINAL_ALLOWLIST.json',dict(status='EXACT_PROPOSAL_NOT_STAGED' if not gaps and not include_gaps else 'EXACT_DRAFT_WITH_EXPLICIT_CLOSURE_GAPS',records=files,count=len(files),bytes=sum(x['bytes'] for x in files),largest=sorted(files,key=lambda x:x['bytes'],reverse=True)[:30],command_gap_count=len(gaps),include_gap_count=len(include_gaps),artifacts_and_databases_excluded=True))
print('FINAL_SELECTED_PROPOSAL',len(files),sum(x['bytes'] for x in files),'results',len(results),'commands',command_count,'gaps',len(gaps),'include_gaps',len(include_gaps))
