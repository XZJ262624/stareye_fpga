from pathlib import Path
import datetime,hashlib,json,subprocess,time
R=Path(__file__).resolve().parents[1];F=R/'reports/m5c_pair_capture_20261016';M=Path('E:/Modelsim_10.1c/win64');W=F/('selection_real_telemetry_'+datetime.datetime.now().strftime('%H%M%S'));W.mkdir()
def rec(p):
 b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
active=json.loads((F/'system_qualified_resume_2103/INPUTS.json').read_text());assert all(rec(Path(x['path']))['sha256']==x['sha256'] for x in active)
base=R/'tb/m5c_pair_diag/tb_pair_selection_diagnosis_v3.sv';s=base.read_text()
s=s.replace('module tb_pair_selection_diagnosis;','module tb_pair_selection_real_telemetry;')
s=s.replace('reg send_normal=0,send_diag=0,telemetry_ready=0,telemetry_pending=0;', 'reg send_normal=0,send_diag=0;wire telemetry_ready,telemetry_pending;\n reg frame_done=0;reg [479:0] pixel_snapshot=0;wire [319:0] telemetry_header;wire [7:0] telemetry_byte;wire [8:0] telemetry_index;wire telemetry_take,telemetry_fault;')
s=s.replace('.REQUEST_CYCLES(10000)', '.REQUEST_CYCLES(5000000)')
s=s.replace('backend.packet.uart.CLOCK=460800', 'backend.packet.uart.CLOCK=960000')
s=s.replace('.telemetry_descriptor(320\'d0),.telemetry_byte(8\'d0)', '.telemetry_descriptor(telemetry_header),.telemetry_byte(telemetry_byte),.telemetry_index(telemetry_index),.telemetry_take(telemetry_take)')
s=s.replace('  if(backend.telemetry_take)telemetry_ready<=0;','').replace('  if(backend.packet_done&&CASE==6)telemetry_pending<=0;','')
a=s.index(' initial begin\n  wait(rst_n);wait(pubs==1');b=s.index(' initial begin #500000000;',a)
s=s[:a]+r'''
 m5c_telemetry telemetry(.pix_clk(pix),.ui_clk(clk),.rst_n(rst_n),.frame_done(frame_done),.pixel_snapshot(pixel_snapshot),
 .active_descriptor(active_desc),.active_session(active_sid),.active_token(fusion_token),.active_slot(fusion_slot),.rejected_jobs(64'd0),.protocol_faults(64'd0),
 .payload_ready(telemetry_ready),.header_descriptor(telemetry_header),.payload_take(telemetry_take),.byte_index(telemetry_index),.payload_byte(telemetry_byte),.snapshot_pending(telemetry_pending),.snapshot_fault(telemetry_fault));
 integer eof_count=0,build_count=0,t4_start=0,t4_done=0,takes=0,packet_window=0;reg oldpending=1,oldready=0;
 always @(posedge pix)if(rst_n&&frame_done)begin eof_count=eof_count+1;$fdisplay(events,"EOF t=%0t sourceSID=%0d seq=%0d",$time,pixel_snapshot[191:128],pixel_snapshot[63:0]);$fflush(events);end
 always @(posedge clk)if(rst_n)begin
  if(telemetry_fault)$fatal(1,"REAL_TELEMETRY_FAULT");
  if(telemetry.accepting)build_count=build_count+1;
  if(backend.packet.start&&backend.packet.packet_type==4)t4_start=t4_start+1;
  if(backend.packet_done&&backend.packet.packet_type==4)t4_done=t4_done+1;
  if(telemetry_take)takes=takes+1;
  if(backend.packet_busy&&!telemetry_pending&&backend.packet.packet_type==4)packet_window=packet_window+1;
  if(oldpending!==telemetry_pending||oldready!==telemetry_ready||telemetry_take||backend.packet_done||backend.packet.start)begin
   $fdisplay(events,"TELEM t=%0t cyc=%0d pending=%b ready=%b take=%b start=%b type=%0d done=%b packetbusy=%b building=%b mailvalid=%b sourcebusy=%b state=%0d",$time,cycle,telemetry_pending,telemetry_ready,telemetry_take,backend.packet.start,backend.packet.packet_type,backend.packet_done,backend.packet_busy,telemetry.building,telemetry.mail_valid,telemetry.mail_busy,backend.state);$fflush(events);
  end
  oldpending=telemetry_pending;oldready=telemetry_ready;
 end
 initial begin
  wait(rst_n);wait(pubs==1&&backend.state==backend.IDLE&&!backend.packet_busy);
  @(negedge clk);
  if(metadata_b!=1||backend.tick>4990000)$fatal(1,"FIXTURE_PUBLICATION_WINDOW");
  pixel_snapshot[63:0]=6;pixel_snapshot[127:64]=2000000;pixel_snapshot[191:128]=0;
  // A completed no-reference frame is a legitimate type4 source before first acquire.
  if(CASE!=0)begin
   @(negedge pix);frame_done=1;
   if(CASE==1)begin send_normal=1;send_diag=1;end
   @(negedge pix);frame_done=0;send_normal=0;send_diag=0;
  end
  if(CASE==2)repeat(100)@(negedge clk);
  if(CASE==3)repeat(4500)@(negedge clk);
  if(CASE==4)begin wait(telemetry_take);repeat(8)@(negedge clk);end
  if(CASE!=1)pulse(1,1);
  wait(acks==1);repeat(30)@(negedge clk);
  if(CASE!=0)begin wait(takes==1);repeat(8)@(negedge clk);end
  if(pubs!=1||metadata_b!=1||acks!=1)$fatal(1,"REAL_TRANSACTION_COUNTS");
  if(CASE==0||CASE==4)begin if(selected!=1)$fatal(1,"IDLE_SELECTION_MISSING");end
  if(CASE==2||CASE==3)begin if(selected!=0||matching_reject!=1)$fatal(1,"REAL_TELEMETRY_BUSY_NOT_REPRODUCED");end
  if(CASE!=0&&(eof_count!=1||build_count!=1||t4_start!=1||t4_done!=1||takes!=1||packet_window==0))$fatal(1,"REAL_TELEMETRY_CHAIN_COUNTS");
  $display("REAL_TELEMETRY_SELECTION_PASS case=%0d pubs=%0d metadataB=%0d ack=%0d select=%0d reject=%0d EOF=%0d build=%0d start=%0d done=%0d take=%0d pending0busyCycles=%0d",CASE,pubs,metadata_b,acks,selected,matching_reject,eof_count,build_count,t4_start,t4_done,takes,packet_window);
  $fclose(events);$fclose(uart_file);$finish;
 end
''' +s[b:]
tb=R/'tb/m5c_pair_diag/tb_pair_selection_real_telemetry.sv';assert not tb.exists();tb.write_text(s)
names=['m5b1_capture.sv','m5b1_global_engine.sv','m5b1_transfer.sv','m5b1_uart.sv','m5b1_mailbox.sv','m5b1_async_fifo.sv','m5b1_arbiter.sv','m5c_display_session.sv','m5c_line_cache.sv','m5c_mask_reader.sv','m5c_telemetry.sv']
sources=[R/'rtl/m5c_fusion'/n for n in names]+[R/'rtl/m5c_pair_diag'/n for n in ['m5c_pair_backend.sv','m5c_pair_diag_lease.sv','m5c_pair_controller.sv']]+[tb]
inputs=[rec(p) for p in sources+[base,Path(__file__)]];(W/'INPUTS.json').write_text(json.dumps(inputs,indent=2));(W/'snapshots').mkdir()
for i,x in enumerate(inputs):(W/'snapshots'/f'{i}_{Path(x["path"]).name}').write_bytes(Path(x['path']).read_bytes())
(W/'DERIVATION.json').write_text(json.dumps(dict(base=rec(base),scope='Real telemetry EOF->word mailbox->32word RAM->UARTpacketDONE->registeredTAKE; all pending/ready/byte/take signals direct, no forced predicate; REQUEST_CYCLES5M conditional initial publication budget; no-source completed frame then first real session acquisition. Reader withheld, not fullvideo proof.',active_63_precheck=True),indent=2));print(W,flush=True)
steps=[]
commands=[('vlib',[str(M/'vlib.exe'),'work']),('compile',[str(M/'vlog.exe'),'-sv']+[str(p) for p in sources])]+[(f'case{c}',[str(M/'vsim.exe'),'-c','-novopt','-wlf','NUL','work.tb_pair_selection_real_telemetry',f'-gCASE={c}','-do','run -all; quit -f']) for c in [2,3,4,1,0]]
for stage,cmd in commands:
 d=W/stage;d.mkdir();cwd=W if stage in ('vlib','compile') else d
 if cwd==d:(d/'modelsim.ini').write_text('[Library]\nwork = '+str(W/'work')+'\n')
 start=time.time()
 with (d/'native.log').open('w') as log:
  p=subprocess.Popen(cmd,cwd=cwd,stdout=log,stderr=subprocess.STDOUT);(d/'OWNER.json').write_text(json.dumps(dict(pid=p.pid,started=datetime.datetime.now().astimezone().isoformat(),command=cmd,cwd=str(cwd)),indent=2));print(stage,p.pid,flush=True);code=p.wait()
 text=(d/'native.log').read_text(errors='replace');ok=code==0 and '** Error' not in text and '** Fatal' not in text and (stage in ('vlib','compile') or 'REAL_TELEMETRY_SELECTION_PASS' in text)
 steps.append(dict(stage=stage,exit=code,ok=ok,seconds=time.time()-start,log=rec(d/'native.log')));(W/'PROGRESS.json').write_text(json.dumps(steps,indent=2))
 if not ok:print(text[-4000:],flush=True);break
unchanged=all(rec(Path(x['path']))==x for x in inputs);act=all(rec(Path(x['path']))['sha256']==x['sha256'] for x in active)
(W/'RESULT.json').write_text(json.dumps(dict(status='PASS_REAL_TELEMETRY_SELECTION_BOUNDARY' if len(steps)==len(commands) and all(x['ok'] for x in steps) and unchanged and act else 'NOT_PASS',steps=steps,source_unchanged=unchanged,active_63_unchanged=act),indent=2));print(W,flush=True)
