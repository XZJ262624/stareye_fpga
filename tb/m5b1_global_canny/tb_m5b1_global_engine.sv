`timescale 1ns/1ps
module tb_m5b1_global_engine;
 parameter WIDTH=128,HEIGHT=32,MAX_PAIRS=64,WALL_CYCLES=96000000;
 localparam PIXELS=WIDTH*HEIGHT;
 reg clk=0;always #5 clk=~clk;reg rst_n=0,start=0;wire busy,finished,failed,published,result_slot;
 wire [319:0] published_descriptor;wire [15:0] pairs,scans;wire [31:0] elapsed,changed_pixels;
 wire tx_start,tx_write;wire [31:0] tx_address;wire [7:0] tx_length;
 reg tx_busy=0,tx_done=0,tx_error=0;reg [7:0] tx_beat=0;reg tx_read_beat=0;reg [127:0] tx_rdata=0;wire [127:0] tx_wdata;
 reg [127:0] mem[0:59135];integer cls[0:PIXELS-1];reg gold[0:PIXELS-1];integer queue[0:PIXELS-1];
 integer head,tail,p,x,y,dx,dy,nx,ny,j,i,k,t,pass=0,pattern,tests=30;
 reg [4095:0] input_file;integer use_file,expect_fail=0,expect_scans=0;
 integer first_pattern=0,tile,digit,value;
 integer phase=0,base=0,len=0,beat=0;reg writing;integer accepted=0,completed=0;
 m5b1_global_engine #(.WIDTH(WIDTH),.HEIGHT(HEIGHT),.MAX_PAIRS(MAX_PAIRS),.WALL_CYCLES(WALL_CYCLES)) dut(
  .clk(clk),.rst_n(rst_n),.stop(1'b0),.start(start),.descriptor(320'h1234),.class_base(32'h01000000),.result_available(2'b11),
  .result_reserved(),.busy(busy),.finished(finished),.failed(failed),.published(published),.result_slot(result_slot),.published_descriptor(published_descriptor),
  .pairs(pairs),.scans(scans),.elapsed(elapsed),.changed_pixels(changed_pixels),
  .tx_start(tx_start),.tx_write(tx_write),.tx_cancel(),.tx_address(tx_address),.tx_length(tx_length),
  .tx_busy(tx_busy),.tx_done(tx_done),.tx_error(tx_error),.tx_beat(tx_beat),.tx_read_beat(tx_read_beat),.tx_rdata(tx_rdata),.tx_write_beat(phase==1&&writing),.tx_wdata(tx_wdata));
 always @(negedge clk)begin
  tx_done=0;tx_read_beat=0;
  if(phase==3)tx_beat=0;
  if(phase==1)begin
   tx_beat=beat;
   if(!writing)begin tx_rdata=mem[base+beat];tx_read_beat=1;end
  end
  if(phase==2)begin tx_done=1;tx_busy=0;phase=0;completed=completed+1;end
 end
 always @(posedge clk)begin
  if(tx_start)begin
   if(phase!=0)$fatal(1,"engine overlaps C2 operations");
   if(tx_length>31||tx_address[3:0]!=0)$fatal(1,"logical transfer bounds");
   base=(tx_address-32'h01000000)>>4;len=tx_length;beat=0;writing=tx_write;phase=3;tx_busy=1;accepted=accepted+1;
  end else if(phase==3)begin phase=1;end else if(phase==1)begin
   if(writing)mem[base+beat]=tx_wdata;
   if(beat==len)phase=2;else beat=beat+1;
  end
 end
 task make_gold;
 begin
  head=0;tail=0;
  for(i=0;i<PIXELS;i=i+1)begin gold[i]=cls[i]==2;if(gold[i])begin queue[tail]=i;tail=tail+1;end end
  while(head<tail)begin
   p=queue[head];head=head+1;x=p%WIDTH;y=p/WIDTH;
   for(dy=-1;dy<=1;dy=dy+1)for(dx=-1;dx<=1;dx=dx+1)begin
    nx=x+dx;ny=y+dy;j=ny*WIDTH+nx;
    if(nx>=0&&nx<WIDTH&&ny>=0&&ny<HEIGHT&&(dx!=0||dy!=0))
     if(cls[j]==1&&!gold[j])begin gold[j]=1;queue[tail]=j;tail=tail+1;end
   end
  end
 end endtask
 initial begin
  use_file=$value$plusargs("INPUT=%s",input_file);
  if($value$plusargs("EXPECT_FAIL=%d",expect_fail))begin end
  if($value$plusargs("EXPECT_SCANS=%d",expect_scans))begin end
  if($value$plusargs("TESTS=%d",tests))begin end
  if($value$plusargs("FIRST=%d",first_pattern))begin end
  repeat(5)@(negedge clk);rst_n=1;
  for(pattern=first_pattern;pattern<first_pattern+tests;pattern=pattern+1)begin
   if(pattern==first_pattern)for(i=0;i<59136;i=i+1)mem[i]=0;
   for(i=0;i<PIXELS;i=i+1)begin
    case(pattern)
     0:cls[i]=0;
     1:cls[i]=2;
     2:cls[i]=(i==0)?2:1;
     3:cls[i]=(i==(PIXELS-1))?2:1;
     4:cls[i]=(i==WIDTH-1)?2:(i==WIDTH)?1:0;
     5:cls[i]=((i%WIDTH)==(i/WIDTH))?((i==0)?2:1):0;
     15:begin
      if(WIDTH==1280&&HEIGHT==720)begin
      x=i%WIDTH;y=i/WIDTH;tile=(y/5)*(WIDTH/5)+x/5;digit=(y%5)*3+x%5;
      value=tile;for(k=0;k<digit;k=k+1)value=value/3;
      cls[i]=(tile<19683&&x%5<3&&y%5<3)?value%3:0;
      end else begin t=(i*1103515245+pattern*12345)^(i>>3);cls[i]=(t&31)==0?2:((t&7)<5?1:0);end
     end
     16:cls[i]=(i==PIXELS-2)?2:((i==PIXELS-1)?1:0);
     default:begin t=(i*1103515245+pattern*12345)^(i>>3);cls[i]=(t&31)==0?2:((t&7)<5?1:0);end
    endcase
    mem[i/64][(i%64)*2+:2]=cls[i];
   end
   if(use_file)begin $readmemh(input_file,cls);for(i=0;i<PIXELS;i=i+1)mem[i/64][(i%64)*2+:2]=cls[i];end
   make_gold();@(negedge clk);start=1;@(negedge clk);start=0;
   wait(finished);#1;
   if(expect_fail)begin
    if(!failed||published||accepted!=completed)$fatal(1,"timeout must drain and never publish");
    $display("M5B1_TIMEOUT_PASS pairs=%0d scans=%0d elapsed=%0d accepted=%0d completed=%0d",pairs,scans,elapsed,accepted,completed);$finish;
   end
   if(expect_scans&&scans!=expect_scans)$fatal(1,"scan count got=%0d expected=%0d",scans,expect_scans);
   if(failed||!published||result_slot!=0||published_descriptor!=320'h1234)$fatal(1,"job failed/publish metadata pattern=%0d state=%0d",pattern,dut.state);
   for(i=0;i<PIXELS;i=i+1)if(mem[(32'hac000>>4)+(i/128)][i%128]!==gold[i])$fatal(1,"BFS mismatch pattern=%0d pixel=%0d got=%b want=%b",pattern,i,mem[(32'hac000>>4)+(i/128)][i%128],gold[i]);
   if(accepted!=completed)$fatal(1,"published before B/R fence");
   if(pattern==16&&(pairs!=2||scans!=4||changed_pixels!=1))$fatal(1,"last-pixel changed reduction lost pair=%0d scans=%0d changed=%0d",pairs,scans,changed_pixels);
   if(pattern==15&&WIDTH==1280&&HEIGHT==720)$display("M5B1_EXHAUSTIVE_PASS ternary_3x3=19683 isolation_gap=2 full_frame_pixels=%0d",PIXELS);
   pass=pass+1;$display("GLOBAL_CASE_PASS pattern=%0d pairs=%0d scans=%0d clocks=%0d",pattern,pairs,scans,elapsed);
   @(negedge clk);
  end
  $display("M5B1_GLOBAL_PASS cases=%0d pixels=%0d transfers=%0d",pass,pass*PIXELS,completed);$finish;
 end
 initial begin #(64'd20000000000);$fatal(1,"global watchdog");end
endmodule

