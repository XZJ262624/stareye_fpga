`timescale 1ns/1ps
module tb_shape_contract_edges;
reg clk=0;always #5 clk=~clk;
reg rst_n=0,ce=1,ss=0,sd=0,sq=0,fd=0;
reg[63:0] id=7,ep=1,cfg=2,seq=3;reg[11:0] x=0,y=0;
wire af,aq,cs,cf,dv,rv;wire[63:0] aid,aep,acfg,aseq;
shape_stream_adapter_contract_v2 dut(.clk(clk),.rst_n(rst_n),.ce(ce),
 .source_sof(ss),.source_de(sd),.source_qualified(sq),.source_frame_id(id),.source_epoch(ep),.source_config(cfg),.source_display_seq(seq),
 .final_de(fd),.final_support(1'b1),.final_edge(1'b0),.final_raster_fault(1'b0),.final_x(x),.final_y(y),
 .adapter_fault(af),.aligned_qualified(aq),.recognition_sof(cs),.recognition_eof(cf),.display_valid(dv),.result_valid(rv),
 .aligned_frame_id(aid),.aligned_epoch(aep),.aligned_config(acfg),.aligned_source_seq(aseq));
task tick;begin @(posedge clk);#1;@(negedge clk);end endtask
task reset_all;begin rst_n=0;ce=1;ss=0;sd=0;sq=0;fd=0;id=7;ep=1;cfg=2;seq=3;repeat(3)tick;rst_n=1;tick;end endtask
task source;begin ss=1;tick;ss=0;sd=1;sq=1;tick;sd=0;sq=0;end endtask
task first;begin fd=1;x=0;y=0;#1;if(!cs||!aq)$fatal(1,"CONTRACT_FIRST_NOT_QUALIFIED");tick;fd=0;end endtask
task last;begin fd=1;x=1279;y=719;tick;fd=0;tick;end endtask
integer k;reg[265:0] held;
initial begin
 reset_all;source;first;
 // ID and pixel qualifier may be meaningless in blanking; controls may not.
 id=999;repeat(5)tick;if(!aq||af)$fatal(1,"LEGAL_BLANK_QUALIFICATION_LOST");id=7;
 sd=1;sq=1;tick;sd=0;sq=0;last;if(af)$fatal(1,"LEGAL_BLANK_FAULT");
 // Startup discarded frame, source SOF overlaps old discarded EOF.
 reset_all;fd=1;x=0;y=0;tick;fd=0;
 if(af||aq||dv||rv||cs)$fatal(1,"STARTUP_DISCARD_FAULT");
 ss=1;fd=1;x=1279;y=719;tick;ss=0;fd=0;sd=1;sq=1;tick;sd=0;sq=0;
 first;if({aid,aep,acfg,aseq}!={64'd7,64'd1,64'd2,64'd3})$fatal(1,"STARTUP_RECOVERY_TAG");last;
 if(af)$fatal(1,"STARTUP_RECOVERY_FAULT");
 // Simultaneous empty-queue enqueue/final-first binds exact incoming tuple.
 reset_all;ss=1;tick;ss=0;sd=1;sq=1;fd=1;x=0;y=0;#1;
 if(!cs||!aq||aid!=7)$fatal(1,"BYPASS_FIRST_TAG");tick;sd=0;sq=0;fd=0;last;
 if(af)$fatal(1,"BYPASS_FAULT");
 // First, middle, and EOF-edge source-pixel invalidity remain sticky.
 for(k=0;k<3;k=k+1)begin
  reset_all;ss=1;tick;ss=0;sd=1;sq=k!=0;tick;sd=0;sq=0;
  fd=1;x=0;y=0;tick;fd=0;
  if(k!=0)begin sd=1;sq=0;if(k==2)begin fd=1;x=1279;y=719;end tick;sd=0;sq=0;fd=0;end
  if(aq)$fatal(1,"INVALID_PIXEL_NOT_STICKY");
  sd=1;sq=1;tick;sd=0;sq=0;if(aq)$fatal(1,"INVALID_PIXEL_RECOVERED_INSIDE_FRAME");
 end
 // Each independently valid control changes during DE=0: still invalidates.
 for(k=0;k<3;k=k+1)begin reset_all;source;first;
  case(k)0:ep=2;1:cfg=3;2:seq=4;endcase tick;
  if(aq)$fatal(1,"BLANK_CONTROL_CHANGE_IGNORED");
 end
 reset_all;source;first;sd=1;sq=1;id=8;tick;sd=0;sq=0;if(aq)$fatal(1,"ACTIVE_ID_CHANGE_IGNORED");
 // New source SOF changes controls without corrupting previous tail's tag.
 reset_all;source;first;ss=1;seq=4;cfg=3;tick;ss=0;sd=1;sq=1;id=8;tick;sd=0;sq=0;
 if(!aq||aseq!=3||acfg!=2)$fatal(1,"NEXT_SOURCE_CORRUPTED_OLD_TAIL");last;
 first;if(aid!=8||aseq!=4||acfg!=3)$fatal(1,"OVERLAP_NEW_TAG_LOST");last;
 // Successful sync permanently disables startup empty-frame discard.
 fd=1;x=0;y=0;tick;fd=0;if(!af||aq)$fatal(1,"SYNCHRONIZED_EMPTY_NOT_FAULT");
 // CE holds every adapter state even while inputs request startup/start/end.
 reset_all;source;first;ce=0;held={dut.synchronized,dut.discard_live,dut.wr,dut.rd,dut.current_tag,dut.final_live,dut.eof_pending,dut.qualified};
 fd=1;x=1279;y=719;ss=1;repeat(5)tick;
 if(held!=={dut.synchronized,dut.discard_live,dut.wr,dut.rd,dut.current_tag,dut.final_live,dut.eof_pending,dut.qualified})$fatal(1,"CONTRACT_CE_CHANGED");
 $display("PASS_CONTRACT_EDGE_PHASES");$finish;
end
endmodule
