from pathlib import Path
import datetime,hashlib,json,subprocess,time
R=Path(__file__).resolve().parents[1];F=R/'reports/m5c_pair_capture_20261016';M=Path('E:/Modelsim_10.1c/win64');W=F/('selection_denied_'+datetime.datetime.now().strftime('%H%M%S'));W.mkdir()
def rec(p):
 b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
base=R/'tb/m5c_pair_diag/tb_pair_selection_lifecycle_v2.sv';s=base.read_text().replace('module tb_pair_selection_lifecycle;','module tb_pair_selection_denied;')
# Inject only the backend acquire identity interface; real lease core must deny.
s=s.replace('.fusion_identity(fusion_identity)', ".fusion_identity(fusion_identity ^ (320'd1<<319))",1)
s=s.replace('if(session_fault||fusion_denied)$fatal(1,"DIAG_REAL_SESSION_FAULT");','if(fusion_denied) denied_seen=denied_seen+1;')
s=s.replace(' integer cycle=0;', ' integer cycle=0,denied_seen=0;')
a=s.index('  wait(acks==1);') if False else s.index('repeat(4500)@(negedge clk);pulse(1,1);wait(acks==1);wait(cap_done);')
b=s.index(' initial begin #500000000;',a)
s=s[:a]+r'''
  repeat(4500)@(negedge clk);pulse(1,1);wait(denied_seen==1);
  wait(pair_completed==1);wait(!backend.pair_hold);repeat(10)@(negedge clk);
  if(selected!=1||acks!=0||first_arm_cycle!=0||current_B!=0||pair_metadata_B!=0||release_cycle!=0||pair_leased!=0||backend.pair_failure!=22||lease_fault)$fatal(1,"REAL_DENIED_ACQUIRE_NOT_CLEAN");
  wait(pubs==2&&backend.state==backend.IDLE&&!backend.packet_busy);
  if(lease_fault||pair_leased!=0||!backend.fresh_publication_seen)$fatal(1,"DENIED_NEXT_PUBLICATION");
  $display("SELECTION_DENIED_PASS actualLeaseDenied=%0d selected=%0d arm=%0d ACK=%0d pubs=%0d failure=%0d",denied_seen,selected,first_arm_cycle,acks,pubs,backend.pair_failure);
  $fclose(events);$fclose(uart_file);$finish;
 end
'''+s[b:]
tb=R/'tb/m5c_pair_diag/tb_pair_selection_denied.sv';assert not tb.exists();tb.write_text(s)
sources=[R/'rtl/m5c_fusion'/n for n in ['m5b1_capture.sv','m5b1_global_engine.sv','m5b1_transfer.sv','m5b1_uart.sv','m5b1_mailbox.sv','m5b1_async_fifo.sv','m5c_display_session.sv','m5c_line_cache.sv','m5c_mask_reader.sv','m5c_telemetry.sv']]+[R/'rtl/m5c_pair_diag'/n for n in ['m5c_pair_backend.sv','m5c_pair_diag_lease.sv','m5c_pair_controller.sv','m5c_pair_capture.sv','m5c_pair_arbiter.sv']]+[tb]
inputs=[rec(p) for p in sources+[base,Path(__file__)]];(W/'INPUTS.json').write_text(json.dumps(inputs,indent=2));(W/'snapshots').mkdir()
for i,x in enumerate(inputs):(W/'snapshots'/f'{i}_{Path(x["path"]).name}').write_bytes(Path(x['path']).read_bytes())
(W/'DERIVATION.json').write_text(json.dumps(dict(base=rec(base),scope='Fault model flips acquire identity bit319 at backend interface; real lease rejects, controller must not arm/read/release, sends reason22 and subsequent background publication recovers. Not natural display-session identity formation'),indent=2));print(W,flush=True)
steps=[]
commands=[('vlib',[str(M/'vlib.exe'),'work']),('compile',[str(M/'vlog.exe'),'-sv']+[str(p) for p in sources])]+[(f'case{c}',[str(M/'vsim.exe'),'-c','-novopt','-wlf','NUL','work.tb_pair_selection_denied',f'-gCASE={c}','-do','run -all; quit -f']) for c in [0]]
for stage,cmd in commands:
 d=W/stage;d.mkdir();cwd=W if stage in ('vlib','compile') else d
 if cwd==d:(d/'modelsim.ini').write_text('[Library]\nwork = '+str(W/'work')+'\n')
 start=time.time()
 with (d/'native.log').open('w') as log:
  p=subprocess.Popen(cmd,cwd=cwd,stdout=log,stderr=subprocess.STDOUT);(d/'OWNER.json').write_text(json.dumps(dict(pid=p.pid,started=datetime.datetime.now().astimezone().isoformat(),command=cmd,cwd=str(cwd)),indent=2));print(stage,p.pid,flush=True);code=p.wait()
 text=(d/'native.log').read_text(errors='replace');ok=code==0 and '** Error' not in text and '** Fatal' not in text and (stage in ('vlib','compile') or 'SELECTION_DENIED_PASS' in text)
 steps.append(dict(stage=stage,exit=code,ok=ok,seconds=time.time()-start,log=rec(d/'native.log')));(W/'PROGRESS.json').write_text(json.dumps(steps,indent=2))
 if not ok:print(text[-4000:],flush=True);break
(W/'RESULT.json').write_text(json.dumps(dict(status='PASS_REAL_LEASE_DENIAL' if len(steps)==len(commands) and all(x['ok'] for x in steps) else 'NOT_PASS',steps=steps,source_unchanged=inputs==[rec(Path(x['path'])) for x in inputs]),indent=2));print(W,flush=True)
