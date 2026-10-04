`timescale 1ns/1ps
module tb_stream;
    parameter WIDTH=9, HEIGHT=7;
    reg clk=0; always #5 clk=~clk;
    reg arst_n=0, valid=0,de=0,hs=1,vs=1,sof=0;
    reg [7:0] gray=0,threshold=0; reg [1:0] mode=0;
    wire [7:0] eg,display_gray; wire eb,ov,od,oh,os;
    wire [11:0] x,y,cx,cy;
    sobel_stream_top #(.WIDTH(WIDTH),.HEIGHT(HEIGHT)) dut (
      .clk(clk),.arst_n(arst_n),.in_gray(gray),.in_valid(valid),.in_de(de),
      .in_hs(hs),.in_vs(vs),.in_sof(sof),.threshold(threshold),.mode(mode),
      .edge_gray(eg),.edge_binary(eb),.out_valid(ov),.out_de(od),.out_hs(oh),.out_vs(os),
      .out_gray(display_gray),.out_x(x),.out_y(y),.center_x(cx),.center_y(cy));
    integer stim,obs,n,cycle=0;
    integer sr,sv,sd,sh,ss,sf,sg,st,sm;
    reg [2047:0] stimfile,obsfile,wavefile;
    initial begin
      if (!$value$plusargs("STIM=%s",stimfile)) $fatal(1,"STIM missing");
      if (!$value$plusargs("OBS=%s",obsfile)) $fatal(1,"OBS missing");
      stim=$fopen(stimfile,"r"); obs=$fopen(obsfile,"w");
      if (!stim || !obs) $fatal(1,"file open failed");
      if ($value$plusargs("WAVE=%s",wavefile)) begin $dumpfile(wavefile); $dumpvars(0,tb_stream); end
      while (!$feof(stim)) begin
        n=$fscanf(stim,"%d %d %d %d %d %d %d %d %d\n",sr,sv,sd,sh,ss,sf,sg,st,sm);
        if (n!=9) $fatal(1,"malformed stimulus at %d",cycle);
        @(negedge clk);
        arst_n=sr; valid=sv; de=sd; hs=sh; vs=ss; sof=sf; gray=sg; threshold=st; mode=sm;
        if(!sr) begin
          #1;
          if(ov!==0 || od!==0 || eg!==0 || eb!==0 || dut.reset_release!==0)
            $fatal(1,"asynchronous reset did not clear outputs before next clock");
        end
        @(posedge clk); #1;
        $fwrite(obs,"%0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d\n",
          cycle,dut.rst_n,dut.lb_valid,dut.win_valid,dut.p00,dut.p01,dut.p02,dut.p10,dut.p11,dut.p12,dut.p20,dut.p21,dut.p22,
          dut.gradient_valid,$signed(dut.gx),$signed(dut.gy),dut.mag_valid,dut.abs_gx,dut.abs_gy,dut.magnitude,dut.mag_gray,
          ov,eg,eb,od,oh,os,display_gray,x,y,cx,cy);
        cycle=cycle+1;
      end
      $fclose(stim);$fclose(obs);$display("HDL_STREAM_DONE %0d",cycle);$finish;
    end
    // The deferred-write architecture must never depend on RAM collision mode.
    always @(posedge clk) if(dut.rst_n && !sof && dut.u_lines.accept && dut.u_lines.write_pending)
      if(dut.u_lines.x==dut.u_lines.write_x) $fatal(1,"line RAM address collision");
endmodule
