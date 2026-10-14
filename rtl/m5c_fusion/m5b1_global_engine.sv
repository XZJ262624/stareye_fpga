// DDR-backed global eight-connected hysteresis. Gauss-Seidel within each scan:
// completed row/new predecessor, old current successor, old following row.
// Work A/B swap only after real final B. Pair reduction includes final pixel.
module m5b1_global_engine #(
 parameter WIDTH=1280,HEIGHT=720,MAX_PAIRS=64,WALL_CYCLES=96000000)(
 input clk,rst_n,stop,input start,input [319:0] descriptor,
 input [31:0] class_base,input [1:0] result_available,
 output reg busy,finished,failed,published,output reg result_reserved,output reg result_slot,
 output reg [319:0] published_descriptor,output reg [15:0] pairs,scans,
 output reg [31:0] elapsed,changed_pixels,
 output reg tx_start,tx_write,output tx_cancel,output reg [31:0] tx_address,output reg [7:0] tx_length,
 input tx_busy,tx_done,tx_error,input [7:0] tx_beat,input tx_read_beat,tx_write_beat,
 input [127:0] tx_rdata,output reg [127:0] tx_wdata);
 localparam CLASS_BEATS=WIDTH/64,WORK_BEATS=WIDTH/128;
 localparam IDLE=0,IC=1,ICW=2,IP=3,IW=4,IWW=5,SC=6,SCW=7,SO=8,SOW=9,
  SN=10,SNW=11,PREP=12,PIXEL=13,SW=14,SWW=15,PAIR=16,RESERVE=17,
  CR=18,CRW=19,CW=20,CWW=21,META=22,METAW=23,ABORT=24,FETCH0=25,FETCH1=26,FETCH2=27;
 reg [4:0] state,drain_state;reg [31:0] metadata_elapsed;
 assign tx_cancel=busy&&(state==ABORT||elapsed>=WALL_CYCLES||stop||(tx_done&&tx_error));
 reg [11:0] row,column;reg reverse;reg pair_changed;
 reg [31:0] src_base,dst_base,classification,copy_offset,result_base;
 reg [319:0] desc;
 (* syn_ramstyle="block_ram" *) reg [127:0] copy_mem[0:31];
 reg [127:0] copy_head;
 wire [4:0] copy_next=tx_beat[4:0]+tx_write_beat;
 always @(posedge clk)begin
  if(state==CRW&&tx_read_beat)copy_mem[tx_beat[4:0]]<=tx_rdata;
  copy_head<=copy_mem[copy_next];
 end
 // Packed beat RAMs replace whole-row bidirectional FF shifters. Processing
 // order is unchanged; every 64 pixels incurs three deterministic prefetch
 // clocks. Previous/new rows use two banks, exchanged only after real B.
 (* syn_ramstyle="block_ram" *) reg [127:0] class_mem[0:CLASS_BEATS-1];
 (* syn_ramstyle="block_ram" *) reg [127:0] old_rows_mem[0:2*WORK_BEATS-1];
 (* syn_ramstyle="block_ram" *) reg [127:0] row_mem[0:2*WORK_BEATS-1];
 reg [127:0] class_shift,cur_shift,next_shift,previous_shift,new_row;
 reg [127:0] class_head,cur_head,next_head,row_head;
 wire [127:0] previous_head=row_head,row_output=row_head;
 reg previous_bank,new_bank,previous_valid,initializing;
 reg peek_up,peek_down,peek_old;
 wire [7:0] work_word=reverse?(WORK_BEATS-1-(column>>7)):(column>>7);
 wire [7:0] class_word=reverse?(CLASS_BEATS-1-(column>>6)):(column>>6);
 wire lookahead=state==FETCH1;
 wire adjacent_valid=reverse?work_word!=0:work_word!=WORK_BEATS-1;
 wire [7:0] ram_word=lookahead&&adjacent_valid?(reverse?work_word-1'b1:work_word+1'b1):work_word;
 wire reached;wire [1:0] cls;
 wire [127:0] new_row_next=initializing?{class_shift[1:0]==2,new_row[127:1]}:
     reverse?{new_row[126:0],reached}:{reached,new_row[127:1]};
 wire processing=state==IP||state==PIXEL;
 wire [7:0] output_word=tx_beat+tx_write_beat;
 wire output_phase=(state==IW||state==IWW||state==SW||state==SWW)||
                   (state==ABORT&&(drain_state==IWW||drain_state==SWW));
 always @(posedge clk)begin
  if((state==ICW||state==SCW)&&tx_read_beat)class_mem[tx_beat]<=tx_rdata;
  class_head<=class_mem[class_word];
  row_head<=row_mem[output_phase?(new_bank*WORK_BEATS+(output_word<WORK_BEATS?output_word:0)):(previous_bank*WORK_BEATS+ram_word)];
  if(processing&&column[6:0]==127&&cls!=3)row_mem[new_bank*WORK_BEATS+work_word]<=new_row_next;
 end
 // True dual-port packed old-row store. Port A owns current-row addresses;
 // port B owns following-row addresses. The two ranges never alias.
 wire [7:0] old_a_addr=state==SOW?tx_beat:ram_word;
 wire [7:0] old_b_addr=WORK_BEATS+(state==SNW?tx_beat:ram_word);
 always @(posedge clk)begin
  if(state==SOW&&tx_read_beat)old_rows_mem[old_a_addr]<=tx_rdata;
  cur_head<=old_rows_mem[old_a_addr];
 end
 always @(posedge clk)begin
  if(state==SNW&&tx_read_beat)old_rows_mem[old_b_addr]<=tx_rdata;
  next_head<=old_rows_mem[old_b_addr];
 end
 reg previous_new,previous_up,previous_down;
 wire oldbit=reverse?cur_shift[127]:cur_shift[0];
 assign cls=reverse?class_shift[127:126]:class_shift[1:0];
 wire up_center=reverse?previous_shift[127]:previous_shift[0];
 wire up_next=column[6:0]==127?peek_up:reverse?previous_shift[126]:previous_shift[1];
 wire down_center=reverse?next_shift[127]:next_shift[0];
 wire down_next=column[6:0]==127?peek_down:reverse?next_shift[126]:next_shift[1];
 wire old_next=column[6:0]==127?peek_old:reverse?cur_shift[126]:cur_shift[1];
 wire last_column=column==WIDTH-1;
 wire neighbor=previous_new||previous_up||previous_down||up_center||down_center||
  (!last_column&&(up_next||down_next||old_next));
 assign reached=oldbit||cls==2||(cls==1&&neighbor);
 wire next_row_outside=reverse?(row==0):(row==HEIGHT-1);
 wire last_row=next_row_outside;
 always @*begin
  tx_wdata=0;
  case(state==ABORT?drain_state:state)
   IWW,SWW:tx_wdata=row_output;
   CWW:tx_wdata=copy_head;
   METAW:case(tx_beat)
    0:tx_wdata=desc[127:0];1:tx_wdata=desc[255:128];
    2:tx_wdata={16'b0,metadata_elapsed,pairs,desc[319:256]};default:tx_wdata=0;
   endcase
  endcase
 end
 task launch(input wr,input [31:0] addr,input [7:0] beats_minus_one);
 begin tx_write<=wr;tx_address<=addr;tx_length<=beats_minus_one;tx_start<=1;end endtask
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin
   busy<=0;finished<=0;failed<=0;published<=0;result_reserved<=0;result_slot<=0;published_descriptor<=0;pairs<=0;scans<=0;elapsed<=0;changed_pixels<=0;
   tx_start<=0;tx_write<=0;tx_address<=0;tx_length<=0;state<=IDLE;drain_state<=IDLE;metadata_elapsed<=0;row<=0;column<=0;reverse<=0;pair_changed<=0;
   src_base<=0;dst_base<=0;classification<=0;copy_offset<=0;result_base<=0;desc<=0;
   class_shift<=0;cur_shift<=0;next_shift<=0;previous_shift<=0;new_row<=0;
   previous_bank<=0;new_bank<=1;previous_valid<=0;initializing<=1;peek_up<=0;peek_down<=0;peek_old<=0;
   previous_new<=0;previous_up<=0;previous_down<=0;
  end else begin
   tx_start<=0;finished<=0;published<=0;
   if(busy&&elapsed!=32'hffffffff)elapsed<=elapsed+1'b1;
   if(busy&&state!=ABORT&&(elapsed>=WALL_CYCLES||stop||(tx_done&&tx_error)))begin drain_state<=state;state<=ABORT;failed<=1;end
   else case(state)
    IDLE:if(start)begin
     busy<=1;failed<=0;result_reserved<=0;elapsed<=0;pairs<=0;scans<=0;changed_pixels<=0;row<=0;column<=0;
     classification<=class_base;desc<=descriptor;state<=IC;src_base<=32'h01072000;dst_base<=32'h0108f000;
     initializing<=1;reverse<=0;previous_valid<=0;previous_bank<=0;new_bank<=1;
    end
    IC:begin launch(0,classification+row*(WIDTH/4),CLASS_BEATS-1);state<=ICW;end
    ICW:begin
     if(tx_done)begin column<=0;new_row<=0;state<=FETCH0;end
    end
    IP:begin
     new_row<=new_row_next;class_shift<=class_shift>>2;
     if(class_shift[1:0]==3)begin state<=ABORT;failed<=1;end
     else if(last_column)state<=IW;
     else begin column<=column+1'b1;if(column[5:0]==63)state<=FETCH0;end
    end
    IW:begin launch(1,32'h01072000+row*(WIDTH/8),WORK_BEATS-1);state<=IWW;end
    IWW:if(tx_done)begin
     if(row==HEIGHT-1)begin row<=0;reverse<=0;pair_changed<=0;previous_valid<=0;initializing<=0;pairs<=1;scans<=1;state<=SC;end
     else begin row<=row+1'b1;state<=IC;end
    end
    SC:begin launch(0,classification+row*(WIDTH/4),CLASS_BEATS-1);state<=SCW;end
    SCW:if(tx_done)state<=SO;
    SO:begin launch(0,src_base+row*(WIDTH/8),WORK_BEATS-1);state<=SOW;end
    SOW:if(tx_done)state<=SN;
    SN:begin
     if(next_row_outside)begin state<=PREP;end
     else begin launch(0,src_base+(reverse?row-1:row+1)*(WIDTH/8),WORK_BEATS-1);state<=SNW;end
    end
    SNW:if(tx_done)state<=PREP;
    PREP:begin previous_new<=0;previous_up<=0;previous_down<=0;new_row<=0;column<=0;state<=FETCH0;end
    FETCH0:state<=FETCH1;
    FETCH1:begin
     class_shift<=class_head;
     cur_shift<=reverse?(cur_head<<column[6:0]):(cur_head>>column[6:0]);
     next_shift<=next_row_outside?128'd0:reverse?(next_head<<column[6:0]):(next_head>>column[6:0]);
     previous_shift<=!previous_valid?128'd0:reverse?(previous_head<<column[6:0]):(previous_head>>column[6:0]);
     state<=FETCH2;
    end
    FETCH2:begin
     peek_old<=adjacent_valid&&(reverse?cur_head[127]:cur_head[0]);
     peek_down<=!next_row_outside&&adjacent_valid&&(reverse?next_head[127]:next_head[0]);
     peek_up<=previous_valid&&adjacent_valid&&(reverse?previous_head[127]:previous_head[0]);
     state<=initializing?IP:PIXEL;
    end
    PIXEL:begin
     if(cls==3)begin failed<=1;state<=ABORT;end
     else begin
      if(reverse)begin
       new_row<=new_row_next;class_shift<=class_shift<<2;
       cur_shift<=cur_shift<<1;next_shift<=next_shift<<1;previous_shift<=previous_shift<<1;
      end else begin
       new_row<=new_row_next;class_shift<=class_shift>>2;
       cur_shift<=cur_shift>>1;next_shift<=next_shift>>1;previous_shift<=previous_shift>>1;
      end
      previous_new<=reached;previous_up<=up_center;previous_down<=down_center;
      if(reached&&!oldbit)begin pair_changed<=1;changed_pixels<=changed_pixels+1'b1;end
      if(last_column)state<=SW;
      else begin column<=column+1'b1;if(column[5:0]==63)state<=FETCH0;end
     end
    end
    SW:begin launch(1,dst_base+row*(WIDTH/8),WORK_BEATS-1);state<=SWW;end
    SWW:if(tx_done)begin
     previous_bank<=new_bank;new_bank<=previous_bank;previous_valid<=1;
     if(last_row)begin
      src_base<=dst_base;dst_base<=src_base;previous_valid<=0;
      if(!reverse)begin reverse<=1;row<=HEIGHT-1;scans<=scans+1'b1;state<=SC;end
      else state<=PAIR;
     end else begin row<=reverse?row-1'b1:row+1'b1;state<=SC;end
    end
    PAIR:begin
     if(!pair_changed)state<=RESERVE;
     else if(pairs>=MAX_PAIRS)begin failed<=1;state<=ABORT;end
     else begin pairs<=pairs+1'b1;scans<=scans+1'b1;reverse<=0;pair_changed<=0;row<=0;state<=SC;end
    end
    RESERVE:begin
     if(result_available!=0)begin
      result_reserved<=1;result_slot<=!result_available[0];result_base<=result_available[0]?32'h010ac000:32'h010c9000;
      copy_offset<=0;state<=CR;
     end else begin failed<=1;state<=ABORT;end
    end
    CR:begin launch(0,src_base+copy_offset,31);state<=CRW;end
    CRW:if(tx_done)state<=CW;
    CW:begin launch(1,result_base+copy_offset,31);state<=CWW;end
    CWW:if(tx_done)begin
     if(copy_offset==WIDTH*HEIGHT/8-512)state<=META;
     else begin copy_offset<=copy_offset+512;state<=CR;end
    end
    META:begin metadata_elapsed<=elapsed;launch(1,32'h010e6000+(result_slot?128:0),2);state<=METAW;end
    METAW:if(tx_done)begin published_descriptor<=desc;published<=1;busy<=0;finished<=1;state<=IDLE;end
    ABORT:if(!tx_busy&&!tx_start)begin result_reserved<=0;busy<=0;finished<=1;state<=IDLE;end
   endcase
  end
 end
 // synthesis translate_off
 initial begin
  if(WIDTH%128!=0||WIDTH*HEIGHT%4096!=0)$fatal(1,"engine packed row/copy alignment");
 end
 // synthesis translate_on
endmodule

