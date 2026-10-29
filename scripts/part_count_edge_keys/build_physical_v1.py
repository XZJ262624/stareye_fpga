"""One fresh minimal flow, exact existing CDC selectors and basic native STA.
No all-FF/metadata/clock-pair audit; no programming hardware.
"""
import sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from physical_common import *
import shutil,xml.etree.ElementTree as ET,sys,datetime
assert json.loads((O/'STAGE1_RESULT.json').read_text())['passed']
sources=json.loads((O/'PRODUCTION_MANIFEST.json').read_text());parents=json.loads((O/'PARENT_PRODUCTION_MANIFEST.json').read_text());verify(sources);verify(parents)
resume=sys.argv[1:]==['--resume-after-interface'];assert not sys.argv[1:] or resume
if resume:
 a=json.loads((O/'ACTIVE_PHYSICAL.json').read_text());F=R/a['path'];B=R/a['project'];mirror=F/'mirror'
 for stage in ('map','interface'):assert json.loads((F/stage/'native_RESULT.json').read_text())['passed']
 for x in sources:
  if x['path'].endswith(('Ti60_Demo.xml','Ti60_Demo.pt.sdc')):continue
  assert rec(mirror/x['path'])['sha256']==x['sha256']
 save(O/'STATIC_PARSER_RECOVERY.json',dict(reason='Initial static parser omitted stripping Verific block comments between closing port parentheses and semicolon. Only1 cell parsed; no evidence of a missing physical CDC endpoint.',production_changes=[],map_interface_rerun=False,original_failure=rec(O/'BUILD_EXCEPTION.json')))
else:
 F=O/('physical_'+time.strftime('%Y%m%d_%H%M%S'));F.mkdir();mirror=F/'mirror'
 for x in sources:
  src=R/x['path'];dst=mirror/x['path'];dst.parent.mkdir(parents=True,exist_ok=True);dst.write_bytes(src.read_bytes());assert rec(dst)['sha256']==x['sha256']
 B=mirror/'efinity/part_count_edge_keys_i3';save(O/'ACTIVE_PHYSICAL.json',dict(path=F.relative_to(R).as_posix(),project=B.relative_to(R).as_posix()))
 save(F/'SOURCE_BINDING.json',dict(sources=sources,parent_sources=parents,xml=rec(B/'Ti60_Demo.xml'),sdc=rec(B/'Ti60_Demo_I3.sdc')))
save(O/'PHYSICAL_PHASE_RESULT.json',dict(status='RUNNING',running=True))
save(O/'PHYSICAL_MANAGER.json',dict(pid=os.getpid(),physical=F.relative_to(R).as_posix(),started_unix=time.time()))
save(O/'PHYSICAL_FINAL_RESULT.json',dict(status='RUNNING',running=True,job='part_count_edge_keys_physical',physical=F.relative_to(R).as_posix()))
save(F/'FINAL_RESULT.json',dict(status='RUNNING',running=True,job='part_count_edge_keys_physical',physical=F.relative_to(R).as_posix()))
context=F/'CONTEXT.json'
save(context,dict(job='part_count_edge_keys_physical',result=str(F/'FINAL_RESULT.json'),codex_checked_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),codex_observation='待确认（开发模型 Astra High）',hardware_next='否，仍须 Work 核定及用户独立 A 审查'))
watch=subprocess.run(['powershell.exe','-NoProfile','-ExecutionPolicy','Bypass','-File',str(R/'scripts/work_notifications/start_watch_v2.ps1'),
 '-ResultPath',str(F/'FINAL_RESULT.json'),'-StatePath',str(F/'NOTIFICATION_STATE.json'),'-JobName','part_count_edge_keys_physical','-TimeoutMinutes','120','-ContextPath',str(context)],
 capture_output=True,text=True,creationflags=subprocess.CREATE_NO_WINDOW,timeout=30)
