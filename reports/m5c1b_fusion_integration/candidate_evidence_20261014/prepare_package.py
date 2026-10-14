from pathlib import Path
import json,hashlib,shutil,collections,subprocess,os,re
F=Path(__file__).resolve().parent;R=F.parents[2];B=F.parent/'fresh_i3_build_20261014';A=F.parent/'offline_artifact_retry_20261014'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def put(n,x,compact=False):
 p=F/n;assert not p.exists(),p;p.write_text(json.dumps(x,indent=None if compact else 2,separators=(',',':') if compact else None));return rec(p)
def chk(x):
 z=rec(R/x['path']);assert (z['bytes'],z['sha256'])==(x['bytes'],x['sha256']),x['path'];return z
mapping={};external={};unique={};direct={};scopes=[]
def add(p,scope):
 p=p.resolve();assert p.is_relative_to(R) and p.is_file();z=rec(p);name=z['path'];assert not any(k in p.parts for k in ['.git','work','__pycache__']) and p.suffix not in ['.exe','.dll','.wlf','.vdb','.lbf']
 if name in mapping:mapping[name]['scopes'].append(scope);return
 if name in direct:return
 if z['bytes']>100000000:
  assert p.name=='v7_cause_trace.txt';external[name]=dict(original=z,reason='827MB cold cause trace explicitly external; extraction result and actual generator are packaged. Recomputing extraction requires this external file.');return
 sha=z['sha256'];q=F/'objects'/sha[:2]/(sha+p.suffix.lower())
 if sha in unique:q=R/unique[sha]['path']
 else:q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,q);unique[sha]=rec(q)
 assert rec(q)['sha256']==sha;mapping[name]=dict(original=z,package=unique[sha],scopes=[scope])
# Protection admits exactly the Work-owned five-document delta.
delta_path=F.parent/'work_management_update_20261014/MANAGEMENT_DELTA.json';delta=json.loads(delta_path.read_text())['records'];ds={x['path']:x for x in delta};assert len(ds)==5
protected=json.loads((F.parent/'SOURCE_PROTECTION.json').read_text());unchanged=0
for x in protected:
 if x['path'] in ds:
  d=ds[x['path']];assert (x['bytes'],x['sha256'])==(d['before']['bytes'],d['before']['sha256']);z=rec(R/d['path']);assert (z['bytes'],z['sha256'])==(d['after']['bytes'],d['after']['sha256']);old=rec(R/d['before']['archive']);assert (old['bytes'],old['sha256'])==(x['bytes'],x['sha256'])
 else:chk(x);unchanged+=1
assert unchanged==4460
selected=json.loads((F.parent/'final_source_selection_20261013_063600/SELECTED_SOURCE_IDENTITY.json').read_text())['records']
for x in selected:z=chk(x['adopted']);direct[z['path']]=z
for n in list(ds)+['docs/AI_WORKFLOW.md','docs/REVIEW_PROTOCOL.md']:
 z=rec(R/n);direct[n]=z
add(delta_path,'management');[add(R/d['before']['archive'],'management_before') for d in delta]
pre=json.loads((B/'PREFLIGHT.json').read_text());assert len(pre['proofs'])==23
for m in pre['proofs']:
 p=R/m['manifest']['path'];chk(m['manifest']);xs=json.loads(p.read_text())['records'];scope=p.parent.relative_to(R).as_posix();add(p,scope)
 for x in xs:chk(x);add(R/x['path'],scope)
 scopes.append(dict(manifest=rec(p),records=len(xs),scope=scope,role='current17' if p.name=='GATE_MANIFEST.json' else 'focused_default_legacy_additional',replay='Exact original runners/commands and sources retained through original-to-package map. Original absolute path assumptions require an isolated restored layout; never run against active production. Tool installations are external prerequisites.'))
# Exact fresh evidence, exclude databases and giant raw structural object; compact derivative below.
for p in B.iterdir():
 if p.is_file() and p.suffix in ['.json','.py','.log']:add(p,'fresh_build_control')
for sub in ['map','interface','place','route','sta_01_bundle_global_Dsetup','sta_02_scoped_D_CE_SR_RAM_DSP_IO','sta_03_connections','sta_04_DSP_config','sta_05_clock_pairs','queries']:
 for p in (B/sub).iterdir():
  if p.is_file() and p.suffix in ['.json','.log','.tcl','.py']:add(p,'fresh_stage_raw')
P=B/'mirror/efinity/m5c_fusion_i3';timing=[]
for p in sorted((P/'outflow').glob('*.rpt')):
 if p.name.startswith(('bundle_','normal_','all_D_','v2_','v5_','clock_')):
  assert re.search(r'^Timing Model:\s*I3\s*$',p.read_text(),re.M);add(p,'actual_I3_raw');timing.append(rec(p))
assert len(timing)==92,len(timing)
for n in ['v4_pin_nets.txt','selected_allpins.txt','outflow/selected_check.rpt','outflow/selected_clocks.rpt','outflow/Ti60_Demo.map.v','outflow/Ti60_Demo.route.rpt','outflow/Ti60_Demo.place.rpt','outflow/Ti60_Demo.interface.io','outflow/Ti60_Demo.pt.sdc','outflow/Ti60_Demo_or.ini']:add(P/n,'fresh_physical_raw')
for p in (B/'mapped_inventory').iterdir():
 if p.is_file() and p.suffix=='.json' and p.stat().st_size<10000000:add(p,'fresh_CDC_inventory')
