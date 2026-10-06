`timescale 1ns/1ps
// Fixed raster only: WIDTH consecutive DE pixels per H_TOTAL-clock line.
// Median center is reanchored; Sobel retains the verified M3 spatial convention.
// From original slot n: aligned packet n+H_TOTAL+11, output n+H_TOTAL+16.
module m32_stream_top #(
    parameter WIDTH=1280, parameter HEIGHT=720, parameter H_TOTAL=1650
)(
    input clk,input arst_n,input [7:0] in_gray,
    input in_de,in_hs,in_vs,in_sof,input filter_request,
    input [7:0] threshold,input [1:0] mode,
    output [7:0] out_gray,raw_gray,edge_gray,output edge_binary,out_valid,
    output out_de,out_hs,out_vs,out_filter_enable,
    output [7:0] out_threshold,output [1:0] out_mode,
    output [11:0] out_x,out_y,center_x,center_y
);
    localparam ALIGN_DELAY=H_TOTAL+11;
    (* async_reg="true" *) reg [1:0] reset_release;
    always @(posedge clk or negedge arst_n)
        if(!arst_n) reset_release<=0;else reset_release<={reset_release[0],1'b1};
    wire rst_n=reset_release[1];
    reg sof_previous,frame_filter;
    wire frame_start=in_sof && !sof_previous;
    wire source_filter=frame_start?filter_request:frame_filter;
    always @(posedge clk or negedge rst_n)
        if(!rst_n) begin sof_previous<=0;frame_filter<=0;end
        else begin
            sof_previous<=in_sof;
            if(frame_start) frame_filter<=filter_request;
        end

    wire [7:0] median_gray;
    wire median_valid;
    median_stream_top #(.WIDTH(WIDTH),.HEIGHT(HEIGHT)) u_median (
        .clk(clk),.arst_n(arst_n),.in_gray(in_gray),.in_valid(in_de),
        .in_de(in_de),.in_hs(in_hs),.in_vs(in_vs),.in_sof(in_sof),
        .filter_enable(filter_request),.median_gray(median_gray),.out_valid(median_valid),
        .out_gray(),.raw_gray(),.out_de(),.out_hs(),.out_vs(),.out_sof(),
        .out_filter_enable(),.out_x(),.out_y(),.center_x(),.center_y());

    wire [22:0] packet;
    wire packet_ready;
    raster_packet_delay #(.BITS(23),.DELAY(ALIGN_DELAY)) u_packet (
        .clk(clk),.rst_n(rst_n),
        .in_packet({in_gray,threshold,mode,source_filter,in_de,in_hs,in_vs,in_sof}),
        .out_packet(packet),.out_ready(packet_ready));
    wire [7:0] aligned_raw=packet[22:15],aligned_threshold=packet[14:7];
    wire [1:0] aligned_mode=packet[6:5];
    wire aligned_filter=packet[4],aligned_de=packet[3];
    wire aligned_hs=packet_ready?packet[2]:1'b1;
    wire aligned_vs=packet_ready?packet[1]:1'b1;
    wire aligned_sof=packet[0];
    wire [7:0] processed_gray=aligned_filter?(median_valid?median_gray:8'd0):aligned_raw;
    wire [7:0] sobel_gray;
    wire sobel_binary,sobel_valid;
    sobel_stream_top #(.WIDTH(WIDTH),.HEIGHT(HEIGHT)) u_sobel (
        .clk(clk),.arst_n(arst_n),.in_gray(processed_gray),
        .in_valid(aligned_de),.in_de(aligned_de),.in_hs(aligned_hs),.in_vs(aligned_vs),
        .in_sof(aligned_sof),.threshold(aligned_threshold),.mode(aligned_mode),
        .edge_gray(sobel_gray),.edge_binary(sobel_binary),.out_valid(sobel_valid),
        .out_de(out_de),.out_hs(out_hs),.out_vs(out_vs),.out_gray(),
        .out_x(out_x),.out_y(out_y),.center_x(),.center_y());

    reg [7:0] raw_pipe[0:4],threshold_pipe[0:4];
    reg [1:0] mode_pipe[0:4];
    reg [4:0] filter_pipe;
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            filter_pipe<=0;
            for(i=0;i<5;i=i+1) begin raw_pipe[i]<=0;threshold_pipe[i]<=0;mode_pipe[i]<=0;end
        end else begin
            raw_pipe[0]<=aligned_raw;threshold_pipe[0]<=aligned_threshold;mode_pipe[0]<=aligned_mode;
            filter_pipe<={filter_pipe[3:0],aligned_filter};
            for(i=1;i<5;i=i+1) begin
                raw_pipe[i]<=raw_pipe[i-1];threshold_pipe[i]<=threshold_pipe[i-1];mode_pipe[i]<=mode_pipe[i-1];
            end
        end
    end
    wire support_ok=!filter_pipe[4] ||
        (out_x>=3 && out_x<=WIDTH-2 && out_y>=3 && out_y<=HEIGHT-2);
    assign out_valid=sobel_valid && support_ok;
    assign raw_gray=raw_pipe[4];
    assign edge_gray=out_valid?sobel_gray:8'd0;
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