(F/'watch_start.log').write_text(watch.stdout+watch.stderr);print(watch.stdout,flush=True)
assert watch.returncode==0,'WATCHER_START_FAILED'
prefix='call E:\\Efinity\\2025.1\\bin\\setup.bat && '
def run(stage,command,marker,timeout=7200):
 heartbeat('PHYSICAL_'+stage.upper());d=json.loads((O/'PHYSICAL_PHASE_RESULT.json').read_text(encoding='utf-8-sig'));d.update(status='RUNNING',running=True,phase='PHYSICAL_'+stage.upper());save(O/'PHYSICAL_PHASE_RESULT.json',d)
 result=execute(F/stage,'native',['cmd.exe','/d','/c',prefix+command],marker,timeout,cwd=B);verify(sources);verify(parents)
 text=(F/stage/'native.log').read_text(errors='replace')
 if stage in ('map','interface','bitgen'):
  flow='pgm' if stage=='bitgen' else stage
  assert re.search(r'\b'+flow+r'\s*:\s*PASS\b',text),text[-2000:]
 if stage in ('query','place','route','sta'):
  sdc=(B/'Ti60_Demo_I3.sdc').read_text();start=next(i+1 for i,l in enumerate(sdc.splitlines()) if l.startswith('# Standalone foreground-only'))
  warnings=[l for l in text.splitlines() if 'WARNING' in l and (m:=re.search(r'\[SDC .*?:(\d+)\]',l)) and int(m[1])>=start]
  assert not warnings,warnings
  save(F/stage/'CDC_APPLICATION.json',dict(passed=True,first_CDC_line=start,warnings=warnings,sdc=rec(B/'Ti60_Demo_I3.sdc')))
 before=json.loads((F/'SOURCE_BINDING.json').read_text())
 xml_before=R/'efinity/part_count_edge_keys_i3/Ti60_Demo.xml';xml_after=B/'Ti60_Demo.xml'
 allowed={'last_change','last_run_state','last_run_flow','config_result_in_sync','design_ood','place_ood','route_ood'}
 a=ET.parse(xml_before).getroot();b=ET.parse(xml_after).getroot()
 changes={k:dict(before=a.attrib.get(k),after=b.attrib.get(k)) for k in set(a.attrib)|set(b.attrib) if a.attrib.get(k)!=b.attrib.get(k)}
 assert set(changes)<=allowed,changes
 for k in allowed:a.attrib.pop(k,None);b.attrib.pop(k,None)
 def semantic(node):return (node.tag,sorted(node.attrib.items()),(node.text or '').strip(),[semantic(c) for c in node])
 assert semantic(a)==semantic(b),'XML_TECHNICAL_CHANGE'
 save(F/stage/'XML_RECONCILIATION.json',dict(passed=True,changes=changes,before=rec(xml_before),after=rec(xml_after)))
 return result
