`timescale 1ns/1ps

module tb_pair_controller_pack5_dense_v2;

 parameter CASE=0;

 reg clk=0;always #5 clk=~clk;

 reg rst=0,sel=0,ack=0,denied=0,expired=0,rel=0,ret=0,held=0;

 wire hold,arm,cancel,release_owned,retire_owned,cap_take,cap_pop,packet_reserve,export_active,terminal;

 wire [31:0] failure;wire [3:0] attempts;wire cw,mw,cr,mr,rr;

 reg done=0;integer ptr=0;reg producer_finished=0;

 wire empty=ptr>=386;

 wire [9:0] count=empty?0:386-ptr;

 function [127:0] word_data(input integer n);integer k;begin

 word_data=0;for(k=0;k<16;k=k+1)word_data[k*8+:8]=(n*16+k)^8'h5a;

 end endfunction

 function [127:0] packed_word(input integer n);integer k;begin
 packed_word=0;for(k=0;k<25;k=k+1)packed_word[k*5+:5]=((n*25+k)%3)|4|((((n*25+k)/7)%2)<<4);
 end endfunction
 wire [127:0] cap_data=ptr<384?packed_word(ptr):ptr==384?{64'd100,64'd90}:{64'd5000,64'd4000};

 reg [767:0] descriptor=0;wire [319:0] identity={64'd1,64'd2,64'd3,64'd4,64'd5};

 wire ts,tw,tc,tbusy,tdone,terr,trb,twb;wire [31:0] ta;wire [7:0] tl,tbeat;wire [127:0] tdata;

 wire av,atype,wv,wl,ready_r;wire [31:0] aa;wire [7:0] al,aid;wire [127:0] wd;

 reg ar=0,wr=0,bv=0,rv=0,rl=0;reg [127:0] rd=0;

 wire buf_write;wire [4:0] buf_wa,buf_ra;wire [127:0] buf_wd;reg [127:0] buf_rd;
 reg [127:0] shared_mem[0:31];
 always @(posedge clk)begin if(buf_write)shared_mem[buf_wa]<=buf_wd;buf_rd<=shared_mem[buf_ra];end
 wire ps,pa,pv,pr,pd,pbusy,uart;wire [7:0] pt,payload;wire [31:0] length;

 m5c_pair_controller #(.CURRENT_BYTES(9600),.REFERENCE_CLASS_BYTES(512),.REFERENCE_MASK_BYTES(512),.CAPTURE_CYCLES(CASE==1||CASE==2?1000:1000000),.EXPORT_CYCLES(CASE>=4?33'd1000:33'd10000000)) dut(

 .clk(clk),.rst_n(rst),.stop(1'b0),.select(sel),.wait_expired(expired),.acquire_ack(ack),.acquire_denied(denied),

 .descriptor(descriptor),.identity(identity),.session(64'd100),.token(64'h100000002),.slot(1'b0),.fusion_release(rel),.fusion_retire(ret),.held(held),

 .hold(hold),.arm(arm),.cancel_capture(cancel),.release_owned(release_owned),.retire_owned(retire_owned),

 .cap_arm_busy(1'b0),.cap_done(done),.cap_reason(32'd0),.cap_take(cap_take),.cap_empty(empty),.cap_count(count),.cap_data(cap_data),.cap_pop(cap_pop),

 .tx_start(ts),.tx_write(tw),.tx_cancel(tc),.tx_addr(ta),.tx_len(tl),.tx_data(tdata),.tx_busy(tbusy),.tx_done(tdone),.tx_error(terr),.tx_read_beat(trb),.tx_write_beat(twb),.tx_beat(tbeat),.rdata(rd),

 .buffer_write(buf_write),.buffer_write_address(buf_wa),.buffer_read_address(buf_ra),.buffer_write_data(buf_wd),.buffer_read_data(buf_rd),
 .packet_start(ps),.packet_abort(pa),.packet_type(pt),.packet_length(length),.payload(payload),.payload_valid(pv),.payload_ready(pr),.packet_done(pd),.packet_busy(pbusy),.packet_reserve(packet_reserve),

 .export_active(export_active),.current_write(cw),.metadata_write(mw),.current_read(cr),.metadata_read(mr),.reference_read(rr),.terminal(terminal),.failure(failure),.attempts(attempts));

 m5b1_transfer transfer(.clk(clk),.rst_n(rst),.stop(1'b0),.start(ts),.cancel(tc),.write_op(tw),.address(ta),.length(tl),.busy(tbusy),.done(tdone),.error(terr),.cancelled(),.beat(tbeat),.read_beat(trb),.write_beat(twb),

 .segment_accept(),.segment_is_write(),.segment_done(),.segment_error(),.logical_drained(),.avalid(av),.aready(ar),.aaddr(aa),.alen(al),.aid(aid),.atype(atype),

 .source_data(tdata),.wdata(wd),.wvalid(wv),.wlast(wl),.wready(wr),.bvalid(bv),.bid(8'h22),.bresp(2'b0),.rvalid(rv),.rlast(rl),.rid(8'h22),.rresp(2'b0),.rready(ready_r),.rejected(1'b0));

 // Dense payload consumer, separate from actual UART/CRC gates.
 integer cycle=0;
 reg dense_busy=0,dense_done=0;integer dense_count=0,dense_length=0,dense_tail=0;
 assign pbusy=dense_busy;assign pd=dense_done;assign pr=dense_busy&&pv&&dense_tail==0&&(cycle%11!=3);assign uart=1;
 always @(posedge clk)begin
  dense_done<=0;
  if(!rst||pa)begin dense_busy<=0;dense_tail<=0;end
  else if(ps)begin dense_busy<=1;dense_count<=0;dense_length<=length;dense_tail<=0;end
  else if(dense_tail!=0)begin
   if(dense_tail==4)begin dense_busy<=0;dense_done<=1;dense_tail<=0;end else dense_tail<=dense_tail+1;
  end else if(pr&&pv)begin dense_count<=dense_count+1;if(dense_count==dense_length-1)dense_tail<=1;end
 end
 reg payload_stalled=0;reg [7:0] saved_payload;
 always @(posedge clk)if(rst)begin
  if(payload_stalled&&pv&&payload!==saved_payload)$fatal(1,"PACK5_PAYLOAD_STALLED_CHANGED");
  payload_stalled<=pv&&!pr;saved_payload<=payload;
 end
 reg [127:0] current_mem[0:383],meta_mem[0:31];integer bus_state=0,beat=0,stall=0,bcount=0;

 reg [31:0] address;reg bus_write;reg read_accepted=0;reg write_accepted=0;reg stalled=0;reg [127:0] stable_data,accepted_data;

 integer current_byte_index=0;
 integer packet_count=0,wirecount=0,fd;reg [1023:0] outpath;

 always @(posedge clk)if(rst)begin

  read_accepted<=rv&&ready_r;

  write_accepted<=wv&&wr;

  if(wv&&wr)accepted_data<=wd;

  cycle<=cycle+1;rel<=0;ret<=0;

  if(arm)held<=1;

  if(cap_pop)begin if(empty)$fatal(1,"PAIR_FIFO_UNDERFLOW");ptr<=ptr+1;end

  if(!producer_finished&&(ptr>=384||cancel))begin done<=1;producer_finished<=1;end

  if(cap_take)done<=0;

  if(producer_finished&&!rel&&!ret)begin rel<=1;ret<=1;end

  if(release_owned)begin

   if(tbusy||!empty||pbusy)$fatal(1,"PAIR_PREMATURE_RELEASE");held<=0;

  end

  if(stalled&&wv&&wd!==stable_data)$fatal(1,"PAIR_STALLED_WRITE_CHANGED");

  stalled<=wv&&!wr;stable_data<=wd;

  if(pv&&pr)begin $fdisplay(fd,"%02x",payload);wirecount<=wirecount+1;end

  if(pv&&pr&&pt==9)begin
   if(current_byte_index>=24 && payload!==(((current_byte_index-24)%3)|4|(((((current_byte_index-24)/7)%2))<<4)))$fatal(1,"PACK5_UNPACK_PIXEL_MISMATCH n=%0d data=%h",current_byte_index-24,payload);
   current_byte_index=current_byte_index+1;
  end
  if(pd)packet_count<=packet_count+1;

 end

 // Response model drives only on falling edges; payload is held until accepted.

 always @(negedge clk)if(rst)begin

  ar=0;wr=0;bv=0;rv=0;rl=0;

  case(bus_state)

   0:if(av)begin ar=1;address=aa;bus_write=atype;beat=0;bus_state=1;end

   1:begin

    if(bus_write)begin

     if(((CASE==1&&address==32'h01100000)||(CASE==2&&address==32'h011e1000))&&beat==30&&stall<1100)begin stall=stall+1;end

     else begin wr=1;bus_state=2;end

    end else begin

     if(address>=32'h01100000&&address<32'h011e1000)rd=current_mem[(address-32'h01100000)/16+beat];

     else if(address==32'h011e1000)rd=meta_mem[beat];else rd=word_data((address>>4)+beat);

     rv=1;rl=beat==31;bus_state=4;

    end

   end

   2:begin

    if(!write_accepted)$fatal(1,"PAIR_WRITE_EXPECTED");

    if(address==32'h011e1000)meta_mem[beat]=accepted_data;

    else begin

     if(accepted_data!==packed_word((address-32'h01100000)/16+beat))$fatal(1,"PAIR_WRITE_PAYLOAD_CORRUPTED");

     current_mem[(address-32'h01100000)/16+beat]=accepted_data;

    end

    if(beat==31)bus_state=3;else begin beat=beat+1;bus_state=1;end

   end

   3:begin bv=1;bcount=bcount+1;bus_state=5;end

   4:begin if(!read_accepted)$fatal(1,"PAIR_READ_EXPECTED");if(beat==31)bus_state=5;else begin beat=beat+1;bus_state=1;end end

   5:bus_state=0;

  endcase

 end

 initial begin

  if(!$value$plusargs("OUT=%s",outpath))$fatal(1,"OUT_REQUIRED");fd=$fopen(outpath,"w");

  descriptor[383:320]=99;descriptor[575:512]=3000;

  repeat(5)@(negedge clk);rst=1;repeat(5)@(negedge clk);

  if(CASE==3||CASE==5)begin ptr=386;expired=1;end

  else begin sel=1;@(negedge clk);sel=0;ack=1;@(negedge clk);ack=0;end

  wait(hold);wait(!hold);repeat(10)@(negedge clk);

  if(CASE==0)begin if(failure!=0||packet_count!=5||bcount!=13||!terminal)$fatal(1,"PAIR_SUCCESS_LEDGER");end

  else if(CASE>=4)begin if(failure==0||packet_count!=0||pbusy||!terminal)$fatal(1,"PAIR_REPORT_TIMEOUT_DRAIN");end

  else if(failure==0||packet_count!=1)$fatal(1,"PAIR_FAILURE_REPORT_MISSING");

  $fclose(fd);$display("PAIR_CONTROLLER_PASS case=%0d packets=%0d bytes=%0d B=%0d failure=%0d",CASE,packet_count,wirecount,bcount,failure);$finish;

 end

 initial begin #100000000;$fatal(1,"PAIR_CONTROLLER_WATCHDOG");end

endmodule

