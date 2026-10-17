from pathlib import Path
import datetime,hashlib,json,subprocess,time
R=Path(__file__).resolve().parents[1];F=R/'reports/m5c_pair_capture_20261016';M=Path('E:/Modelsim_10.1c/win64');W=F/('selection_rejections_'+datetime.datetime.now().strftime('%H%M%S'));W.mkdir()
def rec(p):
 b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
base=R/'tb/m5c_pair_diag/tb_pair_selection_repaired.sv';s=base.read_text().replace('module tb_pair_selection_real_telemetry;','module tb_pair_selection_rejections;')
a=s.index(' initial begin\n  wait(rst_n);wait(pubs==1');b=s.index(' initial begin #500000000;',a)
s=s[:a]+r'''
 initial begin
  wait(rst_n);
  if(CASE==0)begin wait(pubs==1);pulse(1,1);end
  else begin
   wait(pubs==1&&backend.state==backend.IDLE&&!backend.packet_busy);
   if(CASE==1)begin wait(backend.writer_owned);pulse(1,1);end
   if(CASE==2)begin diag_sid=normal_sid^64'h0000000100000000;pulse(1,1);end
   if(CASE==3)begin pulse(1,0);repeat(8)@(negedge pix);pulse(0,1);end
  end
  wait(acks==1);repeat(40)@(negedge clk);
  if(selected!=0||arm_count!=0||acks!=1)$fatal(1,"REJECTION_PROTECTION_BYPASSED");
  if(CASE<2&&matching_reject!=1)$fatal(1,"REJECTION_WINDOW_NOT_HIT");
  $display("SELECTION_REJECTION_PASS case=%0d pubs=%0d selected=%0d ack=%0d rejected=%0d",CASE,pubs,selected,acks,matching_reject);
  $fclose(events);$fclose(uart_file);$finish;
 end
'''+s[b:]
tb=R/'tb/m5c_pair_diag/tb_pair_selection_rejections.sv';assert not tb.exists();tb.write_text(s)
sources=[R/'rtl/m5c_fusion'/n for n in ['m5b1_capture.sv','m5b1_global_engine.sv','m5b1_transfer.sv','m5b1_uart.sv','m5b1_mailbox.sv','m5b1_async_fifo.sv','m5c_display_session.sv','m5c_line_cache.sv','m5c_mask_reader.sv','m5c_telemetry.sv','m5b1_arbiter.sv']]+[R/'rtl/m5c_pair_diag'/n for n in ['m5c_pair_backend.sv','m5c_pair_diag_lease.sv','m5c_pair_controller.sv','m5c_pair_capture.sv','m5c_pair_arbiter.sv']]+[tb]
inputs=[rec(p) for p in sources+[base,Path(__file__)]];(W/'INPUTS.json').write_text(json.dumps(inputs,indent=2));(W/'snapshots').mkdir()
for i,x in enumerate(inputs):(W/'snapshots'/f'{i}_{Path(x["path"]).name}').write_bytes(Path(x['path']).read_bytes())
(W/'DERIVATION.json').write_text(json.dumps(dict(base=rec(base),scope='Actual backend publication and lease ACK; STATS, writer, wrong high SID and late mailbox must not select. No capture lifecycle claim'),indent=2));print(W,flush=True)
steps=[]
commands=[('vlib',[str(M/'vlib.exe'),'work']),('compile',[str(M/'vlog.exe'),'-sv']+[str(p) for p in sources])]+[(f'case{c}',[str(M/'vsim.exe'),'-c','-novopt','-wlf','NUL','work.tb_pair_selection_rejections',f'-gCASE={c}','-do','run -all; quit -f']) for c in [0,1,2,3]]
for stage,cmd in commands:
 d=W/stage;d.mkdir();cwd=W if stage in ('vlib','compile') else d
 if cwd==d:(d/'modelsim.ini').write_text('[Library]\nwork = '+str(W/'work')+'\n')
 start=time.time()
 with (d/'native.log').open('w') as log:
  p=subprocess.Popen(cmd,cwd=cwd,stdout=log,stderr=subprocess.STDOUT);(d/'OWNER.json').write_text(json.dumps(dict(pid=p.pid,started=datetime.datetime.now().astimezone().isoformat(),command=cmd,cwd=str(cwd)),indent=2));print(stage,p.pid,flush=True);code=p.wait()
 text=(d/'native.log').read_text(errors='replace');ok=code==0 and '** Error' not in text and '** Fatal' not in text and (stage in ('vlib','compile') or 'SELECTION_REJECTION_PASS' in text)
 steps.append(dict(stage=stage,exit=code,ok=ok,seconds=time.time()-start,log=rec(d/'native.log')));(W/'PROGRESS.json').write_text(json.dumps(steps,indent=2))
 if not ok:print(text[-4000:],flush=True);break
(W/'RESULT.json').write_text(json.dumps(dict(status='PASS_SELECTION_REJECTIONS' if len(steps)==len(commands) and all(x['ok'] for x in steps) else 'NOT_PASS',steps=steps,source_unchanged=inputs==[rec(Path(x['path'])) for x in inputs]),indent=2));print(W,flush=True)
