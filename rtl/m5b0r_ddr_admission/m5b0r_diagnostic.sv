// Standalone volatile-DDR diagnostic; never connected to a video client.
module m5b0r_diagnostic #(
 parameter [31:0] RANGE_START=32'h01000000,
 parameter [31:0] RANGE_END=32'h010e7000,
 parameter integer CAL_TIMEOUT=960000000,
 parameter integer TOTAL_TIMEOUT=1920000000,
 parameter integer TX_TIMEOUT=960000
)(input clk,input rst_n,input cal_done,input cal_pass,
 output reg [3:0] status,output reg alias_pass,range_pass,
 output [31:0] failure_address,output [127:0] expected,actual,
 output [3:0] reason,output reg [7:0] failure_stage,
 output reg [31:0] transaction_count,output reg [31:0] beat_count,
 output controller_reset_request,
 output [7:0] aid,output [31:0] aaddr,output [7:0] alen,
 output [2:0] asize,output [1:0] aburst,alock,output avalid,
 input aready,output atype,output [7:0] wid,output [127:0] wdata,
 output [15:0] wstrb,output wlast,wvalid,input wready,
 input [7:0] bid,input [1:0] bresp,input bvalid,output bready,
 input [7:0] rid,input [127:0] rdata,input [1:0] rresp,input rlast,rvalid,output rready
);
 // Status RESET/WAIT=0,CALIBRATING=1,CAL_PASS=2,CAL_FAIL=3,ALIAS=4,
 // RANGE=5,PASS=6,FAIL=7,TIMEOUT=8. Each success bit is sticky only in this reset epoch.
 localparam POINTS=38;
 reg [7:0] phase;reg [5:0] point;reg [3:0] mode;reg [6:0] walk;
 reg [31:0] cursor,ticks;reg pending;
 wire tx_ready,tx_done,tx_fail,tx_timeout;
 // HALT invalidates the bus only together with this controller reset. Preserve
 // diagnostic registers until the next whole-test reset; never reuse an owner.
 // A dedicated sticky bit avoids glitches from decoding multi-bit status
 // transitions (e.g. 5 -> 6 can momentarily resemble the FAIL encoding).
 reg diagnostic_halt;
 assign controller_reset_request=tx_fail||diagnostic_halt;
 wire enabled=cal_done&&cal_pass&&status!=3&&status!=7&&status!=8;
 reg request,wr;reg [31:0] address;reg [7:0] length;reg [3:0] pattern;
 function automatic [31:0] point_address(input [5:0] n);
 begin
   if(n==0) point_address=0;
   else if(n<=25) point_address=32'b1<<(n+3); // individual address bits 4..28
   else case(n)
    26:point_address=32'h00fffff0;
    27:point_address=32'h01073800;
    28:point_address=32'h010e6ff0;
    29:point_address=32'h00073800;
    30:point_address=32'h000e6ff0;
    31:point_address=32'h01400000;
    32:point_address=32'h01c00000;
    33:point_address=32'h1ffffff0;
    34:point_address=32'h00c00000;
    35:point_address=32'h010007f0;
    36:point_address=32'h01000800;
    default:point_address=32'h01000ff0;
   endcase
 end endfunction
 always @* begin
  request=0;wr=0;address=point_address(point);length=0;pattern=0;
  if(status==4) begin
   request=!pending;
   wr=(phase==0)||(phase==2&&address<32'h01000000);
   pattern=(phase>=2&&address<32'h01000000)?1:0;
   // phase 2 updates guards only, while high addresses are read unchanged.
  end else if(status==5) begin
   request=!pending;
   if(phase==4 || phase==5) begin
    address=cursor;length=127;wr=phase==4;pattern=mode;
   end else if(phase==6) begin // walking tests at 8 boundary representatives
    case(point[2:0])
     0:address=RANGE_START;1:address=RANGE_START+16;
     2:address=RANGE_START+2032;3:address=RANGE_START+2048;
     4:address=RANGE_START+4080;5:address=RANGE_START+4096;
     6:address=RANGE_START+32'h73800;7:address=RANGE_END-16;
    endcase
    pattern=mode;wr=!point[3];
   end else begin // reread all guard positions after every range pattern/walking
    pattern=1;
    if(address>=32'h01000000) request=0;
   end
  end
 end
 m5b0r_transaction #(.WATCHDOG(TX_TIMEOUT)) u_tx(
 .clk(clk),.rst_n(rst_n),.enable(enabled),.request(request),.write_request(wr),
 .address(address),.length(length),.pattern(pattern),.walking_bit(walk),
 .ready(tx_ready),.done(tx_done),.failed(tx_fail),.timed_out(tx_timeout),
 .failure_address(failure_address),.expected(expected),.actual(actual),.reason(reason),
 .aid(aid),.aaddr(aaddr),.alen(alen),.asize(asize),.aburst(aburst),.alock(alock),
 .avalid(avalid),.aready(aready),.atype(atype),.wid(wid),.wdata(wdata),.wstrb(wstrb),
 .wlast(wlast),.wvalid(wvalid),.wready(wready),.bid(bid),.bresp(bresp),.bvalid(bvalid),
 .bready(bready),.rid(rid),.rdata(rdata),.rresp(rresp),.rlast(rlast),.rvalid(rvalid),.rready(rready));
 always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin status<=0;phase<=0;point<=0;mode<=0;walk<=0;cursor<=RANGE_START;
   ticks<=0;pending<=0;alias_pass<=0;range_pass<=0;failure_stage<=0;
   transaction_count<=0;beat_count<=0;diagnostic_halt<=0;
  end else begin
   if(status!=6&&status!=7&&status!=8&&status!=3) ticks<=ticks+1'b1;
   if(status==0) status<=1;
   else if(status==1) begin
    if(cal_done) begin if(cal_pass) begin status<=2;ticks<=0;end else begin status<=3;failure_stage<=8'hf1;diagnostic_halt<=1;end end
    else if(ticks>=CAL_TIMEOUT-1) begin status<=8;failure_stage<=8'hf2;diagnostic_halt<=1;end
   end else if(status==2) begin status<=4;phase<=0;point<=0;end
   else if(status==4||status==5||status==6) begin
    if(tx_fail) begin status<=tx_timeout?8:7;failure_stage<=phase;end
    else if(!cal_done||!cal_pass) begin status<=3;alias_pass<=0;range_pass<=0;failure_stage<=8'h40|phase;diagnostic_halt<=1;end
    else if(status!=6 && ticks>=TOTAL_TIMEOUT-1) begin status<=8;failure_stage<=8'h80|phase;diagnostic_halt<=1;end
    else if(status!=6) begin
     if(request&&tx_ready) begin pending<=1;transaction_count<=transaction_count+1'b1;end
     if((wvalid&&wready)||(rvalid&&rready)) beat_count<=beat_count+1'b1;
     if(tx_done || (status==5&&phase==7&&address>=32'h01000000&&!pending)) begin
      pending<=0;
      if(status==4) begin
       if(point==POINTS-1) begin
        point<=0;
        if(phase==3) begin alias_pass<=1;status<=5;phase<=4;cursor<=RANGE_START;end
        else phase<=phase+1'b1;
       end else point<=point+1'b1;
      end else if(phase==4) begin
       if(cursor==(mode[0]?RANGE_START:RANGE_END-2048)) phase<=5;
       else cursor<=mode[0]?cursor-2048:cursor+2048;
      end else if(phase==5) begin
       if(cursor==(mode[0]?RANGE_END-2048:RANGE_START)) begin phase<=7;point<=0;end
       else cursor<=mode[0]?cursor+2048:cursor-2048;
      end else if(phase==6) begin
       if(point==15) begin
        point<=0;
        if(walk==127) begin
         walk<=0;
         if(mode==6) mode<=7;
         else begin phase<=7;point<=0;mode<=8;end
        end else walk<=walk+1'b1;
       end else point<=point+1'b1;
      end else if(phase==7) begin
       if(point==POINTS-1) begin
        point<=0;
        if(mode<5) begin mode<=mode+1'b1;phase<=4;cursor<=mode[0]?RANGE_START:RANGE_END-2048;end
        else if(mode==5) begin mode<=6;phase<=6;walk<=0;end
        else begin range_pass<=1;status<=6;end
       end else point<=point+1'b1;
      end
     end
    end
   end
  end
 end
endmodule
