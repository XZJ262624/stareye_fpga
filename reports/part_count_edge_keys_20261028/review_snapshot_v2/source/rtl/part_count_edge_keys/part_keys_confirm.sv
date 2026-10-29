`timescale 1ns/1ps
// Three distinct camera jobs confirm CURRENT quantity. No arrival accumulator.
module part_keys_confirm #(
 parameter CONFIRM_JOBS=3,parameter [63:0] STALE_TICKS=37200000
)(
 input wire clk,rst_n,ce,invalidate,job_begin,job_done,job_good,
 input wire [63:0] ticks,epoch,config_id,job_frame,job_epoch,job_config,job_seq,job_tick,
 input wire [3:0] job_count,input wire [409:0] job_objects,
 output wire pose_event,pose_failure,output wire [31:0] pose_reasons,output wire [255:0] pose_data,
 output wire [63:0] pose_frame,pose_seq,pose_tick,
 output reg valid,have_value,output reg [3:0] count,output reg [1:0] confirmations,
 output reg [63:0] result_frame,result_seq,result_tick,output wire matching
);
 localparam IDLE=0,MATCH=1,REBASE=2,ACCEPT=3;
 reg [1:0] state;reg [63:0] ep,cfg,last_frame,last_job_tick;reg seen;
 reg [409:0] baseline,current;reg [3:0] baseline_count,current_count;
 reg [63:0] current_frame,current_seq,current_tick;
 reg [3:0] i,j,match_count,match_index;reg [9:0] used;
 wire [40:0] a=baseline[i*41+:41],b=current[j*41+:41];
 wire [18:0] aa=a[18:0],ba=b[18:0];
 wire [19:0] da=aa>=ba?{1'b0,aa}-{1'b0,ba}:{1'b0,ba}-{1'b0,aa};
 wire [10:0] ax=a[29:19],ay=a[40:30],bx=b[29:19],by=b[40:30];
 wire [11:0] dx=ax>=bx?{1'b0,ax}-{1'b0,bx}:{1'b0,bx}-{1'b0,ax};
 wire [11:0] dy=ay>=by?{1'b0,ay}-{1'b0,by}:{1'b0,by}-{1'b0,ay};
 wire hit=(da*24'd10<={5'd0,aa})&&dx<=8&&dy<=8;
 wire [4:0] found={1'b0,match_count}+(hit?5'd1:5'd0);
 wire [3:0] index=hit?j:match_index;
 assign matching=state!=IDLE;

 // POSE_OBSERVER_BEGIN. Nearest center is diagnostic, not a persistent object ID.
 reg [31:0] diag_reason;reg any_area,any_center;reg [12:0] best_distance;
 reg [18:0] best_area;reg [11:0] best_dx,best_dy;reg [3:0] best_j;reg best_area_ok,best_center_ok;
 wire area_ok=da*24'd10<={5'd0,aa};wire center_ok=dx<=8&&dy<=8;
 wire [12:0] distance_sum={1'b0,dx}+{1'b0,dy};
 wire choose_pair=j==0||distance_sum<best_distance;
 wire diag_clear=invalidate||epoch!=ep||config_id!=cfg||
  (seen&&ticks<last_job_tick)||(state!=IDLE&&(job_begin||ticks<current_tick||ticks-current_tick>=STALE_TICKS));
 assign pose_event=ce&&!diag_clear&&!job_done&&state==REBASE;
 assign pose_failure=|diag_reason[7:2];
 assign pose_reasons=diag_reason;
 assign pose_frame=current_frame;assign pose_seq=current_seq;assign pose_tick=current_tick;
 wire pair_valid=pose_failure;
 assign pose_data={15'd0,pair_valid,16'd0,
  30'd0,(pair_valid&&best_center_ok),(pair_valid&&best_area_ok),
  12'd0,(pair_valid?best_j:4'd0),12'd0,(pair_valid?i:4'd0),
  12'd0,current_count,12'd0,baseline_count,
  20'd0,(pair_valid?best_dy:12'd0),20'd0,(pair_valid?best_dx:12'd0),
  13'd0,(pair_valid?best_area:19'd0),13'd0,(pair_valid?aa:19'd0)};
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin diag_reason<=0;any_area<=0;any_center<=0;best_distance<=0;best_area<=0;best_dx<=0;best_dy<=0;best_j<=0;best_area_ok<=0;best_center_ok<=0;end
  else if(ce)begin
   if(diag_clear)begin diag_reason<=0;any_area<=0;any_center<=0;end
   else if(job_done)begin
    // This is only observable when the original qualified job takes REBASE.
    diag_reason<=seen&&baseline_count!=job_count?32'h2:32'h1;
    any_area<=0;any_center<=0;
   end else if(state==MATCH)begin
    if(choose_pair)begin best_distance<=distance_sum;best_area<=ba;best_dx<=dx;best_dy<=dy;best_j<=j;best_area_ok<=area_ok;best_center_ok<=center_ok;end
    any_area<=(j==0?1'b0:any_area)||area_ok;any_center<=(j==0?1'b0:any_center)||center_ok;
    if(j+1>=current_count)begin
     if(found==0)diag_reason<=32'h4|
       ((!((j!=0&&any_area)||area_ok))?32'h8:32'd0)|
       ((!((j!=0&&any_center)||center_ok))?32'h10:32'd0)|
       ((((j!=0&&any_area)||area_ok)&&((j!=0&&any_center)||center_ok))?32'h20:32'd0);
     else if(found!=1)diag_reason<=32'h40;
     else if(used[index])diag_reason<=32'h80;
    end
   end
  end
 end
 // POSE_OBSERVER_END

 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin
   state<=IDLE;valid<=0;have_value<=0;count<=0;confirmations<=0;
   ep<=0;cfg<=0;last_frame<=0;last_job_tick<=0;seen<=0;baseline<=0;current<=0;baseline_count<=0;current_count<=0;
   current_frame<=0;current_seq<=0;current_tick<=0;result_frame<=0;result_seq<=0;result_tick<=0;
   i<=0;j<=0;match_count<=0;match_index<=0;used<=0;
  end else if(ce)begin
   if(invalidate||epoch!=ep||config_id!=cfg)begin
    valid<=0;confirmations<=0;state<=IDLE;seen<=0;ep<=epoch;cfg<=config_id;
    // Threshold changes revoke CURRENT and confirmation, preserving LAST.
    // Epoch change retains the original history reset policy.
    if(epoch!=ep)have_value<=0;
   end else if((seen&&ticks<last_job_tick)||(state!=IDLE&&(job_begin||ticks<current_tick||ticks-current_tick>=STALE_TICKS)))begin
    valid<=0;confirmations<=0;state<=IDLE;
   end else begin
    if(have_value&&(ticks<result_tick||ticks-result_tick>=STALE_TICKS))valid<=0;
    if(seen&&(ticks<last_job_tick||ticks-last_job_tick>=STALE_TICKS))confirmations<=0;
    if(job_begin)valid<=0;
    if(job_done)begin
     valid<=0;
     if(!job_good||job_epoch!=epoch||job_config!=config_id||job_frame==64'hffffffffffffffff||job_count>10||ticks<job_tick||ticks-job_tick>=STALE_TICKS||state!=IDLE)begin confirmations<=0;state<=IDLE;end
     else if(!seen||job_frame>last_frame)begin
      last_frame<=job_frame;last_job_tick<=ticks;seen<=1;current<=job_objects;current_count<=job_count;current_frame<=job_frame;current_seq<=job_seq;current_tick<=job_tick;
      i<=0;j<=0;match_count<=0;used<=0;
      if(confirmations==0||baseline_count!=job_count||(seen&&(ticks<last_job_tick||ticks-last_job_tick>=STALE_TICKS)))state<=REBASE;
      else if(job_count==0)state<=ACCEPT;
      else state<=MATCH;
     end
    end else case(state)
     MATCH:begin
      if(j+1>=current_count)begin
       if(found!=1||used[index])state<=REBASE;
       else begin
        used[index]<=1;
        if(i+1>=baseline_count)state<=ACCEPT;
        else begin i<=i+1'b1;j<=0;match_count<=0;end
       end
      end else begin
       j<=j+1'b1;
       if(hit)begin match_count<=match_count+1'b1;match_index<=j;end
      end
     end
     REBASE:begin baseline<=current;baseline_count<=current_count;confirmations<=1;state<=IDLE;end
     ACCEPT:begin
      if(confirmations<CONFIRM_JOBS)confirmations<=confirmations+1'b1;
      if(confirmations>=CONFIRM_JOBS-1)begin
       valid<=1;have_value<=1;count<=current_count;result_frame<=current_frame;result_seq<=current_seq;result_tick<=current_tick;
      end
      state<=IDLE;
     end
     default:begin end
    endcase
   end
  end
 end
endmodule
