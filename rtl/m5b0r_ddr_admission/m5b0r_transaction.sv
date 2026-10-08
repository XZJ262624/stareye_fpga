// Diagnostic only: one modified-AXI transaction, real response fence.
module m5b0r_transaction #(
 parameter integer WATCHDOG=960000,
 parameter [7:0] ID=8'h5b
)(input clk,input rst_n,input enable,
 input request,input write_request,input [31:0] address,input [7:0] length,
 input [3:0] pattern,input [6:0] walking_bit,
 output ready,output reg done,output reg failed,output reg timed_out,
 output reg [31:0] failure_address,output reg [127:0] expected,actual,
 output reg [3:0] reason,
 output [7:0] aid,output [31:0] aaddr,output [7:0] alen,
 output [2:0] asize,output [1:0] aburst,alock,
 output avalid,input aready,output atype,
 output [7:0] wid,output [127:0] wdata,output [15:0] wstrb,
 output wlast,wvalid,input wready,
 input [7:0] bid,input [1:0] bresp,input bvalid,output bready,
 input [7:0] rid,input [127:0] rdata,input [1:0] rresp,input rlast,rvalid,output rready
);
 localparam IDLE=0,ADDR=1,WRITE=2,BRESP=3,READ=4,HALT=5;
 reg [2:0] state;
 reg wr;reg [31:0] base;reg [7:0] len,beat;reg [3:0] pat;reg [6:0] bitno;
 reg [31:0] watchdog;
 wire [31:0] beat_address=base+{20'b0,beat,4'b0};
 function automatic [127:0] data_pattern(input [31:0] a,input [3:0] p,input [6:0] b);
 reg [127:0] v;
 begin
   // Different lane salts expose byte/lane/beat swaps even at address zero.
   v={a^32'hfedcba98,a^32'h89abcdef,a^32'h76543210,a^32'h01234567};
   case(p)
    0:data_pattern=v;1:data_pattern=~v;2:data_pattern=128'b0;
    3:data_pattern=~128'b0;4:data_pattern={16{8'haa}};5:data_pattern={16{8'h55}};
    6:data_pattern=128'b1<<b;7:data_pattern=~(128'b1<<b);
    default:data_pattern=v;
   endcase
 end endfunction
 assign ready=(state==IDLE)&&enable&&!failed;
 assign aid=ID;assign wid=ID;assign aaddr=base;assign alen=len;
 assign asize=3'd4;assign aburst=2'b01;assign alock=2'b00;
 assign atype=wr;assign avalid=state==ADDR;
 assign wdata=data_pattern(beat_address,pat,bitno);assign wstrb=16'hffff;
 assign wlast=beat==len;assign wvalid=state==WRITE;
 assign bready=state==BRESP;assign rready=state==READ;
 task automatic fail(input [3:0] why,input [127:0] observed);
 begin failed<=1;reason<=why;failure_address<=beat_address;
 expected<=data_pattern(beat_address,pat,bitno);actual<=observed;state<=HALT;end
 endtask
 always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin state<=IDLE;done<=0;failed<=0;timed_out<=0;watchdog<=0;
   base<=0;len<=0;beat<=0;wr<=0;pat<=0;bitno<=0;
   failure_address<=0;expected<=0;actual<=0;reason<=0;
  end else begin
   done<=0;
   if(state==IDLE) begin
    watchdog<=0;
    if(request&&ready) begin
     base<=address;len<=length;beat<=0;wr<=write_request;pat<=pattern;bitno<=walking_bit;
     // Fixed 128-bit beats, capacity and 4KiB whitelist enforced before AVALID.
     if(address[3:0]!=0 || length>127 || address>=32'h20000000 ||
        ({1'b0,address}+(({25'b0,length}+33'd1)<<4))>33'h020000000 ||
        ({1'b0,address[11:0]}+(({5'b0,length}+13'd1)<<4))>4096) begin
       failed<=1;reason<=4'd1;failure_address<=address;state<=HALT;
     end else state<=ADDR;
    end
   end else if(state!=HALT) begin
    if(!enable) fail(4'd2,128'b0);
    else if(watchdog>=WATCHDOG-1) begin fail(4'd3,128'b0);timed_out<=1;end
    else begin
     watchdog<=watchdog+1'b1;
     case(state)
      ADDR:if(aready) state<=wr?WRITE:READ;
      WRITE:if(wready) begin if(beat==len) state<=BRESP;else beat<=beat+1'b1;end
      BRESP:if(bvalid) begin
       if(bid!=ID || bresp!=0) fail(4'd4,{118'b0,bid,bresp});
       else begin state<=IDLE;done<=1;end
      end
      READ:if(rvalid) begin
       if(rid!=ID || rresp!=0) fail(4'd5,{118'b0,rid,rresp});
       else if(rlast!=(beat==len)) fail(4'd6,rdata);
       else if(rdata!=data_pattern(beat_address,pat,bitno)) fail(4'd7,rdata);
       else if(beat==len) begin state<=IDLE;done<=1;end
       else beat<=beat+1'b1;
      end
      default:state<=HALT;
     endcase
    end
   end
  end
 end
endmodule
