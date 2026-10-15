from pathlib import Path
import subprocess,json,hashlib,datetime,time,shutil,sys,re
R=Path(__file__).resolve().parents[1];kind=sys.argv[1]
spec={'earlyack':('rtl/m5c_fusion/m5b1_uart.sv','6:if(ready)begin if(crc_pos==3)state<=7;',"6:if(ready)begin if(crc_pos==3)begin diag_done<=1;state<=0;end ",0,'DIAG_EARLY_RECORD_ACK')}
rel,old,new,case,fatal=spec[kind]
D=R/'reports/m5c_diagnostics'/('stage2_negative_'+kind+'_'+datetime.datetime.now().strftime('%Y%m%d_%H%M%S'));D.mkdir()
original=R/rel;data=original.read_bytes();assert data.count(old.encode())==1
mutated=data.replace(old.encode(),new.encode());assert mutated.replace(new.encode(),old.encode(),1)==data if kind=='window' else True
mutant=D/original.name;mutant.write_bytes(mutated)
sources=sorted((R/'rtl/m5c_fusion').glob('*.sv'))+sorted((R/'rtl/m5c_fusion/m5a_copy').glob('*.v'))+[R/'rtl/m5c_diagnostics/m5c_diag_slot_guard.sv',R/'rtl/m5c_diagnostics/m5c_diag_record_bridge.sv',R/'rtl/m5c_diagnostics/m5c_diag_observer_v2.sv',R/'tb/m5c_diagnostics/tb_diag_coupled_ack.sv']
assert sources.count(original)==1;sources=[mutant if p==original else p for p in sources]
def rec(p):
 b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
inputs=[rec(p) for p in sources+[original,Path(__file__)]];(D/'INPUTS.json').write_text(json.dumps(inputs,indent=2));(D/'snapshots').mkdir()
for i,x in enumerate(inputs):shutil.copyfile(x['path'],D/'snapshots'/f'{i:03d}_{Path(x["path"]).name}')
offset=data.index(old.encode());assert mutated[:offset]+old.encode()+mutated[offset+len(new):]==data
(D/'DERIVATION.json').write_text(json.dumps(dict(original=rec(original),mutant=rec(mutant),offset=offset,old=old,new=new,inverse_byte_exact=True,expected_fatal=fatal,case=case),indent=2))
N=Path('E:/Modelsim_10.1c/win64');commands=[[str(N/'vlib.exe'),'work'],[str(N/'vlog.exe'),'-sv','-work','work','+incdir+'+str(R/'rtl/m5c_fusion')]+[str(p) for p in sources],[str(N/'vsim.exe'),'-c','-novopt','-lib','work','tb_diag_coupled_ack','+PHASE=2','+OUT='+D.as_posix(),'-l','sim.log','-do','run -all; quit -code 0']]
steps=[]
for i,cmd in enumerate(commands):
 start=time.time();p=subprocess.Popen(cmd,cwd=D,stdout=subprocess.PIPE,stderr=subprocess.STDOUT);(D/f'OWNER_{i}.json').write_text(json.dumps(dict(pid=p.pid,start=start,cmd=cmd,cwd=str(D)),indent=2));print(i,p.pid,D,flush=True);timeout=False
 try:log=p.communicate(timeout=180)[0]
 except subprocess.TimeoutExpired:
  timeout=True;subprocess.run(['taskkill','/PID',str(p.pid),'/T','/F'],capture_output=True);log=p.communicate()[0]
 (D/f'step{i}.log').write_bytes(log);steps.append(dict(exit=p.returncode,timeout=timeout,log=rec(D/f'step{i}.log')))
 if timeout or p.returncode or b'** Error:' in log:break
text=(D/'sim.log').read_text(errors='replace') if (D/'sim.log').exists() else ''
actual=re.findall(r'\*\* Fatal: ([^\r\n]+)',text)
ok=len(steps)==3 and all(s['exit']==0 and not s['timeout'] for s in steps) and len(actual)==1 and actual[0].startswith(fatal) and '** Error:' not in text and inputs==[rec(Path(x['path'])) for x in inputs]
(D/'RESULT.json').write_text(json.dumps(dict(status='PASS_EXPECTED_NAMED_FATAL' if ok else 'FAIL',actual_fatals=actual,steps=steps,raw_exit=steps[-1]['exit'],inputs_unchanged=inputs==[rec(Path(x['path'])) for x in inputs]),indent=2));print('RESULT',ok,D,flush=True)

