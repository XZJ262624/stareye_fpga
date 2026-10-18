// UI controller for the independent pair-diagnostic build. Generic lease core
// remains unchanged; original fusion release is delayed, never acknowledged early.
module m5c_pair_controller #(
 parameter CURRENT_BYTES=921600,REFERENCE_CLASS_BYTES=230400,REFERENCE_MASK_BYTES=115200,
 parameter CAPTURE_CYCLES=96000000,parameter [32:0] EXPORT_CYCLES=33'd6144000000)(
 input clk,rst_n,stop,select,wait_expired,acquire_ack,acquire_denied,
 input [767:0] descriptor,input [319:0] identity,input [63:0] session,token,input slot,
 input fusion_release,fusion_retire,input held,
 output hold,output retain_owner,output reg arm,output cancel_capture,output release_owned,output retire_owned,
 input cap_arm_busy,cap_done,input [31:0] cap_reason,output reg cap_take,
 input cap_empty,input [9:0] cap_count,input [127:0] cap_data,output cap_pop,
 output tx_start,tx_write,tx_cancel,output [31:0] tx_addr,output [7:0] tx_len,output [127:0] tx_data,
 input tx_busy,tx_done,tx_error,tx_read_beat,tx_write_beat,input [7:0] tx_beat,input [127:0] rdata,
 output buffer_write,output [4:0] buffer_write_address,buffer_read_address,output [127:0] buffer_write_data,input [127:0] buffer_read_data,
 output packet_start,packet_abort,output [7:0] packet_type,output [31:0] packet_length,
 output [7:0] payload,output payload_valid,input payload_ready,packet_done,packet_busy,
 output packet_reserve,output export_active,output current_write,metadata_write,current_read,metadata_read,reference_read,
 output reg terminal,output reg [31:0] failure,output reg [3:0] attempts);
 localparam CURRENT_PHYSICAL_BYTES=(CURRENT_BYTES/25)*16;
 initial begin if(CURRENT_BYTES<=0||CURRENT_BYTES%800!=0||REFERENCE_CLASS_BYTES%512!=0||REFERENCE_MASK_BYTES%512!=0)$fatal(1,"PAIR_PACK5_GEOMETRY");end
 localparam IDLE=0,ACQ=1,CAPWAIT=2,WRITE=3,WRITEWAIT=4,TAIL0=5,TAIL1=6,WAITDONE=7,
  FORMAT=8,META=9,META_WAIT=10,WAIT_RELEASE=11,START_PACKET=12,READ=13,READWAIT=14,
  PREFETCH=15,BYTES=16,END_PACKET=17,COMP_FORMAT=18,COMP_START=19,COMP_BYTES=20,
  ABORT=21,RELEASE=22,RELEASE_WAIT=23,FAIL_WAIT=24,ABANDON_PACKET=25,WORD_PREFETCH0=26,WORD_PREFETCH1=27;
 reg [4:0] state;reg rel_seen,ret_seen,producer_done,armed,acquired,export_owned,write_metadata;reg [31:0] b_commits;reg [31:0] timer,offset;
 reg [32:0] export_timer;reg [1:0] plane;reg [9:0] index;reg [5:0] format_index;
 reg [4:0] sample_lane,read_word;
 reg [31:0] producer_reason;
 reg [63:0] source_id,current_seq,sof_tick,eof_tick;
 wire selected_read=state==READ||state==READWAIT;
 wire [31:0] plane_bytes=plane==0?512:plane==1?REFERENCE_CLASS_BYTES:plane==2?REFERENCE_MASK_BYTES:CURRENT_BYTES;
 wire [31:0] plane_physical_bytes=plane==3?CURRENT_PHYSICAL_BYTES:plane_bytes;
 wire [9:0] chunk_last=plane==3?10'd799:10'd511;
 wire [31:0] plane_base=plane==0?32'h011e1000:plane==1?(slot?32'h01039000:32'h01000000):plane==2?(slot?32'h010c9000:32'h010ac000):32'h01100000;
 wire prefix=plane!=0&&offset==0&&index<24;
 wire [9:0] data_index=index-((plane!=0&&offset==0)?10'd24:10'd0);
 wire [191:0] pair_prefix={token,session,64'd1};
 wire write_failed=(cap_done&&cap_reason!=0)||(producer_done&&producer_reason!=0);
 wire timed=timer>=CAPTURE_CYCLES;
 assign hold=state!=IDLE;
 // A failure report without a selected/acquired owner must not intercept another session.
 assign retain_owner=hold&&(acquired||(state==ACQ&&acquire_ack));
 assign cancel_capture=state==ABORT||stop;
 assign release_owned=state==RELEASE&&acquired&&!stop&&!tx_busy;
 assign retire_owned=release_owned;
 assign export_active=export_owned;
 assign packet_reserve=state==FAIL_WAIT||export_owned||((state==WAIT_RELEASE||state==ABORT)&&(!acquired||(rel_seen&&ret_seen)));
 assign packet_start=(state==START_PACKET||state==COMP_START)&&!stop;
 assign packet_abort=((state==ABORT||state==ABANDON_PACKET)&&export_owned)||stop;
 assign packet_type=state==COMP_START||state==COMP_BYTES?8'd10:8'd6+plane;
 assign packet_length=state==COMP_START||state==COMP_BYTES?256:plane_bytes+(plane!=0?24:0);
 assign payload=state==COMP_BYTES?buffer_read_data[index[3:0]*8+:8]:prefix?pair_prefix[index*8+:8]:plane==3?{3'b0,buffer_read_data[sample_lane*5+:5]}:buffer_read_data[data_index[3:0]*8+:8];
 assign payload_valid=!stop&&(state==BYTES||state==COMP_BYTES);
 assign tx_start=!stop&&((state==READ)||(!write_failed&&(state==WRITE||state==META)));
 assign tx_write=state==WRITE||state==WRITEWAIT||state==META||state==META_WAIT;
 assign tx_cancel=state==ABORT;
 assign tx_addr=(state==META||state==META_WAIT)?32'h011e1000:tx_write?32'h01100000+offset:plane_base+offset;
 assign tx_len=31;
 assign tx_data=write_metadata?buffer_read_data:cap_data;
 assign cap_pop=(!stop)&&(((state==WRITEWAIT||(state==ABORT&&!write_metadata))&&tx_write_beat)||((state==TAIL0||state==TAIL1)&&!cap_empty)||(state==ABORT&&!cap_empty&&!tx_busy));
 assign current_write=state==WRITE||state==WRITEWAIT;
 assign metadata_write=state==META||state==META_WAIT;
 assign current_read=selected_read&&plane==3;
 assign metadata_read=selected_read&&plane==0;
 assign reference_read=selected_read&&(plane==1||plane==2);
 // Metadata word function has only frozen sources and exact zero reserved bytes.
 function [127:0] meta_word(input [5:0] wordno,input completion);
 begin
  meta_word=128'd0;
  case(wordno)
   0:begin meta_word[31:0]=2;meta_word[63:32]=failure==0?13:2;meta_word[127:64]=1;end
   1:begin meta_word[63:0]={60'd0,attempts};meta_word[127:64]=acquired?session:0;end
   2:begin meta_word[63:0]=acquired?token:0;meta_word[127:64]=acquired?{63'd0,slot}:0;end
   3:meta_word=completion?(acquired?identity[127:0]:128'd0):descriptor[127:0];
   4:meta_word=completion?(acquired?identity[255:128]:128'd0):descriptor[255:128];
   5:if(completion)begin meta_word[63:0]=acquired?identity[319:256]:0;meta_word[95:64]=failure==0?CURRENT_BYTES:0;meta_word[127:96]=failure==0?REFERENCE_CLASS_BYTES:0;end else meta_word=descriptor[383:256];
   6:if(completion)begin meta_word[31:0]=failure==0?REFERENCE_MASK_BYTES:0;meta_word[63:32]=failure;meta_word[95:64]=1;meta_word[127:96]=5;end else meta_word=descriptor[511:384];
   7:if(completion)begin meta_word[31:0]=25;meta_word[63:32]=CURRENT_PHYSICAL_BYTES;meta_word[95:64]=CURRENT_PHYSICAL_BYTES/16;meta_word[127:96]=CURRENT_PHYSICAL_BYTES/512;end else meta_word=descriptor[639:512];
   8:if(!completion)meta_word=descriptor[767:640];
   9:if(!completion)meta_word=identity[127:0];
   10:if(!completion)meta_word=identity[255:128];
   11:if(!completion)meta_word={source_id,identity[319:256]};
   12:if(!completion)meta_word={sof_tick,current_seq};
   13:if(!completion)meta_word={descriptor[639:576],eof_tick};
   14:if(!completion)meta_word={16'd720,16'd1280,descriptor[735:640]};
   15:if(!completion)begin meta_word[31:0]=CURRENT_BYTES;meta_word[63:32]=b_commits;meta_word[127:64]=current_seq-descriptor[383:320];end
   16:if(!completion)begin meta_word[63:0]=sof_tick-descriptor[575:512];meta_word[95:64]=CURRENT_BYTES;meta_word[127:96]=REFERENCE_CLASS_BYTES;end
   17:if(!completion)begin meta_word[31:0]=REFERENCE_MASK_BYTES;meta_word[95:64]=74400000;meta_word[127:96]=96000000;end
   18:if(!completion)begin meta_word[31:0]=1;meta_word[63:32]=5;meta_word[95:64]=25;meta_word[127:96]=CURRENT_PHYSICAL_BYTES;end
   19:if(!completion)begin meta_word[31:0]=CURRENT_PHYSICAL_BYTES/16;meta_word[63:32]=CURRENT_PHYSICAL_BYTES/512;end
   default:meta_word=0;
  endcase
 end endfunction
 // Exactly one external RAM write port and one synchronous read address.
 // FORMAT -> actual metadata B -> read refill -> completion rebuild are disjoint.
 assign buffer_write=(state==FORMAT&&!write_failed)||state==COMP_FORMAT||(state==READWAIT&&tx_read_beat);
 assign buffer_write_address=(state==FORMAT||state==COMP_FORMAT)?format_index[4:0]:tx_beat[4:0];
 assign buffer_write_data=(state==FORMAT||state==COMP_FORMAT)?meta_word(format_index,state==COMP_FORMAT):rdata;
 wire [9:0] next_payload_index=index+{9'd0,payload_ready};
 wire [9:0] next_data_index=data_index+{9'd0,(state==BYTES&&payload_ready)};
 assign buffer_read_address=(write_metadata&&tx_busy)?tx_beat[4:0]+{4'd0,tx_write_beat}:
  state==COMP_BYTES?next_payload_index[8:4]:
  (plane==3&&(state==BYTES||state==WORD_PREFETCH0||state==WORD_PREFETCH1))?read_word:
  (state==BYTES&&!prefix)?next_data_index[8:4]:5'd0;
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin state<=IDLE;sample_lane<=0;read_word<=0;producer_reason<=0;producer_done<=0;armed<=0;acquired<=0;export_owned<=0;write_metadata<=0;b_commits<=0;rel_seen<=0;ret_seen<=0;timer<=0;export_timer<=0;offset<=0;plane<=0;index<=0;format_index<=0;arm<=0;cap_take<=0;source_id<=0;current_seq<=0;sof_tick<=0;eof_tick<=0;terminal<=0;failure<=0;attempts<=0;end
  else begin
   arm<=0;cap_take<=0;
   if(hold)timer<=timer+1'b1;
   if(export_owned)export_timer<=export_timer+1'b1;
   if(hold&&cap_done)begin producer_done<=1;producer_reason<=cap_reason;cap_take<=1;end
   if(retain_owner&&fusion_release)rel_seen<=1;
   if(retain_owner&&fusion_retire)ret_seen<=1;
   if(!stop)case(state)
    IDLE:if(select&&!terminal)begin state<=ACQ;producer_reason<=0;producer_done<=0;armed<=0;acquired<=0;export_owned<=0;write_metadata<=0;b_commits<=0;rel_seen<=0;ret_seen<=0;timer<=0;offset<=0;failure<=0;attempts<=attempts+1'b1;end
    else if(wait_expired&&!terminal)begin failure<=23;acquired<=0;armed<=0;state<=FAIL_WAIT;end
    FAIL_WAIT:if(!packet_busy)begin export_owned<=1;export_timer<=0;format_index<=0;state<=COMP_FORMAT;end
    ACQ:if(acquire_ack)begin arm<=1;armed<=1;acquired<=1;state<=CAPWAIT;timer<=0;end
     else if(acquire_denied)begin failure<=22;state<=ABORT;end
    CAPWAIT:if(write_failed)begin failure<=cap_done?cap_reason:producer_reason;state<=ABORT;end
     else if(cap_count>=32)state<=WRITE;
    WRITE:if(write_failed)begin failure<=cap_done?cap_reason:producer_reason;state<=ABORT;end else state<=WRITEWAIT;
    WRITEWAIT:if(write_failed)begin failure<=cap_done?cap_reason:producer_reason;state<=ABORT;end else if(tx_done)begin
     if(write_failed)begin failure<=cap_done?cap_reason:producer_reason;state<=ABORT;end
     else if(tx_error)begin failure<=16;state<=ABORT;end
     else if(offset==CURRENT_PHYSICAL_BYTES-512)begin b_commits<=b_commits+1;state<=TAIL0;end
     else begin b_commits<=b_commits+1;offset<=offset+512;state<=CAPWAIT;end
    end
    TAIL0:if(write_failed)begin failure<=cap_done?cap_reason:producer_reason;state<=ABORT;end else if(!cap_empty)begin source_id<=cap_data[63:0];current_seq<=cap_data[127:64];state<=TAIL1;end
    TAIL1:if(write_failed)begin failure<=cap_done?cap_reason:producer_reason;state<=ABORT;end else if(!cap_empty)begin sof_tick<=cap_data[63:0];eof_tick<=cap_data[127:64];state<=WAITDONE;end
    WAITDONE:if(write_failed)begin failure<=cap_done?cap_reason:producer_reason;state<=ABORT;end else if(producer_done)begin
     if(producer_reason!=0||b_commits!=CURRENT_PHYSICAL_BYTES/512||current_seq!=session||eof_tick<sof_tick||current_seq<descriptor[383:320]||current_seq-descriptor[383:320]>120||sof_tick<descriptor[575:512]||sof_tick-descriptor[575:512]>148500000)begin failure<=17;state<=ABORT;end
     else begin cap_take<=1;format_index<=0;state<=FORMAT;end
    end
    FORMAT:if(write_failed)begin failure<=cap_done?cap_reason:producer_reason;state<=ABORT;end else if(format_index==31)begin write_metadata<=1;state<=META;end else format_index<=format_index+1'b1;
    META:if(write_failed)begin failure<=cap_done?cap_reason:producer_reason;state<=ABORT;end else state<=META_WAIT;
    META_WAIT:if(write_failed)begin failure<=cap_done?cap_reason:producer_reason;state<=ABORT;end else if(tx_done)begin if(tx_error)begin failure<=18;state<=ABORT;end else begin state<=WAIT_RELEASE;timer<=0;end end
    WAIT_RELEASE:if(rel_seen&&ret_seen&&!packet_busy)begin export_owned<=1;plane<=0;offset<=0;export_timer<=0;state<=START_PACKET;end
    START_PACKET:begin index<=0;offset<=0;state<=READ;end
    READ:state<=READWAIT;
    READWAIT:if(tx_done)begin
     if(tx_error)begin failure<=19;state<=ABORT;end
     else begin index<=0;sample_lane<=0;read_word<=0;state<=PREFETCH;end
    end
    PREFETCH:state<=BYTES;
    WORD_PREFETCH0:state<=WORD_PREFETCH1;
    WORD_PREFETCH1:state<=BYTES;
    BYTES:if(payload_ready)begin
     if(data_index==chunk_last&&!prefix)begin
      if(offset==plane_physical_bytes-512)state<=END_PACKET;
      else begin offset<=offset+512;index<=0;state<=READ;end
     end else begin
      index<=index+1'b1;
      if(plane==3&&!prefix)begin
       if(sample_lane==24)begin sample_lane<=0;read_word<=read_word+1'b1;state<=WORD_PREFETCH0;end
       else sample_lane<=sample_lane+1'b1;
      end
     end
    end
    END_PACKET:if(packet_done)begin
     if(plane==3)begin format_index<=0;state<=COMP_FORMAT;end
     else begin plane<=plane+1'b1;state<=START_PACKET;end
    end
    COMP_FORMAT:if(format_index==15)state<=COMP_START;else format_index<=format_index+1'b1;
    COMP_START:begin index<=0;state<=COMP_BYTES;end
    COMP_BYTES:begin if(payload_ready&&index<255)index<=index+1'b1;if(packet_done)begin terminal<=failure==0||failure==23||attempts>=8;export_owned<=0;state<=RELEASE;end end
    ABORT:begin
     if(cap_done)cap_take<=1;
     if(!tx_busy&&cap_empty&&!cap_arm_busy&&(!armed||producer_done)&&(!acquired||(rel_seen&&ret_seen))&&!packet_busy)begin export_owned<=1;export_timer<=0;format_index<=0;state<=COMP_FORMAT;end
    end
    ABANDON_PACKET:if(!packet_busy&&!tx_busy)begin export_owned<=0;terminal<=1;state<=RELEASE;end
    RELEASE:if(!tx_busy)state<=RELEASE_WAIT;
    RELEASE_WAIT:if(!acquired||held===1'b0)begin state<=IDLE;timer<=0;end
    default:state<=ABORT;
   endcase
   if(!stop&&hold&&state<START_PACKET&&timed&&!write_failed)begin failure<=20;state<=ABORT;end
   if(!stop&&export_owned&&state!=ABORT&&state!=ABANDON_PACKET&&export_timer>=EXPORT_CYCLES)begin
    if(failure!=0)begin state<=ABANDON_PACKET;end
    else begin failure<=21;state<=ABORT;end
   end
  end
 end
endmodule

