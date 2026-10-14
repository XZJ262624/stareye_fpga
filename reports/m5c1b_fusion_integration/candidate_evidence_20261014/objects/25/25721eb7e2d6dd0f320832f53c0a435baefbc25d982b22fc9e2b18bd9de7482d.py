from pathlib import Path
import subprocess,json,hashlib,time,sys,shutil,re,collections
F=Path(__file__).resolve().parent;R=F.parents[2];P=F/'mirror/efinity/m5c_fusion_i3';Q=F/'queries';m=json.loads((F/'COPY_MANIFEST.json').read_text());plan=json.loads((F/'QUERY_DERIVATION.json').read_text())
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def preserve(W,label):
 rows=[]
 for p in sorted(P.rglob('*'))+sorted(W.iterdir()):
  if not p.is_file():continue
  a=rec(p);q=F/'content_archive'/a['sha256'][:2]/a['sha256'];q.parent.mkdir(parents=True,exist_ok=True)
  if not q.exists():shutil.copyfile(p,q)
  z=rec(q);assert z['sha256']==a['sha256'] and z['bytes']==a['bytes'];rows.append(dict(original=a,archive=z))
 out=W/(label+'.json');assert not out.exists();out.write_text(json.dumps(dict(records=rows),indent=2));return rec(out)
def verify_previous(result):
 for x in json.loads((R/result['output_archive']['path']).read_text())['records']:
  assert rec(R/x['archive']['path'])==x['archive']
  if x['original']['path'].startswith(P.relative_to(R).as_posix()+'/'):assert rec(R/x['original']['path'])==x['original']
def parsed(p):
 txt=p.read_text();assert re.search(r'Timing Model\s*:\s*I3',txt,re.I),('HEADER_NOT_I3',str(p))
 rows=[]
 for block in re.split(r'\+{4} Path \d+ \+{4,}',txt)[1:]:
  def val(k):
   a=re.search(r'^'+re.escape(k)+r'\s*:\s*([^\r\n]+)',block,re.M);return a[1].strip() if a else None
  rows.append(dict(end=val('Path End'),slack=float(val('Slack').split()[0]),cq=float(val('+ Clock To Q + Data Path Delay').split()[0]) if val('+ Clock To Q + Data Path Delay') else None,arrival=float(val('End-of-path arrival time').split()[0]) if val('End-of-path arrival time') else None))
 return rows
previous=json.loads((F/'route/RESULT.json').read_text());assert previous['status']=='PASS_STAGE' and previous['resources']['pass'];verify_previous(previous)
for item in plan['queries']:
 name=item['name'];query=R/item['query']['path'];assert rec(query)==item['query'];W=F/('sta_'+name);W.mkdir(exist_ok=False);verify_previous(previous)
 for x in m['records']:assert rec(R/x['source']['path'])==x['source']
 inputs=[rec(R/x['copy']['path']) for x in m['records']];db=[rec(p) for root in ['outflow','work_pnr'] for p in sorted((P/root).rglob('*')) if p.is_file() and p.suffix in ['.vdb','.lbf','.troutingtraces'] and not p.name.endswith('.prevpr.vdb')]
 batch=W/'run.bat';batch.write_text('@echo off\ncall E:\\Efinity\\2025.1\\bin\\setup.bat\nif errorlevel 1 exit /b %errorlevel%\nE:\\Efinity\\2025.1\\bin\\efx_sta.exe --prj Ti60_Demo --output_dir outflow --tclsh "'+str(query)+'"\nexit /b %errorlevel%\n')
 (W/'INPUTS.json').write_text(json.dumps(dict(design=inputs,database=db,query=rec(query),runner=rec(Path(__file__)),batch=rec(batch),derivation=rec(F/'QUERY_DERIVATION.json')),indent=2));pre=preserve(W,'PRE_NATIVE_ARCHIVE');start=time.time();timed=False
 with (W/'tool.log').open('wb') as f:
  p=subprocess.Popen(['cmd','/c',str(batch)],cwd=P,stdout=f,stderr=subprocess.STDOUT);owner=dict(pid=p.pid,started_unix=start,command=['cmd','/c',str(batch)],cwd=str(P));(W/'OWNER.json').write_text(json.dumps(owner,indent=2));print('OWNED_STA',name,p.pid,flush=True)
  ps='Get-CimInstance Win32_Process -Filter "ProcessId = '+str(p.pid)+'" | Select-Object ProcessId,ParentProcessId,CreationDate,Name,CommandLine | ConvertTo-Json -Depth 4';ci=subprocess.run(['powershell','-NoProfile','-Command',ps],capture_output=True);(W/'OWNER_CIM.json').write_bytes(ci.stdout)
  try:code=p.wait(timeout=1200)
  except subprocess.TimeoutExpired:
   timed=True
   if p.poll() is None:subprocess.run(['taskkill','/PID',str(p.pid),'/T','/F'],stdout=f,stderr=subprocess.STDOUT)
   code=p.wait(timeout=30)
 log=(W/'tool.log').read_text(errors='replace');unchanged=all(rec(R/x['path'])==x for x in inputs+db);ok=code==0 and not timed and unchanged and 'ACTUAL_TIMING_MODEL I3' in log and ('FRESH_QUERY_COMPLETE '+name) in log
 post=preserve(W,'POST_NATIVE_ARCHIVE');result=dict(status='PASS_QUERY_EXECUTION_PENDING_RECONCILIATION' if ok else 'FAIL_QUERY_BLOCK_DESCENDANTS',exit=code,timeout=timed,seconds=time.time()-start,source_db_unchanged=unchanged,input_archive=pre,output_archive=post,log=rec(W/'tool.log'));(W/'RESULT.json').write_text(json.dumps(result,indent=2));assert ok,result
 if name.startswith('01_'):
  normal={}
  for mode in ['setup','hold']:
   rows=parsed(P/('outflow/normal_'+mode+'.rpt'));assert rows and min(x['slack'] for x in rows)>=0;normal[mode]=min(x['slack'] for x in rows)
  check=(P/'outflow/selected_check.rpt').read_text();counts={k:int(v) for k,v in re.findall(r'checking (\w+) \((\d+)\)',check)}
  for k in ['no_clock','unconstrained_internal_endpoints','multiple_clock']:assert counts[k]==0,(k,counts)
  groups=json.loads((F/'QUERY_EXPECTATIONS.json').read_text())['groups'];bundle=[]
  for g in groups:
   if not g['name'].endswith('_destination'):continue
   p=P/('outflow/bundle_'+g['name']+'_setup.rpt');rows=parsed(p);assert set(x['end'] for x in rows)==set(g['pins']) and len(rows)==len(g['pins']);assert min(x['slack'] for x in rows)>=0 and max(x['cq'] for x in rows)<=5 and max(x['arrival'] for x in rows)-min(x['arrival'] for x in rows)<=5
   bundle.append(dict(group=g['name'],count=len(rows),max_cq_data=max(x['cq'] for x in rows),skew=max(x['arrival'] for x in rows)-min(x['arrival'] for x in rows),report=rec(p)))
  assert len(bundle)==24 and sum(x['count'] for x in bundle)==1487
  (W/'INITIAL_PHYSICAL_GATE.json').write_text(json.dumps(dict(status='PASS_NORMAL_AND_BUNDLE_SETUP_ONLY_HOLD_CUT_CONTROL_RECONCILIATION_PENDING',normal=normal,counts=counts,bundle=bundle),indent=2))
 print('DONE_STA',name,result['seconds'],flush=True);previous=result
print('ALL_QUERIES_EXECUTED_NOT_FINAL_QUALIFICATION',flush=True)
