`timescale 1ns/1ps
module tb_m5a_recovery;
reg test_pass=0;
localparam W=16,H=16,HT=20,VT=26,LAT=4*HT+25;
reg clk=0;always #5 clk=~clk;
reg rst=0,de=0,hs=1,vs=1,sof=0;reg[7:0]gray=0;
wire[23:0]rgb;wire od,oh,ov,valid,edgebit,fault;wire[11:0]x,y;
m5a_stream_top #(.WIDTH(W),.HEIGHT(H),.H_TOTAL(HT)) dut(
 .clk(clk),.ce(1'b1),.arst_n(rst),.in_gray(gray),.in_de(de),.in_hs(hs),.in_vs(vs),.in_sof(sof),
 .filter_request(1'b1),.threshold(8'd64),.mode(3'd6),.out_rgb(rgb),.out_de(od),.out_hs(oh),.out_vs(ov),
 .out_raw(),.out_legacy_mag(),.out_legacy_bin(),.out_threshold(),.out_mode(),.out_filter_enable(),.out_overlay_valid(),.out_overlay_edge(),.out_nms(),.out_nms_valid(),.out_canny_valid(valid),.out_canny_edge(edgebit),.out_x(x),.out_y(y),.raster_fault(fault));
integer f,v,z,ix,iy,i,faults=0,good_valid=0,cycles=0;reg check_good=0;
task tick;
input d,hh,vv;input[7:0]g;
begin
 @(negedge clk);de=d;hs=hh;vs=vv;sof=!vv;gray=g;
 @(posedge clk);#1;cycles=cycles+1;
 if(fault)begin faults=faults+1;if(dut.u_base.center_support)$fatal(1,"GAP_FAIL_CLOSED");end
 if(check_good && valid)good_valid=good_valid+1;
 if(edgebit && (x<4 || x>=W-4 || y<4 || y>=H-4))$fatal(1,"RECOVERY_BORDER_RED");
end endtask
initial begin
 repeat(3)@(negedge clk);rst=1;repeat(8)@(negedge clk);
 for(f=0;f<4;f=f+1)begin
  check_good=f>=2;
  for(v=0;v<VT;v=v+1)for(z=0;z<HT;z=z+1)begin
   ix=z-2;iy=v-2;
   // Frame 0: invalid line gap. Frame 1: asynchronous mid-frame reset.
   if(f==1 && v==5 && z==5)begin #2;rst=0;#2;end
   if(f==1 && v==6 && z==0)rst=1;
   if(ix>=0&&ix<W&&iy>=0&&iy<H)tick(!(f==0 && iy==3 && ix==4),z>=1,v>=1,(ix*9+iy*13+f*21)%256);
   else tick(0,z>=1,v>=1,0);
  end
 end
 repeat(LAT+5)tick(0,1,1,0);
 if(faults==0 || good_valid<16)$fatal(1,"RECOVERY_COVERAGE faults=%0d good=%0d",faults,good_valid);
 test_pass=1;$display("M5A_RECOVERY_PASS cycles=%0d malformed_fault_cycles=%0d recovered_windows=%0d",cycles,faults,good_valid);$finish;
end
endmodule
