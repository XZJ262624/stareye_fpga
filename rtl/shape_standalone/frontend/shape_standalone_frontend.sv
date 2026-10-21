module shape_standalone_frontend(
 input ui_clk,cam_clk,pix_clk,rst_n,pll_locked,cal_done,cal_pass,
 input cam_vs,cam_valid,input [7:0] cam_data,input pix_sof,pix_request,
 output [7:0] pix_data,output [63:0] frame_id,epoch,output pix_qualified,output [5:0] led,
 output [7:0] aid,alen,wid,output [31:0] aaddr,output [2:0] asize,
 output [1:0] aburst,alock,output avalid,atype,input aready,
 output [127:0] wdata,output [15:0] wstrb,output wlast,wvalid,input wready,
 input [7:0] bid,input [1:0] bresp,input bvalid,output bready,
 input [7:0] rid,input [1:0] rresp,input [127:0] rdata,input rlast,rvalid,output rready);
 wire run,stop,ack,video_fault,quarantine,reset_request,arb_busy;
 wire [3:0] error_reason;wire [3:0] fifo_ready;wire [223:0] error_counts;wire [3:0] video_fifo_faults;
 wire [95:0] max_wait,max_service;wire [31:0] qos_exceeded,accepts,completes,rejects;
 wire [2:0] ca,car,cw,cwl,cwr,cb,cr,crl,crr,rejected;wire [95:0] cad;
 wire [23:0] cl,ci,cbi,cri;wire [2:0] ct;wire [383:0] cwd,crd;wire [5:0] cbr,crresp;
 wire [3:0] wp,rp;wire [6:0] bwp=7'd0,brp=7'd0;
 wire [13:0] camera_bytes,display_bytes,camera_max,display_min;
 wire [1:0] urgent;wire safe_window,display_valid;
 m5b1_failstop bridge(.ref_clk(ui_clk),.pll_locked(pll_locked),.cal_done(cal_done),.cal_pass(cal_pass),
  .protocol_fault(quarantine||reset_request),.fifo_fault(video_fault),.domains_ready(&fifo_ready),
  .allow_run(run),.stop(stop),.ddr_reset_ack(ack),.epoch(epoch));
 m5b1_video_dma video(.ui_clk(ui_clk),.cam_clk(cam_clk),.pix_clk(pix_clk),.arst_n(rst_n),.run(run),.stop(stop),.epoch(epoch),
  .cam_vs(cam_vs),.cam_valid(cam_valid),.cam_data(cam_data),.pix_sof(pix_sof),.pix_request(pix_request),
  .pix_data(pix_data),.replay_frame_id(frame_id),.pix_qualified(pix_qualified),.display_valid(display_valid),.fault(video_fault),
  .avalid(ca[1:0]),.aready(car[1:0]),.aaddr(cad[63:0]),.alen(cl[15:0]),.aid(ci[15:0]),.atype(ct[1:0]),
  .wvalid(cw[0]),.wlast(cwl[0]),.wdata(cwd[127:0]),.wready(cwr[0]),
  .bvalid(cb[0]),.bresp(cbr[1:0]),.bid(cbi[7:0]),.rvalid(cr[1]),.rlast(crl[1]),.rdata(crd[255:128]),.rresp(crresp[3:2]),.rid(cri[15:8]),.rready(crr[1]),
  .rejected(rejected[1:0]),.write_permission(wp),.read_permission(rp),.camera_bytes(camera_bytes),.display_bytes(display_bytes),.urgent(urgent),.safe_window(safe_window),
  .fifo_ready(fifo_ready[3:0]),.camera_max(camera_max),.display_min(display_min),.fifo_faults(video_fifo_faults));
 assign cw[1]=0;assign cwl[1]=0;assign cwd[255:128]=0;assign crr[0]=1;
 // Client2 does not exist in this profile; its request and payload inputs are inert.
 assign ca[2]=0;assign cad[95:64]=0;assign cl[23:16]=0;assign ci[23:16]=0;assign ct[2]=0;
 assign cw[2]=0;assign cwl[2]=0;assign cwd[383:256]=0;assign crr[2]=1;
 m5b1_arbiter arbiter(.clk(ui_clk),.rst_n(rst_n),.soft_reset(1'b0),.ddr_reset_ack(ack),.urgent(urgent),.safe_window(safe_window),
  .emergency_stop(stop||!run),.epoch(epoch),.c_epoch({epoch,epoch,epoch}),.video_write_permission(wp),.video_read_permission(rp),.bg_write_permission(bwp),.bg_read_permission(brp),
  .error_counts(error_counts),.max_wait(max_wait),.max_service(max_service),.qos_exceeded(qos_exceeded),.accepts(accepts),.completes(completes),.rejects(rejects),
  .c_avalid(ca),.c_aready(car),.c_aaddr(cad),.c_alen(cl),.c_aid(ci),.c_atype(ct),
  .c_wvalid(cw),.c_wlast(cwl),.c_wready(cwr),.c_wdata(cwd),.c_wstrb(48'hffffffffffff),
  .c_bvalid(cb),.c_bready(3'b111),.c_bid(cbi),.c_bresp(cbr),.c_rvalid(cr),.c_rlast(crl),.c_rready(crr),.c_rdata(crd),.c_rid(cri),.c_rresp(crresp),
  .rejected(rejected),.quarantine(quarantine),.reset_request(reset_request),.error_reason(error_reason),.busy(arb_busy),
  .aid(aid),.alen(alen),.wid(wid),.aaddr(aaddr),.asize(asize),.aburst(aburst),.alock(alock),.avalid(avalid),.atype(atype),.aready(aready),
  .wdata(wdata),.wstrb(wstrb),.wlast(wlast),.wvalid(wvalid),.wready(wready),.bid(bid),.bresp(bresp),.bvalid(bvalid),.bready(bready),
  .rid(rid),.rresp(rresp),.rdata(rdata),.rlast(rlast),.rvalid(rvalid),.rready(rready));
 reg [26:0] heartbeat;always @(posedge ui_clk or negedge rst_n)if(!rst_n)heartbeat<=0;else heartbeat<=heartbeat+1'b1;
 assign led={2'b0,video_fault||quarantine||stop,1'b0,cal_done&&cal_pass,heartbeat[25]};
endmodule
