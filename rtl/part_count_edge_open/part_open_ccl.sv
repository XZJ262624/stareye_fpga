`timescale 1ns/1ps
// Single-bank bounded complement CCL: 4-connected background, edge-only hole contacts.
module part_open_ccl #(
 parameter RX=160,RY=90,RW=960,RH=540,MAX_RUNS=5120,MAX_ROW_RUNS=128,SERVICE_LIMIT=2000000,
 parameter [63:0] INTERVAL_TICKS=7440000,STALE_TICKS=37200000
)(
 input wire clk,rst_n,ce,invalidate,input wire [63:0] ticks,
 input wire sof,eof,active,qualified,arm,input wire [11:0] x,y,input wire edge_pixel,edge_support,
 input wire [63:0] frame_id,epoch,config_id,display_seq,
 output wire busy,accept_now,output reg accepted,done,good,output reg [3:0] error_code,count,
 output reg [409:0] objects,output reg [63:0] result_frame,result_epoch,result_config,result_seq,result_tick,
 output reg [20:0] service_cycles,output reg [12:0] captured_runs,
 output wire diag_event,output wire [255:0] diag_data,output wire [63:0] diag_tick
);
 localparam IDLE=0,CAPTURE=1,START=2,C_REQ=3,C_WAIT=4,C_LOAD=5,ROW_REQ=6,ROW_WAIT=7,ROW_LOAD=8,
 P_REQ=9,P_WAIT=10,P_LOAD=11,C_ROOT_A=12,C_ROOT_B=13,C_UNION=14,C_RANK=15,NEXT_CUR=16,
 A_REQ=17,A_WAIT=18,A_LOAD=19,A_ROOT=20,S_WAIT=21,S_LOAD=22,S_WRITE=23,
 ROOT_REQ=24,ROOT_WAIT=25,ROOT_LOAD=26,
 SCAN_ROW=27,SCAN_ROW_WAIT=28,SCAN_ROW_LOAD=29,SCAN_RUN=30,SCAN_RUN_WAIT=31,SCAN_RUN_LOAD=32,GAP=33,
 H_A_ROOT=34,H_A_WAIT=35,H_A_STATS=36,H_B_ROOT=37,H_B_WAIT=38,H_B_STATS=39,
 V_TOP=40,V_TOP_FOUND=41,V_A_ROOT=42,V_A_WAIT=43,V_A_STATS=44,V_BOTTOM=45,V_BOTTOM_FOUND=46,V_B_ROOT=47,V_B_WAIT=48,V_B_STATS=49,
 HOLE_LINK=50,HOLE_RANK=51,HOLE_STATS=52,HOLE_CLEAR=53,PIXEL_NEXT=54,
 LOOK_ROW=55,LOOK_ROW_WAIT=56,LOOK_ROW_LOAD=57,LOOK_NEXT=58,LOOK_WAIT=59,LOOK_LOAD=60,LOOK_RESULT=61,LOOK_RESULT_WAIT=62,LOOK_RESULT_LOAD=63,
 CLASS_REQ=64,CLASS_WAIT=65,CLASS_LOAD=66,CLASS_GEOM=67,CLASS_TEST=68,CLASS_NEXT=70,
 PUBLISH=78,FAIL=79;
 reg [6:0] state,root_return,lookup_return,merge_return;
 reg [6:0] fail_origin;
 reg [9:0] scan_y,gap_x,gap_last,next_bg_end;reg [12:0] scan_run_id,scan_run_end,next_bg_id,left_bg_id;reg left_bg_valid,right_bg_valid,gap_prepared;
 reg [1:0] bridge_length;
 reg [63:0] capture_tick,last_attempt;reg attempted;
 reg [12:0] run_total,row_start;reg [7:0] row_runs;reg [18:0] pixels,edge_total;
 reg [9:0] expected_x,expected_y,run_x;reg run_open;
 wire in_roi=active&&x>=RX&&x<RX+RW&&y>=RY&&y<RY+RH;
 wire [9:0] lx=x-RX,ly=y-RY;wire bg=!edge_pixel,row_last=lx==RW-1;
 wire flush_run=state==CAPTURE&&in_roi&&((run_open&&!bg)||(bg&&row_last));
 wire [9:0] flush_x0=run_open?run_x:lx,flush_x1=bg?lx:lx-1'b1;
 wire [31:0] flush_word={2'd0,ly,flush_x1,flush_x0};
 wire capture_identity=frame_id==result_frame&&epoch==result_epoch&&config_id==result_config&&display_seq==result_seq;
 wire expired=ticks<capture_tick||ticks-capture_tick>=STALE_TICKS;
 assign busy=state!=IDLE;
 assign accept_now=ce&&state==IDLE&&!invalidate&&sof&&arm&&qualified&&!active&&!eof&&(!attempted||ticks<last_attempt||ticks-last_attempt>=INTERVAL_TICKS);
 wire [31:0] run_q;wire [17:0] parent_q;wire [63:0] stats_q;
 (* syn_ramstyle="block_ram" *) reg [25:0] row_mem[0:RH-1];reg [25:0] row_q;
 reg [12:0] run_addr,parent_addr,stats_addr,parent_waddr,stats_waddr;
 reg [9:0] row_addr;reg parent_we,stats_we,run_we,row_we;
 reg [17:0] parent_wdata;reg [63:0] stats_wdata;
 part_open_bank_ram #(.WIDTH(32),.DEPTH(MAX_RUNS)) run_store(.clk(clk),.ce(ce),.read_address(run_addr),.write_address(run_total),.write_enable(run_we),.write_data(flush_word),.read_data(run_q));
 part_open_bank_ram #(.WIDTH(18),.DEPTH(MAX_RUNS)) parent_store(.clk(clk),.ce(ce),.read_address(parent_addr),.write_address(parent_waddr),.write_enable(parent_we),.write_data(parent_wdata),.read_data(parent_q));
 part_open_bank_ram #(.WIDTH(64),.DEPTH(MAX_RUNS)) stats_store(.clk(clk),.ce(ce),.read_address(stats_addr),.write_address(stats_waddr),.write_enable(stats_we),.write_data(stats_wdata),.read_data(stats_q));
 always @(posedge clk)if(ce)begin
  row_q<=row_mem[row_addr];
  if(row_we)row_mem[ly]<={run_total+(flush_run?13'd1:13'd0),row_start};
 end
 reg [12:0] current_id,prev_base,prev_end,scan_id,aggregate_id,class_id,root_node,root_a,root_b,aggregate_root;
 reg [31:0] current_run;reg [9:0] last_y;reg have_y;reg [3:0] root_depth,rank_a,rank_b;
 wire [9:0] c_x0=current_run[9:0],c_x1=current_run[19:10],c_y=current_run[29:20];
 wire [18:0] c_area={9'd0,c_x1}-{9'd0,c_x0}+19'd1;
 wire [63:0] run_stats={3'd0,(c_x0==0||c_x1==RW-1||c_y==0||c_y==RH-1),1'b1,c_y,c_y,c_x1,c_x0,c_area};
 function [63:0] combine(input [63:0] a,input [63:0] b);
  reg [63:0] v;
  begin
   if(!a[59])v=b;else if(!b[59])v=a;else begin
    v=0;v[18:0]=a[18:0]+b[18:0];v[28:19]=a[28:19]<b[28:19]?a[28:19]:b[28:19];
    v[38:29]=a[38:29]>b[38:29]?a[38:29]:b[38:29];v[48:39]=a[48:39]<b[48:39]?a[48:39]:b[48:39];
    v[58:49]=a[58:49]>b[58:49]?a[58:49]:b[58:49];v[59]=1;v[60]=a[60]||b[60];
   end
   combine=v;
  end
 endfunction
 reg [63:0] a_stats,b_stats,class_stats;
 wire a_wins=rank_a>=rank_b;wire [12:0] winner=a_wins?root_a:root_b,loser=a_wins?root_b:root_a;
 wire [10:0] bw={1'b0,class_stats[38:29]}-{1'b0,class_stats[28:19]}+11'd1,bh={1'b0,class_stats[58:49]}-{1'b0,class_stats[48:39]}+11'd1;
 reg [21:0] diagonal;reg [18:0] small_area;
 reg [9:0] query_y,query_lo,query_hi;reg [12:0] search_lo,search_hi,search_mid,search_end,lookup_id;reg lookup_found;reg [31:0] lookup_run;
 always @*begin
  parent_we=0;stats_we=0;run_we=0;row_we=0;parent_waddr=0;stats_waddr=0;parent_wdata=0;stats_wdata=0;
  if(state==CAPTURE&&!invalidate&&qualified&&capture_identity)begin
   if(flush_run&&run_total<MAX_RUNS&&row_runs<MAX_ROW_RUNS)begin
    run_we=1;parent_we=1;parent_waddr=run_total;parent_wdata={5'd0,run_total};stats_we=1;stats_waddr=run_total;stats_wdata=0;
   end
   if(in_roi&&row_last&&run_total+(flush_run?1:0)<=MAX_RUNS)row_we=1;
  end else if(state==C_UNION||state==HOLE_LINK)begin
   parent_we=1;parent_waddr=loser;parent_wdata={1'b0,(a_wins?rank_b:rank_a),winner};
  end else if(state==C_RANK||state==HOLE_RANK)begin parent_we=1;parent_waddr=root_a;parent_wdata={1'b0,rank_a+4'd1,root_a};end
  else if(state==S_WRITE)begin stats_we=1;stats_waddr=aggregate_root;stats_wdata=combine(stats_q,run_stats);end
  else if(state==HOLE_STATS)begin stats_we=1;stats_waddr=winner;stats_wdata=combine(a_stats,b_stats);end
  else if(state==HOLE_CLEAR)begin stats_we=1;stats_waddr=loser;stats_wdata=0;end
  if(invalidate)begin parent_we=0;stats_we=0;run_we=0;row_we=0;end
 end
 // Captured at terminal failure publication; the bank/job identity cannot be overwritten then.
 assign diag_event=ce&&state==FAIL&&!invalidate;
 assign diag_tick=capture_tick;
 wire diag_hole_valid=fail_origin==CLASS_TEST;
 assign diag_data={15'd0,diag_hole_valid,9'd0,fail_origin,11'd0,service_cycles,12'd0,count,3'd0,class_id,(diag_hole_valid?{5'd0,bh,5'd0,bw}:32'd0),13'd0,small_area,19'd0,run_total,13'd0,edge_total,13'd0,(diag_hole_valid?class_stats[18:0]:19'd0)};
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin
   state<=IDLE;fail_origin<=IDLE;accepted<=0;done<=0;good<=0;error_code<=0;count<=0;objects<=0;
   result_frame<=0;result_epoch<=0;result_config<=0;result_seq<=0;result_tick<=0;capture_tick<=0;last_attempt<=0;attempted<=0;
   run_total<=0;row_start<=0;row_runs<=0;pixels<=0;edge_total<=0;expected_x<=0;expected_y<=0;run_x<=0;run_open<=0;
   run_addr<=0;parent_addr<=0;stats_addr<=0;row_addr<=0;current_id<=0;prev_base<=0;prev_end<=0;scan_id<=0;aggregate_id<=0;class_id<=0;
   root_node<=0;root_a<=0;root_b<=0;aggregate_root<=0;current_run<=0;last_y<=0;have_y<=0;root_depth<=0;rank_a<=0;rank_b<=0;root_return<=IDLE;
   a_stats<=0;b_stats<=0;class_stats<=0;diagonal<=0;small_area<=0;scan_y<=0;gap_x<=0;gap_last<=0;next_bg_end<=0;
   scan_run_id<=0;scan_run_end<=0;next_bg_id<=0;left_bg_id<=0;left_bg_valid<=0;right_bg_valid<=0;gap_prepared<=0;
   query_y<=0;query_lo<=0;query_hi<=0;search_lo<=0;search_hi<=0;search_mid<=0;search_end<=0;lookup_id<=0;lookup_found<=0;lookup_run<=0;
   bridge_length<=0;lookup_return<=IDLE;merge_return<=IDLE;service_cycles<=0;captured_runs<=0;
  end else if(ce)begin
   accepted<=0;done<=0;
   if(state!=FAIL)fail_origin<=state;
   if(state!=IDLE&&state!=CAPTURE&&state!=FAIL)service_cycles<=service_cycles+1'b1;
   if(invalidate)begin
    if(state!=IDLE)begin done<=1;good<=0;error_code<=8;end
    state<=IDLE;attempted<=0;
   end else if(state!=IDLE&&state!=FAIL&&(expired||(state!=CAPTURE&&service_cycles>=SERVICE_LIMIT)))begin state<=FAIL;error_code<=7;end
   else case(state)
    IDLE:if(accept_now)begin
     accepted<=1;state<=CAPTURE;good<=0;error_code<=0;count<=0;objects<=0;
     result_frame<=frame_id;result_epoch<=epoch;result_config<=config_id;result_seq<=display_seq;capture_tick<=ticks;last_attempt<=ticks;attempted<=1;
     run_total<=0;row_start<=0;row_runs<=0;pixels<=0;edge_total<=0;expected_x<=0;expected_y<=0;run_open<=0;service_cycles<=0;captured_runs<=0;small_area<=0;class_stats<=0;have_y<=0;
    end
    CAPTURE:begin
     if(!qualified||!capture_identity||sof)begin state<=FAIL;error_code<=8;end
     else if(in_roi)begin
      pixels<=pixels+1'b1;
      if(lx!=expected_x||ly!=expected_y||pixels>=RW*RH||!edge_support)begin state<=FAIL;error_code<=8;end
      if(row_last)begin expected_x<=0;expected_y<=expected_y+1'b1;end else expected_x<=expected_x+1'b1;
      if(edge_pixel)begin
       edge_total<=edge_total+1'b1;
      end
      if(bg&&!run_open)begin run_open<=1;run_x<=lx;end
      if(flush_run)begin run_open<=0;if(run_total>=MAX_RUNS||row_runs>=MAX_ROW_RUNS)begin state<=FAIL;error_code<=6;end else begin run_total<=run_total+1'b1;row_runs<=row_runs+1'b1;end end
      if(row_last)begin row_runs<=0;row_start<=run_total+(flush_run?13'd1:13'd0);end
     end
     if(eof)begin
      captured_runs<=run_total;
      if(sof||active||pixels!=RW*RH||expected_x!=0||expected_y!=RH||run_open||!capture_identity||!qualified)begin state<=FAIL;error_code<=8;end else state<=START;
     end
    end
    START:begin current_id<=0;aggregate_id<=0;have_y<=0;state<=run_total==0?FAIL:C_REQ;if(run_total==0)error_code<=3;end
    C_REQ:begin run_addr<=current_id;state<=C_WAIT;end
    C_WAIT:state<=C_LOAD;
    C_LOAD:begin
     current_run<=run_q;
     if(!have_y||last_y!=run_q[29:20])begin have_y<=1;last_y<=run_q[29:20];row_addr<=run_q[29:20]==0?10'd0:run_q[29:20]-1'b1;
      if(run_q[29:20]==0)begin prev_base<=0;prev_end<=0;scan_id<=0;state<=NEXT_CUR;end else state<=ROW_REQ;
     end else begin scan_id<=prev_base;state<=P_REQ;end
    end
    ROW_REQ:state<=ROW_WAIT;
    ROW_WAIT:state<=ROW_LOAD;
    ROW_LOAD:begin prev_base<=row_q[12:0];prev_end<=row_q[25:13];scan_id<=row_q[12:0];state<=P_REQ;end
    P_REQ:if(scan_id>=prev_end)state<=NEXT_CUR;else begin run_addr<=scan_id;state<=P_WAIT;end
    P_WAIT:state<=P_LOAD;
    P_LOAD:begin
     if(run_q[19:10]<c_x0)begin scan_id<=scan_id+1'b1;prev_base<=scan_id+1'b1;state<=P_REQ;end
     else if(run_q[9:0]>c_x1)state<=NEXT_CUR;
     else begin root_node<=current_id;root_depth<=0;root_return<=C_ROOT_A;state<=ROOT_REQ;end
    end
    C_ROOT_A:begin root_a<=root_node;rank_a<=parent_q[16:13];root_node<=scan_id;root_depth<=0;root_return<=C_ROOT_B;state<=ROOT_REQ;end
    C_ROOT_B:begin root_b<=root_node;rank_b<=parent_q[16:13];if(root_a==root_node)begin scan_id<=scan_id+1'b1;state<=P_REQ;end else state<=C_UNION;end
    C_UNION:if(rank_a==rank_b)state<=C_RANK;else begin scan_id<=scan_id+1'b1;state<=P_REQ;end
    C_RANK:begin scan_id<=scan_id+1'b1;state<=P_REQ;end
    NEXT_CUR:if(current_id+1>=run_total)begin aggregate_id<=0;state<=A_REQ;end else begin current_id<=current_id+1'b1;state<=C_REQ;end
    ROOT_REQ:begin parent_addr<=root_node;state<=ROOT_WAIT;end
    ROOT_WAIT:state<=ROOT_LOAD;
    ROOT_LOAD:if(parent_q[12:0]!=root_node)begin
     if(root_depth>=12||parent_q[12:0]>=run_total)begin state<=FAIL;error_code<=6;end else begin root_node<=parent_q[12:0];root_depth<=root_depth+1'b1;state<=ROOT_REQ;end
    end else state<=root_return;
    A_REQ:begin run_addr<=aggregate_id;state<=A_WAIT;end
    A_WAIT:state<=A_LOAD;
    A_LOAD:begin current_run<=run_q;root_node<=aggregate_id;root_depth<=0;root_return<=A_ROOT;state<=ROOT_REQ;end
    A_ROOT:begin aggregate_root<=root_node;stats_addr<=root_node;state<=S_WAIT;end
    S_WAIT:state<=S_LOAD;
    S_LOAD:state<=S_WRITE;
    S_WRITE:if(aggregate_id+1>=run_total)begin scan_y<=0;state<=SCAN_ROW; end else begin aggregate_id<=aggregate_id+1'b1;state<=A_REQ;end
    // Enumerate only obstacle gaps between stored background runs. No full-frame mask RAM.
    SCAN_ROW:begin row_addr<=scan_y;state<=SCAN_ROW_WAIT;end
    SCAN_ROW_WAIT:state<=SCAN_ROW_LOAD;
    SCAN_ROW_LOAD:begin scan_run_id<=row_q[12:0];scan_run_end<=row_q[25:13];gap_x<=0;left_bg_valid<=0;gap_prepared<=0;state<=SCAN_RUN;end
    SCAN_RUN:if(scan_run_id<scan_run_end)begin run_addr<=scan_run_id;state<=SCAN_RUN_WAIT;end else begin
     if(gap_x<RW)begin gap_last<=RW-1;right_bg_valid<=0;state<=GAP;end
     else if(scan_y+1<RH)begin scan_y<=scan_y+1'b1;state<=SCAN_ROW;end
     else begin class_id<=0;state<=CLASS_REQ;end
    end
    SCAN_RUN_WAIT:state<=SCAN_RUN_LOAD;
    SCAN_RUN_LOAD:begin
     next_bg_end<=run_q[19:10];next_bg_id<=scan_run_id;right_bg_valid<=1;scan_run_id<=scan_run_id+1'b1;
     if(gap_x<run_q[9:0])begin gap_last<=run_q[9:0]-1'b1;state<=GAP;end
     else begin gap_x<=run_q[19:10]+1'b1;left_bg_id<=scan_run_id;left_bg_valid<=1;state<=SCAN_RUN;end
    end
    GAP:begin
     gap_prepared<=1;
     if(!gap_prepared&&left_bg_valid&&right_bg_valid&&gap_last-gap_x<2)begin root_node<=left_bg_id;root_depth<=0;root_return<=H_A_ROOT;state<=ROOT_REQ;end
     else state<=V_TOP;
    end
    H_A_ROOT:begin root_a<=root_node;rank_a<=parent_q[16:13];stats_addr<=root_node;state<=H_A_WAIT;end
    H_A_WAIT:state<=H_A_STATS;
    H_A_STATS:if(stats_q[60])state<=V_TOP;else begin a_stats<=stats_q;root_node<=next_bg_id;root_depth<=0;root_return<=H_B_ROOT;state<=ROOT_REQ;end
    H_B_ROOT:begin root_b<=root_node;rank_b<=parent_q[16:13];stats_addr<=root_node;state<=H_B_WAIT;end
    H_B_WAIT:state<=H_B_STATS;
    H_B_STATS:if(root_a==root_b||stats_q[60])state<=V_TOP;else begin b_stats<=stats_q;merge_return<=V_TOP;state<=HOLE_LINK;end
    V_TOP:if(scan_y==0)state<=PIXEL_NEXT;else begin query_y<=scan_y-1'b1;query_lo<=gap_x;query_hi<=gap_x;lookup_return<=V_TOP_FOUND;state<=LOOK_ROW;end
    V_TOP_FOUND:if(!lookup_found)state<=PIXEL_NEXT;else begin root_node<=lookup_id;root_depth<=0;root_return<=V_A_ROOT;state<=ROOT_REQ;end
    V_A_ROOT:begin root_a<=root_node;rank_a<=parent_q[16:13];stats_addr<=root_node;state<=V_A_WAIT;end
    V_A_WAIT:state<=V_A_STATS;
    V_A_STATS:if(stats_q[60])state<=PIXEL_NEXT;else begin a_stats<=stats_q;bridge_length<=1;state<=V_BOTTOM;end
    V_BOTTOM:if(scan_y+bridge_length>=RH)state<=PIXEL_NEXT;else begin query_y<=scan_y+bridge_length;query_lo<=gap_x;query_hi<=gap_x;lookup_return<=V_BOTTOM_FOUND;state<=LOOK_ROW;end
    V_BOTTOM_FOUND:if(!lookup_found)begin if(bridge_length==1)begin bridge_length<=2;state<=V_BOTTOM;end else state<=PIXEL_NEXT;end
     else begin root_node<=lookup_id;root_depth<=0;root_return<=V_B_ROOT;state<=ROOT_REQ;end
    V_B_ROOT:begin root_b<=root_node;rank_b<=parent_q[16:13];stats_addr<=root_node;state<=V_B_WAIT;end
    V_B_WAIT:state<=V_B_STATS;
    V_B_STATS:if(root_a==root_b||stats_q[60])state<=PIXEL_NEXT;else begin b_stats<=stats_q;merge_return<=PIXEL_NEXT;state<=HOLE_LINK;end
    HOLE_LINK:if(rank_a==rank_b)state<=HOLE_RANK;else state<=HOLE_STATS;
    HOLE_RANK:state<=HOLE_STATS;
    HOLE_STATS:state<=HOLE_CLEAR;
    HOLE_CLEAR:state<=merge_return;
    PIXEL_NEXT:if(gap_x<gap_last)begin gap_x<=gap_x+1'b1;state<=GAP;end else begin
     gap_prepared<=0;
     if(right_bg_valid)begin gap_x<=next_bg_end+1'b1;left_bg_id<=next_bg_id;left_bg_valid<=1;end else gap_x<=RW;
     state<=SCAN_RUN;
    end
    // Binary lower-bound over a row: first background run whose end>=query_lo.
    LOOK_ROW:begin row_addr<=query_y;state<=LOOK_ROW_WAIT;end
    LOOK_ROW_WAIT:state<=LOOK_ROW_LOAD;
    LOOK_ROW_LOAD:begin search_lo<=row_q[12:0];search_hi<=row_q[25:13];search_end<=row_q[25:13];lookup_found<=0;state<=LOOK_NEXT;end
    LOOK_NEXT:if(search_lo>=search_hi)state<=LOOK_RESULT;else begin search_mid<=({1'b0,search_lo}+{1'b0,search_hi})>>1;run_addr<=({1'b0,search_lo}+{1'b0,search_hi})>>1;state<=LOOK_WAIT;end
    LOOK_WAIT:state<=LOOK_LOAD;
    LOOK_LOAD:begin if(run_q[19:10]<query_lo)search_lo<=search_mid+1'b1;else search_hi<=search_mid;state<=LOOK_NEXT;end
    LOOK_RESULT:if(search_lo>=search_end)begin lookup_found<=0;state<=lookup_return;end else begin run_addr<=search_lo;state<=LOOK_RESULT_WAIT;end
    LOOK_RESULT_WAIT:state<=LOOK_RESULT_LOAD;
    LOOK_RESULT_LOAD:begin lookup_id<=search_lo;lookup_run<=run_q;lookup_found<=run_q[9:0]<=query_hi;state<=lookup_return;end
    CLASS_REQ:begin stats_addr<=class_id;state<=CLASS_WAIT;end
    CLASS_WAIT:state<=CLASS_LOAD;
    CLASS_LOAD:begin class_stats<=stats_q;if(!stats_q[59]||stats_q[60])state<=CLASS_NEXT;else state<=CLASS_GEOM;end
    CLASS_GEOM:begin diagonal<=bw*bw+bh*bh;state<=CLASS_TEST;end
    CLASS_TEST:begin
     if(class_stats[18:0]<=16)begin small_area<=small_area+class_stats[18:0];state<=CLASS_NEXT;end
     else if(class_stats[18:0]<2800||class_stats[18:0]>7000||(bw<96&&bh<96)||bw>176||bh>176||diagonal<12000||diagonal>36000)begin state<=FAIL;error_code<=3;end
     else if(count>=10)begin state<=FAIL;error_code<=10;end
     else begin objects[count*41+:41]<={{1'b0,class_stats[48:39]}+{1'b0,class_stats[58:49]},{1'b0,class_stats[28:19]}+{1'b0,class_stats[38:29]},class_stats[18:0]};count<=count+1'b1;state<=CLASS_NEXT;end
    end
    CLASS_NEXT:if(class_id+1>=run_total)state<=PUBLISH;else begin class_id<=class_id+1'b1;state<=CLASS_REQ;end
    PUBLISH:begin done<=1;good<=1;error_code<=0;result_tick<=capture_tick;state<=IDLE;end
    FAIL:begin done<=1;good<=0;result_tick<=capture_tick;captured_runs<=run_total;state<=IDLE;end
    default:begin state<=FAIL;error_code<=15;end
   endcase
  end
 end
 // synthesis translate_off
 initial if(MAX_RUNS>5120||MAX_RUNS<1||MAX_ROW_RUNS>128||RW>960||RH>540)$fatal(1,"EDGE_CCL_LIMITS");
 // synthesis translate_on
endmodule
