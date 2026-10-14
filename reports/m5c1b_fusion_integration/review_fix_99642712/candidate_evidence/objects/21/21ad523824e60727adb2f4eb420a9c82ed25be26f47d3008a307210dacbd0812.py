from pathlib import Path
import json,hashlib,shutil,subprocess,os,re,collections
F=Path(__file__).resolve().parent;R=F.parents[2];A=F/'resource_area_bound';O=F/'offline_area_artifact';E=F/'candidate_evidence';OLD=R/'reports/m5c1b_fusion_integration/candidate_evidence_20261014'
assert not E.exists();E.mkdir();cache={}
def rec(p):
 p=p.resolve()
 if p not in cache:
  h=hashlib.sha256()
  with p.open('rb') as f:
   for b in iter(lambda:f.read(1048576),b''):h.update(b)
  cache[p]=dict(path=p.relative_to(R).as_posix(),bytes=p.stat().st_size,sha256=h.hexdigest())
 return cache[p]
def put(n,x):
 p=E/n;assert not p.exists();p.write_text(json.dumps(x,indent=2));return rec(p)
os.environ['GIT_OPTIONAL_LOCKS']='0';git=['git','-c','safe.directory=F:/Projects/stareye_fpga'];head=subprocess.check_output(git+['rev-parse','HEAD'],cwd=R,text=True).strip();assert head=='99642712cfb912f484006f4cd74aba4bdaa8d57b';assert not subprocess.check_output(git+['diff','--cached','--name-only'],cwd=R,text=True).strip()
tracked=set(subprocess.check_output(git+['ls-files','-z'],cwd=R).decode().split('\0'));pool={};available={}
manifests=[F/'FOCUSED_MANIFEST.json',F/'resource_diagnostic/REGRESSION18_MANIFEST.json',F/'finite64/GATE_MANIFEST.json',F/'legacy46_current_220203/GATE_MANIFEST.json']
items=[x for p in manifests for x in json.loads(p.read_text())['records']]
items += json.loads((OLD/'FINAL_ALLOWLIST.json').read_text())['records']
items += [rec(p) for p in (F/'root_configuration_adoption').glob('*.before')]
for x in items:
 p=R/x['path']
 if p.is_file() and rec(p)==x:
  pool.setdefault(x['sha256'],p)
  if x['path'] in tracked:available.setdefault(x['sha256'],x)
mapping={};external={};objects={};direct={};scopes=[]
def add(x,scope):
 if isinstance(x,Path):x=rec(x)
 key=(x['path'],x['sha256']);p=R/x['path']
 if key in mapping:mapping[key]['scopes'].append(scope);return
 if p.is_file() and rec(p)==x:resolved=p
 else:resolved=pool.get(x['sha256']);assert resolved and rec(resolved)['bytes']==x['bytes'],('UNRESOLVED_CURRENT_RECORD',x)
 assert resolved.is_relative_to(R)
 if resolved.suffix.lower() in ['.vdb','.lbf','.troutingtraces','.wlf','.dll','.exe'] or resolved.name in ['Ti60_Demo.map.v','ALL_SEQUENTIAL_INPUTS.json'] or x['bytes']>100000000:
  external[key]=dict(original=x,resolved_current=rec(resolved),scope=scope,reason='External exact-hash native database/map, raw full structural representation or large raw cause trace; no packaged-byte/replay claim.');return
 assert not any(k in resolved.parts for k in ['.git','work','__pycache__'])
 assert resolved.name not in ['Ti60_Demo.bit','Ti60_Demo.bit.bin','Ti60_Demo.hex','Ti60_Demo.hex.bin']
 sha=x['sha256'];package=available.get(sha) or objects.get(sha)
 if package is None:
  q=E/'objects'/sha[:2]/(sha+resolved.suffix.lower());q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(resolved,q);package=rec(q);objects[sha]=package
 assert package['sha256']==sha and package['bytes']==x['bytes']
 mapping[key]=dict(original=x,resolved_current=rec(resolved),package=package,scopes=[scope],already_in_parent=package['path'] in tracked)
