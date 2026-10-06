`timescale 1ns/1ps
// Standalone pixel-domain wrapper, eleven sampling stages: input n -> n+10.
// DE/RAW/sync advance each clock; only accepted valid pixels advance the raster.
module median_stream_top #(
    parameter WIDTH=1280, parameter HEIGHT=720
)(
    input clk, input arst_n,
    input [7:0] in_gray, input in_valid,in_de,in_hs,in_vs,in_sof,
    input filter_enable,
    output [7:0] out_gray,median_gray,raw_gray,
    output out_valid,out_de,out_hs,out_vs,out_sof,out_filter_enable,
    output [11:0] out_x,out_y,center_x,center_y
);
    (* async_reg="true" *) reg [1:0] reset_release;
    always @(posedge clk or negedge arst_n)
        if (!arst_n) reset_release<=0;
        else reset_release<={reset_release[0],1'b1};
    wire rst_n=reset_release[1];
    reg sof_d,active_enable;
    wire frame_start=in_sof && !sof_d;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin sof_d<=0; active_enable<=0; end
        else begin
            sof_d<=in_sof;
            // One update per SOF interval, including a multi-clock VS-low level.
            if (frame_start) active_enable<=filter_enable;
        end
    end
    wire lb_valid,win_valid;
    wire [11:0] lb_x,lb_y;
    wire [7:0] top_pixel,middle_pixel,bottom_pixel;
    wire [7:0] p00,p01,p02,p10,p11,p12,p20,p21,p22;
    line_buffer_3x3 #(.WIDTH(WIDTH),.HEIGHT(HEIGHT)) u_lines (
        .clk(clk),.rst_n(rst_n),.in_sof(in_sof),.in_valid(in_valid),.in_gray(in_gray),
        .out_valid(lb_valid),.top_pixel(top_pixel),.middle_pixel(middle_pixel),
        .bottom_pixel(bottom_pixel),.out_x(lb_x),.out_y(lb_y));
    window_3x3 u_window (
        .clk(clk),.rst_n(rst_n),.in_valid(lb_valid),.in_x(lb_x),.in_y(lb_y),
        .top_pixel(top_pixel),.middle_pixel(middle_pixel),.bottom_pixel(bottom_pixel),
        .out_valid(win_valid),.p00(p00),.p01(p01),.p02(p02),.p10(p10),.p11(p11),
        .p12(p12),.p20(p20),.p21(p21),.p22(p22));
    median_3x3 u_median (
        .clk(clk),.rst_n(rst_n),.in_valid(win_valid),
        .p00(p00),.p01(p01),.p02(p02),.p10(p10),.p11(p11),.p12(p12),
        .p20(p20),.p21(p21),.p22(p22),.out_valid(out_valid),.median_gray(median_gray));

    reg [10:0] de_pipe,hs_pipe,vs_pipe,sof_pipe,mode_pipe;
    reg [7:0] gray_pipe[0:10];
    reg [11:0] x_pipe[0:9],y_pipe[0:9];
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            de_pipe<=0; hs_pipe<=11'h7ff; vs_pipe<=11'h7ff;
            sof_pipe<=0; mode_pipe<=0;
            for(i=0;i<11;i=i+1) gray_pipe[i]<=0;
            for(i=0;i<10;i=i+1) begin x_pipe[i]<=0; y_pipe[i]<=0; end
        end else begin
            de_pipe<={de_pipe[9:0],in_de}; hs_pipe<={hs_pipe[9:0],in_hs};
            vs_pipe<={vs_pipe[9:0],in_vs}; sof_pipe<={sof_pipe[9:0],in_sof};
            // Tag the boundary itself with the new mode without affecting old slots.
            mode_pipe<={mode_pipe[9:0],frame_start ? filter_enable : active_enable};
            gray_pipe[0]<=in_gray;
            x_pipe[0]<=lb_x; y_pipe[0]<=lb_y;
            for(i=1;i<11;i=i+1) gray_pipe[i]<=gray_pipe[i-1];
            for(i=1;i<10;i=i+1) begin x_pipe[i]<=x_pipe[i-1]; y_pipe[i]<=y_pipe[i-1]; end
        end
    end
    assign out_de=de_pipe[10]; assign out_hs=hs_pipe[10]; assign out_vs=vs_pipe[10];
    assign out_sof=sof_pipe[10]; assign out_filter_enable=mode_pipe[10];
    assign raw_gray=gray_pipe[10];
    assign out_x=x_pipe[9]; assign out_y=y_pipe[9];
    assign center_x=out_valid ? out_x-12'd1 : 12'd0;
    assign center_y=out_valid ? out_y-12'd1 : 12'd0;
    assign out_gray=!out_de ? 8'd0 : out_filter_enable ? median_gray : raw_gray;
endmodule
