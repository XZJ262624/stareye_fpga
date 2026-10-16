`timescale 1ns/1ps
module tb_shadow_rows;
 reg clk=0;always #5 clk=~clk;
 reg rst=0,ce=1,sof=0,block=0,valid=0;
 reg [11:0] x=0,y=0,fx=0,fy=0;reg [1:0] cc=0,rc=0;
 wire sv,s64,s128,sl,il,complete,equal_row,rtag,fok,quiet,tf,retire,edge_out,promoted;
 wire [11:0] retired;wire tg,bd,w,s,g;
 reg [319:0] identity=320'hfedcba9876543210_123456789abcdef0_ffff000012345678_1122334455667788_aabbccddeeff0001;
 m5c_row_fusion dut(.context_block(block),.context_quiet(quiet),.context_tail_fault(tf),.clk(clk),.rst_n(rst),.ce(ce),.sof(sof),.admit(1'b1),.invalidate(1'b0),.identity_in(identity),
  .tap_valid(valid),.tap_qualified(1'b1),.tap_x(x),.tap_y(y),.current_class(cc),.current_support(1'b1),.ref_ready(1'b1),.ref_class(rc),.ref_global(1'b1),.ref_identity(identity),.ref_x(x),.ref_y(y),.support_radius(4'd3),
  .final_de(1'b0),.final_x(fx),.final_y(fy),.local_edge(1'b0),.diag_tag_good(tg),.diag_bounds(bd),.diag_weak(w),.diag_support(s),.diag_global(g),.diag_row_complete(complete),.diag_row_equal(equal_row),.diag_row_tag(rtag),
  .diag_shadow_valid(sv),.diag_shadow64(s64),.diag_shadow128(s128),.diag_strong_loss(sl),.diag_illegal(il),.fused_edge(edge_out),.promoted(promoted),.frame_ok(fok),.row_retire(retire),.retired_y(retired));
 reg [3:0] classes[0:15359];reg [23:0] expected[0:11];integer row,col,checks=0,f;
 reg [2047:0] source,exppath;
 task check_row;
 begin
  fy=row;fx=0;#1;
  if(!sv||!complete||!rtag)$fatal(1,"SHADOW_ROW_LIFETIME");
  if(sl!==expected[row][20]||il!==expected[row][21]||equal_row!==expected[row][22])$fatal(1,"SHADOW_RISK_OR_ROW");
  for(col=0;col<1280;col=col+1)begin
   fx=col;#1;
   if(s64!==expected[row][col/64])$fatal(1,"SHADOW64_ORACLE row=%0d x=%0d",row,col);
   if(s128!==(expected[row][(col/128)*2]&&expected[row][(col/128)*2+1]))$fatal(1,"SHADOW128_ORACLE row=%0d x=%0d",row,col);
   checks=checks+1;
  end
  fy=row+4;#1;if(sv)$fatal(1,"SHADOW_OLD_ROW_ALIAS");fy=row;
 end endtask
 initial begin
  if(!$value$plusargs("CLASSES=%s",source)||!$value$plusargs("EXPECTED=%s",exppath))$fatal(1,"SHADOW_REQUIRED_INPUTS");
  $readmemh(source,classes);$readmemh(exppath,expected);
  repeat(4)@(negedge clk);rst=1;
  // Explicit state seeding only verifies full-width cookie matching, not a hardware reset claim.
  dut.frame_cookie=64'h1234567800000000;
  for(row=0;row<12;row=row+1)begin
   fy=row;fx=0;
   for(col=0;col<1280;col=col+1)begin
    @(negedge clk);x=col;y=row;valid=1;sof=row==0&&col==0;cc=classes[row*1280+col][1:0];rc=classes[row*1280+col][3:2];
    if(col==64)begin ce=0;repeat(3)@(negedge clk);ce=1;end
    @(posedge clk);#1;
    if(col<1279&&sv)$fatal(1,"SHADOW_EARLY_COMPLETE");
   end
   @(negedge clk);valid=0;sof=0;check_row;
  end
  // New SOF invalidates old banks before each receives its new full row.
  @(negedge clk);x=0;y=0;valid=1;sof=1;identity=identity^320'h10000000000000000;
  @(posedge clk);#1;fy=11;#1;if(sv)$fatal(1,"SHADOW_OLD_COOKIE");
  @(negedge clk);valid=0;sof=0;block=1;@(posedge clk);#1;if(sv)$fatal(1,"SHADOW_KILL");
  @(negedge clk);block=0;rst=0;@(posedge clk);#1;if(sv)$fatal(1,"SHADOW_RESET");
  $display("SHADOW_ROWS_PASS checks=%0d",checks);$finish;
 end
 initial begin #2000000;$fatal(1,"SHADOW_ROWS_WATCHDOG");end
endmodule
