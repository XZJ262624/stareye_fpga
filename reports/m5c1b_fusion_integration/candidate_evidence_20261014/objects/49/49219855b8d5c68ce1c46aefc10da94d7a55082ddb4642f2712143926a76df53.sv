// UI-domain core. Fixed class-slot N/result-slot N pairing.
// Identity {epoch,job,source_frame,config_generation,slot_generation} = 320 bits.
// Production adapter supplies real metadata B and accepted-read/final-R drain.
// Isolated unit tests model these events; this core never fabricates ACKs.
module m5c_pair_lease(
 input clk,rst_n,stop,export_exclusive,
 input reserve_valid,input [319:0] reserve_identity,
 output reg reserve_ack,reserve_denied,reserve_slot,
 input bind_valid,bind_slot,input [319:0] bind_identity,
 output reg bind_ack,
 input publish_valid,publish_slot,metadata_b_done,input [319:0] publish_identity,
 input cancel_valid,cancel_slot,write_drained,input [319:0] cancel_identity,
 input acquire_valid,acquire_slot,acquire_uart,input [319:0] acquire_identity,input [63:0] acquire_token,
 output reg acquire_ack,acquire_denied,
 input release_valid,release_slot,release_uart,input [319:0] release_identity,input [63:0] release_token,
 input read_accept,read_slot,read_uart,input [319:0] read_identity,input [63:0] read_token,
 input read_done,done_slot,done_uart,input [319:0] done_identity,input [63:0] done_token,
 input retire_valid,retire_slot,retire_uart,input [319:0] retire_identity,input [63:0] retire_token,
 output reg latest_valid,latest_slot,
 output [1:0] reserved,committed,output [3:0] leased,
 output reg protocol_fault,output reg event_rejected);
 reg halted;
 reg [1:0] writing,ready,cancelling;
 reg [1:0] bound,nbound;reg ba;
 reg [319:0] identity[0:1];
 reg held[0:1][0:1],pending[0:1][0:1],cache[0:1][0:1];
 reg [15:0] reads[0:1][0:1];
 reg [63:0] token[0:1][0:1],ntoken[0:1][0:1];
 reg [1:0] nw,nr,nc;reg [319:0] ni[0:1];
 reg nh[0:1][0:1],np[0:1][0:1],ncache[0:1][0:1];
 reg [15:0] nreads[0:1][0:1];
 reg nlv,nls,nfault,ra,rd,rs,aa,ad,reject_event;integer i,j,k,free_slot;
 reg busy_slot,other_consumer;
 assign reserved=writing;assign committed=ready;
 assign leased={held[1][1],held[1][0],held[0][1],held[0][0]};
 // Compare each complete fixed slot before selecting one bit. Avoid wide
 // dynamic read muxes without narrowing identity/token or changing ordering.
 // An unknown selector is never an optimistic successful match in simulation.
 function choose2(input selector,input zero_result,one_result);
  begin case(selector)1'b0:choose2=zero_result;1'b1:choose2=one_result;default:choose2=0;endcase end
 endfunction
 function choose4(input slot,owner,input r00,r01,r10,r11);
  begin case({slot,owner})2'b00:choose4=r00;2'b01:choose4=r01;2'b10:choose4=r10;2'b11:choose4=r11;default:choose4=0;endcase end
 endfunction
 always @*begin
  nw=writing;nr=ready;nc=cancelling;nbound=bound;ba=0;nlv=latest_valid;nls=latest_slot;nfault=protocol_fault;
  ra=0;rd=0;rs=0;aa=0;ad=0;reject_event=0;free_slot=-1;busy_slot=0;other_consumer=0;
  for(i=0;i<2;i=i+1)begin
   ni[i]=identity[i];for(j=0;j<2;j=j+1)begin
    nh[i][j]=held[i][j];np[i][j]=pending[i][j];ncache[i][j]=cache[i][j];nreads[i][j]=reads[i][j];ntoken[i][j]=token[i][j];
   end
  end
  // Done requires a PRE-edge transaction: production DDR cannot return the
  // last R on the first client-accept edge. An existing completion and a new
  // acceptance may coincide; accounting still increments before decrement.
  if(read_accept)begin
   if(!held[read_slot][read_uart]||pending[read_slot][read_uart]||reads[read_slot][read_uart]==65535||!choose2(read_slot,read_identity==identity[0],read_identity==identity[1])||!choose4(read_slot,read_uart,read_token==token[0][0],read_token==token[0][1],read_token==token[1][0],read_token==token[1][1]))nfault=1;
   else nreads[read_slot][read_uart]=nreads[read_slot][read_uart]+1'b1;
  end
  if(read_done)begin
   if(reads[done_slot][done_uart]==0||!choose2(done_slot,done_identity==identity[0],done_identity==identity[1])||!choose4(done_slot,done_uart,done_token==token[0][0],done_token==token[0][1],done_token==token[1][0],done_token==token[1][1]))nfault=1;
   else nreads[done_slot][done_uart]=nreads[done_slot][done_uart]-1'b1;
  end
  if(retire_valid)begin
   if(held[retire_slot][retire_uart]&&choose2(retire_slot,retire_identity==identity[0],retire_identity==identity[1])&&choose4(retire_slot,retire_uart,retire_token==token[0][0],retire_token==token[0][1],retire_token==token[1][0],retire_token==token[1][1]))ncache[retire_slot][retire_uart]=0;
   else reject_event=1;
  end
  if(release_valid)begin
   if(held[release_slot][release_uart]&&choose2(release_slot,release_identity==identity[0],release_identity==identity[1])&&choose4(release_slot,release_uart,1'b1,1'b1,1'b1,1'b1))np[release_slot][release_uart]=1;
   else reject_event=1;
  end
  for(i=0;i<2;i=i+1)for(j=0;j<2;j=j+1)
   if(np[i][j] && nreads[i][j]==0 && !ncache[i][j])begin nh[i][j]=0;np[i][j]=0;end
  // Work-approved writer bind: source/config are unknown until real capture.
  // Zero is a legal source/config value; the separate bound bit is mandatory.
  if(bind_valid)begin
   if(writing[bind_slot]&&!bound[bind_slot]&&!cancelling[bind_slot]&&
      !held[bind_slot][0]&&!held[bind_slot][1]&&reads[bind_slot][0]==0&&reads[bind_slot][1]==0&&
      choose2(bind_slot,{bind_identity[319:192],bind_identity[63:0]}=={identity[0][319:192],identity[0][63:0]},
       {bind_identity[319:192],bind_identity[63:0]}=={identity[1][319:192],identity[1][63:0]})&&
      !(cancel_valid&&cancel_slot==bind_slot))begin
    ni[bind_slot]=bind_identity;nbound[bind_slot]=1;ba=1;
   end else reject_event=1;
  end
  // Cancellation wins over publication, even if metadata B completes now.
  if(cancel_valid)begin
   if(writing[cancel_slot]&&choose2(cancel_slot,cancel_identity==identity[0],cancel_identity==identity[1]))nc[cancel_slot]=1;
   else reject_event=1;
  end
  if(write_drained)begin
   if(nc[cancel_slot]&&choose2(cancel_slot,cancel_identity==identity[0],cancel_identity==identity[1]))begin nw[cancel_slot]=0;nr[cancel_slot]=0;nc[cancel_slot]=0;end
   else reject_event=1;
  end
  if(publish_valid&&bound[publish_slot]&&writing[publish_slot]&&!cancelling[publish_slot]&&
     !nc[publish_slot]&&!(cancel_valid&&cancel_slot==publish_slot&&choose2(publish_slot,cancel_identity==identity[0],cancel_identity==identity[1]))&&
     choose2(publish_slot,publish_identity==identity[0],publish_identity==identity[1])&&metadata_b_done)begin
   nw[publish_slot]=0;nr[publish_slot]=1;nlv=1;nls=publish_slot;
  end
  if(publish_valid&&(!bound[publish_slot]||!writing[publish_slot]||!choose2(publish_slot,publish_identity==identity[0],publish_identity==identity[1])))reject_event=1;
  // Publish is visible to acquire on this edge; same-consumer release/acquire
  // is rejected. Opposite consumer has global mutual exclusion (first export).
  if(acquire_valid)begin
   other_consumer=nh[0][!acquire_uart]||nh[1][!acquire_uart];
   if(nr[acquire_slot]&&!nw[acquire_slot]&&choose2(acquire_slot,ni[0]==acquire_identity,ni[1]==acquire_identity)&&
      !nh[acquire_slot][acquire_uart]&&!np[acquire_slot][acquire_uart]&&choose4(acquire_slot,acquire_uart,acquire_token>token[0][0],acquire_token>token[0][1],acquire_token>token[1][0],acquire_token>token[1][1])&&!(export_exclusive&&other_consumer)&&
      !(release_valid&&release_slot==acquire_slot&&release_uart==acquire_uart))begin
    nh[acquire_slot][acquire_uart]=1;ncache[acquire_slot][acquire_uart]=1;ntoken[acquire_slot][acquire_uart]=acquire_token;aa=1;
   end else ad=1;
  end
  // Allocator deliberately uses PRE-edge ownership: never reuse on a release
  // edge. This also separates generation changes from late response handling.
  for(k=1;k>=0;k=k-1)begin
   busy_slot=writing[k]||cancelling[k]||(latest_valid&&latest_slot==k)||
    held[k][0]||held[k][1]||pending[k][0]||pending[k][1]||cache[k][0]||cache[k][1]||
    reads[k][0]!=0||reads[k][1]!=0;
   if(!busy_slot&&!(publish_valid&&publish_slot==k)&&!(acquire_valid&&acquire_slot==k))free_slot=k;
  end
  if(reserve_valid)begin
   if(free_slot<0)rd=1;
   else if(!choose2(free_slot[0],reserve_identity[63:0]>identity[0][63:0],reserve_identity[63:0]>identity[1][63:0]))rd=1;
   else begin ra=1;rs=free_slot;ni[free_slot]=reserve_identity;nw[free_slot]=1;nr[free_slot]=0;nc[free_slot]=0;nbound[free_slot]=0;end
  end
 end
 integer a,b;
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin
   writing<=0;ready<=0;cancelling<=0;bound<=0;bind_ack<=0;latest_valid<=0;latest_slot<=0;protocol_fault<=0;event_rejected<=0;halted<=0;
   reserve_ack<=0;reserve_denied<=0;reserve_slot<=0;acquire_ack<=0;acquire_denied<=0;
   for(a=0;a<2;a=a+1)begin identity[a]<=0;for(b=0;b<2;b=b+1)begin held[a][b]<=0;pending[a][b]<=0;cache[a][b]<=0;reads[a][b]<=0;token[a][b]<=0;end end
  end else begin
   reserve_ack<=0;reserve_denied<=0;acquire_ack<=0;acquire_denied<=0;event_rejected<=0;bind_ack<=0;
   if(stop)halted<=1;
   if(!stop&&!halted&&!protocol_fault)begin
    writing<=nw;ready<=nr;cancelling<=nc;bound<=nbound;bind_ack<=ba;latest_valid<=nlv;latest_slot<=nls;protocol_fault<=nfault;
    reserve_ack<=ra;reserve_denied<=rd;reserve_slot<=rs;acquire_ack<=aa;acquire_denied<=ad;event_rejected<=reject_event;
    for(a=0;a<2;a=a+1)begin identity[a]<=ni[a];for(b=0;b<2;b=b+1)begin held[a][b]<=nh[a][b];pending[a][b]<=np[a][b];cache[a][b]<=ncache[a][b];reads[a][b]<=nreads[a][b];token[a][b]<=ntoken[a][b];end end
   end
  end
 end
endmodule
