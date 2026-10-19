// Isolated 64x32 telemetry experiment. Source hold is atomic through real ACK.
module m5c_telemetry(
 input pix_clk,ui_clk,rst_n,input frame_done,input [479:0] pixel_snapshot,
 input [767:0] active_descriptor,input [63:0] active_session,active_token,input active_slot,
 input [63:0] rejected_jobs,protocol_faults,
 output reg payload_ready,output reg [319:0] header_descriptor,
 input payload_take,input [8:0] byte_index,output [7:0] payload_byte,
 output snapshot_pending,output reg snapshot_fault);
 (* async_reg="true", syn_srlstyle="registers", syn_keep="true" *) reg [1:0] pixel_release;
 always @(posedge pix_clk or negedge rst_n)
  if(!rst_n)pixel_release<=0;else pixel_release<={pixel_release[0],1'b1};
 wire pixel_rst_n=pixel_release[1];
 wire mail_busy,mail_valid;wire [479:0] held;wire [63:0] source_guard;reg mail_take;
 reg [63:0] dropped_snapshots,frozen_rejected_jobs,frozen_protocol_faults;
 m5c_telemetry_word_mailbox snapshot_box(.sclk(pix_clk),.dclk(ui_clk),.arst_n(rst_n),
  .send(frame_done),.sdata(pixel_snapshot),.busy(mail_busy),.valid(mail_valid),
  .held(held),.source_guard(source_guard),.take(mail_take));
 always @(posedge pix_clk or negedge pixel_rst_n)
  if(!pixel_rst_n)dropped_snapshots<=0;
  else if(frame_done&&mail_busy&&dropped_snapshots!=64'hffffffffffffffff)dropped_snapshots<=dropped_snapshots+1'b1;
 (* syn_ramstyle="block_ram" *) reg [63:0] mem[0:31];
 reg [63:0] head,raw_stage;reg [4:0] raw_tag,word_index;reg raw_valid,building;
 wire has_source=source_guard!=0;
 wire source_matches=!has_source||source_guard==active_session;
 wire [767:0] desc=has_source?active_descriptor:768'd0;
 (* async_reg="true" *) reg [1:0] inflight_sync;
 always @(posedge ui_clk or negedge rst_n)
  if(!rst_n)inflight_sync<=3;else inflight_sync<={inflight_sync[0],mail_busy};
 assign snapshot_pending=mail_valid||building||inflight_sync[1];
 assign payload_byte=head[byte_index[2:0]*8+:8];
 wire accepting=mail_valid&&!payload_ready&&!building&&source_matches;
 wire [4:0] load_index=accepting?5'd0:word_index+5'd1;
 reg [63:0] raw_selected,word_data;
 wire [63:0] age_operand=raw_tag[0]?desc[575:512]:desc[383:320];
 wire [63:0] age=raw_stage-age_operand;
 always @*begin
  raw_selected=0;
  case(load_index)
   0:raw_selected={32'd0,held[319:288]};
   1,12:raw_selected=held[63:0];
   4,13:raw_selected=held[127:64];
   14:raw_selected=held[255:192];
   15:raw_selected={held[351:320],held[287:256]};
   16:raw_selected=held[479:416];
   17:raw_selected=held[415:352];
  endcase
 end
 // Only this raw D cone and the mailbox guard D cone receive held PIX data.
 always @(posedge ui_clk)
  if(rst_n&&(accepting||(building&&source_matches&&word_index!=31)))raw_stage<=raw_selected;
 always @*begin
  word_data=0;
  case(raw_tag)
   0:word_data={raw_stage[31:0],32'd1};
   1,4,14,15,16,17:word_data=raw_stage;
   2:word_data=desc[383:320];
   3:word_data=desc[575:512];
   5:word_data=desc[63:0];
   6:word_data=desc[191:128];
   7:word_data=desc[127:64];
   8:word_data=desc[447:384];
   9:word_data=desc[511:448];
   10:word_data=has_source?active_token:64'd0;
   11:word_data=source_guard;
   12,13:word_data=has_source?age:64'hffffffffffffffff;
   18:word_data=frozen_rejected_jobs;
   19:word_data=frozen_protocol_faults;
   20:word_data={63'd0,has_source&&active_slot};
  endcase
 end
 always @(posedge ui_clk)begin
  if(building&&raw_valid&&source_matches)mem[raw_tag]<=word_data;
  head<=mem[byte_index[7:3]];
 end
 always @(posedge ui_clk or negedge rst_n)begin
  if(!rst_n)begin
   payload_ready<=0;header_descriptor<=0;mail_take<=0;building<=0;word_index<=0;
   raw_tag<=0;raw_valid<=0;snapshot_fault<=0;frozen_rejected_jobs<=0;frozen_protocol_faults<=0;
  end else begin
   mail_take<=0;
   if(payload_take)payload_ready<=0;
   if(mail_valid&&!payload_ready&&!building)begin
    if(source_matches)begin
     building<=1;word_index<=0;raw_tag<=0;raw_valid<=1;header_descriptor<=desc[319:0];
     frozen_rejected_jobs<=rejected_jobs;frozen_protocol_faults<=protocol_faults;
    end else begin snapshot_fault<=1;mail_take<=1;raw_valid<=0;end
   end
   if(building)begin
    if(!source_matches)begin snapshot_fault<=1;building<=0;mail_take<=1;raw_valid<=0;end
    else if(word_index==31)begin building<=0;payload_ready<=1;mail_take<=1;raw_valid<=0;end
    else begin word_index<=word_index+1'b1;raw_tag<=word_index+1'b1;end
   end
  end
 end
endmodule

module m5c_telemetry_word_mailbox(
 input sclk,dclk,arst_n,send,input [479:0] sdata,output busy,
 output reg valid,output reg [479:0] held,output reg [63:0] source_guard,input take);
 (* async_reg="true" *) reg [1:0] srelease,drelease;
 always @(posedge sclk or negedge arst_n)if(!arst_n)srelease<=0;else srelease<={srelease[0],1'b1};
 always @(posedge dclk or negedge arst_n)if(!arst_n)drelease<=0;else drelease<={drelease[0],1'b1};
 wire srst_n=srelease[1],drst_n=drelease[1];
 reg req,ack;
 (* async_reg="true" *) reg [1:0] req_sync,ack_sync;
 assign busy=!srst_n||req!=ack_sync[1];
 always @(posedge sclk or negedge srst_n)
  if(!srst_n)begin held<=0;req<=0;ack_sync<=0;end
  else begin ack_sync<={ack_sync[0],ack};if(send&&!busy)begin held<=sdata;req<=!req;end end
 always @(posedge dclk or negedge drst_n)
  if(!drst_n)begin ack<=0;req_sync<=0;valid<=0;end
  else begin
   req_sync<={req_sync[0],req};
   if(!valid&&req_sync[1]!=ack)begin valid<=1;end
   if(valid&&take)begin ack<=req_sync[1];valid<=0;end
  end
 always @(posedge dclk)
  if(drst_n&&!valid&&req_sync[1]!=ack)source_guard<=held[191:128];
endmodule
