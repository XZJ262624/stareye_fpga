`timescale 1ns/1ps
module tb_gaussian_kernel;
 reg clk=0;always #5 clk=~clk;
 reg rst_n=0,ce=1,in_valid=0;reg[71:0] pixels=0;reg[63:0] tag=0;
 wire gv,mv;wire[7:0] g,m;wire[63:0] ot;
 gaussian_3x3 dut(.clk(clk),.ce(ce),.rst_n(rst_n),.in_valid(in_valid),
  .p00(pixels[7:0]),.p01(pixels[15:8]),.p02(pixels[23:16]),.p10(pixels[31:24]),.p11(pixels[39:32]),.p12(pixels[47:40]),.p20(pixels[55:48]),.p21(pixels[63:56]),.p22(pixels[71:64]),.in_tag(tag),.out_valid(gv),.gaussian_gray(g),.out_tag(ot));
 m5a_median reference(.clk(clk),.ce(ce),.rst_n(rst_n),.in_valid(in_valid),
  .p00(pixels[7:0]),.p01(pixels[15:8]),.p02(pixels[23:16]),.p10(pixels[31:24]),.p11(pixels[39:32]),.p12(pixels[47:40]),.p20(pixels[55:48]),.p21(pixels[63:56]),.p22(pixels[71:64]),.out_valid(mv),.median_gray(m));
 reg[152:0] records[0:10000],e[0:8];reg[81:0] held;reg[4095:0] path;integer count,i,j,checks=0,stalls=0;
 task tick;begin
  held={gv,mv,g,m,ot};@(posedge clk);#1;
  if(rst_n)begin
   if(ce)begin
    for(j=8;j>0;j=j-1)e[j]=e[j-1];e[0]=records[i];
    if({gv,mv,g,m,ot}!=={e[8][64],e[8][64],e[8][80:73],e[8][72:65],e[8][63:0]})$fatal(1,"KERNEL_VALUE_OR_N8_TAG idx=%0d got=%0d/%0d tag=%0d expected=%0d/%0d tag=%0d",i,g,m,ot,e[8][80:73],e[8][72:65],e[8][63:0]);
    checks=checks+1;
   end else begin if({gv,mv,g,m,ot}!==held)$fatal(1,"KERNEL_CE_FREEZE");stalls=stalls+1;end
  end
  @(negedge clk);
 end endtask
 initial begin
  if(!$value$plusargs("DATA=%s",path)||!$value$plusargs("COUNT=%d",count))$fatal(1,"KERNEL_ARGS");
  $readmemh(path,records,0,count-1);for(j=0;j<9;j=j+1)e[j]=0;
  repeat(3)begin @(posedge clk);#1;@(negedge clk);end rst_n=1;
  for(i=0;i<count+9;i=i+1)begin
   if(i>=count)records[i]=0;
   pixels=records[i][152:81];tag=records[i][63:0];in_valid=records[i][64];
   if(i%7==2)begin ce=0;repeat(3)tick;end
   ce=1;tick;
  end
  if(checks!=count+9||stalls==0)$fatal(1,"KERNEL_COUNTS");
  $display("PASS_GAUSSIAN_KERNEL vectors=%0d checks=%0d stalls=%0d n_to_n8=1",count,checks,stalls);$finish;
 end
endmodule
