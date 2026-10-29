`timescale 1ns/1ps
module tb_keys_core;
reg clk=0;always #5 clk=~clk;reg rst_n=0,ce=1,sof=0,eof=0,active=0,edge_pixel=0,qualified=1,event_valid=0;
reg [2:0] event_code=0;reg [11:0] x=0,y=0;reg [63:0] ticks=0,fid=1,seq=1,epoch=1,gen=1,cfg=1;
always @(posedge clk)ticks<=ticks+1;
wire valid,have,busy,done,good;wire [3:0] count,err;wire [1:0] conf;
part_keys_core #(.RX(0),.RY(0),.RW(160),.RH(60),.INTERVAL_TICKS(0)) dut(.clk(clk),.rst_n(rst_n),.ce(ce),.source_sof(sof),.ticks(ticks),.live_epoch(epoch),.generation(gen),.event_valid(event_valid),.event_fault(1'b0),.event_code(event_code),.sof(sof),.eof(eof),.active(active),.qualified(qualified),.x(x),.y(y),.edge_pixel(edge_pixel),.edge_support(1'b1),.frame_id(fid),.epoch(epoch),.config_id(cfg),.display_seq(seq),.count_valid(valid),.have_value(have),.busy(busy),.count(count),.error_code(err),.confirmations(conf),.job_done(done),.job_good(good));
integer xx,yy,n,jobs=0;
task tick;begin @(posedge clk);#1;@(negedge clk);end endtask
task image;begin fid=fid+1;seq=seq+1;sof=1;tick();sof=0;
 for(yy=0;yy<60;yy=yy+1)for(xx=0;xx<160;xx=xx+1)begin x=xx;y=yy;active=1;edge_pixel=((xx==20||xx==140)&&yy>=14&&yy<=46)||((yy==14||yy==46)&&xx>=20&&xx<=140);tick();end
 active=0;eof=1;tick();eof=0;
end endtask
task finish_job;begin n=0;while(!done&&n<300000)begin tick();n=n+1;end if(!done||!good)$fatal(1,"CORE_JOB e=%d n=%d",err,n);repeat(30)tick();jobs=jobs+1;end endtask
task send;begin image();finish_job();end endtask
initial begin repeat(5)tick();rst_n=1;repeat(10)tick();send();send();send();if(!valid||!have||count!=1||conf!=3)$fatal(1,"CORE_CURRENT1");
 // A real job is in flight, then live config changes before CCL publication.
 image();if(!busy)$fatal(1,"NO_INFLIGHT");gen=2;tick();tick();if(valid||conf||!have||count!=1)$fatal(1,"CONFIG_LAST_REVOKE");
 repeat(60000)begin tick();if(good&&done)$fatal(1,"OLD_JOB_PUBLISHED");end
 // An old aligned tag after the context switch must not restart counting.
 image();repeat(30000)tick();if(valid||conf||!have)$fatal(1,"OLD_TAG_ACCEPTED");
 cfg=2;send();if(conf!=1||valid)$fatal(1,"NEW_FIRST");
 // ABA returns to original threshold externally but requires a third generation.
 gen=3;cfg=3;tick();tick();if(conf||valid||!have)$fatal(1,"ABA_REVOKE");send();send();send();if(!valid||conf!=3)$fatal(1,"NEW_THREE");
 // View events and no-change saturation do not alter generation or CURRENT.
 event_valid=1;event_code=3;tick();event_valid=0;repeat(4)tick();if(!valid||conf!=3||!have)$fatal(1,"VIEW_REVOKE");
 repeat(10)tick();if(!valid)$fatal(1,"SATURATION_REVOKE");
 epoch=2;tick();tick();if(have||valid)$fatal(1,"EPOCH_HISTORY_CLEAR");
 $display("PASS_KEYS_CORE jobs=%0d busy_config_cancel old_tags ABA CURRENT_LAST three_confirm view_saturation epoch",jobs);$finish;
end
initial begin repeat(2000000)@(posedge clk);$fatal(1,"CORE_WATCHDOG");end
endmodule
