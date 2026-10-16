from pathlib import Path
import sys,json,subprocess,hashlib,time,datetime,shutil
sys.dont_write_bytecode=True
R=Path(__file__).resolve().parents[1];sys.path.insert(0,str(R/'scripts'));from m5c_shadow_oracle import check
out=R/'reports/m5c_shadow_stats_20261016'/('observer_'+datetime.datetime.now().strftime('%Y%m%d_%H%M%S'));out.mkdir(parents=True)
rtl=R/'rtl/m5c_diagnostics/m5c_diag_observer_v3.sv';tb=R/'tb/m5c_diagnostics/tb_shadow_observer.sv';osd=R/'rtl/m5c_fusion/m5a_copy/m5a_osd.v';native=Path('E:/Modelsim_10.1c/win64')
def rec(p):
 b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
inputs=[rec(p) for p in [rtl,tb,osd,Path(__file__),R/'scripts/m5c_shadow_oracle.py']];(out/'INPUTS.json').write_text(json.dumps(inputs,indent=2))
(out/'input_snapshot').mkdir()
for x in inputs:shutil.copyfile(x['path'],out/'input_snapshot'/Path(x['path']).name)
def run(case,source,label,expected=None,fatal=None):
 p=out/label;p.mkdir();steps=[]
 cmds=[[str(native/'vlib.exe'),'work'],[str(native/'vlog.exe'),'-sv','-work','work',str(source),str(osd),str(tb)],[str(native/'vsim.exe'),'-c','-novopt','-lib','work','tb_shadow_observer',f'-gCASE={case}',f'+OUT={p.as_posix()}','-l','sim.log','-do','run -all; quit -code 0']]
 if expected:cmds[-1]+=[f'+EXPECT={expected.as_posix()}',f'+FATAL_NAME={fatal}']
 for i,cmd in enumerate(cmds):
  start=time.time();proc=subprocess.Popen(cmd,cwd=p,stdout=subprocess.PIPE,stderr=subprocess.STDOUT);(p/f'OWNER_{i}.json').write_text(json.dumps(dict(pid=proc.pid,command=cmd,cwd=str(p),started=start),indent=2));timeout=False
  try:log=proc.communicate(timeout=120)[0]
  except subprocess.TimeoutExpired:
   timeout=True;subprocess.run(['taskkill','/PID',str(proc.pid),'/T','/F'],capture_output=True);log=proc.communicate()[0]
  (p/f'step{i}.log').write_bytes(log);steps.append(dict(command=cmd,exit=proc.returncode,timeout=timeout,seconds=time.time()-start,log=rec(p/f'step{i}.log')))
  if timeout or proc.returncode!=0 or (i==1 and b'** Error:' in log):break
 result=dict(case=case,label=label,inputs=[rec(source),rec(tb),rec(osd)],steps=steps,status='NOT_PASS')
 try:
  assert len(steps)==3 and all(x['exit']==0 and not x['timeout'] for x in steps),'NATIVE_STAGE_FAILURE'
  text=(p/'sim.log').read_text(errors='replace')
  if fatal:
   assert text.count('** Fatal:')==1 and ('** Fatal: '+fatal) in text,'EXPECTED_NAMED_FATAL_MISSING_OR_OTHER_FATAL'
   result['status']='PASS_EXPECTED_NAMED_FATAL';result['raw_native_exit']=steps[-1]['exit']
  else:
   assert f'DIAG_SIM_DONE case={case}' in text and '** Fatal:' not in text,'POSITIVE_SIM_FAILURE'
   result['oracle']=check(p,case);result['status']='PASS_POSITIVE'
 except Exception as e:result['error']=str(e)
 (p/'RESULT.json').write_text(json.dumps(result,indent=2));print(label,result['status'],result.get('error',''),flush=True);return p,result
