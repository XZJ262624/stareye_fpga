module m5b0r_top(
 input clk_24m,clk_sys,sys_pll_lock,ddr_pll_lock,
 input core_clk,tac_clk,twd_clk,tdqss_clk,
 output sys_pll_rstn_o,ddr_pll_rstn_o,output [2:0] shift,output [4:0] shift_sel,output shift_ena,
 output [15:0] addr,output [2:0] ba,output we,reset,ras,cas,odt,cke,cs,
 input [15:0] i_dq_hi,i_dq_lo,output [15:0] o_dq_hi,o_dq_lo,o_dq_oe,
 output [1:0] o_dm_hi,o_dm_lo,input [1:0] i_dqs_hi,i_dqs_lo,i_dqs_n_hi,i_dqs_n_lo,
 output [1:0] o_dqs_hi,o_dqs_lo,o_dqs_n_hi,o_dqs_n_lo,o_dqs_oe,o_dqs_n_oe,
 output clk_p_hi,clk_p_lo,clk_n_hi,clk_n_lo,output [5:0] led_o
);
 assign sys_pll_rstn_o=1'b1;assign ddr_pll_rstn_o=sys_pll_lock;
 assign clk_p_hi=0;assign clk_p_lo=1;assign clk_n_hi=1;assign clk_n_lo=0;
 wire locked=sys_pll_lock&&ddr_pll_lock;
 (* async_reg="true" *)reg [2:0] rst_release=0;
 always @(posedge clk_sys or negedge locked)begin
  if(!locked)rst_release<=0;else rst_release<={rst_release[1:0],1'b1};
 end
 wire rst_n=rst_release[2];
 reg [8:0] heartbeat=0;always @(posedge clk_sys)heartbeat<=heartbeat+1'b1;
 wire [3:0] status,reason;wire alias_pass,range_pass,cal_done,cal_pass;
 wire [7:0] failure_stage;wire [31:0] failure_address,transaction_count,beat_count;
 wire [127:0] expected,actual;
 wire controller_reset_request,reference_timeout;
 wire [7:0] aid,alen,wid,bid,rid;wire [31:0] aaddr;
 wire [2:0] asize;wire [1:0] aburst,alock,bresp,rresp;
 wire avalid,aready,atype,wlast,wvalid,wready,bvalid,bready,rlast,rvalid,rready;
 wire [127:0] wdata,rdata;wire [15:0] wstrb;
 m5b0r_diagnostic u_diag(.clk(clk_sys),.*);
 m5b0r_monitor u_monitor(.refclk(clk_24m),.ui_heartbeat(heartbeat[8]),.*);
 // A diagnostic error/timeout simultaneously resets the DDR controller and
 // blocks reuse. Diagnostic first-failure payload is NOT reset by this path.
 DdrCtrl u_ddr(.clk(clk_sys),.core_clk(core_clk),.tac_clk(tac_clk),.twd_clk(twd_clk),.tdqss_clk(tdqss_clk),
 .reset_n(rst_n&&!controller_reset_request&&!reference_timeout),
 .reset(reset),.cs(cs),.ras(ras),.cas(cas),.we(we),.cke(cke),.addr(addr),.ba(ba),.odt(odt),
 .shift(shift),.shift_sel(shift_sel),.shift_ena(shift_ena),.cal_ena(1'b1),.cal_done(cal_done),.cal_pass(cal_pass),.cal_shift_val(),.cal_fail_log(),
 .o_dm_hi(o_dm_hi),.o_dm_lo(o_dm_lo),.i_dqs_hi(i_dqs_hi),.i_dqs_lo(i_dqs_lo),.i_dqs_n_hi(i_dqs_n_hi),.i_dqs_n_lo(i_dqs_n_lo),
 .o_dqs_hi(o_dqs_hi),.o_dqs_lo(o_dqs_lo),.o_dqs_n_hi(o_dqs_n_hi),.o_dqs_n_lo(o_dqs_n_lo),.o_dqs_oe(o_dqs_oe),.o_dqs_n_oe(o_dqs_n_oe),
 .i_dq_hi(i_dq_hi),.i_dq_lo(i_dq_lo),.o_dq_hi(o_dq_hi),.o_dq_lo(o_dq_lo),.o_dq_oe(o_dq_oe),
 .axi_aid(aid),.axi_aaddr(aaddr),.axi_alen(alen),.axi_asize(asize),.axi_aburst(aburst),.axi_alock(alock),.axi_avalid(avalid),.axi_aready(aready),.axi_atype(atype),
 .axi_wid(wid),.axi_wdata(wdata),.axi_wstrb(wstrb),.axi_wlast(wlast),.axi_wvalid(wvalid),.axi_wready(wready),
 .axi_bid(bid),.axi_bresp(bresp),.axi_bvalid(bvalid),.axi_bready(bready),
 .axi_rid(rid),.axi_rdata(rdata),.axi_rresp(rresp),.axi_rlast(rlast),.axi_rvalid(rvalid),.axi_rready(rready));
endmodule
