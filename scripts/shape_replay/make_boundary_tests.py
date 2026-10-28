from common import *
# The already-running broad integration remains untouched. These tests target
# transitions by real lease / first-DE events, not guessed elapsed delays.
s=(R/'tb/canny_replay/tb_replay.sv').read_text().replace('module tb_replay;','module tb_retire_clip;').replace('CF=32','CF=3')
s=s.replace('if(bslot>=4&&!clip)$fatal(1,"read invalid clip");','if(bslot>=4&&!clip&&!(retiring&&dut.video.lease&&dut.video.rslot==retiring_slot&&bslot==retiring_slot))$fatal(1,"new read from invalid clip");')
s=s.replace(' integer i,j;', ' reg retiring=0;integer retiring_slot=-1;integer old_drain_reads=0;\n integer i,j;')
s=s.replace('reads=reads+1;bus_state=3;', 'reads=reads+1;bus_state=3;if(retiring&&!clip&&bslot>=4)old_drain_reads=old_drain_reads+1;')
a=s.index(' initial begin\n  for(j=0;j<36');b=s.index(' initial begin #2000000000',a)
s=s[:a]+''' initial begin
  for(j=0;j<36;j=j+1)slot_capture[j]=-1;
  #100;rst=1;wait(display_frames>=3);cmd(0);wait(clip);
  wait(dut.video.rs==2&&dut.video.read_clip&&dut.video.roffset==0);
  retiring_slot=dut.video.rslot;retiring=1;cmd(1);cmd(0);
  if(clip||state!=1)$fatal(1,"start did not invalidate");
  while(dut.video.lease&&dut.video.rslot==retiring_slot)begin
   @(negedge ui);
   if(dut.video.wslot>=4||recorded!=0)$fatal(1,"overwrite or registration before retired reader drained");
  end
  retiring=0;if(old_drain_reads==0)$fatal(1,"old lease drain not observed");
  cmd(1);cmd(2);repeat(100)@(negedge ui);if(clip||state!=0)$fatal(1,"cancel revived partial clip");
  last_registered=-1;cmd(0);wait(clip);if(recorded!=CF)$fatal;
  repeat(FB*3)@(negedge pix);
  if(dut.video_fault||dut.quarantine||dut.stop)$fatal(1,"retirement fault");
  $display("RETIRE_CLIP_PASS old_read_bursts=%0d pixel_checks=%0d complete_new_clip=%0d",old_drain_reads,pixel_checks,recorded);$finish;
 end
''' +s[b:];put(R/'tb/shape_replay/tb_retire_clip.sv',s)
s=(R/'tb/shape_replay/tb_shape_replay.sv').read_text().replace('module tb_shape_replay;','module tb_context_boundary;').replace('CF=3','CF=1')
s=s.replace('context_changes=context_changes+1;', 'context_changes=context_changes+1;$display("ACTUAL_CONTEXT_CHANGE n=%0d clip=%0d capture=%0d displayseq=%0d effective_cfg=%0d",context_changes,dut.incoming_clip,dut.m5b1_lcd_frame_id,dut.display_seq,dut.source_generation);')
a=s.index(' initial begin\n  for(j=0;j<36');b=s.index(' initial begin #2000000000',a)
s=s[:a]+''' initial begin
  for(j=0;j<36;j=j+1)slot_capture[j]=-1;
  #100;rst=1;wait(display_frames>=3);cmd(0);wait(clip);
  wait(context_changes==1);wait(history_results>=1);cmd(1);
  wait(context_changes==2);wait(dut.u_shape.result_done&&dut.u_shape.result_config==dut.generation);
  cmd(2);wait(context_changes==3);wait(history_results>=2);cmd(1);
  wait(context_changes==4);wait(dut.u_shape.result_done&&dut.u_shape.result_config==dut.generation);
  if(dut.u_m5b1.video_fault||dut.u_m5b1.quarantine||dut.u_m5b1.stop||dut.u_shape.adapter_fault||dut.shape_raster_fault)$fatal;
  if(class_results<4||history_results<2||context_changes!=4||final_pixels<5*FB)$fatal(1,"target coverage");
  $display("CONTEXT_BOUNDARY_PASS actual_contexts=%0d results=%0d history=%0d pixels=%0d same_edge_tag=1 stale_PREV_rejected=1",context_changes,class_results,history_results,final_pixels);$finish;
 end
''' +s[b:];put(R/'tb/shape_replay/tb_context_boundary.sv',s)
