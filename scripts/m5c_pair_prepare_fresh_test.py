from pathlib import Path
import json,hashlib
R=Path.cwd();O=R/'reports/m5c_pair_capture_20261016/pair_only_revision_v2';p=R/'tb/m5c_pair_diag/tb_pair_backend_legacy_recovery.sv';s=p.read_text().replace('tb_pair_backend_legacy_recovery','tb_pair_backend_fresh');s=s.replace(' wire [31:0] address;'," reg request_pair=0,cap_done=0;wire cap_take;reg [63:0] sid=64'h1234000000000007;\n wire [767:0] result_desc;\n wire [31:0] address;")
s=s.replace(".pair_request(1'b0),.pair_request_session(64'd0)",'.pair_request(request_pair),.pair_request_session(sid)').replace(".active_pair_descriptor(768'd0),.pair_session(64'd0)",'.active_pair_descriptor(result_desc),.pair_session(sid)').replace(".pair_done(1'b0),.pair_reason(32'd0)",".pair_done(cap_done),.pair_done_take(cap_take),.pair_reason(32'd2)").replace('.fusion_ack(fusion_ack)', '.result_descriptor(result_desc),.fusion_ack(fusion_ack)',1)
s=s.replace(".rresp((CASE==2&&backend.uart_owned&&cr[2])?2'b10:crp[5:4])",'.rresp(crp[5:4])')
a=s.index(' // Recovery oracle');s=s[:a]+''' integer cycle=0,metadata_b=0,phase=0,pubs=0,selected=0,failed_packets=0,stats_packets=0;
 reg meta_pending=0;reg previous_fresh=0;integer ack_deadline=0;
 always @(posedge clk)if(rst_n)begin
  cycle=cycle+1;
  if(lease_fault||backend.export_exclusive||pair_leased[1]||pair_leased[3])$fatal(1,"PAIR_ONLY_LEASE_PROFILE");
  if(backend.publication_accept)begin
   pubs=pubs+1;if(backend.pair_selected||backend.state!=backend.ENGINE_WAIT)$fatal(1,"PAIR_ONLY_PUBLISH_SELECT_LIFECYCLE");
  end
  if(backend.pair_selected)begin selected=selected+1;if(!backend.fresh_publication_seen||pubs!=2)$fatal(1,"PAIR_ONLY_NOT_REAL_FRESH");end
  if(backend.packet.start&&backend.packet.packet_type!=1&&backend.packet.packet_type!=10)$fatal(1,"PAIR_ONLY_LEGACY_PACKET");
  if(backend.packet_done)begin
   if(backend.packet.packet_type==1)stats_packets=stats_packets+1;
   else if(backend.packet.packet_type==10)failed_packets=failed_packets+1;
  end
  if(avalid&&aready)meta_pending=(aaddr==32'h010e6000||aaddr==32'h010e6080)&&atype;
  if(bvalid&&bready&&meta_pending)begin metadata_b=metadata_b+1;meta_pending=0;end
  if(backend.pair_arm)cap_done<=1;
  if(cap_take)cap_done<=0;
  if(phase==0&&pubs==1&&backend.state==backend.IDLE)begin
   if(!backend.fresh_publication_seen||metadata_b!=1||stats_packets!=1)$fatal(1,"PAIR_ONLY_FIRST_PUBLICATION");
   fusion_slot<=backend.result_slot;fusion_identity<={result_desc[63:0],result_desc[191:128],result_desc[127:64],result_desc[447:384],result_desc[511:448]};fusion_acquire<=1;ack_deadline=cycle+32;phase=1;
  end
  if((phase==1||phase==4)&&cycle>ack_deadline)$fatal(1,"PAIR_ONLY_ACK_DEADLINE");
  if((phase==1||phase==4)&&fusion_ack)begin
   if(fusion_denied||!pair_leased[fusion_slot?2:0])$fatal(1,"PAIR_ONLY_BAD_REAL_ACK");
   fusion_acquire<=0;fusion_release<=1;fusion_retire<=1;request_pair<=0;phase=phase==1?2:5;
  end else if(phase==2)begin fusion_release<=0;fusion_retire<=0;fusion_token<=2;phase=3;end
  else if(phase==5)begin fusion_release<=0;fusion_retire<=0;phase=6;end
  if(phase==3&&pubs==2&&backend.state==backend.IDLE)begin
   if(metadata_b!=2||!backend.fresh_publication_seen||selected!=0)$fatal(1,"PAIR_ONLY_SECOND_PUBLICATION");
   fusion_slot<=backend.result_slot;fusion_identity<={result_desc[63:0],result_desc[191:128],result_desc[127:64],result_desc[447:384],result_desc[511:448]};request_pair<=1;fusion_acquire<=1;ack_deadline=cycle+32;phase=4;
  end
  if(phase==6&&!backend.pair_hold)begin
   if(selected!=1||backend.fresh_publication_seen||failed_packets!=1||pair_leased!=0)$fatal(1,"PAIR_ONLY_FAILED_ATTEMPT_DRAIN");phase=7;
  end
  if(phase==7&&pubs==3&&backend.state==backend.IDLE)begin
   if(!backend.fresh_publication_seen||metadata_b!=3||selected!=1||stats_packets!=3||backend.requests!=backend.accepted+backend.busy_rejected)$fatal(1,"PAIR_ONLY_RECOVERY_PUBLICATION");
   $fclose(uart_file);$display("PAIR_ONLY_BACKEND_PASS pubs=%0d metadataB=%0d selected=%0d failurePackets=%0d stats=%0d RT=%0d",pubs,metadata_b,selected,failed_packets,stats_packets,rt_completed);$finish;
  end
 end
 initial begin #500000000;$fatal(1,"PAIR_ONLY_WATCHDOG phase=%0d state=%0d",phase,backend.state);end
endmodule
''';q=R/'tb/m5c_pair_diag/tb_pair_backend_fresh.sv';q.write_text(s)
def rec(q):b=q.read_bytes();return dict(path=q.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
(O/'FRESH_TEST_DERIVATION.json').write_text(json.dumps(dict(parent=rec(p),derived=rec(q),scope='Real backend/capture/engine/lease/transfer/arbiter with zeroDDR class model and independent B conservation. Mock PIX done reason2 after real arm tests failed attempt; not fullvideo success. Firstnormalacquire,secondselectedfailure,thirdnewpublication; byteacceptedUART notpin.'),indent=2))
