from pathlib import Path
import datetime,hashlib,json,subprocess,time
R=Path(__file__).resolve().parents[1];F=R/'reports/m5c_pair_capture_20261016';M=Path('E:/Modelsim_10.1c/win64');W=F/('selection_lifecycle_v2_'+datetime.datetime.now().strftime('%H%M%S'));W.mkdir()
def rec(p):
 b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
base=R/'tb/m5c_pair_diag/tb_pair_selection_repaired.sv';s=base.read_text().replace('module tb_pair_selection_real_telemetry;','module tb_pair_selection_lifecycle;')
s=s.replace("64'h1234000000000007","64'd7")
s=s.replace('reg cap_done=0;','wire cap_done;')
s=s.replace('.pair_arm_busy(1\'b0)', '.pair_arm(cap_arm),.pair_cancel(cap_cancel),.pair_arm_busy(cap_arm_busy)')
s=s.replace('.pair_reason(32\'d2),.pair_empty(1\'b1),.pair_count(10\'d0),.pair_data(128\'d0)', '.pair_reason(cap_reason),.pair_empty(cap_empty),.pair_count(cap_count),.pair_data(cap_data),.pair_pop(cap_pop)')
s=s.replace('.pixel_release(1\'b0),.pixel_release_final(1\'b0),.pixel_release_session(64\'d0)', '.pixel_release(pixel_release),.pixel_release_final(1\'b1),.pixel_release_session(active_sid)')
s=s.replace('.offer_take(1\'b0)', '.offer_take(1\'b1)')
s=s.replace('m5b1_arbiter #(.BG_REFILL(2)) arbiter(', 'm5c_pair_arbiter #(.BG_REFILL(2)) arbiter(.pair_write_permission({backend.pair_metadata_write,backend.pair_current_write}),.pair_read_permission({backend.pair_metadata_read,backend.pair_current_read}),')
decl=r'''
 wire cap_arm,cap_cancel,cap_arm_busy,cap_empty,cap_pop;wire [9:0] cap_count;wire [31:0] cap_reason;wire [127:0] cap_data;
 reg pixel_release=0,cap_sof=0,cap_de=0,cap_kill=0;reg [11:0] cx=0,cy=0;reg [63:0] ticks=0;
 reg [127:0] current_mem[0:63],metadata_mem[0:31];reg [31:0] mem_addr=0;integer current_B=0,pair_metadata_B=0,pair_A=0,first_sample_busy=0,held_W_cycles=0;
 reg current_tx=0,pairmeta_tx=0;integer first_arm_cycle=0,final_b_cycle=0,release_cycle=0;
'''
s=s.replace('integer cycle=0,pubs=0', 'integer pubs=0')
s=s.replace(' reg run_enable=1;', ' integer cycle=0;'+decl+' reg run_enable=1;')
s=s.replace('rdata=0;rlast=mb==ml;rvalid=1;', "if(mem_addr>=32'h01100000&&mem_addr<32'h01100400)rdata=current_mem[(mem_addr-32'h01100000)/16+mb];else if(mem_addr==32'h011e1000)rdata=metadata_mem[mb];else rdata=0;rlast=mb==ml;rvalid=1;")
s=s.replace('commands=commands+1;ms=atype?1:2;',"mem_addr=aaddr;current_tx=atype&&aaddr>=32'h01100000&&aaddr<32'h01100400;pairmeta_tx=atype&&aaddr==32'h011e1000;if(current_tx)pair_A=pair_A+1;commands=commands+1;ms=atype?1:2;")
s=s.replace('if(mb==ml)ms=3;else mb=mb+1;',"if(current_tx)current_mem[(mem_addr-32'h01100000)/16+mb]=wdata;if(pairmeta_tx)metadata_mem[mb]=wdata;if(mb==ml)ms=3;else mb=mb+1;")
s=s.replace('if(bvalid&&bready)begin bvalid<=0;', 'if(bvalid&&bready)begin if(current_tx)begin current_B=current_B+1;final_b_cycle=cycle;end if(pairmeta_tx)pair_metadata_B=pair_metadata_B+1;bvalid<=0;')
a=s.index(' initial begin\n  wait(rst_n);wait(pubs==1');b=s.index(' initial begin #500000000;',a)
s=s[:a]+r'''
 defparam backend.pair_controller.CURRENT_BYTES=1024;
 defparam backend.pair_controller.REFERENCE_CLASS_BYTES=512;
 defparam backend.pair_controller.REFERENCE_MASK_BYTES=512;
 m5c_pair_capture #(.WIDTH(128),.HEIGHT(8)) capture(.ui_clk(clk),.pix_clk(pix),.arst_n(rst_n),.arm(cap_arm),.arm_session(active_sid),.cancel(cap_cancel),.arm_busy(cap_arm_busy),.done_valid(cap_done),.done_reason(cap_reason),.done_take(cap_take),
 .source_tap_valid(cap_sof||cap_de),.source_tap_qualified(1'b1),.ce(1'b1),.frame_sof(cap_sof),.frame_admit(1'b1),.mode_cov(1'b1),.fusion_enabled(1'b1),.kill(cap_kill),.identity_ok(1'b1),
 .session(active_sid),.current_source_frame(64'd9),.display_seq(active_sid),.pixel_ticks(ticks),.final_de(cap_de),.final_x(cx),.final_y(cy),.final_class(2'd0),.support(1'b1),.local_edge(1'b0),.accepted_domain(1'b0),.row_complete(1'b1),.row_tag(1'b1),
 .data(cap_data),.empty(cap_empty),.pop(cap_pop),.count(cap_count));
 always @(posedge pix)if(rst_n)ticks<=ticks+1;
 integer yy,xx,pair_completed=0;
 always @(posedge clk)if(rst_n)begin
  if(cap_arm)begin first_arm_cycle=cycle;$fdisplay(events,"CAPTURE_ARM cycle=%0d SID=%h token=%h",cycle,active_sid,fusion_token);end
  if(wvalid&&!wready&&current_tx)held_W_cycles=held_W_cycles+1;
  if(backend.pair_release)begin release_cycle=cycle;if(tx_busy||!cap_empty)$fatal(1,"PAIR_RELEASE_BEFORE_REAL_DRAIN");$fdisplay(events,"RELEASE cycle=%0d lastCurrentB=%0d held=%b",cycle,final_b_cycle,pair_leased);end
  if(backend.packet_done&&backend.packet.packet_type==10)pair_completed=pair_completed+1;
  if(backend.pair_export&&(backend.state==backend.TELEMETRY||backend.state==backend.TELEMETRY_WAIT))$fatal(1,"PAIR_STOLE_TYPE4_UART");
 end
 initial begin
  wait(capture.state==capture.WAIT);@(negedge pix);cap_sof=1;
  @(negedge pix);cap_sof=0;repeat(16)@(negedge pix);
  for(yy=0;yy<8;yy=yy+1)for(xx=0;xx<128;xx=xx+1)begin
   @(negedge pix);cap_de=1;cx=xx;cy=yy;
   if(yy==0&&xx==0)begin first_sample_busy=backend.packet_busy;if(!first_arm_cycle||!first_sample_busy)$fatal(1,"CAPTURE_FIRST_SAMPLE_NOT_OVERLAPPING_TYPE4");end
  end
  @(negedge pix);cap_de=0;
 end
 initial if(CASE==1)begin
  wait(capture.state==capture.CAPTURE);hold_w=1;wait(pair_A==1);
  @(negedge pix);cap_kill=1;repeat(32)@(negedge clk);hold_w=0;
 end
 initial begin
  wait(rst_n);wait(pubs==1&&backend.state==backend.IDLE&&!backend.packet_busy);
  @(negedge clk);if(metadata_b!=1||backend.tick>4990000)$fatal(1,"FIXTURE_PUBLICATION_WINDOW");
  pixel_snapshot[63:0]=6;pixel_snapshot[127:64]=2000000;pixel_snapshot[191:128]=0;
  @(negedge pix);frame_done=1;@(negedge pix);frame_done=0;
  repeat(4500)@(negedge clk);pulse(1,1);wait(acks==1);wait(cap_done);
  @(negedge pix);pixel_snapshot[63:0]=active_sid;pixel_snapshot[127:64]=ticks;pixel_snapshot[191:128]=active_sid;frame_done=1;pixel_release=1;
  @(negedge pix);frame_done=0;pixel_release=0;
  wait(pair_completed==1);wait(!backend.pair_hold&&pair_leased==0);repeat(10)@(negedge clk);
  if(selected!=1||first_sample_busy!=1||takes!=2||t4_start!=2||t4_done!=2||build_count!=2||eof_count!=2||release_cycle<=final_b_cycle)$fatal(1,"LIFECYCLE_INCOMPLETE");
  if(CASE==0&&(backend.pair_failure!=0||current_B!=2||pair_metadata_B!=1))$fatal(1,"LIFECYCLE_SUCCESS_COUNTS");
  if(CASE==1&&(backend.pair_failure==0||current_B!=1||held_W_cycles<32||pair_metadata_B!=0))$fatal(1,"LIFECYCLE_CANCEL_DRAIN");
  wait(pubs==2&&backend.state==backend.IDLE&&!backend.packet_busy);
  if(lease_fault||session_fault||pair_leased!=0||!backend.fresh_publication_seen||metadata_b!=2)$fatal(1,"LIFECYCLE_NEXT_PUBLICATION");
  $display("SELECTION_LIFECYCLE_PASS case=%0d pubs=%0d selection=%0d currentB=%0d pairMetadataB=%0d type4=%0d/%0d/%0d heldW=%0d lastB=%0d release=%0d",CASE,pubs,selected,current_B,pair_metadata_B,t4_start,t4_done,takes,held_W_cycles,final_b_cycle,release_cycle);$fclose(events);$fclose(uart_file);$finish;
 end
''' +s[b:]
tb=R/'tb/m5c_pair_diag/tb_pair_selection_lifecycle_v2.sv';assert not tb.exists();tb.write_text(s)
sources=[R/'rtl/m5c_fusion'/n for n in ['m5b1_capture.sv','m5b1_global_engine.sv','m5b1_transfer.sv','m5b1_uart.sv','m5b1_mailbox.sv','m5b1_async_fifo.sv','m5c_display_session.sv','m5c_line_cache.sv','m5c_mask_reader.sv','m5c_telemetry.sv']]+[R/'rtl/m5c_pair_diag'/n for n in ['m5c_pair_backend.sv','m5c_pair_diag_lease.sv','m5c_pair_controller.sv','m5c_pair_capture.sv','m5c_pair_arbiter.sv']]+[tb]
inputs=[rec(p) for p in sources+[base,Path(__file__)]];(W/'INPUTS.json').write_text(json.dumps(inputs,indent=2));(W/'snapshots').mkdir()
for i,x in enumerate(inputs):(W/'snapshots'/f'{i}_{Path(x["path"]).name}').write_bytes(Path(x['path']).read_bytes())
(W/'DERIVATION.json').write_text(json.dumps(dict(base=rec(base),scope='Real pair capture128x8, full backend publication, actual selected lease, telemetry EOF and two full packets, retained release/drain, current DDR W/B and metadata storage; dimensions reduced, reader A withheld, no fullvideo claim'),indent=2));print(W,flush=True)
steps=[]
commands=[('vlib',[str(M/'vlib.exe'),'work']),('compile',[str(M/'vlog.exe'),'-sv']+[str(p) for p in sources])]+[(f'case{c}',[str(M/'vsim.exe'),'-c','-novopt','-wlf','NUL','work.tb_pair_selection_lifecycle',f'-gCASE={c}','-do','run -all; quit -f']) for c in [0,1]]
for stage,cmd in commands:
 d=W/stage;d.mkdir();cwd=W if stage in ('vlib','compile') else d
 if cwd==d:(d/'modelsim.ini').write_text('[Library]\nwork = '+str(W/'work')+'\n')
 start=time.time()
 with (d/'native.log').open('w') as log:
  p=subprocess.Popen(cmd,cwd=cwd,stdout=log,stderr=subprocess.STDOUT);(d/'OWNER.json').write_text(json.dumps(dict(pid=p.pid,started=datetime.datetime.now().astimezone().isoformat(),command=cmd,cwd=str(cwd)),indent=2));print(stage,p.pid,flush=True);code=p.wait()
 text=(d/'native.log').read_text(errors='replace');ok=code==0 and '** Error' not in text and '** Fatal' not in text and (stage in ('vlib','compile') or 'SELECTION_LIFECYCLE_PASS' in text)
 steps.append(dict(stage=stage,exit=code,ok=ok,seconds=time.time()-start,log=rec(d/'native.log')));(W/'PROGRESS.json').write_text(json.dumps(steps,indent=2))
 if not ok:print(text[-4000:],flush=True);break
(W/'RESULT.json').write_text(json.dumps(dict(status='PASS_SELECTION_LIFECYCLE' if len(steps)==len(commands) and all(x['ok'] for x in steps) else 'NOT_PASS',steps=steps,source_unchanged=inputs==[rec(Path(x['path'])) for x in inputs]),indent=2));print(W,flush=True)
