`timescale 1ns/1ps
module tb_median_stream;
    integer test_pass=0;
    parameter WIDTH=9,HEIGHT=7;
    reg clk=0; always #5 clk=~clk;
    reg arst_n=0,iv=0,de=0,hs=1,vs=1,sof=0,en=0;
    reg [7:0] gray=0;
    wire ov,od,oh,os,oframe,omode;
    wire [7:0] og,mg,rg;
    wire [11:0] x,y,cx,cy;
    median_stream_top #(.WIDTH(WIDTH),.HEIGHT(HEIGHT)) dut (
        .clk(clk),.arst_n(arst_n),.in_gray(gray),.in_valid(iv),.in_de(de),
        .in_hs(hs),.in_vs(vs),.in_sof(sof),.filter_enable(en),.out_gray(og),
        .median_gray(mg),.raw_gray(rg),.out_valid(ov),.out_de(od),.out_hs(oh),
        .out_vs(os),.out_sof(oframe),.out_filter_enable(omode),
        .out_x(x),.out_y(y),.center_x(cx),.center_y(cy));
    integer stim,gold,obs,n,m,c=0,i,sr,sv,sd,sh,ss,sf,sg,se;
    integer e[0:25]; reg [31:0] a[0:25];
    reg [4095:0] stimfile,goldfile,obsfile,wavefile;
    initial begin
        if(!$value$plusargs("STIM=%s",stimfile) || !$value$plusargs("GOLD=%s",goldfile) ||
           !$value$plusargs("OBS=%s",obsfile)) $fatal(1,"missing file arguments");
        stim=$fopen(stimfile,"r"); gold=$fopen(goldfile,"r"); obs=$fopen(obsfile,"w");
        if(!stim || !gold || !obs) $fatal(1,"file open failed");
        if($value$plusargs("WAVE=%s",wavefile)) begin $dumpfile(wavefile); $dumpvars(0,tb_median_stream); end
        while(!$feof(stim)) begin
            n=$fscanf(stim,"%d %d %d %d %d %d %d %d\n",sr,sv,sd,sh,ss,sf,sg,se);
            m=$fscanf(gold,"%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d\n",
                e[0],e[1],e[2],e[3],e[4],e[5],e[6],e[7],e[8],e[9],e[10],e[11],e[12],
                e[13],e[14],e[15],e[16],e[17],e[18],e[19],e[20],e[21],e[22],e[23],e[24],e[25]);
            if(n!=8 || m!=26 || e[0]!=c) $fatal(1,"malformed/truncated files at %0d",c);
            @(negedge clk); arst_n=sr; iv=sv; de=sd; hs=sh; vs=ss; sof=sf; gray=sg; en=se;
            if(!sr) begin #1;
                if(ov!==0 || od!==0 || mg!==0 || rg!==0 || og!==0 ||
                   oh!==1 || os!==1 || oframe!==0 || omode!==0 || x!==0 || y!==0 || cx!==0 || cy!==0)
                    $fatal(1,"asynchronous reset failure before clock");
            end
            @(posedge clk); #1;
            a[0]=c; a[1]=dut.rst_n; a[2]=dut.lb_valid; a[3]=dut.win_valid;
            a[4]=ov; a[5]=mg; a[6]=rg; a[7]=od; a[8]=oh; a[9]=os;
            a[10]=oframe; a[11]=omode; a[12]=og; a[13]=x; a[14]=y; a[15]=cx; a[16]=cy;
            a[17]=dut.p00; a[18]=dut.p01; a[19]=dut.p02; a[20]=dut.p10; a[21]=dut.p11;
            a[22]=dut.p12; a[23]=dut.p20; a[24]=dut.p21; a[25]=dut.p22;
            // Taps are meaningful only for a complete window; all outputs always checked.
            for(i=0;i<26;i=i+1) begin
                if(i>0) $fwrite(obs," "); $fwrite(obs,"%0d",a[i]);
                if((i<17 || e[3]==1) && a[i]!==e[i])
                    $fatal(1,"STREAM_MISMATCH cycle=%0d field=%0d got=%0d expected=%0d",c,i,a[i],e[i]);
            end
            $fwrite(obs,"\n"); c=c+1;
        end
        if(!$feof(gold)) $fatal(1,"extra golden rows");
        $fclose(stim); $fclose(gold); $fclose(obs);
        test_pass=1; $display("STREAM_SELF_CHECK_PASS cycles=%0d",c); $finish;
    end
    // Check the deferred-write baseline's key inference precondition too.
    always @(posedge clk) if(dut.rst_n && !sof && dut.u_lines.accept && dut.u_lines.write_pending)
        if(dut.u_lines.x==dut.u_lines.write_x) $fatal(1,"line RAM address collision");
endmodule