try:
 if not resume:
  run('map','call E:\\Efinity\\2025.1\\bin\\efx_run.bat Ti60_Demo.xml --flow map',None)
  run('interface','call E:\\Efinity\\2025.1\\bin\\efx_run.bat Ti60_Demo.xml --flow interface',None)
 # All exact retained foreground CDC pins must exist in the fresh map.
 raw=re.sub(r'/\*.*?\*/','',(B/'outflow/Ti60_Demo.map.v').read_text().split('endmodule',1)[0],flags=re.S);cells={m[2].lstrip('\\'):set(re.findall(r'\.(\w+)\s*\(',m[3])) for m in re.finditer(r'^    (EFX_\w+)\s+(\\\S+|\w+)\s+\((.*?)\)\s*;',raw,re.M|re.S)}
 sdc=(B/'Ti60_Demo_I3.sdc').read_text();groups=[];missing=[];mapped_pins={name+'|'+port for name,ports in cells.items() for port in ports}
 for m in re.finditer(r'set (\w+) \[shape_exact \{(.*?)\}\s*(\w+)\]',sdc,re.S):
  pats=re.findall(r'\{(\^.*?)\}',m[2]);groups.append(dict(name=m[1],patterns=pats))
  for pat in pats:
   literal=re.sub(r'\\(.)',r'\1',pat[1:-1]);assert re.fullmatch(pat,literal)
   matches=[literal] if literal in mapped_pins else []
   if len(matches)!=1:missing.append(dict(pattern=pat,matches=matches))
 assert len(groups)==17 and not missing,(len(groups),missing)
 for key in range(2):
  pat=rf'^u_shape_system/u_controls/key_meta\[{key}\]~FF\|D$'
  matches=[p for p in mapped_pins if re.fullmatch(pat,p)]
  assert len(matches)==1,(pat,matches)
  groups.append(dict(name='key'+str(key),patterns=[pat]))
 baseline_map=R/'reports/shape_wide_roi_fast_20261022/physical_20261022_154646/mirror/efinity/shape_wide_roi_i3/outflow/Ti60_Demo.map.v'
 def clocks(path):
  text=re.sub(r'/\*.*?\*/','',path.read_text().split('endmodule',1)[0],flags=re.S)
  return {m[2].lstrip('\\'):re.search(r'\.CLK\s*\((.*?)\)',m[3],re.S)[1].strip() for m in re.finditer(r'^    (EFX_\w+)\s+(\\\S+|\w+)\s+\((.*?)\)\s*;',text,re.M|re.S) if re.search(r'\.CLK\s*\(',m[3])}
 old_clocks=clocks(baseline_map);new_clocks=clocks(B/'outflow/Ti60_Demo.map.v');clock_checks=[]
 for g in groups:
  for pat in g['patterns']:
   literal=re.sub(r'\\(.)',r'\1',pat[1:-1]);cell=literal.rsplit('|',1)[0]
   assert cell in old_clocks and cell in new_clocks,(cell,'CLOCK_MISSING')
   assert old_clocks[cell]==new_clocks[cell],(cell,old_clocks[cell],new_clocks[cell])
   clock_checks.append(dict(pin=literal,clock=new_clocks[cell]))
 save(F/'CDC_CLOCK_CORRESPONDENCE.json',dict(passed=True,checks=clock_checks,baseline_map=rec(baseline_map),fresh_map=rec(B/'outflow/Ti60_Demo.map.v')))
 save(F/'EXACT_CDC_SELECTOR_STATIC.json' ,dict(passed=True,groups=groups,missing=missing,map=rec(B/'outflow/Ti60_Demo.map.v'),sdc=rec(B/'Ti60_Demo_I3.sdc')))
 (B/'part_query.sdc').write_text(sdc+'\nputs {PART_EXACT_CDC_NATIVE_COMPLETE}\nexit 0\n')
 pnr='E:\\Efinity\\2025.1\\python311\\bin\\python.exe -B E:\\Efinity\\2025.1\\scripts\\efx_run_pnr.py Ti60_Demo --prj --family Titanium --device Ti60F225 --timing_model I3 '
 run('query',pnr+'--work_dir work_query --output_dir outflow --opt pack place timing_analysis=on seed=2 max_threads=32 sdc_file=part_query.sdc','PART_EXACT_CDC_NATIVE_COMPLETE')
 run('place',pnr+'--work_dir work_pnr --output_dir outflow --opt pack place timing_analysis=on seed=2 max_threads=32 sdc_file=Ti60_Demo_I3.sdc','Post-placement primitive-level checks is successful')
 run('route',pnr+'--work_dir work_pnr --output_dir outflow --opt route timing_analysis=on seed=2 max_threads=32 sdc_file=Ti60_Demo_I3.sdc','Ending stage final timing analysis')
 text=(B/'outflow/Ti60_Demo.route.rpt').read_text();resource={k:int(re.search(v,text)[1]) for k,v in dict(XLR=r'XLRs:\s*(\d+)',RAM=r'Memory Blocks:\s*(\d+)',DSP=r'DSP Blocks:\s*(\d+)').items()};assert resource['XLR']<=51680 and resource['RAM']<=204 and resource['DSP']<=128,resource
 save(F/'RESOURCE.json',dict(passed=True,resource=resource,report=rec(B/'outflow/Ti60_Demo.route.rpt')))
 # Basic normal timing and internal-unconstrained checks only. Re-evaluate
 # existing exact CDC collections in the actual routed native database.
 body='set_timing_model I3\nif {[get_timing_model] ne "I3"} {error WRONG_TIMING_MODEL}\nputs "ACTUAL_TIMING_MODEL [get_timing_model]"\n'
 for g in groups:
  for pat in g['patterns']:body+='set one [get_pins -regexp {'+pat+'}]\nif {[llength $one]!=1} {error PART_NATIVE_EXACT_SELECTOR_MISSING}\n'
 for mode in ('setup','hold'):body+=f'report_timing -{mode} -npaths 200 -nworst 1 -detail full_path -file part_normal_{mode}.rpt\n'
 body+='check_timing -verbose -file part_check.rpt\nreport_clocks -file part_clocks.rpt\nputs {PART_BASIC_STA_COMPLETE}\n'
 q=F/'basic_sta.tcl';q.write_text(body)
 run('sta','E:\\Efinity\\2025.1\\bin\\efx_sta.exe --prj Ti60_Demo --output_dir outflow --tclsh '+q.as_posix(),'PART_BASIC_STA_COMPLETE')
 normal={mode:[float(v) for v in re.findall(r'^Slack\s*:\s*([-\d.]+)',(B/f'outflow/part_normal_{mode}.rpt').read_text(),re.M)] for mode in ('setup','hold')}
 assert all(v and min(v)>0 for v in normal.values()),normal
 counts={k:int(v) for k,v in re.findall(r'checking (\w+) \((\d+)\)',(B/'outflow/part_check.rpt').read_text())}
 assert all(counts.get(k)==0 for k in ('no_clock','unconstrained_internal_endpoints','multiple_clock')),counts
 sta=dict(passed=True,status='PASS_BASIC_NORMAL_I3_INTERNAL_CONSTRAINT_CHECK',normal={k:min(v) for k,v in normal.items()},counts=counts,report=[rec(B/f'outflow/part_normal_{m}.rpt') for m in ('setup','hold')]+[rec(B/'outflow/part_check.rpt')],limitations='Inherited PLL SR and PVT restrictions retained; actual external UART endpoint counts are recorded in counts/report, not assumed unchanged. No new exhaustive FF/metadata or all-clock-pair audit')
 save(O/'BASIC_STA_RESULT.json',sta)
 # PGM here is offline bitstream file generation. No Programmer executable,
 # --program option, hardware cable or Flash operation is invoked.
 db=[rec(p) for p in sorted((B/'work_pnr').rglob('*')) if p.is_file()];save(F/'BIT_INPUTS.json',dict(routed_db=db,sources=sources,sdc=rec(B/'Ti60_Demo_I3.sdc'),sta=rec(O/'BASIC_STA_RESULT.json')))
 run('bitgen','call E:\\Efinity\\2025.1\\bin\\efx_run.bat Ti60_Demo.xml --flow pgm',None,1800)
 verify(db);bit=B/'outflow/Ti60_Demo.bit';assert bit.is_file() and bit.stat().st_size>0
 artifacts=O/'artifacts';artifacts.mkdir(exist_ok=True);dest=artifacts/'StarEye_CountEdgeKeys.bit';dest.write_bytes(bit.read_bytes())
 save(O/'BUILD_RESULT.json',dict(passed=True,status='PASS_FRESH_BUILD_BASIC_STA_BIT_OFFLINE',resource=resource,STA=sta,bit=rec(dest),native_bit=rec(bit),physical=F.relative_to(R).as_posix(),source_manifest=rec(O/'PRODUCTION_MANIFEST.json'),routed_db_binding=rec(F/'BIT_INPUTS.json'),hardware=False,git_mutation=False))
 save(O/'PHYSICAL_FINAL_RESULT.json',dict(status='PASS_PHYSICAL_BUILD_PENDING_WORK_REVIEW',passed=True,running=False,physical=F.relative_to(R).as_posix(),build=rec(O/'BUILD_RESULT.json')))
 save(F/'FINAL_RESULT.json',json.loads((O/'PHYSICAL_FINAL_RESULT.json').read_text()))
 save(O/'PHYSICAL_PHASE_RESULT.json',dict(status='PASS_PHYSICAL_BUILD_PENDING_WORK_REVIEW',passed=True,running=False))
 save(O/'HEARTBEAT.json',dict(status='BUILD_BIT_READY_FOR_MINIMAL_SNAPSHOT',running=False,updated_unix=time.time(),hardware_next=False))
 print('PART_BUILD_COMPLETE',json.dumps(rec(dest)),flush=True)
except Exception as error:
 save(O/'BUILD_EXCEPTION.json',dict(status='REQUIRES_WRITER_INSPECTION',error=repr(error),physical=F.relative_to(R).as_posix()));save(O/'PHYSICAL_FINAL_RESULT.json',dict(status='FAIL_PHYSICAL_REQUIRES_WRITER_INSPECTION',passed=False,running=False,error=repr(error),physical=F.relative_to(R).as_posix()));save(F/'FINAL_RESULT.json',json.loads((O/'PHYSICAL_FINAL_RESULT.json').read_text()));raise