for p in manifests:
 add(p,'functional_manifest');xs=json.loads(p.read_text())['records'];label=p.relative_to(F).as_posix()
 for x in xs:add(x,label)
 scopes.append(dict(manifest=rec(p),records=len(xs),scope=label))
# Exact selected technical input version. Only changed tracked files belong to the stage proposal.
source=json.loads((F/'root_configuration_adoption/SOURCE101_AFTER_ADOPTION.json').read_text())['records']
for x in source:assert rec(R/x['path'])==x
changed=set(subprocess.check_output(git+['diff','--name-only'],cwd=R,text=True).splitlines())
allowed_direct={x['path'] for x in source}|{'docs/STATUS.md','docs/HANDOFF.md','docs/DECISIONS.md','docs/PROJECT_BRIEF.md'}
assert changed<=allowed_direct,('UNEXPECTED_TRACKED_CHANGES',changed-allowed_direct)
for n in sorted(changed):direct[n]=rec(R/n)
for p in A.iterdir():
 if p.is_file() and p.suffix in ['.json','.py','.log','.gz'] and p.name!='CURRENT_INVENTORY_COMPACT.json':add(p,'current_area_physical_helpers_and_receipts')
for sub in ['map','interface','place','route','sta_01_bundle_global_Dsetup','sta_02_scoped_D_CE_SR_RAM_DSP_IO','sta_03_connections','sta_04_DSP_config','sta_05_clock_pairs','sta_06_backend_cleanup_controls','sta_07_backend_connections','queries','rgb_factor_diagnostic','root_adoption_proposal']:
 for p in (A/sub).iterdir():
  if p.is_file() and p.suffix in ['.json','.log','.tcl','.py','.blif','.sdc','.xml']:add(p,'current_area_stage_or_exact_proof')
P=A/'mirror/efinity/m5c_fusion_i3';timing=[]
for p in sorted((P/'outflow').glob('*.rpt')):
 if p.name.startswith(('bundle_','normal_','all_D_','v2_','v5_','clock_','backend_')):
  assert re.search(r'^Timing Model:\s*I3\s*$',p.read_text(),re.M);add(p,'actual_I3_raw_timing');timing.append(rec(p))
assert len(timing)==97,len(timing)
for n in ['v4_pin_nets.txt','backend_pin_nets.txt','selected_allpins.txt','outflow/selected_check.rpt','outflow/selected_clocks.rpt','outflow/Ti60_Demo.place.rpt','outflow/Ti60_Demo.route.rpt','Ti60_Demo.xml','Ti60_Demo_I3.sdc']:add(P/n,'current_physical_objects')
add(P/'outflow/Ti60_Demo.map.v','external_physical_map');add(A/'full_inventory/ALL_SEQUENTIAL_INPUTS.json','lossless_compact_original_external')
for base in [O,F/'root_configuration_adoption']:
 for p in base.iterdir():
  if p.is_file() and p.suffix in ['.json','.py','.log','.before']:add(p,'artifact_metadata_or_adoption')
for n in ['FOCUSED_HANDBACK.json','WORK_FIX_FREEZE.md','WORK_FOCUSED_CHECK.json','WORK_RESOURCE_DIAG_FREEZE.md','WORK_RESOURCE_SEED_FREEZE.md','WORK_AREA_EXPERIMENT_FREEZE.md','WORK_AREA65_BIND_FREEZE.md','WORK_RGB_DUPLICATE_WITNESS_FREEZE.md','WORK_AREA_ROUTE_STA_FREEZE.md','WORK_AREA_OFFLINE_BIT_AND_ADOPTION_FREEZE.md','WORK_NEXT_EVIDENCE_REQUIREMENTS.md','prepare_offline_area.py','adopt_qualified_root_configuration.py','prepare_candidate_evidence.py','resource_diagnostic/REGRESSION18_SEALED_SUMMARY.json','finite64/GATE_HANDBACK.json','legacy46_current_220203/GATE_HANDBACK.json']:
 add(F/n,'review_fix_scope')
for base in [F/'work_management_2239',F/'work_management_2245',F/'work_management_2337']:
 for p in base.iterdir():
  if p.is_file():add(p,'exact_management_history')
