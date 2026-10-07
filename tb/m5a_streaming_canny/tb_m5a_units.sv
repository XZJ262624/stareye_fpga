`timescale 1ns/1ps
module tb_m5a_units;
 reg test_pass=0;reg signed[10:0] gx,gy;wire[1:0] direction;
 reg support;reg[11:0] nms;reg[7:0] high;wire[7:0] low;wire strong_edge,weak_edge;
 m5a_direction d(gx,gy,direction);
 m5a_dual_threshold c(support,nms,high,low,strong_edge,weak_edge);
 integer x,y,ax,ay,expected,t,z,dcount=0,tcount=0,equalities=0;
 initial begin
  support=1;high=64;nms=0;
  for(x=-1024;x<=1023;x=x+1)for(y=-1024;y<=1023;y=y+1)begin
   gx=x;gy=y;ax=(x<0)?-x:x;ay=(y<0)?-y:y;
   if(ay*128<=ax*53)expected=0;
   else if(ax*128<=ay*53)expected=2;
   else if(x*y>=0)expected=1;else expected=3;
   #1;if(direction!==expected[1:0])$fatal(1,"DIRECTION x=%0d y=%0d got=%0d want=%0d",x,y,direction,expected);
   if(ay*128==ax*53 || ax*128==ay*53)equalities=equalities+1;dcount=dcount+1;
  end
  for(t=0;t<256;t=t+1)for(z=0;z<4096;z=z+1)begin
   high=t;nms=z;#1;
   if(low!==(t/2) || strong_edge!==((z!=0)&&(z>=t)) || weak_edge!==((z!=0)&&(z>=t/2)&&(z<t)))$fatal(1,"CLASSIFY high=%0d nms=%0d",t,z);
   tcount=tcount+1;
  end
  support=0;for(t=0;t<256;t=t+1)begin high=t;nms=4095;#1;if(strong_edge || weak_edge)$fatal(1,"CLASSIFY_SUPPORT");end
  if(dcount!=4194304 || tcount!=1048576 || equalities!=61)$fatal(1,"UNIT_COVERAGE directions=%0d classifications=%0d ties=%0d",dcount,tcount,equalities);
  test_pass=1;$display("M5A_UNITS_PASS directions=%0d exact_ties=%0d classifications=%0d thresholds=256",dcount,equalities,tcount);$finish;
 end
endmodule
