// One logical C2 operation, split at 4KiB into individually fenced bursts.
// Caller holds the complete write payload cached until final real B.
module m5b1_transfer(input clk,rst_n,stop,input start,input cancel,input write_op,
 input [31:0] address,input [7:0] length,output reg busy,done,error,cancelled,
 output [7:0] beat,output read_beat,write_beat,
 output segment_accept,segment_is_write,segment_done,segment_error,logical_drained,
 output avalid,input aready,output [31:0] aaddr,output [7:0] alen,aid,output atype,
 input [127:0] source_data,output [127:0] wdata,output wvalid,wlast,input wready,
 input bvalid,input [7:0] bid,input [1:0] bresp,
 input rvalid,rlast,input [7:0] rid,input [1:0] rresp,output rready,input rejected);
 reg [2:0] state;reg [31:0] addr;reg [7:0] len,index,segment_end,segment_len;reg wr,cancel_pending;
 reg client_accepted;
 // Outer arbiter reports local permission rejection one cycle after client
 // handshake. Confirm legal ownership on that cycle; reject is never a DDR
 // completion. The outer ADDR state prevents a real response before this.
 always @(posedge clk or negedge rst_n)
  if(!rst_n)client_accepted<=0;
  else client_accepted<=avalid&&aready;
 assign segment_accept=client_accepted;
 assign segment_is_write=wr;
 assign segment_done=(state==3&&bvalid&&!stop)||(read_beat&&rlast);
 assign segment_error=(state==3&&bvalid&&(bresp!=0||bid!=8'h22))||
   (read_beat&&(rresp!=0||rid!=8'h22||rlast!=(index==segment_end)));
 assign logical_drained=!busy;
 wire [8:0] boundary_beats=(13'd4096-{1'b0,address[11:0]})>>4;
 wire [7:0] first_end=({1'b0,length}<boundary_beats)?length:boundary_beats-1'b1;
 assign beat=index;assign aaddr=addr;assign alen=segment_len;assign aid=8'h22;assign atype=wr;
 // Cancellation wins BEFORE the client handshake, so the arbiter cannot
 // acquire an orphan. After that handshake even stalled DDR A is owned:
 // keep W/R active, drain the actual B/final R, and cancel remaining segments.
 assign avalid=state==1&&!stop&&!cancel;assign wvalid=state==2&&!stop;
 assign wlast=index==segment_end;assign wdata=source_data;assign rready=state==4&&!stop;
 assign read_beat=rvalid&&rready;assign write_beat=wvalid&&wready;
 task next_segment;
 begin addr<={addr[31:12]+1'b1,12'b0};segment_len<=len-index-1'b1;segment_end<=len;index<=index+1'b1;state<=1;end endtask
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin state<=0;addr<=0;len<=0;index<=0;wr<=0;segment_end<=0;segment_len<=0;busy<=0;done<=0;error<=0;cancelled<=0;cancel_pending<=0;end
  else begin
   done<=0;cancelled<=0;
   if(busy&&cancel)cancel_pending<=1;
   if(rejected&&busy)begin state<=0;busy<=0;done<=1;error<=1;end
   else case(state)
    0:if(start&&!stop)begin
     cancel_pending<=0;
     if(cancel)begin done<=1;error<=1;cancelled<=1;end
     else begin addr<=address;len<=length;wr<=write_op;index<=0;busy<=1;error<=0;state<=1;segment_end<=first_end;segment_len<=first_end;end
    end
    1:if(cancel)begin state<=0;busy<=0;done<=1;error<=1;cancelled<=1;end
      else if(avalid&&aready)state<=wr?2:4;
    2:if(write_beat)begin if(index==segment_end)state<=3;else index<=index+1'b1;end
    3:if(bvalid)begin
     if(cancel||cancel_pending)begin error<=1;busy<=0;done<=1;cancelled<=1;state<=0;end
     else if(bresp!=0||bid!=8'h22)begin error<=1;busy<=0;done<=1;state<=0;end
     else if(index==len)begin busy<=0;done<=1;state<=0;end
     else next_segment();
    end
    4:if(read_beat)begin
     if(rid!=8'h22||rresp!=0||rlast!=(index==segment_end))error<=1;
     if(rlast)begin
      if(cancel||cancel_pending)begin busy<=0;done<=1;error<=1;cancelled<=1;state<=0;end
      else if(index==len||error||rid!=8'h22||rresp!=0||index!=segment_end)begin busy<=0;done<=1;state<=0;end
      else next_segment();
     end else index<=index+1'b1;
    end
   endcase
  end
 end
endmodule