results=[];positive={}
resume=Path(sys.argv[1]).resolve() if len(sys.argv)>1 else None
if resume:
 oldinputs=json.loads((resume/'INPUTS.json').read_text())
 for x in oldinputs:
  if x['path']!=str(Path(__file__)):assert rec(Path(x['path']))==x
 for case in range(9):
  p=resume/f'positive_{case}';r=json.loads((p/'RESULT.json').read_text());assert r['status']=='PASS_POSITIVE';results.append(r);positive[case]=p
 prior=json.loads((resume/'negative_row_gate/RESULT.json').read_text());assert prior['status']=='PASS_EXPECTED_NAMED_FATAL';results.append(prior)
 (out/'RESUME_RECEIPT.json').write_text(json.dumps(dict(parent_inputs=rec(resume/'INPUTS.json'),parent_results=[rec(resume/f'positive_{c}/RESULT.json') for c in range(9)]+[rec(resume/'negative_row_gate/RESULT.json')],only_runner_changed=True,reason='Global reverse replacement also touched pre-existing P3 expression; switch to exact changed-line inverse. No RTL/TB/oracle changes.'),indent=2))
else:
 for case in range(9):
  p,r=run(case,rtl,f'positive_{case}');results.append(r);positive[case]=p
  if r['status']!='PASS_POSITIVE':break
if (len(results)==9 and all(x['status']=='PASS_POSITIVE' for x in results)) or resume:
 base=rtl.read_text();mutants=[('row_gate',0,'wire row_candidate=candidate&&row_complete&&row_equal&&row_tag_good;','wire row_candidate=candidate&&row_complete&&row_tag_good;','DIAG_ROW_GATE_REMOVED'),('pre_osd',0,"osd_rgb==24'h00ffff","fused_rgb==24'h00ffff",'DIAG_PRE_OSD_USED'),('mode',1,"mode==6&&enable&&fused_rgb==24'h00ffff","enable&&fused_rgb==24'h00ffff",'DIAG_MODE_IGNORED'),('identity',0,'word_data<=memory[read_word];','word_data<=memory[read_word]; if(record_ready)memory[8]<=source_descriptor[63:0];','DIAG_IDENTITY_EARLY_OVERWRITE')]
 mutants += [('schema',0,"aborted,1'b1,32'd2}","aborted,1'b1,32'd1}",'SHADOW_SCHEMA_VERSION'),('equal_counter',0,'equal_fail<=inc(equal_fail);','equal_fail<=equal_fail;','SHADOW_EQUAL_COUNT'),('tile_select',0,'if(shadow_events[3])tile64_count','if(shadow_events[4])tile64_count','SHADOW64_COUNTER_SELECT')]
 for name,case,before,after,fatal in mutants:
  if resume and name=='row_gate':continue
  count=base.count(before);assert count>=1
  original_lines=base.splitlines(keepends=True);derived_lines=[line.replace(before,after) for line in original_lines];changed=[i for i,(a,b) in enumerate(zip(original_lines,derived_lines)) if a!=b]
  restored=derived_lines.copy()
  for i in changed:assert derived_lines[i]==original_lines[i].replace(before,after);restored[i]=original_lines[i]
  assert ''.join(restored)==base
  derived=''.join(derived_lines);p=out/(name+'_mutant.sv');p.write_text(derived)
  (out/(name+'_DERIVATION.json')).write_text(json.dumps(dict(parent=rec(rtl),derived=rec(p),before=before,after=after,replacements=count,inverse_exact=True,changed_line_indices=changed,inverse_scope='Only exact changed lines; existing identical replacement substrings elsewhere are preserved.'),indent=2))
  _,r=run(case,p,'negative_'+name,positive[case]/'expected_0.hex',fatal);results.append(r)
assert inputs==[rec(Path(x['path'])) for x in inputs],'ACTIVE_INPUT_CHANGED'
(out/'SUMMARY.json').write_text(json.dumps(dict(results=results,inputs_unchanged=True,all_pass=len(results)==16 and all(x['status'].startswith('PASS') for x in results)),indent=2));print('OUTPUT',out,flush=True)
