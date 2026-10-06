`timescale 1ns/1ps
module tb_m32_stream;
 parameter WIDTH=160,HEIGHT=40,H_TOTAL=200;
 reg clk=0;always #5 clk=~clk;
 reg rst=0,de=0,hs=1,vs=1,sof=0,request=0;reg[7:0] gray=0,threshold=64;reg[1:0] mode=0;
 wire[7:0] result,raw,mag,th,og;wire bin,valid,od,oh,ov,filter;wire[1:0] om;wire[11:0] x,y,cx,cy;
 wire dd,dh,dv;
 m32_stream_top #(.WIDTH(WIDTH),.HEIGHT(HEIGHT),.H_TOTAL(H_TOTAL)) dut(
 .clk(clk),.arst_n(rst),.in_gray(gray),.in_de(de),.in_hs(hs),.in_vs(vs),.in_sof(sof),.filter_request(request),.threshold(threshold),.mode(mode),
 .out_gray(result),.raw_gray(raw),.edge_gray(mag),.edge_binary(bin),.out_valid(valid),.out_de(od),.out_hs(oh),.out_vs(ov),.out_filter_enable(filter),.out_threshold(th),.out_mode(om),.out_x(x),.out_y(y),.center_x(cx),.center_y(cy));
 m31_osd osd(.clk(clk),.arst_n(rst),.gray(result),.de(od),.hs(oh),.vs(ov),.threshold(th),.mode(om),.out_gray(og),.out_de(dd),.out_hs(dh),.out_vs(dv));
 // Independently instantiate old M31 display chain for exact bypass comparison.
 wire[7:0] oldgray,oldosd;wire oldde,oldhs,oldvs,oldod,oldoh,oldov;
 sobel_stream_top #(.WIDTH(WIDTH),.HEIGHT(HEIGHT)) oldsobel(.clk(clk),.arst_n(rst),.in_gray(gray),.in_valid(de),.in_de(de),.in_hs(hs),.in_vs(vs),.in_sof(sof),.threshold(threshold),.mode(mode),.out_gray(oldgray),.out_de(oldde),.out_hs(oldhs),.out_vs(oldvs),.edge_gray(),.edge_binary(),.out_valid(),.out_x(),.out_y(),.center_x(),.center_y());
 reg[7:0] ot[0:4];reg[1:0] omode[0:4];integer k;
 always @(posedge clk or negedge rst) if(!rst)for(k=0;k<5;k=k+1)begin ot[k]<=64;omode[k]<=0;end else begin ot[0]<=threshold;omode[0]<=mode;for(k=1;k<5;k=k+1)begin ot[k]<=ot[k-1];omode[k]<=omode[k-1];end end
 m31_osd oldosd_inst(.clk(clk),.arst_n(rst),.gray(oldgray),.de(oldde),.hs(oldhs),.vs(oldvs),.threshold(ot[4]),.mode(omode[4]),.out_gray(oldosd),.out_de(oldod),.out_hs(oldoh),.out_vs(oldov));
 integer f,g,n,a,b,c,d,e,h,i,j,l,cycle=0,pass=0;reg[2047:0] stim,obs;
 initial begin
 if(!$value$plusargs("STIM=%s",stim)||!$value$plusargs("OBS=%s",obs))$fatal(1,"paths");
 f=$fopen(stim,"r");g=$fopen(obs,"w");if(!f||!g)$fatal(1,"open");
 while(!$feof(f))begin
 n=$fscanf(f,"%d %d %d %d %d %d %d %d %d\n",a,b,c,d,e,h,i,j,l);
 if(n!=9)$fatal(1,"truncated stimulus");
 @(negedge clk);rst=a;gray=b;de=c;hs=d;vs=e;sof=h;request=i;threshold=j;mode=l;
 @(posedge clk);#1;
 $fwrite(g,"%0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d\n",cycle,result,raw,mag,bin,valid,od,oh,ov,filter,th,om,x,y,cx,cy,og,dd,dh,dv,oldosd,oldod,oldoh,oldov,dut.u_packet.out_ready);
 cycle=cycle+1;end
 $fclose(f);$fclose(g);pass=1;$display("M32_STREAM_COMPLETE cycles=%0d",cycle);$finish;
 end
endmodule
