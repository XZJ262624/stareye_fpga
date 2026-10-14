// M5B1 permissions/epoch-enforced single-owner adapter.
// Isolated prototype. One owner slot over the actual combined A/W/B/R interface.
// Client 0 camera W, client 1 HDMI R, client 2 background R/W.
// soft_reset QUIESCES; it does not reset this module or the DDR bus.
// ddr_reset_ack is trusted only after actual DDR reset and client epoch flush.
module m5b1_arbiter #(
 parameter integer TX_LIMIT=2048,
 parameter integer BG_REFILL=1,
 parameter integer BG_MAX_BEATS=32
)(input clk,input rst_n,input soft_reset,input ddr_reset_ack,
 input [1:0] urgent,input safe_window,
 input emergency_stop,input [63:0] epoch,input [191:0] c_epoch,
 input [3:0] video_write_permission,video_read_permission,
 input [6:0] bg_write_permission,bg_read_permission,
 output reg [95:0] max_wait,max_service,output reg [31:0] qos_exceeded,
 output reg [31:0] accepts,completes,rejects,
 output reg [223:0] error_counts,
 input [2:0] c_avalid,output reg [2:0] c_aready,
 input [95:0] c_aaddr,input [23:0] c_alen,c_aid,input [2:0] c_atype,
 input [2:0] c_wvalid,c_wlast,output reg [2:0] c_wready,
 input [383:0] c_wdata,input [47:0] c_wstrb,
 output reg [2:0] c_bvalid,input [2:0] c_bready,
 output reg [23:0] c_bid,output reg [5:0] c_bresp,
 output reg [2:0] c_rvalid,c_rlast,input [2:0] c_rready,
 output reg [383:0] c_rdata,output reg [23:0] c_rid,output reg [5:0] c_rresp,
 output reg [2:0] rejected,output reg quarantine,output reg reset_request,
 output reg [3:0] error_reason,output busy,
 output [7:0] aid,alen,wid,output [31:0] aaddr,output [2:0] asize,
 output [1:0] aburst,alock,output avalid,atype,input aready,
 output [127:0] wdata,output [15:0] wstrb,output wlast,wvalid,input wready,
 input [7:0] bid,input [1:0] bresp,input bvalid,output bready,
 input [7:0] rid,input [1:0] rresp,input [127:0] rdata,input rlast,rvalid,output rready
);
 localparam IDLE=0,A=1,W=2,B=3,R=4;
 reg [2:0] state;reg [1:0] owner;reg [7:0] local_id,len,beat;
 reg [31:0] address,age,refill;reg write_op,rt_turn,credit;
 reg [1:0] rt_served;reg [1:0] choice;reg choose_valid;
 wire discard=quarantine||soft_reset||reset_request;
 wire [31:0] selected_address=c_aaddr[choice*32+:32];
 wire [7:0] selected_len=c_alen[choice*8+:8];
 wire [32:0] selected_end={1'b0,selected_address}+(({25'b0,selected_len}+33'd1)<<4);
 function automatic bg_range_ok(input [31:0] a,input [32:0] e,input wr);
 reg [6:0] hit;begin
  hit[0]=a>=32'h01000000&&e<=33'h001038400;
  hit[1]=a>=32'h01039000&&e<=33'h001071400;
  hit[2]=a>=32'h01072000&&e<=33'h00108e200;
  hit[3]=a>=32'h0108f000&&e<=33'h0010ab200;
  hit[4]=a>=32'h010ac000&&e<=33'h0010c8200;
  hit[5]=a>=32'h010c9000&&e<=33'h0010e5200;
  hit[6]=a>=32'h010e6000&&e<=33'h0010e7000;
  bg_range_ok=|(hit&(wr?bg_write_permission:bg_read_permission));
 end endfunction
 wire video_range_ok=selected_address<32'h01000000 &&
  {1'b0,selected_address[21:0]}+(({15'b0,selected_len}+23'd1)<<4)<=23'd921600;
 wire selected_legal=selected_address[3:0]==0 && selected_len<128 &&
  c_epoch[choice*64+:64]==epoch &&
  (selected_address[11:0]+(({5'b0,selected_len}+13'd1)<<4))<=4096 &&
  ((choice==0&&c_atype[0]&&video_range_ok&&video_write_permission[selected_address[23:22]])||
   (choice==1&&!c_atype[1]&&video_range_ok&&video_read_permission[selected_address[23:22]])||
   (choice==2&&selected_len<BG_MAX_BEATS&&bg_range_ok(selected_address,selected_end,c_atype[2])));
 reg [31:0] waiting[0:2];integer ci;
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin max_wait<=0;max_service<=0;qos_exceeded<=0;accepts<=0;completes<=0;rejects<=0;
   error_counts<=0;for(ci=0;ci<3;ci=ci+1)waiting[ci]<=0;
  end else begin
   // Counter words: B response, R response, ID, LAST, address/permission,
   // stale epoch, transaction watchdog. Count actual events; ACK cannot fabricate one.
   if(!ddr_reset_ack)begin
    if(bvalid&&bready&&bresp!=0)error_counts[31:0]<=error_counts[31:0]+1'b1;
    if(rvalid&&rready&&rresp!=0)error_counts[63:32]<=error_counts[63:32]+1'b1;
    if((bvalid&&bready&&bid!=aid)||(rvalid&&rready&&rid!=aid))error_counts[95:64]<=error_counts[95:64]+1'b1;
    if((wvalid&&wready&&wlast!=(beat==len))||(rvalid&&rready&&rlast!=(beat==len)))error_counts[127:96]<=error_counts[127:96]+1'b1;
    if(|(c_avalid&c_aready)&&!selected_legal)begin
     if(c_epoch[choice*64+:64]!=epoch)error_counts[191:160]<=error_counts[191:160]+1'b1;
     else error_counts[159:128]<=error_counts[159:128]+1'b1;
    end
    if(state!=IDLE&&age==TX_LIMIT-1)error_counts[223:192]<=error_counts[223:192]+1'b1;
   end
   for(ci=0;ci<3;ci=ci+1)begin
    if(c_avalid[ci]&&!c_aready[ci])begin if(waiting[ci]!=32'hffffffff)waiting[ci]<=waiting[ci]+1'b1;end
    else waiting[ci]<=0;
    if(waiting[ci]>max_wait[ci*32+:32])max_wait[ci*32+:32]<=waiting[ci];
   end
   if(|(c_avalid&c_aready))begin accepts<=accepts+1'b1;if(!selected_legal)rejects<=rejects+1'b1;end
   if((bvalid&&bready)||(rvalid&&rready&&rlast))begin
    completes<=completes+1'b1;
    if(age>max_service[owner*32+:32])max_service[owner*32+:32]<=age;
    if(age>384)qos_exceeded<=qos_exceeded+1'b1;
   end
  end
 end
 assign busy=state!=IDLE;
 always @* begin
  choose_valid=0;choice=0;c_aready=0;
  // Urgent RT always wins, then eligible BG after two RT grants, then RT RR.
  if(c_avalid[0]&&urgent[0]&&!(c_avalid[1]&&urgent[1]&&rt_turn))begin choice=0;choose_valid=1;end
  else if(c_avalid[1]&&urgent[1])begin choice=1;choose_valid=1;end
  else if(c_avalid[2]&&safe_window&&urgent==0&&credit&&rt_served==2)begin choice=2;choose_valid=1;end
  else if(c_avalid[0]&&(!c_avalid[1]||!rt_turn))begin choice=0;choose_valid=1;end
  else if(c_avalid[1])begin choice=1;choose_valid=1;end
  else if(c_avalid[2]&&safe_window&&urgent==0&&credit)begin choice=2;choose_valid=1;end
  if(state==IDLE&&!emergency_stop&&!discard&&choose_valid)c_aready[choice]=1;
 end
 assign aid={6'b0,owner}+8'd1;assign wid=aid;assign aaddr=address;assign alen=len;
 assign asize=4;assign aburst=1;assign alock=0;assign atype=write_op;
 // Real reset ACK cancels this epoch on both interfaces, including this edge.
 // soft_reset alone must preserve stalled A/W until drained or real ACK.
 assign avalid=state==A&&!emergency_stop;
 assign wvalid=state==W&&!emergency_stop&&c_wvalid[owner];
 assign wdata=c_wdata[owner*128+:128];assign wstrb=c_wstrb[owner*16+:16];
 assign wlast=c_wlast[owner];
 assign bready=state==B&&!emergency_stop&&(discard||bid!=aid||c_bready[owner]);
 assign rready=state==R&&!emergency_stop&&(discard||rid!=aid||rlast!=(beat==len)||c_rready[owner]);
 always @* begin
  c_wready=0;c_bvalid=0;c_bid=0;c_bresp=0;c_rvalid=0;c_rlast=0;c_rdata=0;c_rid=0;c_rresp=0;
  if(state==W&&!emergency_stop)c_wready[owner]=wready;
  if(state==B&&!emergency_stop&&!discard&&bid==aid)begin
   c_bvalid[owner]=bvalid;c_bid[owner*8+:8]=local_id;c_bresp[owner*2+:2]=bresp;
  end
  if(state==R&&!emergency_stop&&!discard&&rid==aid&&rlast==(beat==len))begin
   c_rvalid[owner]=rvalid;c_rlast[owner]=rlast;c_rid[owner*8+:8]=local_id;
   c_rdata[owner*128+:128]=rdata;c_rresp[owner*2+:2]=rresp;
  end
 end
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin
   state<=IDLE;owner<=0;local_id<=0;len<=0;beat<=0;address<=0;age<=0;write_op<=0;
   rt_turn<=0;credit<=1;refill<=0;rt_served<=0;rejected<=0;quarantine<=0;reset_request<=0;error_reason<=0;
  end else if(ddr_reset_ack)begin
   state<=IDLE;quarantine<=0;reset_request<=0;error_reason<=0;age<=0;beat<=0;
   rejected<=0;credit<=1;refill<=0;rt_served<=0;
  end else begin
   rejected<=0;
   if(soft_reset)quarantine<=1;
   if(refill==BG_REFILL-1)begin refill<=0;credit<=1;end else refill<=refill+1'b1;
   if(state!=IDLE&&age<TX_LIMIT)age<=age+1'b1;
   if(state!=IDLE&&age==TX_LIMIT-1)begin quarantine<=1;reset_request<=1;error_reason<=1;end
   case(state)
    IDLE:begin
     age<=0;
     if(choose_valid&&c_aready[choice])begin
      if(!selected_legal)rejected[choice]<=1;
      else begin
       owner<=choice;local_id<=c_aid[choice*8+:8];address<=selected_address;len<=selected_len;
       write_op<=c_atype[choice];beat<=0;state<=A;
       if(choice==2)begin credit<=0;refill<=0;rt_served<=0;end
       else begin rt_turn<=choice==0;if(rt_served<2)rt_served<=rt_served+1'b1;end
      end
     end
    end
    A:if(avalid&&aready)state<=write_op?W:R;
    W:if(wvalid&&wready)begin
     if(wlast!=(beat==len))begin quarantine<=1;reset_request<=1;error_reason<=2;end
     if(beat==len)state<=B;else beat<=beat+1'b1;
    end
    B:if(bvalid&&bready)begin
     if(bid!=aid||bresp!=0)begin quarantine<=1;reset_request<=1;error_reason<=3;end
     state<=IDLE;
    end
    R:if(rvalid&&rready)begin
     if(rid!=aid||rlast!=(beat==len)||rresp!=0)begin quarantine<=1;reset_request<=1;error_reason<=4;end
     if(rlast)state<=IDLE;
     else if(beat!=255)beat<=beat+1'b1;
     else begin quarantine<=1;reset_request<=1;error_reason<=5;end
    end
    default:begin quarantine<=1;reset_request<=1;error_reason<=6;end
   endcase
  end
 end
endmodule
