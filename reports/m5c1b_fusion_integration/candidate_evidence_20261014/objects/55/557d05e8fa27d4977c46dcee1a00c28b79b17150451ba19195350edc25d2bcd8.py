from pathlib import Path
import json,hashlib,subprocess,datetime,os
F=Path(__file__).resolve().parent;R=F.parents[2];P=F/'mirror/efinity/m5c_fusion_i3'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def put(name,a):
 p=F/name;assert not p.exists(),p;p.write_text(json.dumps(a,indent=2));return rec(p)
def check(xs):
 for x in xs:assert rec(R/x['path'])==x,x['path']
 return len(xs)
assert json.loads((F/'TIMING_CURRENT_AUDIT.json').read_text())['status']=='PASS_ACTUAL_FRESH_I3_PENDING_FINAL_ARCHIVE_PROTECTION_SEAL'
assert json.loads((F/'QUERY_CHAIN_RESULT.json').read_text())['exit']==0
assert json.loads((F/'EXIT_NATIVE_CIM.json').read_text(encoding='utf-8-sig'))==[]
cache={};archives=[];history=[]
for p in sorted(F.glob('*/*_NATIVE_ARCHIVE.json')):
 a=json.loads(p.read_text());assert a['records']
 for x in a['records']:
  z=x['archive'];q=R/z['path']
  if z['path'] not in cache:cache[z['path']]=rec(q)
  assert cache[z['path']]==z and z['bytes']==x['original']['bytes'] and z['sha256']==x['original']['sha256']
  if p.parent.name=='route' and p.name=='POST_NATIVE_ARCHIVE.json' and x['original']['path'].endswith(('Ti60_Demo.timing.rpt','Ti60_Demo.prevpr.vdb')):history.append(x)
 archives.append(dict(manifest=rec(p),records=len(a['records'])))
assert len(archives)==18 and len(history)==2,(len(archives),len(history))
put('ARCHIVE_CHAIN_AUDIT.json',dict(status='PASS_ALL_STAGE_OUTPUTS_PRESERVED_NO_ROUTE_HISTORY_GAP',archives=archives,unique_content_files=len(cache),route_original_timing_and_previous_database=history,notes='Original path in each archive record is a historical role; corresponding content-addressed archive bytes are the immutable evidence. Current mirror files are separately bound at final hash.'))
identity=R/'reports/m5c1b_fusion_integration/final_source_selection_20261013_063600/SELECTED_SOURCE_IDENTITY.json';sourcecheck=check([x['adopted'] for x in json.loads(identity.read_text())['records']]);protected=check(json.loads((R/'reports/m5c1b_fusion_integration/SOURCE_PROTECTION.json').read_text()));assert sourcecheck==101 and protected==4465
copy=json.loads((F/'COPY_MANIFEST.json').read_text());check([x['source'] for x in copy['records']]);settings=[]
for x in copy['settings']:
 a=json.loads((R/x['source']['path']).read_text());b=json.loads((R/x['copy']['path']).read_text());i=b['args'].index('--base_path')+1;assert b['args'][i]==x['new'];b['args'][i]=x['old'];assert a==b;settings.append(x)
assert len(settings)==11
pre=json.loads((F/'PREFLIGHT.json').read_text());proofchecks=0
for x in pre['proofs']:assert rec(R/x['manifest']['path'])==x['manifest'];proofchecks+=check(json.loads((R/x['manifest']['path']).read_text())['records'])
assert proofchecks==9569
os.environ['GIT_OPTIONAL_LOCKS']='0';cmd=['git','-c','safe.directory=F:/Projects/stareye_fpga'];head=subprocess.check_output(cmd+['rev-parse','HEAD'],cwd=R,text=True).strip();assert head==pre['head'];assert not subprocess.check_output(cmd+['diff','--cached','--name-only'],cwd=R,text=True).strip();status=subprocess.check_output(cmd+['status','--porcelain=v1','-uno'],cwd=R,text=True)
put('PROTECTION_FINAL.json',dict(source101=sourcecheck,protected4465=protected,qualified_proof_records=proofchecks,settings_rebases=11,head=head,parent=pre['parent'],branch=pre['branch'],index_empty=True,tracked_worktree_status=status,mismatches=[]))
for stage in ['map','interface','place','route']:
 a=json.loads((F/stage/'RESULT.json').read_text());assert a['status']=='PASS_STAGE' and a['exit']==0 and not a['timeout'] and a['production_unchanged'] and a['source_equivalent'] and not a['forbidden']
# No programming outputs have been generated. DDR initialization source bins are declared design inputs.
for x in (P/'outflow').rglob('*'):assert not (x.is_file() and x.name.endswith(('.bit','.bit.bin','.hex','.hex.bin','.pgm'))),x
for p in sorted(F.glob('sta_*/RESULT.json')):
 a=json.loads(p.read_text());assert a['status']=='PASS_QUERY_EXECUTION_PENDING_RECONCILIATION' and a['exit']==0 and not a['timeout']
t=json.loads((F/'TIMING_CURRENT_AUDIT.json').read_text());hand=put('FINAL_HANDBACK.json',dict(status='PASS_FRESH_BUILD_AND_I3_TIMING_ONLY_STOP_FOR_WORK',branch=pre['branch'],head=head,parent=pre['parent'],candidate=None,bitstream=None,resources=t['resource'],setup_min_ns=t['setup_min'],hold_min_ns=t['hold_min'],bundle_groups=24,bundle_destinations=1487,bundle_max_clock_Q_plus_data_ns=t['bundled24_dest1487_max'],bundle_arrival_skew_ns=t['bundled_skew_max'],coverage=t['coverage'],clock_pairs=t['clock_pairs'],records=[rec(F/n) for n in ['TIMING_CURRENT_AUDIT.json','CONTROL_COVERAGE_CURRENT.json','GLOBAL_D_COVERAGE_CURRENT.json','BUNDLE_CURRENT_AUDIT.json','EXTERNAL_IO_BOUNDARY.json','ARCHIVE_CHAIN_AUDIT.json','PROTECTION_FINAL.json','CURRENT_SDC_ALIAS_RECEIPT.json','CURRENT_SCOPED_TARGETS.json','MAPPED_AUDIT_GATE.json','NATIVE_SELECTOR_GATE.json']],limits=['Actual I3 model only; hold margin is narrow and no multi-PVT or board margin claim.','External7input/135output delay boundaries are explicit; internal0/0/0 only.','No PGM/bitstream/candidate/Git mutation/hardware performed.','Previously failed fixtures remain failed; current functional gates have separate scope.','Fresh stage archives preserve original route timing.rpt/prevpr.vdb, repairing provenance for this run only; old diagnostic gap remains old history.','Startup automatic tool timing summaries excluded; only explicit actual-I3 query reports qualify.']))
records=[rec(p) for p in sorted(F.rglob('*')) if p.is_file() and p.name!='HANDBACK_MANIFEST.json']
put('HANDBACK_MANIFEST.json',dict(status='SEALED_CURRENT_FILES_AND_CONTENT_ARCHIVES',records=records,scope='Current new package files; historical original path fields inside immutable archive manifests are not falsely asserted current.'))
print('FINAL_HANDBACK',hand,'manifest_records',len(records),rec(F/'HANDBACK_MANIFEST.json'),flush=True)
