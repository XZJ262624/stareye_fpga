`timescale 1ns/1ps
// Actual validated R0_FIFO_8 HDL, asynchronous writer, original lcd_driver,
// and new Sobel adapter. Independent analytic image checks two complete frames.
module tb_video;
    localparam W=1280,H=720;
    reg clk=0,wclk=0,rst_n=0;
    always #5 clk=~clk; always #3 wclk=~wclk;
    wire [7:0] fifo_gray,lcd_gray,eg,display_gray;
    wire request,de,hs,vs,full,busy,empty,underflow;
    wire ov,od,oh,os,eb;wire [11:0] ox,oy,cx,cy;
    wire fifo_reset=!rst_n || !vs;
    wire wen=!fifo_reset && !busy && !full;
    integer write_index=0,epoch=0,j;
    reg [127:0] wdata;
    function integer pixel;
      input integer x,y,f;
      begin pixel=(x*3+y*5+f*31)%256; end
    endfunction
    always @(negedge vs) if(rst_n) epoch=epoch+1;
    always @* begin
      for(j=0;j<16;j=j+1)
        wdata[127-8*j -: 8]=pixel((write_index+j)%W,(write_index+j)/W,epoch);
    end
    always @(posedge wclk or posedge fifo_reset)
      if(fifo_reset) write_index<=0;
      else if(wen) write_index<=write_index+16;
    R0_FIFO_8 fifo(.wr_clk_i(wclk),.rd_clk_i(clk),.a_rst_i(fifo_reset),
      .wr_en_i(wen),.rd_en_i(request),.wdata(wdata),.rdata(fifo_gray),
      .full_o(full),.rst_busy(busy),.empty_o(empty),.underflow_o(underflow));
    lcd_driver #(.DATA_WIDTH(8)) lcd(.clk(clk),.rst_n(rst_n),
      .lcd_request(request),.lcd_hs(hs),.lcd_vs(vs),.lcd_en(de),
      .lcd_rgb(lcd_gray),.lcd_data(fifo_gray));
    sobel_stream_top dut(.clk(clk),.arst_n(rst_n),.in_gray(lcd_gray),
      .in_valid(de),.in_de(de),.in_hs(hs),.in_vs(vs),.in_sof(!vs),
      .threshold(8'd64),.mode(2'd2),.edge_gray(eg),.edge_binary(eb),.out_valid(ov),
      .out_de(od),.out_hs(oh),.out_vs(os),.out_gray(display_gray),
      .out_x(ox),.out_y(oy),.center_x(cx),.center_y(cy));
    integer idx=0,x,y,a00,a01,a02,a10,a12,a20,a21,a22,gx,gy,mag;
    integer ed[0:4],ev[0:4],em[0:4],ex[0:4],ey[0:4];
    reg eh[0:4],es[0:4]; integer k,frames=0,out_pixels=0,valid_pixels=0;
    integer total_inputs=0,total_outputs=0,total_windows=0;
    initial begin
      for(k=0;k<5;k=k+1) begin ed[k]=0;ev[k]=0;em[k]=0;ex[k]=0;ey[k]=0;eh[k]=1;es[k]=1;end
      repeat(5) @(negedge clk);rst_n=1;
      #30000000;$fatal(1,"video timeout");
    end
    always @(posedge clk) begin
      if(!dut.rst_n) begin
        for(k=0;k<5;k=k+1) begin ed[k]=0;ev[k]=0;em[k]=0;eh[k]=1;es[k]=1;end
      end else begin
        for(k=4;k>0;k=k-1) begin
          ed[k]=ed[k-1];ev[k]=ev[k-1];em[k]=em[k-1];ex[k]=ex[k-1];ey[k]=ey[k-1];eh[k]=eh[k-1];es[k]=es[k-1];
        end
        ed[0]=de;eh[0]=hs;es[0]=vs;ev[0]=0;em[0]=0;
        if(vs===0) idx=0;
        if(de===1) begin
          x=idx%W;y=idx/W;
          if(lcd_gray!==pixel(x,y,epoch)) begin
            $display("FIFO_LCD_MISMATCH index=%0d epoch=%0d got=%0d expected=%0d",idx,epoch,lcd_gray,pixel(x,y,epoch));$fatal(1,"FWFT alignment");
          end
          if(x>=2 && y>=2) begin
            a00=pixel(x-2,y-2,epoch);a01=pixel(x-1,y-2,epoch);a02=pixel(x,y-2,epoch);
            a10=pixel(x-2,y-1,epoch);a12=pixel(x,y-1,epoch);
            a20=pixel(x-2,y,epoch);a21=pixel(x-1,y,epoch);a22=pixel(x,y,epoch);
            gx=-a00+a02-2*a10+2*a12-a20+a22;
            gy=a00+2*a01+a02-a20-2*a21-a22;
            mag=(gx<0?-gx:gx)+(gy<0?-gy:gy);
            ev[0]=1;em[0]=(mag>255)?255:mag;
          end
          ex[0]=x;ey[0]=y;idx=idx+1;total_inputs=total_inputs+1;
        end
      end
      #1;
      if(od!==ed[4] || oh!==eh[4] || os!==es[4]) $fatal(1,"video sync mismatch");
      if(ov!==ev[4] || eg!==em[4] || eb!==(ev[4] && em[4]>=64)) $fatal(1,"edge value mismatch");
      if(od) begin
        out_pixels=out_pixels+1;total_outputs=total_outputs+1;
        if(display_gray!==((ev[4] && em[4]>=64)?8'd255:8'd0)) $fatal(1,"display mismatch");
        if(ov) begin
          valid_pixels=valid_pixels+1;total_windows=total_windows+1;
          if(ox!=ex[4] || oy!=ey[4] || cx!=ex[4]-1 || cy!=ey[4]-1) $fatal(1,"coordinate mismatch");
        end
        if(out_pixels==W*H) begin
          if(valid_pixels!=(W-2)*(H-2)) $fatal(1,"window count mismatch");
          frames=frames+1;
          $display("VIDEO_FRAME_PASS frame=%0d de=%0d windows=%0d",frames,out_pixels,valid_pixels);
          out_pixels=0;valid_pixels=0;
          if(frames==2) begin
            $display("HDL_VIDEO_PASS frames=2 inputs=%0d outputs=%0d windows=%0d",total_inputs,total_outputs,total_windows);$finish;
          end
        end
      end
    end
    always @(posedge clk) if(rst_n && request && empty) $fatal(1,"FIFO underflow at request");
endmodule
