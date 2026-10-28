// M5A-only CE adaptation of committed rtl/m32_median_integration/m32_stream_top.v.
`timescale 1ns/1ps
// Fixed accepted-CE raster: WIDTH DE pixels per H_TOTAL enabled-tick line.
// Median center is reanchored; Sobel retains the verified M3 spatial convention.
// From original slot n: aligned packet n+H_TOTAL+11, output n+H_TOTAL+16.
module m5a_m32_stream #(
    parameter WIDTH=1280, parameter HEIGHT=720, parameter H_TOTAL=1650
)(
    input clk,input ce,input arst_n,input [7:0] in_gray,
    input in_de,in_hs,in_vs,in_sof,input [1:0] filter_request,
    input [7:0] threshold,input [2:0] mode,
    output [7:0] out_gray,raw_gray,edge_gray,output edge_binary,out_valid,
    output out_de,out_hs,out_vs,output [1:0] out_filter_enable,
    output [7:0] out_threshold,output [2:0] out_mode,
    output [11:0] out_x,out_y,center_x,center_y,
    output [11:0] full_magnitude,output [1:0] out_direction
);
    localparam ALIGN_DELAY=H_TOTAL+11;
    (* async_reg="true" *) reg [1:0] reset_release;
    always @(posedge clk or negedge arst_n)
        if(!arst_n) reset_release<=0;else reset_release<={reset_release[0],1'b1};
    wire rst_n=reset_release[1];
    reg sof_previous;reg [1:0] frame_filter;
    wire frame_start=in_sof && !sof_previous;
    wire [1:0] source_filter=frame_start?filter_request:frame_filter;
    always @(posedge clk or negedge rst_n)
        if(!rst_n) begin sof_previous<=0;frame_filter<=0;end
        else if (ce) begin
            sof_previous<=in_sof;
            if(frame_start) frame_filter<=filter_request;
        end

    wire [7:0] median_gray,gaussian_gray;
    wire window_support;
    gaussian_median_stream #(.WIDTH(WIDTH),.HEIGHT(HEIGHT)) u_median (
        .clk(clk),.ce(ce),.arst_n(arst_n),.in_gray(in_gray),.in_valid(in_de),
        .in_de(in_de),.in_hs(in_hs),.in_vs(in_vs),.in_sof(in_sof),
        .filter_request(filter_request),.in_frame_id(64'd0),
        .median_gray(median_gray),.gaussian_gray(gaussian_gray),.window_support(window_support),
        .out_gray(),.raw_gray(),.out_support(),.out_de(),.out_hs(),.out_vs(),.out_sof(),
        .out_filter_id(),.out_frame_id(),.out_x(),.out_y(),.center_x(),.center_y(),.selected_x(),.selected_y());

    wire [24:0] packet;
    wire packet_ready;
    m5a_packet_delay #(.BITS(25),.DELAY(ALIGN_DELAY)) u_packet (
        .clk(clk),.ce(ce),.rst_n(rst_n),
        .in_packet({in_gray,threshold,mode,source_filter,in_de,in_hs,in_vs,in_sof}),
        .out_packet(packet),.out_ready(packet_ready));
    wire [7:0] aligned_raw=packet[24:17],aligned_threshold=packet[16:9];
    wire [2:0] aligned_mode=packet[8:6];
    wire [1:0] aligned_filter=packet[5:4];wire aligned_de=packet[3];
    wire aligned_hs=packet_ready?packet[2]:1'b1;
    wire aligned_vs=packet_ready?packet[1]:1'b1;
    wire aligned_sof=packet[0];
    wire [7:0] processed_gray=aligned_filter==0?aligned_raw:!window_support?8'd0:aligned_filter==1?median_gray:aligned_filter==2?gaussian_gray:8'd0;
    wire [7:0] sobel_gray;
    wire [11:0] sobel_full;
    wire sobel_binary,sobel_valid;
    m5a_sobel_stream #(.WIDTH(WIDTH),.HEIGHT(HEIGHT)) u_sobel (
        .clk(clk),.ce(ce),.arst_n(arst_n),.in_gray(processed_gray),
        .in_valid(aligned_de),.in_de(aligned_de),.in_hs(aligned_hs),.in_vs(aligned_vs),
        .in_sof(aligned_sof),.threshold(aligned_threshold),.mode(aligned_mode),
        .edge_gray(sobel_gray),.edge_binary(sobel_binary),.out_valid(sobel_valid),
        .out_de(out_de),.out_hs(out_hs),.out_vs(out_vs),.out_gray(),
        .out_x(out_x),.out_y(out_y),.center_x(),.center_y(),
        .full_magnitude(sobel_full),.out_direction(out_direction));

    reg [7:0] raw_pipe[0:4],threshold_pipe[0:4];
    reg [2:0] mode_pipe[0:4];
    reg [1:0] filter_pipe[0:4];
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            for(i=0;i<5;i=i+1)filter_pipe[i]<=0;
            for(i=0;i<5;i=i+1) begin raw_pipe[i]<=0;threshold_pipe[i]<=0;mode_pipe[i]<=0;end
        end else if (ce) begin
            raw_pipe[0]<=aligned_raw;threshold_pipe[0]<=aligned_threshold;mode_pipe[0]<=aligned_mode;
            filter_pipe[0]<=aligned_filter;
            for(i=1;i<5;i=i+1) begin
                raw_pipe[i]<=raw_pipe[i-1];threshold_pipe[i]<=threshold_pipe[i-1];mode_pipe[i]<=mode_pipe[i-1];filter_pipe[i]<=filter_pipe[i-1];
            end
        end
    end
    wire support_ok=filter_pipe[4]!=3 && mode_pipe[4]!=7 && (filter_pipe[4]==0 ||
        (out_x>=3 && out_x<=WIDTH-2 && out_y>=3 && out_y<=HEIGHT-2));
    assign out_valid=sobel_valid && support_ok;
    assign raw_gray=raw_pipe[4];
    assign edge_gray=out_valid?sobel_gray:8'd0;
    assign full_magnitude=out_valid?sobel_full:12'd0;
    assign edge_binary=out_valid && sobel_binary;
    assign out_threshold=threshold_pipe[4];assign out_mode=mode_pipe[4];
    assign out_filter_enable=filter_pipe[4];
    assign center_x=out_valid?out_x-12'd1:12'd0;
    assign center_y=out_valid?out_y-12'd1:12'd0;
    assign out_gray=!out_de?8'd0:(out_mode==0)?raw_gray:(out_mode==1)?edge_gray:{8{edge_binary}};
    // synthesis translate_off
    initial if(WIDTH<5 || HEIGHT<5 || H_TOTAL<=WIDTH)
        $fatal(1,"M32 requires WIDTH/HEIGHT>=5 and fixed H_TOTAL>WIDTH");
    // synthesis translate_on
endmodule
