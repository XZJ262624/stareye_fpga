`timescale 1ns/1ps
module tb_median_core;
    integer test_pass=0;
    reg clk=0; always #5 clk=~clk;
    reg rst_n=0,in_valid=0;
    reg [7:0] p[0:8];
    wire out_valid; wire [7:0] median_gray;
    median_3x3 dut(.clk(clk),.rst_n(rst_n),.in_valid(in_valid),
        .p00(p[0]),.p01(p[1]),.p02(p[2]),.p10(p[3]),.p11(p[4]),
        .p12(p[5]),.p20(p[6]),.p21(p[7]),.p22(p[8]),
        .out_valid(out_valid),.median_gray(median_gray));
    integer stim,gold,obs,n,m,c=0,i,sr,sv,px[0:8],ec,ev,eg;
    reg [4095:0] sf,gf,of,wf;
    initial begin
        for(i=0;i<9;i=i+1) p[i]=0;
        if(!$value$plusargs("STIM=%s",sf) || !$value$plusargs("GOLD=%s",gf) ||
           !$value$plusargs("OBS=%s",of)) $fatal(1,"missing file arguments");
        stim=$fopen(sf,"r"); gold=$fopen(gf,"r"); obs=$fopen(of,"w");
        if(!stim || !gold || !obs) $fatal(1,"file open failed");
        if($value$plusargs("WAVE=%s",wf)) begin $dumpfile(wf); $dumpvars(0,tb_median_core); end
        while(!$feof(stim)) begin
            n=$fscanf(stim,"%d %d %d %d %d %d %d %d %d %d %d\n",
                sr,sv,px[0],px[1],px[2],px[3],px[4],px[5],px[6],px[7],px[8]);
            m=$fscanf(gold,"%d %d %d\n",ec,ev,eg);
            if(n!=11 || m!=3 || ec!=c) $fatal(1,"malformed/truncated files at %0d",c);
            @(negedge clk); rst_n=sr; in_valid=sv;
            for(i=0;i<9;i=i+1) p[i]=px[i];
            if(!sr) begin #1; if(out_valid!==0 || median_gray!==0)
                $fatal(1,"core asynchronous reset failure"); end
            @(posedge clk); #1;
            $fwrite(obs,"%0d %0d %0d\n",c,out_valid,median_gray);
            if(out_valid!==ev[0] || median_gray!==eg[7:0])
                $fatal(1,"CORE_MISMATCH cycle=%0d got=%0d,%0d expected=%0d,%0d",
                    c,out_valid,median_gray,ev,eg);
            c=c+1;
        end
        if(!$feof(gold)) $fatal(1,"extra golden rows");
        $fclose(stim); $fclose(gold); $fclose(obs);
        test_pass=1; $display("CORE_SELF_CHECK_PASS cycles=%0d",c); $finish;
    end
endmodule
