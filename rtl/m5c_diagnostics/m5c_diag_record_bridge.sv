// Observer-only four-phase record ownership. No production flow-control output.
module m5c_diag_record_bridge(
 input pix_clk,ui_clk,arst_n,
 input pix_ready,output pix_take,pix_cancel,
 output pix_rst_n,ui_rst_n,
 output ui_ready,input ui_done,ui_cancel,
 input [8:0] byte_index,output [5:0] read_word,
 input [63:0] word_data,output [7:0] byte_data,output byte_valid);
 (* async_reg="true",syn_srlstyle="registers",syn_keep="true" *) reg [1:0] pr,ur;
 always @(posedge pix_clk or negedge arst_n)
  if(!arst_n)pr<=0;else pr<={pr[0],1'b1};
 always @(posedge ui_clk or negedge arst_n)
  if(!arst_n)ur<=0;else ur<={ur[0],1'b1};
 assign pix_rst_n=pr[1];assign ui_rst_n=ur[1];
 (* async_reg="true" *) reg [1:0] ready_sync,ack_sync,cancel_sync;
 reg ack,cancel_held,ack_seen;
 always @(posedge ui_clk or negedge ui_rst_n)begin
  if(!ui_rst_n)begin ready_sync<=0;ack<=0;cancel_held<=0;end
  else begin
   ready_sync<={ready_sync[0],pix_ready};
   if(!ready_sync[1])begin ack<=0;cancel_held<=0;end
   else if(!ack&&!cancel_held&&(ui_done||ui_cancel))begin ack<=!ui_cancel;cancel_held<=ui_cancel;end
  end
 end
 always @(posedge pix_clk or negedge pix_rst_n)begin
  if(!pix_rst_n)begin ack_sync<=0;cancel_sync<=0;ack_seen<=0;end
  else begin
   ack_sync<={ack_sync[0],ack};cancel_sync<={cancel_sync[0],cancel_held};
   if(!ack_sync[1]&&!cancel_sync[1])ack_seen<=0;
   else if(pix_ready&&!ack_seen)ack_seen<=1;
  end
 end
 assign pix_take=pix_ready&&(ack_sync[1]||cancel_sync[1])&&!ack_seen;
 assign pix_cancel=cancel_sync[1];
 assign ui_ready=ready_sync[1]&&!ack&&!cancel_held;
 // Header64 precedes payload256. Consumer waits for synchronous RAM read.
 assign read_word=byte_index<64?6'd32+byte_index[8:3]:byte_index[8:3]-6'd8;
 reg [5:0] address_d;
 reg address_settled;
 always @(posedge ui_clk or negedge ui_rst_n)begin
  if(!ui_rst_n)begin address_d<=0;address_settled<=0;end
  else begin address_d<=read_word;address_settled<=address_d==read_word;end
 end
 assign byte_data=word_data[byte_index[2:0]*8+:8];
 assign byte_valid=ui_ready&&byte_index<320&&address_settled&&address_d==read_word;
endmodule
