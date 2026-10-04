`timescale 1ns/1ps
// Simulate the ACTUAL full final mapped netlist, not a reconstructed RAM.
// Only the already separately tested LCD adapter boundary is overridden.
module tb_mapped_ram;
  reg clk=0;always #5 clk=~clk;
  reg stimulus_arst_n=0,stimulus_valid=0,stimulus_sof=0;
  reg [7:0] stimulus_gray=0;
  example_top dut(.clk_pixel(clk));
  wire local_rst_n=dut.\u_sobel_stream/reset_release [1];
  wire mapped_valid=dut.\u_sobel_stream/u_lines/write_pending ;
  wire [11:0] mapped_x=dut.\u_sobel_stream/u_lines/write_x ;
  wire [7:0] top_pixel=dut.\u_sobel_stream/top_pixel ;
  wire [7:0] middle_pixel=dut.\u_sobel_stream/middle_pixel ;
  wire [7:0] bottom_pixel=dut.\u_sobel_stream/bottom_pixel ;
  integer x=0,y=0,epoch=0,checked=0,top_checked=0,cycles=0;
  integer i,f;reg armed=0,expected_valid;integer ex,ey,eg;
  function integer pixel;
    input integer px,py,pe;
    begin pixel=(px*17+py*43+pe*71+(px/7)*3)%256;end
  endfunction
  task tick;
    input integer r,v,s,g;
    begin
      @(negedge clk);stimulus_arst_n=r;stimulus_valid=v;stimulus_sof=s;stimulus_gray=g;
      @(posedge clk);
      expected_valid=0;
      if(!local_rst_n) begin armed=0;x=0;y=0;end
      else if(s) begin armed=1;x=0;y=0;end
      else if(v && armed) begin
        expected_valid=1;ex=x;ey=y;eg=g;
        if(x==1279) begin x=0;y=y+1;end else x=x+1;
      end
      #1;cycles=cycles+1;
      if(mapped_valid!==expected_valid) $fatal(1,"mapped valid mismatch cycle=%0d",cycles);
      if(expected_valid) begin
        if(mapped_x!==ex || bottom_pixel!==eg) $fatal(1,"mapped x/current mismatch");
        if(ey>=1 && middle_pixel!==pixel(ex,ey-1,epoch)) $fatal(1,"mapped row1 mismatch x=%0d y=%0d got=%0d",ex,ey,middle_pixel);
        if(ey>=2) begin
          if(top_pixel!==pixel(ex,ey-2,epoch)) $fatal(1,"mapped row2 mismatch x=%0d y=%0d got=%0d",ex,ey,top_pixel);
          top_checked=top_checked+1;
        end
        checked=checked+1;
      end
    end
  endtask
  initial begin
    force dut.lcd_gray=stimulus_gray;
    force dut.lcd_de=stimulus_valid;
    force dut.lcd_vs=~stimulus_sof;
    force dut.rstn_pixel=stimulus_arst_n;
    tick(0,0,0,0);tick(0,0,0,0);repeat(3)tick(1,0,0,0);
    for(f=1;f<=2;f=f+1) begin
      epoch=f;tick(1,0,1,0);
      for(i=0;i<1280*6;i=i+1) begin
        if(i%29==0)tick(1,0,0,199);
        if(i%1280==0)repeat(3)tick(1,0,0,255);
        tick(1,1,0,pixel(i%1280,i/1280,epoch));
      end
    end
    epoch=3;tick(1,0,1,0);
    for(i=0;i<1280*3+2;i=i+1)tick(1,1,0,pixel(i%1280,i/1280,epoch));
    tick(0,1,0,255);repeat(12)tick(1,1,0,255);
    epoch=4;tick(1,0,1,0);
    for(i=0;i<1280*6;i=i+1) begin
      if(i%11==0)tick(1,0,0,0);
      tick(1,1,0,pixel(i%1280,i/1280,epoch));
    end
    repeat(5)tick(1,0,0,0);
    $display("HDL_MAPPED_RAM_PASS pixels=%0d top_row_checks=%0d cycles=%0d",checked,top_checked,cycles);$finish;
  end
endmodule
