from pathlib import Path
import datetime,hashlib,json,subprocess,time,sys
R=Path(__file__).resolve().parents[1]; F=R/'reports/m5c_pair_capture_20261016'; M=Path('E:/Modelsim_10.1c/win64')
W=F/('selection_coupled_'+datetime.datetime.now().strftime('%H%M%S'));W.mkdir()
def rec(p):
 b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
active=json.loads((F/'system_qualified_resume_2103/INPUTS.json').read_text())
assert all(rec(Path(x['path']))['sha256']==x['sha256'] for x in active)
s=(R/'tb/m5c_pair_diag/tb_pair_backend_fresh.sv').read_text()
s=s.replace('module tb_pair_backend_fresh;','module tb_pair_selection_diagnosis;')
s=s.replace('reg run_enable=1;reg fusion_acquire=0,fusion_release=0,fusion_retire=0;reg fusion_slot=0;reg [319:0] fusion_identity=0;reg [63:0] fusion_token=1;', 'reg run_enable=1;wire fusion_acquire,fusion_release,fusion_retire,fusion_slot;wire [319:0] fusion_identity;wire [63:0] fusion_token;')
s=s.replace('reg request_pair=0,cap_done=0;', 'wire request_pair;reg cap_done=0;')
s=s.replace('.pair_request_session(sid)', '.pair_request_session(pair_sid)').replace('.active_pair_descriptor(result_desc),.pair_session(sid)', '.active_pair_descriptor(active_desc),.pair_session(active_sid)')
s=s.replace('.pair_wait_expired(1\'b0)', '.pair_request_take(pair_take),.pair_wait_expired(1\'b0)')
s=s.replace('.telemetry_ready(1\'b0)', '.telemetry_ready(telemetry_ready)')
start=s.index(' integer cycle=0,metadata_b=0')
s=s[:start]+r'''
 reg send_normal=0,send_diag=0,telemetry_ready=0,telemetry_pending=0;
 wire pair_take,pair_busy;wire [63:0] pair_sid,active_sid;wire [767:0] active_desc;
 reg [63:0] normal_sid=64'h1234000000000007,diag_sid=64'h1234000000000007;
 wire session_fault;wire [767:0] offer_desc;wire [63:0] offer_sid;
 wire offer_valid;
 m5b1_mailbox #(.WIDTH(64)) pair_box(.sclk(pix),.dclk(clk),.arst_n(rst_n),.send(send_diag),.sdata(diag_sid),.busy(pair_busy),.valid(request_pair),.ddata(pair_sid),.take(pair_take));
 m5c_display_session ds(.ui_clk(clk),.pix_clk(pix),.rst_n(rst_n),.stop(1'b0),
 .request_frame(send_normal),.request_seq(normal_sid),.request_config(result_desc[735:576]),
 .pixel_release(1'b0),.pixel_release_final(1'b0),.pixel_release_session(64'd0),
 .result_valid(backend.result_valid),.result_slot(backend.result_slot),.result_descriptor(result_desc),.export_exclusive(backend.export_exclusive),
 .acquire(fusion_acquire),.lease_slot(fusion_slot),.lease_identity(fusion_identity),.lease_token(fusion_token),
 .acquire_ack(fusion_ack),.acquire_denied(fusion_denied),.pair_leased(pair_leased),.lease_release(fusion_release),.lease_retire(fusion_retire),.session_fault(session_fault),
 .telemetry_pending(telemetry_pending),.telemetry_descriptor(active_desc),.telemetry_session(active_sid),
 .offer_valid(offer_valid),.offer_take(1'b0),.offer_descriptor(offer_desc),.offer_session(offer_sid),
 .context_quiet(1'b1),.context_tail_fault(1'b0),.ce(1'b1),.read_valid(1'b0),.read_x(12'd0),.read_y(12'd0),.read_session(64'd0),
 .retire(1'b0),.retire_row(12'd0),.flush(1'b1),.aready(1'b0),.rvalid(1'b0),.rlast(1'b0),.rdata(128'd0),.rid(8'd0),.rresp(2'd0),.rejected(1'b0));
 integer cycle=0,pubs=0,selected=0,acks=0,consumed=0,stale=0,matching_reject=0,metadata_b=0;
 reg meta_pending=0;integer events;
 initial events=$fopen("events.txt","w");
 always @(posedge pix)if(rst_n&&(send_normal||send_diag))begin
  $fdisplay(events,"PIX t=%0t mode=%0d normal=%b nsid=%h nbusy=%b diag=%b dsid=%h dbusy=%b",$time,CASE>=8?CASE-8:6,send_normal,normal_sid,ds.req_busy,send_diag,diag_sid,pair_busy);$fflush(events);
 end
 always @(posedge clk)if(rst_n)begin
  cycle=cycle+1;
  if(backend.publication_accept)begin pubs=pubs+1;$fdisplay(events,"PUBLICATION t=%0t cycle=%0d job=%0d",$time,cycle,backend.job_id);end
  if(avalid&&aready)meta_pending=(aaddr==32'h010e6000||aaddr==32'h010e6080)&&atype;
  if(bvalid&&bready&&meta_pending)begin metadata_b=metadata_b+1;meta_pending=0;end
  if(backend.telemetry_take)telemetry_ready<=0;
  if(backend.packet_done&&CASE==6)telemetry_pending<=0;
  if(session_fault||fusion_denied)$fatal(1,"DIAG_REAL_SESSION_FAULT");
  if(fusion_ack)begin acks=acks+1;if(!pair_leased[fusion_slot?2:0])$fatal(1,"DIAG_ACK_WITHOUT_REAL_LEASE");end
  if(backend.pair_selected)selected=selected+1;
  if(pair_take&&request_pair)begin
   consumed=consumed+1;
   if(pair_sid<active_sid)stale=stale+1;
   else if(backend.pair_selected)begin end
   else if(pair_sid==active_sid&&fusion_acquire)matching_reject=matching_reject+1;
   else $fatal(1,"DIAG_UNCLASSIFIED_CONSUMPTION");
  end
  if(fusion_acquire||fusion_ack||pair_take||backend.pair_selected||ds.req_take)begin
   $fdisplay(events,"UI t=%0t cyc=%0d req=%b pairSID=%h activeSID=%h normalvalid=%b normalSID=%h acq=%b ack=%b fresh=%b eq=%b state=%0d tx=%b eng=%b arm=%b writer=%b packet=%b start=%b hold=%b terminal=%b selected=%b take=%b pending=%b",$time,cycle,request_pair,pair_sid,active_sid,ds.req_valid,ds.req_data[223:160],fusion_acquire,fusion_ack,backend.fresh_publication_seen,active_desc==result_desc,backend.state,backend.tx_busy,backend.eng_busy,backend.arm_busy,backend.writer_owned,backend.packet_busy,backend.packet_start,backend.pair_hold,backend.pair_terminal,backend.pair_selected,pair_take,telemetry_pending);$fflush(events);
  end
 end
 task pulse(input integer normal,input integer diag);begin
  @(negedge pix);send_normal=normal;send_diag=diag;
  @(negedge pix);send_normal=0;send_diag=0;
 end endtask
 initial begin
  wait(rst_n);wait(pubs==1&&backend.state==backend.IDLE&&!backend.packet_busy);
  @(negedge clk);run_enable=1;
  if(metadata_b!=1)$fatal(1,"DIAG_NO_REAL_METADATA_B");
  if(CASE==3)begin diag_sid=normal_sid-1;pulse(0,1);repeat(12)@(negedge pix);end
  if(CASE==4)diag_sid=normal_sid^64'h0000000100000000;
  if(CASE==5||CASE==6)begin
   telemetry_pending=(CASE==6);telemetry_ready=1;
   wait(backend.packet_busy);repeat(20)@(negedge pix);
  end
  if(CASE==1)begin pulse(0,1);repeat(8)@(negedge pix);pulse(1,0);end
  else if(CASE==2)begin pulse(1,0);repeat(8)@(negedge pix);pulse(0,1);end
  else if(CASE==3)pulse(1,1);
  else if(CASE>=8)pulse(1,CASE==14);
  else pulse(1,1);
  wait(acks==1);repeat(30)@(negedge clk);
  if(pubs!=1||acks!=1)$fatal(1,"DIAG_REAL_TRANSACTION_COUNTS");
  if((CASE==0||CASE==1||CASE==6||CASE==14)&&selected!=1)$fatal(1,"DIAG_NORMAL_SELECTION_MISSING");
  if((CASE==2||CASE==3||CASE==4||CASE==5||(CASE>=8&&CASE<14))&&selected!=0)$fatal(1,"DIAG_UNEXPECTED_SELECTION");
  if(CASE==5&&matching_reject!=1)$fatal(1,"DIAG_TELEMETRY_REJECTION_NOT_HIT");
  if(CASE==3&&stale!=1)$fatal(1,"DIAG_STALE_NOT_HIT");
  $display("SELECTION_DIAG_PASS case=%0d pubs=%0d metadataB=%0d ACK=%0d selected=%0d consumed=%0d stale=%0d matchingRejected=%0d",CASE,pubs,metadata_b,acks,selected,consumed,stale,matching_reject);
  $fclose(events);$fclose(uart_file);$finish;
 end
 initial begin #500000000;$fatal(1,"SELECTION_DIAG_WATCHDOG");end
endmodule
'''
decl=s[s.index(' reg send_normal='):s.index(' m5b1_mailbox #(.WIDTH(64)) pair_box')]
s=s.replace(decl,'')
s=s.replace(' reg run_enable=1;',decl+' reg run_enable=1;')
tb=R/'tb/m5c_pair_diag/tb_pair_selection_diagnosis_v3.sv'
if tb.exists():assert tb.read_text()==s
else:tb.write_text(s)
sources=[R/'rtl/m5c_fusion'/n for n in ['m5b1_capture.sv','m5b1_global_engine.sv','m5b1_transfer.sv','m5b1_uart.sv','m5b1_mailbox.sv','m5b1_async_fifo.sv','m5b1_arbiter.sv','m5c_display_session.sv','m5c_line_cache.sv','m5c_mask_reader.sv']]+[R/'rtl/m5c_pair_diag'/n for n in ['m5c_pair_backend.sv','m5c_pair_diag_lease.sv','m5c_pair_controller.sv']]+[tb]
deps=sources+[Path(__file__),R/'tb/m5c_pair_diag/tb_pair_backend_fresh.sv'];inputs=[rec(p) for p in deps]
(W/'snapshots').mkdir()
for i,p in enumerate(deps):(W/'snapshots'/f'{i:02}_{p.name}').write_bytes(p.read_bytes())
(W/'INPUTS.json').write_text(json.dumps(inputs,indent=2));(W/'DERIVATION.json').write_text(json.dumps(dict(base=rec(deps[-1]),scope='real backend capture/engine/arbiter publication and B; real display session and dual mailboxes; reader bus withheld after selection, no full pixel lifecycle claim',active_before_63_unchanged=True),indent=2))
print(W,flush=True)
steps=[]
cmds=[('vlib',[str(M/'vlib.exe'),'work']),('compile',[str(M/'vlog.exe'),'-sv','-work','work']+[str(p) for p in sources])]
cases=[5,6,8,9,10,11,12,13,14]
cmds += [(f'case{c}',[str(M/'vsim.exe'),'-c','-novopt','-wlf','NUL','work.tb_pair_selection_diagnosis',f'-gCASE={c}','-do','run -all; quit -f']) for c in cases]
for stage,cmd in cmds:
 d=W/stage;d.mkdir(); cwd=W if stage in ('vlib','compile') else d
 if stage not in ('vlib','compile'):cmd[cmd.index('work.tb_pair_selection_diagnosis')]=str(W/'work')+'.tb_pair_selection_diagnosis'
 # Explicit library mapping for independent case output directories.
 if stage not in ('vlib','compile'):
  (d/'modelsim.ini').write_text('[Library]\nwork = '+str(W/'work')+'\n')
  cmd[cmd.index(str(W/'work')+'.tb_pair_selection_diagnosis')]='work.tb_pair_selection_diagnosis'
 start=time.time()
 with (d/'native.log').open('w') as log:
  p=subprocess.Popen(cmd,cwd=cwd,stdout=log,stderr=subprocess.STDOUT)
  (d/'OWNER.json').write_text(json.dumps(dict(pid=p.pid,started=datetime.datetime.now().astimezone().isoformat(),command=cmd,cwd=str(cwd)),indent=2));print(stage,p.pid,flush=True);code=p.wait()
 text=(d/'native.log').read_text(errors='replace');ok=code==0 and '** Error' not in text and '** Fatal' not in text and (stage in ('vlib','compile') or 'SELECTION_DIAG_PASS' in text)
 steps.append(dict(stage=stage,exit=code,ok=ok,seconds=time.time()-start,log=rec(d/'native.log')))
 (W/'PROGRESS.json').write_text(json.dumps(steps,indent=2))
 if not ok:print(text[-5000:],flush=True);break
unchanged=all(rec(Path(x['path']))==x for x in inputs)
act=all(rec(Path(x['path']))['sha256']==x['sha256'] for x in active)
(W/'RESULT.json').write_text(json.dumps(dict(status='PASS_BOUNDED_SELECTION_MATRIX' if len(steps)==len(cmds) and all(x['ok'] for x in steps) and unchanged and act else 'NOT_PASS',steps=steps,source_unchanged=unchanged,active_63_unchanged=act),indent=2));print(W,flush=True)
