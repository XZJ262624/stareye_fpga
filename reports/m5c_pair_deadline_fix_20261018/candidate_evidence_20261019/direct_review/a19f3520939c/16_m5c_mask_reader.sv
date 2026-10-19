// Read complete paired rows; no READY before both planes really finish.
module m5c_mask_reader(
 input clk,rst_n,stop,start,abort,input slot,input [63:0] session,
 input [7:0] free_banks,output reg busy,output reg drained,output reg fault,
 output write_valid,write_mask,output [2:0] write_bank,output [4:0] write_beat,
 output [127:0] write_data,output reg commit,output reg [11:0] commit_row,
 output [63:0] commit_session,
 output segment_accept,segment_done,
 output avalid,input aready,output [31:0] aaddr,output [7:0] alen,aid,output atype,
 input rvalid,rlast,input [127:0] rdata,input [7:0] rid,input [1:0] rresp,
 output rready,input rejected);
 localparam IDLE=0,WAIT_BANK=1,START_CLASS=2,CLASS=3,START_MASK=4,MASK=5,COMMIT=6,DRAIN=7;
 reg [2:0] state;reg [11:0] row;reg pair_slot;reg [63:0] nonce;
 reg abort_pending;wire cancelling=abort||abort_pending;
 wire tx_busy,tx_done,tx_error,tx_cancelled,read_beat;wire [7:0] beat;
 wire plane=state==START_MASK||state==MASK;
 wire [31:0] base=plane?(pair_slot?32'h010c9000:32'h010ac000):(pair_slot?32'h01039000:32'h01000000);
 wire [31:0] address=base+row*(plane?160:320);
 wire segerror;
 m5b1_transfer transfer(.clk(clk),.rst_n(rst_n),.stop(stop),
  .start((state==START_CLASS||state==START_MASK)&&!cancelling),.cancel(cancelling),.write_op(1'b0),
  .address(address),.length(plane?8'd9:8'd19),.busy(tx_busy),.done(tx_done),.error(tx_error),.cancelled(tx_cancelled),
  .beat(beat),.read_beat(read_beat),.write_beat(),.segment_accept(segment_accept),.segment_is_write(),
  .segment_done(segment_done),.segment_error(segerror),.logical_drained(),
  .avalid(avalid),.aready(aready),.aaddr(aaddr),.alen(alen),.aid(aid),.atype(atype),
  .source_data(128'd0),.wdata(),.wvalid(),.wlast(),.wready(1'b0),
  .bvalid(1'b0),.bid(8'd0),.bresp(2'd0),.rvalid(rvalid),.rlast(rlast),.rid(rid),.rresp(rresp),.rready(rready),.rejected(rejected));
 assign write_valid=read_beat&&!cancelling&&!fault&&!segerror;
 assign write_mask=plane;assign write_bank=row[2:0];assign write_beat=beat[4:0];assign write_data=rdata;
 assign commit_session=nonce;
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin state<=IDLE;row<=0;pair_slot<=0;nonce<=0;abort_pending<=0;busy<=0;drained<=1;fault<=0;commit<=0;commit_row<=0;end
  else begin
   commit<=0;
   if(abort&&busy)abort_pending<=1;
   if(segerror||rejected)fault<=1;
   if(!stop)case(state)
    IDLE:if(start&&!abort&&!fault)begin
     pair_slot<=slot;nonce<=session;row<=0;busy<=1;drained<=0;abort_pending<=0;state<=WAIT_BANK;
    end
    WAIT_BANK:if(cancelling)state<=DRAIN;else if(free_banks[row[2:0]])state<=START_CLASS;
    START_CLASS:state<=cancelling?DRAIN:CLASS;
    CLASS:if(tx_done)begin if(tx_error||cancelling)state<=DRAIN;else state<=START_MASK;end
    START_MASK:state<=cancelling?DRAIN:MASK;
    MASK:if(tx_done)begin if(tx_error||cancelling)state<=DRAIN;else state<=COMMIT;end
    COMMIT:begin
     if(!cancelling&&!fault)begin commit<=1;commit_row<=row;end
     if(cancelling||fault||row==719)state<=DRAIN;
     else begin row<=row+1'b1;state<=WAIT_BANK;end
    end
    DRAIN:if(!tx_busy)begin busy<=0;drained<=1;state<=IDLE;end
   endcase
  end
 end
endmodule
