from pathlib import Path
import re,json,hashlib,datetime,subprocess,time
R=Path.cwd();W=R/'reports/m5c_pair_capture_20261016'/('capture_pack_diff_'+datetime.datetime.now().strftime('%H%M%S'));W.mkdir();orig=R/'rtl/m5c_pair_diag/m5c_pair_capture.sv';s=orig.read_text();v=s.replace('module m5c_pair_capture','module pair_capture_pack_variant').replace('pack,push_data','pack').replace('.wdata(push_data)','.wdata(pack)').replace('push_data<=0;','').replace('push<=1;push_data<={sample,pack[119:0]};','push<=1;').replace('push_data<={seq,source_id}','pack<={seq,source_id}').replace('push_data<={eof_tick,sof_tick}','pack<={eof_tick,sof_tick}');assert 'push_data' not in v
(W/'variant.sv').write_text(v);(W/'original.sv').write_bytes(orig.read_bytes());inputs=[orig]
for kind in ['capture','capture_pressure']:
 p=R/f'tb/m5c_pair_diag/tb_pair_{kind}.sv';inputs.append(p);t=p.read_text();instance=re.search(r' m5c_pair_capture #.*?\);',t,re.S)[0];alt=instance.replace('m5c_pair_capture #','pair_capture_pack_variant #').replace(' dut(',' shadow(')
 outs={'busy':'busy2','dv':'dv2','empty':'empty2','reason':'reason2','data':'data2','count':'count2','resetdone':'resetdone2','fault':'fault2'}
 for a,b in outs.items():alt=alt.replace('('+a+')','('+b+')')
 decl='wire busy2,dv2,empty2;wire [31:0] reason2;wire [127:0] data2;wire [9:0] count2;wire [1:0] resetdone2,fault2;\n'
 checks='''always @(posedge ui) if(rst) begin
 if({busy,dv,empty,reason,count,resetdone,fault} !== {busy2,dv2,empty2,reason2,count2,resetdone2,fault2}) $fatal(1,"PACK_DIFF_UI_CONTROL");
 if(!empty && data!==data2)$fatal(1,"PACK_DIFF_FIFO_DATA");
 end
 always @(posedge pix)if(rst)begin
 if({dut.state,dut.push,dut.position,dut.reason}!=={shadow.state,shadow.push,shadow.position,shadow.reason})$fatal(1,"PACK_DIFF_PIXEL_CONTROL");
 if(dut.push&&dut.push_data!==shadow.pack)$fatal(1,"PACK_DIFF_ACTUAL_PUSH_DATA");
 end
'''
 t=t.replace(instance,decl+instance+'\n'+alt+'\n'+checks);(W/f'tb_pair_{kind}.sv').write_text(t)
def rec(p):b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
sources=[R/'rtl/m5c_fusion/m5b1_mailbox.sv',R/'rtl/m5c_fusion/m5b1_async_fifo.sv',W/'original.sv',W/'variant.sv',W/'tb_pair_capture.sv',W/'tb_pair_capture_pressure.sv'];binding=[rec(p) for p in inputs+sources+[Path(__file__).resolve()]];(W/'INPUTS.json').write_text(json.dumps(binding,indent=2));(W/'RUNNER.py').write_bytes(Path(__file__).read_bytes());M=Path('E:/Modelsim_10.1c/win64')
def run(n,args):
 with (W/(n+'.log')).open('wb') as f:
  p=subprocess.Popen(args,cwd=W,stdout=f,stderr=subprocess.STDOUT);(W/(n+'_OWNER.json')).write_text(json.dumps(dict(pid=p.pid,started=time.time(),command=args)));code=p.wait()
 return code,(W/(n+'.log')).read_text(errors='replace')
c,t=run('vlib',[str(M/'vlib.exe'),'work']);assert c==0
c,t=run('vlog',[str(M/'vlog.exe'),'-sv','-work','work']+list(map(str,sources)));assert c==0 and '** Error' not in t,t
rows=[]
for kind,n in [('capture',6),('capture_pressure',2)]:
 for i in range(n):
  label=kind+str(i);c,t=run(label,[str(M/'vsim.exe'),'-c','-novopt','-l',label+'.native.log','-wlf',label+'.wlf','work.tb_pair_'+kind,'-gCASE='+str(i),'-do','run -all;quit -f']);ok=c==0 and 'PAIR_CAPTURE_' in t and 'PASS' in t and '** Fatal' not in t and '** Error' not in t;rows.append(dict(case=label,exit=c,pass_gate=ok));print(label,ok,flush=True)
  (W/'RESULT.json').write_text(json.dumps(dict(status='PASS_FINITE_EDGE_AND_FIFO_DIFFERENTIAL' if len(rows)==8 and all(x['pass_gate'] for x in rows) else 'INCOMPLETE_OR_FAIL',cases=rows,unchanged=binding==[rec(Path(x['path'])) for x in binding]),indent=2))
  if not ok:print(t);raise SystemExit(1)
print(W)