for p in A.iterdir():
 if p.is_file() and p.suffix in ['.json','.py','.log']:add(p,'artifact_receipts_only')
# Relevant failure receipts referenced by current gate manifests remain unchanged; additional known build/conversion failures.
for p in (F.parent/'offline_artifact_20261014').iterdir():
 if p.is_file() and p.suffix in ['.json','.py','.log']:add(p,'old_conversion_NOT_FINAL')
for n in ['POSTPROCESS_FAILURE_AND_ARTIFACT_RECEIPT.json','AUDIT_V1_FAILURE_RECEIPT.json']:
 pass
# Complete reversible structural compaction; retain raw parser labels, never relabel 9993 as timed from structure alone.
rawpath=B/'full_inventory/ALL_SEQUENTIAL_INPUTS.json';raw=json.loads(rawpath.read_text());columns=['endpoint','kind','port','clock','net','classification','sources'];strings=[];sid={};source_sets=[];source_ids={}
def intern(s):
 if s not in sid:sid[s]=len(strings);strings.append(s)
 return sid[s]
rows=[]
for x in raw['pins']:
 key=json.dumps(x['sources'],separators=(',',':'))
 if key not in source_ids:source_ids[key]=len(source_sets);source_sets.append([[intern(v) for v in src] for src in x['sources']])
 rows.append([intern(x[k]) for k in columns[:-1]]+[source_ids[key]])
der=dict(format='exact_dictionary_interned_v1',raw=rec(rawpath),header={k:v for k,v in raw.items() if k!='pins'},columns=columns,strings=strings,source_sets=source_sets,rows=rows)
for original,row in zip(raw['pins'],rows):
 rebuilt={k:strings[v] for k,v in zip(columns[:-1],row[:-1])};rebuilt['sources']=[[strings[v] for v in src] for src in source_sets[row[-1]]];assert rebuilt==original
assert len(rows)==61480 and len({x['endpoint'] for x in raw['pins']})==61480
put('COMPLETE_ENDPOINTS_COMPACT.json',der,True)
put('COMPACT_DERIVATION.json',dict(raw=rec(rawpath),compact=rec(F/'COMPLETE_ENDPOINTS_COMPACT.json'),generator=rec(Path(__file__)),count=61480,exact_roundtrip_all_fields=True,classification_counts=dict(collections.Counter(x['classification'] for x in raw['pins'])),scope='Generic parser PRIMARY_OR_UNRESOLVED_EXPLICIT remains 9993; structural labels alone are not timing coverage. Actual I3 full D/control reports, constants/exact cuts, vendor/native pin evidence and 7/135 external boundary supply qualification. No blanket unknown=0 claim from this compact table.'))
put('SOURCE_PACKAGE_MAPPING.json',dict(records=list(mapping.values()),external=list(external.values()),direct=list(direct.values())))
put('SCOPE_DEPENDENCY_MAPPING.json',dict(scopes=scopes,reported_manifest_records=sum(x['records'] for x in scopes),raw_timing_reports=timing,external_boundaries=list(external.values()),notes=['All original manifests remain exact historical bytes. References are resolved through SOURCE_PACKAGE_MAPPING; not rewritten to suggest original paths committed.','Executable source fixtures, signed gold, native logs and software gate evidence are content-deduplicated. No ModelSim work libraries or installed tools included.','External827MB cold trace means this package alone cannot re-execute its full trace oracle. Native simulation replay additionally requires installed licensed tools and path reconstruction; no portable replay claim without validation.']))
os.environ['GIT_OPTIONAL_LOCKS']='0';git=['git','-c','safe.directory=F:/Projects/stareye_fpga'];head=subprocess.check_output(git+['rev-parse','HEAD'],cwd=R,text=True).strip();assert head==pre['head'];index=subprocess.check_output(git+['diff','--cached','--name-only'],cwd=R,text=True);assert not index.strip()
diff=subprocess.check_output(git+['diff','--','.gitattributes','.gitignore'],cwd=R,text=True)
put('ATTRIBUTES_IGNORE_PROPOSAL.json',dict(current_bytes=[rec(R/'.gitattributes'),rec(R/'.gitignore')],existing_diff=diff,action='PLAN_ONLY_NO_MODIFICATION',proposed='Preserve exact existing selected101 paths and candidate_evidence_20261014/** as -text for byte-exact hashes; keep generated programming artifacts ignored via existing exact local sidecars. Work must approve final explicit attributes diff; do not silently broaden to all unselected experiments.',candidate_root_files='Current .gitattributes/.gitignore diffs shown for review; NOT included in technical allowlist pending Work choice.'))
put('PROTECTION_AND_IDENTITY.json',dict(selected101=101,protected4460_unchanged=4460,management5_authorized_delta=delta,head=head,desired_candidate_parent=head,branch=pre['branch'],index_clean=True,git_writes=False))
files=list(direct.values())+[rec(p) for p in sorted(F.rglob('*')) if p.is_file()];assert len({x['path'] for x in files})==len(files)
put('CANDIDATE_ALLOWLIST.json',dict(status='PROPOSED_EXACT_SCOPE_NOT_STAGED',records=files,total_bytes=sum(x['bytes'] for x in files),largest=sorted(files,key=lambda x:x['bytes'],reverse=True)[:25],count=len(files),external_count=len(external),review_boundaries='Review-only proposal. No Git operations or external reviewer delivery until Work freezes exact candidate scope.'))
print('PACKAGE_PREPARED',len(files),sum(x['bytes'] for x in files),'rawreports',len(timing),'external',len(external),flush=True)
