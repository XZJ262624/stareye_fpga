"""Root independent negative tests and evidence verification; no hardware access."""
from pathlib import Path
import subprocess,json,hashlib,re,sys,shutil,os
ROOT=Path(__file__).resolve().parents[1];R=ROOT/'reports/m5b0r_ddr_admission/root_review'
PY=sys.executable;MS=Path('E:/Modelsim_10.1c/win64')
def rec(p):return dict(path=p.relative_to(ROOT).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def command(args,cwd,log):
 with log.open('wb') as f:p=subprocess.run(list(map(str,args)),cwd=cwd,stdout=f,stderr=subprocess.STDOUT,timeout=900)
 return p.returncode,log.read_text(errors='replace')
def negatives():
 R.mkdir(parents=True,exist_ok=True);out=[]
 cases=[('diagnostic','m5b0r_transaction.sv','rdata!=data_pattern','1\'b0 && rdata!=data_pattern','tb_m5b0r_diagnostic',['+FAULT=1'], 'wrong detection'),
 ('arbiter','m5b0r_arbiter.sv','c_bid[owner*8+:8]=local_id','c_bid[owner*8+:8]=local_id^8\'h80','tb_m5b0r_arbiter',[], 'B misroute'),
 ('ack','m5b0r_arbiter.sv','!ddr_reset_ack&&!discard','!discard','tb_m5b0r_arbiter',[], 'ACK accepted request'),
 ('ack_a_edge','m5b0r_arbiter.sv','assign avalid=state==A&&!ddr_reset_ack','assign avalid=state==A','tb_m5b0r_arbiter',[], 'ACK DDR A handshake'),
 ('ack_w_edge','m5b0r_arbiter.sv','assign wvalid=state==W&&!ddr_reset_ack','assign wvalid=state==W','tb_m5b0r_arbiter',[], 'ACK DDR W handshake'),
 ('ack_b_edge','m5b0r_arbiter.sv','assign bready=state==B&&!ddr_reset_ack','assign bready=state==B','tb_m5b0r_arbiter',[], 'ACK DDR B handshake'),
 ('ack_r_edge','m5b0r_arbiter.sv','assign rready=state==R&&!ddr_reset_ack','assign rready=state==R','tb_m5b0r_arbiter',[], 'ACK DDR R handshake'),
 ('skip_walking','m5b0r_diagnostic.sv','else if(mode==5) begin mode<=6;phase<=6;walk<=0;end','else if(mode==5) begin range_pass<=1;status<=6;end','tb_m5b0r_diagnostic',[], 'diagnostic plan incomplete'),
 ('skip_guard','m5b0r_diagnostic.sv','phase<=7;point<=0;end','phase<=7;point<=1;end','tb_m5b0r_diagnostic',[], 'diagnostic plan command mismatch'),
 ('short_range','m5b0r_diagnostic.sv','RANGE_END-2048','RANGE_END-4096','tb_m5b0r_diagnostic',[], 'diagnostic plan command mismatch'),
 ('wrong_pattern','m5b0r_transaction.sv',"4:data_pattern={16{8'haa}}","4:data_pattern={16{8'h55}}",'tb_m5b0r_diagnostic',[], 'diagnostic plan pattern mismatch'),
 ('monitor','m5b0r_monitor.sv','actual,expected,failure_address','expected,actual,failure_address','tb_m5b0r_monitor',[], 'LED payload corruption')]
 for name,filename,old,new,top,plus,expected in cases:
  w=R/('negative_'+name);w.mkdir(exist_ok=True)
  src=[]
  for p in (ROOT/'rtl/m5b0r_ddr_admission').glob('*.sv'):
   s=p.read_text()
   if p.name==filename:
    assert old in s;s=s.replace(old,new)
   q=w/p.name;q.write_text(s);src.append(q)
  src+=list((ROOT/'tb/m5b0r_ddr_admission').glob('*.sv'))
  if not(w/'work').exists():
   rc,t=command([MS/'vlib.exe','work'],w,w/'vlib.log');assert rc==0
  rc,t=command([MS/'vlog.exe','-sv','-work','work',*src],w,w/'compile.log');assert rc==0 and '** Error:' not in t
  rc,t=command([MS/'vsim.exe','-c','-novopt','-onfinish','exit','work.'+top,*plus,'-do',ROOT/'tb/m5b0r_ddr_admission/run.do'],w,w/'run.log')
  # ModelSim 10.1c can return zero on $fatal with -onfinish exit. Exercise
  # the REAL project's fail-closed Python runner, which also rejects Fatal
  # text, rather than trusting the simulator process exit code alone.
  assert expected in t and '** Fatal:' in t,(name,rc,t[-3000:])
  child=("import importlib.util;from pathlib import Path;"
    "spec=importlib.util.spec_from_file_location('runner',"+repr(str(ROOT/'scripts/m5b0r_sim.py'))+");"
    "m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);"
    "m.TB=Path("+repr(str(w))+");m.OUT=m.TB;"
    "m.run("+repr([str(MS/'vsim.exe'),'-c','-novopt','-onfinish','exit','work.'+top,*plus,'-do',str(ROOT/'tb/m5b0r_ddr_admission/run.do')])+",'acceptance')")
  driver_rc,driver_text=command([PY,'-B','-c',child],ROOT,w/'driver.log')
  assert driver_rc!=0 and expected in driver_text,(name,driver_rc,driver_text[-2000:])
  out.append(dict(case=name,simulator_exit_code=rc,acceptance_exit_code=driver_rc,expected_failure=expected,log=rec(w/'run.log'),driver_log=rec(w/'driver.log')))
 rc,t=command([PY,'-B',ROOT/'scripts/m5b0r_models.py','--negative'],ROOT,R/'software_negative.log')
 assert rc!=0 and 'canary comparator mutation' in t;out.append(dict(case='software_comparator_disabled',exit_code=rc))
 (R/'NEGATIVE_RESULTS.json').write_text(json.dumps(dict(status='PASS_NEGATIVE_ACCEPTANCE',cases=out),indent=2));print('ROOT_NEGATIVES_PASS',len(out))
def normal():
 R.mkdir(parents=True,exist_ok=True)
 for mode in ('diagnostic','monitor'):
  rc,t=command([PY,'-B',ROOT/'scripts/m5b0r_sim.py',mode],ROOT,R/(mode+'_replay.log'))
  assert rc==0,(mode,t[-2000:]);print('ROOT_REPLAY_PASS',mode,flush=True)
 # Independently chosen arbiter seed, in the already compiled library.
 rc,t=command([MS/'vsim.exe','-c','-novopt','-onfinish','exit','work.tb_m5b0r_arbiter','+SEED=20261009','-do',ROOT/'tb/m5b0r_ddr_admission/run.do'],ROOT/'tb/m5b0r_ddr_admission',R/'arbiter_independent_seed.log')
 assert rc==0 and 'M5B0R_ARBITER_PASS' in t;print('ROOT_ARBITER_INDEPENDENT_PASS',flush=True)
 (R/'REPLAY_RESULTS.json').write_text(json.dumps(dict(status='PASS_ROOT_REPLAY',diagnostic_cases=54,monitor_cases=6,arbiter_independent_seed=20261009,sources=[rec(p) for p in (ROOT/'rtl/m5b0r_ddr_admission').glob('*.sv')]),indent=2))
if __name__=='__main__':
 assert sys.argv[1] in ('negative','normal')
 negatives() if sys.argv[1]=='negative' else normal()
