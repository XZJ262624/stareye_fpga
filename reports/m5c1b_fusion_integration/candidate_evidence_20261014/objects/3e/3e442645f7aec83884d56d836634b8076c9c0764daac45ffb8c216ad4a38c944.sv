`timescale 1ns/1ps
module tb_model_preflight;
 reg clk=0,rst_n=0,avalid=0;always #5 clk=~clk;
 reg [7:0] aid=3,alen=3;reg [31:0] aaddr=0,service_delay=1632;
 wire aready,wready,bvalid,rvalid,rlast;wire [7:0] bid,rid;wire [1:0] bresp,rresp;wire [127:0] rdata;wire [31:0] accepted,completed,max_service;
 integer tick=0,accepted_tick=0,beats=0,cases=0,expect_age=0,k;reg held=0;reg [138:0] held_data;
 selected_fault_ddr_model_retry #(.WORDS(32)) memory(.clk(clk),.rst_n(rst_n),.stall(1'b0),.aid(aid),.alen(alen),.wid(8'd0),.aaddr(aaddr),.asize(3'd4),.aburst(2'd1),.alock(2'd0),.avalid(avalid),.atype(1'b0),.aready(aready),.wdata(128'd0),.wstrb(16'hffff),.wlast(1'b0),.wvalid(1'b0),.wready(wready),.bid(bid),.bresp(bresp),.bvalid(bvalid),.bready(1'b1),.rid(rid),.rresp(rresp),.rdata(rdata),.rlast(rlast),.rvalid(rvalid),.rready(1'b1),.service_delay(service_delay),.inject_b_error(1'b0),.inject_r_error(1'b0),.accepted(accepted),.completed(completed),.max_service(max_service));
 always @(posedge clk)if(rst_n)begin
  tick=tick+1;
  if(avalid&&aready)begin accepted_tick=tick;beats=0;end
  if(rvalid)begin
   if(rid!==aid||rresp!==0||rdata!=={4{32'h10203040}}||rlast!==(beats==alen))$fatal(1,"MODEL_PREFLIGHT_REAL_R_FIELDS");
   beats=beats+1;
   if(rlast)begin
    if(tick-accepted_tick!=expect_age)$fatal(1,"MODEL_PREFLIGHT_INDEPENDENT_AGE got=%0d expected=%0d",tick-accepted_tick,expect_age);
    cases=cases+1;$display("PREFLIGHT_REAL_TERMINAL case=%0d id=%0d len=%0d elapsed=%0d",cases,rid,alen,tick-accepted_tick);
   end
  end
 end
 task read_case(input [7:0] n);
 begin @(negedge clk);alen=n;expect_age=1632;avalid=1;@(posedge clk);while(!aready)@(posedge clk);@(negedge clk);avalid=0;wait(completed==cases&&cases>0&&memory.state==0);repeat(2)@(negedge clk);end
 endtask
 initial begin
  for(k=0;k<32;k=k+1)memory.mem[k]={4{32'h10203040}};
  repeat(4)@(negedge clk);rst_n=1;
  read_case(0);read_case(3);read_case(19);
  if(cases!=3||accepted!=3||completed!=3||max_service!=1632||memory.max_by_id[3]!=1632)$fatal(1,"MODEL_PREFLIGHT_COUNTS");
  $display("PASS_MODEL_PREFLIGHT_ONLY exact1632 three_lengths realA_R independentedgeledger");$finish;
 end
 initial begin #100000;$fatal(1,"MODEL_PREFLIGHT_TIMEOUT");end
endmodule