# Actual production golden generator closure, unchanged historical gold bytes.
for n in ['scripts/m5c1b_golden.py','scripts/m5a_streaming_canny_gold.py','reports/m5c1b_fusion_integration/golden_v2/GOLDEN_FREEZE.json']:
 add(R/n,'actual_golden_generator_closure')
put('SOURCE_PACKAGE_MAPPING.json',dict(records=list(mapping.values()),external=list(external.values()),direct=list(direct.values())))
put('CURRENT_SCOPE_INDEX.json',dict(scopes=scopes,technical101=source,timing_reports=timing,endpoint_count=61048,coverage='7 focused repair gates;18 separately scoped long/default gates;64 finite gates;46 legacy gates. Not a sum of distinct fullsystem scenarios.',compiled_RTL='Identical current backend074809 and other RTL across tests and qualified area build. Later root XML/SDC adoption creates explicit new configuration version only.',raw_inventory='61048 objects transported losslessly by gzip compact plus exact all-field reconstruction receipt/generator; raw415MB inventory external.',artifact='Only metadata included. Four generated programming files stay ignored/external.',large_external='Cold827876321-byte trace is external; causal oracle/result retained but full trace recomputation needs external bytes. Map/DB/tools are external, not candidate payload.'))
refs={}
def walk(v):
 if isinstance(v,dict):
  if isinstance(v.get('path'),str) and isinstance(v.get('sha256'),str) and isinstance(v.get('bytes'),int):refs[(v['path'],v['sha256'])]=v
  for z in v.values():walk(z)
 elif isinstance(v,list):
  for z in v:walk(z)
bysha={x['package']['sha256']:x['package'] for x in mapping.values()};bysha.update({x['sha256']:x for x in source})
for x in mapping.values():
 p=R/x['package']['path']
 if p.suffix=='.json':
  try:walk(json.loads(p.read_text()))
  except (UnicodeError,json.JSONDecodeError):pass
resolved=[];unresolved=[]
for x in refs.values():
 q=bysha.get(x['sha256'])
 if q and q['bytes']==x['bytes']:resolved.append(dict(reference=x,package=q))
 else:unresolved.append(dict(reference=x,classification='EXPLICIT_EXTERNAL_OR_HISTORICAL_METADATA_REFERENCE_NOT_PACKAGED'))
put('NESTED_REFERENCE_BOUNDARY.json',dict(resolved=resolved,external=unresolved,not_recursive_admission=True,boundary='Protection4465 and physical5392 manifests are historical scope metadata, never instructions to include all referenced files. Current primary functional records have exact versioned mapping; nested older archives, DB and installed-tool references may remain external.'))
put('IDENTITY_AND_LIMITS.json',dict(head=head,desired_parent=head,branch=subprocess.check_output(git+['branch','--show-current'],cwd=R,text=True).strip(),index_empty=True,no_git_writes=True,limits=['Current HEAD remains independently rejected candidate; no new candidate yet.','I3 only setup+.191ns hold+.026ns, narrow hold remains material; no cross-PVT/hardware qualification.','Cold terminal scope not warm recovery; default full UART initial availability remains hardware-unmeasured.','Conditional fullsystem UART960000 vs production96000000 at460800; complete payload/CRC/lease/DDR gates preserved, not realtime throughput claim.','Native tools/licenses and reconstructed original layout needed; no turnkey portable replay claim.'],root_config=rec(F/'root_configuration_adoption/APPLICATION_RECEIPT.json'),artifact=rec(O/'FINAL_HANDBACK.json')))
files=list(direct.values())+[rec(p) for p in E.rglob('*') if p.is_file()]
assert len({x['path'] for x in files})==len(files)
put('ALLOWLIST_DRAFT.json',dict(status='EXACT_DRAFT_NOT_STAGED_PENDING_COMMAND_CLOSURE_REVIEW',records=files,count=len(files),bytes=sum(x['bytes'] for x in files),largest=sorted(files,key=lambda x:x['bytes'],reverse=True)[:30],inherited_parent_objects=len({x['package']['path'] for x in mapping.values() if x['already_in_parent']}),excluded_programming_artifacts=True))
print('CANDIDATE_DRAFT',len(files),sum(x['bytes'] for x in files),'mapping',len(mapping),'external_primary',len(external),'nested_external',len(unresolved))
