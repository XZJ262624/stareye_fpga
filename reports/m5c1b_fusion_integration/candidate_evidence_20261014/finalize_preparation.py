from pathlib import Path
import json,hashlib,subprocess,os
F=Path(__file__).resolve().parent;R=F.parents[2]
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def put(n,x):
 p=F/n;assert not p.exists();p.write_text(json.dumps(x,indent=2));return rec(p)
mapping=json.loads((F/'SOURCE_PACKAGE_MAPPING.json').read_text());known={x['original']['path']:x['package'] for x in mapping['records']};known.update({x['path']:x for x in mapping['direct']});bysha={x['sha256']:x for x in known.values()};cases=[];gaps=[]
scopes=json.loads((F/'SCOPE_DEPENDENCY_MAPPING.json').read_text())['scopes']
for scope in scopes:
 if scope['role']!='current17':continue
 d=(R/scope['manifest']['path']).parent;p=d/'RESULT.json';obj=json.loads(p.read_text());files=[];tools=[]
 def walk(x):
  if isinstance(x,dict):
   cmd=x.get('command')
   if isinstance(cmd,list):
    for token in cmd:
     if not isinstance(token,str):continue
     q=token.split('=',1)[1] if token.startswith('+') and '=' in token else token
     if q.startswith('+incdir+'):continue
     pp=Path(q)
     if not pp.is_absolute():continue
     if not pp.is_relative_to(R):tools.append(q);continue
     if not pp.is_file():continue
     z=rec(pp);pkg=known.get(z['path']) or bysha.get(z['sha256'])
     if not pkg or pkg['sha256']!=z['sha256']:gaps.append(z)
     files.append(dict(original=z,package=pkg))
   for v in x.values():walk(v)
  elif isinstance(x,list):
   for v in x:walk(v)
 walk(obj);cases.append(dict(result=rec(p),files=files,external_installed_tools=sorted(set(tools))))
assert len(cases)==17
put('CURRENT17_COMMAND_FILE_CLOSURE.json',dict(cases=cases,missing_current_file_dependencies=gaps,scope='Actual RESULT owner.command absolute file tokens, including GOLD arguments; include directories are represented by selected/source manifest closure. Does not claim arbitrary dynamic imports are inferred.'))
attrs='# PROPOSAL ONLY, NOT APPLIED\n# Narrow additions relative to HEAD for selected technical/package bytes:\n/efinity/m5c_fusion_i3/** -text\n/rtl/m5c_fusion/** -text\n/reports/m5c1b_fusion_integration/candidate_evidence_20261014/** -text\n# Existing unrelated/unselected working-tree additions are shown in ATTRIBUTES_IGNORE_PROPOSAL.json; Work chooses exact diff.\n'
(F/'NARROW_ATTRIBUTES_PROPOSAL.txt').write_text(attrs)
allow=json.loads((F/'CANDIDATE_ALLOWLIST_V2.json').read_text());checked=0
for x in allow['records']:
 z=rec(R/x['path']);assert z==x,x['path'];checked+=1
os.environ['GIT_OPTIONAL_LOCKS']='0';git=['git','-c','safe.directory=F:/Projects/stareye_fpga'];assert not subprocess.check_output(git+['diff','--cached','--name-only'],cwd=R,text=True).strip()
put('PACKAGE_VALIDATION.json',dict(allowlist_records_checked=checked,mismatch=0,primary_source_paths=len(mapping['records']),complete_endpoint_count=61480,current17_command_file_gaps=gaps,staging=False,packaging_diagnostic='First draft restricted I3 header search to first2500 characters; report command header exceeded this. Replaced with actual full-line Timing Model:I3 match for all92; no timing or gate weakened.'))
records=mapping['direct']+[rec(p) for p in sorted(F.rglob('*')) if p.is_file() and p.name not in ['FINAL_ALLOWLIST.json','HANDOFF.json']]
final=put('FINAL_ALLOWLIST.json',dict(status='EXACT_REVIEWABLE_PROPOSAL_NOT_STAGED',records=records,count=len(records),total_bytes=sum(x['bytes'] for x in records),largest=sorted(records,key=lambda x:x['bytes'],reverse=True)[:25],root_attributes_ignore='Proposal only outside this list; Work must freeze their exact patch separately.',self='This allowlist itself is delivery metadata, bound by HANDOFF; no self-hash included.'))
hand=put('HANDOFF.json',dict(status='PREPARED_FOR_WORK_SCOPE_REVIEW_NO_COMMIT',allowlist=final,count=len(records),bytes=sum(x['bytes'] for x in records),current17_actual_command_dependency_gaps=gaps,source101_unchanged=True,protection='4460 unchanged + exactly5 Work-declared management deltas verified against before archive/currentafter',primary_external='One827876321-byte cold trace; exact hash and original pointer in SOURCE_PACKAGE_MAPPING. Nested historical/tool/database references separately explicit, not claimed present.',limits=rec(F/'KNOWN_LIMITS.json'),manifest_scope='Exact proposed files, no staging. No simulated replay/build/STA/conversion performed during evidence preparation.',git='HEAD and desired direct parent f8bc4492f7247b5c242c80b76d9ca4a76347f30d, branch codex/m5c-fusion-prototype, index clean; candidate absent.'))
print(json.dumps(dict(handoff=hand,allowlist=final,count=len(records),bytes=sum(x['bytes'] for x in records),current17gaps=len(gaps))),flush=True)
