`timescale 1ns/1ps
module tb_m5a_windows;
 reg test_pass=0;localparam W=19,H=17,F=25;
 reg clk=0;always #5 clk=~clk;reg rst=0,ce=1,sof=0,de=0,support=0,strong_edge=0,weak_edge=0;reg[11:0] mag=0;reg[1:0] dir=0;
 wire ns,cs,edgebit;wire[11:0] nms,nx,ny,cx,cy;
 m5a_nms #(.WIDTH(W),.HEIGHT(H)) n(clk,ce,rst,sof,de,support,mag,dir,ns,nms,nx,ny);
 m5a_local_hysteresis #(.WIDTH(W),.HEIGHT(H)) c(clk,ce,rst,sof,de,support,strong_edge,weak_edge,cs,edgebit,cx,cy);
 reg[43:0] data[0:W*H-1];reg[14:0] q[0:1];integer qp=0,ticks=0,stalls=0,checks=0,edges=0,nonzero=0;
 reg[27:0] holdn,holdc;reg[2047:0] path,root;integer f,x,y,i;reg[14:0] expected;
 task tick;input dd,ss;input[43:0] p;input[14:0] exp;
 begin
  if(ticks%11==4)begin
   @(negedge clk);ce=0;holdn={ns,nms,nx};holdc={cs,edgebit,cx,cy};
   repeat(2)begin @(posedge clk);#1;if(holdn!=={ns,nms,nx} || holdc!=={cs,edgebit,cx,cy})$fatal(1,"WINDOW_STALL");stalls=stalls+1;end
  end
  @(negedge clk);ce=1;de=dd;sof=ss;{support,strong_edge,weak_edge,dir,mag}=p[16:0];
  @(posedge clk);#1;
  if({ns,nms,cs,edgebit}!==q[qp])$fatal(1,"WINDOW_RESULT frame=%0d x=%0d y=%0d got=%h exp=%h",f,x,y,{ns,nms,cs,edgebit},q[qp]);
  if(ns)begin checks=checks+1;if(nms)nonzero=nonzero+1;end
  if(edgebit)edges=edges+1;
  q[qp]=exp;qp=1-qp;ticks=ticks+1;
 end endtask
 initial begin
  if(!$value$plusargs("DIR=%s",root))$fatal(1,"DIR");q[0]=0;q[1]=0;
  repeat(4)@(negedge clk);rst=1;
  for(f=0;f<F;f=f+1)begin
   $sformat(path,"%0s/window_%0d.hex",root,f);$readmemh(path,data);
   tick(0,1,0,0);tick(0,1,0,0);tick(0,0,0,0);
   for(y=0;y<H;y=y+1)begin
    for(x=0;x<W;x=x+1)begin
     expected=(x>=2 && y>=2)?data[(y-1)*W+x-1][31:17]:15'd0;
     tick(1,0,data[y*W+x],expected);
    end
    tick(0,0,0,0);tick(0,0,0,0);
   end
   repeat(4)tick(0,0,0,0);
   if(f==11)begin
    @(negedge clk);rst=0;repeat(2)@(negedge clk);rst=1;q[0]=0;q[1]=0;qp=0;
    // After a reset, valid without SOF must be ignored rather than mislabeled.
    repeat(30)tick(1,0,44'h1ffff,0);
   end
  end
  if(checks<5000 || edges<100 || nonzero<100 || stalls<100)$fatal(1,"WINDOW_COVERAGE");
  test_pass=1;$display("M5A_WINDOWS_PASS frames=%0d full_windows=%0d nms_nonzero=%0d edges=%0d stalls=%0d reset_rearm=1",F,checks,nonzero,edges,stalls);$finish;
 end
endmodule
