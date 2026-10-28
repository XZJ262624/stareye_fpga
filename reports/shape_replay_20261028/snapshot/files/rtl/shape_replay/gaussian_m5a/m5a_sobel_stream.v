// M5A-only CE adaptation of committed rtl/m3_sobel_core/sobel_stream_top.v.
`timescale 1ns/1ps
// Five sampling stages: input edge n -> output immediately after edge n+4.
// in_valid advances image coordinates; in_de independently describes the raster.
// SOF is synchronous, never concurrent with accepted data; modes 0/raw,1/gray,2/binary.
module m5a_sobel_stream #(
    parameter WIDTH=1280, parameter HEIGHT=720
)(
    input clk,input ce, input arst_n,
    input [7:0] in_gray, input in_valid, in_de, in_hs, in_vs, in_sof,
    input [7:0] threshold, input [2:0] mode,
    output [7:0] edge_gray, output edge_binary, out_valid,
    output out_de, out_hs, out_vs,
    output [7:0] out_gray,
    output [11:0] out_x, out_y, center_x, center_y,
    output reg [11:0] full_magnitude,output reg [1:0] out_direction
);
    (* async_reg = "true" *) reg [1:0] reset_release;
    always @(posedge clk or negedge arst_n)
        if (!arst_n) reset_release <= 2'b00;
        else reset_release <= {reset_release[0],1'b1};
    wire rst_n=reset_release[1];
    wire lb_valid, win_valid, gradient_valid, mag_valid;
    wire [11:0] lb_x,lb_y;
    wire [7:0] top_pixel,middle_pixel,bottom_pixel;
    wire [7:0] p00,p01,p02,p10,p11,p12,p20,p21,p22,mag_gray;
    wire signed [10:0] gx,gy;
    wire [10:0] abs_gx,abs_gy;
    wire [11:0] magnitude;
    wire [1:0] direction_now;
    reg [1:0] direction_mag;
    m5a_direction u_direction(.gx(gx),.gy(gy),.direction(direction_now));
    always @(posedge clk or negedge rst_n)
        if(!rst_n)begin direction_mag<=0;out_direction<=0;full_magnitude<=0;end
        else if(ce)begin direction_mag<=direction_now;out_direction<=direction_mag;
            full_magnitude<=mag_valid?magnitude:12'd0;end
    m5a_line_buffer #(.WIDTH(WIDTH),.HEIGHT(HEIGHT)) u_lines (
        .clk(clk),.ce(ce),.rst_n(rst_n),.in_sof(in_sof),.in_valid(in_valid),.in_gray(in_gray),
        .out_valid(lb_valid),.top_pixel(top_pixel),.middle_pixel(middle_pixel),
        .bottom_pixel(bottom_pixel),.out_x(lb_x),.out_y(lb_y));
    m5a_window u_window (.clk(clk),.ce(ce),.rst_n(rst_n),.in_valid(lb_valid),
        .in_x(lb_x),.in_y(lb_y),.top_pixel(top_pixel),.middle_pixel(middle_pixel),
        .bottom_pixel(bottom_pixel),.out_valid(win_valid),
        .p00(p00),.p01(p01),.p02(p02),.p10(p10),.p11(p11),.p12(p12),
        .p20(p20),.p21(p21),.p22(p22));
    m5a_sobel u_sobel (.clk(clk),.ce(ce),.rst_n(rst_n),.in_valid(win_valid),
        .p00(p00),.p01(p01),.p02(p02),.p10(p10),.p11(p11),.p12(p12),
        .p20(p20),.p21(p21),.p22(p22),.gradient_valid(gradient_valid),
        .gx(gx),.gy(gy),.out_valid(mag_valid),.abs_gx(abs_gx),.abs_gy(abs_gy),
        .magnitude(magnitude),.edge_gray(mag_gray));

    reg [4:0] de_pipe,hs_pipe,vs_pipe;
    reg [7:0] gray_pipe[0:4],threshold_pipe[0:3];
    reg [2:0] mode_pipe[0:4];
    reg [11:0] x_pipe[0:3],y_pipe[0:3];
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            de_pipe<=0; hs_pipe<=5'b11111; vs_pipe<=5'b11111;
            for (i=0;i<5;i=i+1) begin gray_pipe[i]<=0; mode_pipe[i]<=0; end
            for (i=0;i<4;i=i+1) begin threshold_pipe[i]<=0; x_pipe[i]<=0; y_pipe[i]<=0; end
        end else if (ce) begin
            de_pipe<={de_pipe[3:0],in_de};
            hs_pipe<={hs_pipe[3:0],in_hs}; vs_pipe<={vs_pipe[3:0],in_vs};
            gray_pipe[0]<=in_gray; mode_pipe[0]<=mode; threshold_pipe[0]<=threshold;
            x_pipe[0]<=lb_x; y_pipe[0]<=lb_y;
            for (i=1;i<5;i=i+1) begin gray_pipe[i]<=gray_pipe[i-1]; mode_pipe[i]<=mode_pipe[i-1]; end
            for (i=1;i<4;i=i+1) begin
                threshold_pipe[i]<=threshold_pipe[i-1]; x_pipe[i]<=x_pipe[i-1]; y_pipe[i]<=y_pipe[i-1];
            end
        end
    end
    m5a_legacy_threshold u_threshold (.clk(clk),.ce(ce),.rst_n(rst_n),.in_valid(mag_valid),
        .in_gray(mag_gray),.threshold(threshold_pipe[3]),
        .out_valid(out_valid),.edge_gray(edge_gray),.edge_binary(edge_binary));
    assign out_de=de_pipe[4]; assign out_hs=hs_pipe[4]; assign out_vs=vs_pipe[4];
    assign out_x=x_pipe[3]; assign out_y=y_pipe[3];
    assign center_x=out_valid ? out_x-12'd1 : 12'd0;
    assign center_y=out_valid ? out_y-12'd1 : 12'd0;
    assign out_gray=!out_de ? 8'd0 : (mode_pipe[4]==0) ? gray_pipe[4] :
                    (mode_pipe[4]==1) ? edge_gray : {8{edge_binary}};
endmodule
