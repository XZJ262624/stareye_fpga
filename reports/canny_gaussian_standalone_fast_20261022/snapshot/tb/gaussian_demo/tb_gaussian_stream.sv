`timescale 1ns/1ps
module tb_gaussian_stream #(parameter WIDTH=13,HEIGHT=9,FRAMES=6,RESTART=0);
 reg clk=0;always #5 clk=~clk;
 reg ce=1,arst_n=0;reg[7:0] gray=0;reg iv=0,de=0,hs=1,vs=1,sof=0;
 reg[1:0] request=0;reg[63:0] frame_id=0;
 wire[7:0] selected,g,m,raw;wire support,window_support,od,oh,ov,os;
 wire[1:0] filter;wire[63:0] fid;wire[11:0] x,y,cx,cy,sx,sy;
 gaussian_median_stream #(.WIDTH(WIDTH),.HEIGHT(HEIGHT)) dut(.clk(clk),.ce(ce),.arst_n(arst_n),.in_gray(gray),.in_valid(iv),.in_de(de),.in_hs(hs),.in_vs(vs),.in_sof(sof),.filter_request(request),.in_frame_id(frame_id),.out_gray(selected),.median_gray(m),.gaussian_gray(g),.raw_gray(raw),.out_support(support),.window_support(window_support),.out_de(od),.out_hs(oh),.out_vs(ov),.out_sof(os),.out_filter_id(filter),.out_frame_id(fid),.out_x(x),.out_y(y),.center_x(cx),.center_y(cy),.selected_x(sx),.selected_y(sy));
 wire[7:0] old_m,old_raw;wire old_valid,old_de,old_hs,old_vs,old_sof;wire[11:0] old_x,old_y,old_cx,old_cy;
 m5a_median_stream #(.WIDTH(WIDTH),.HEIGHT(HEIGHT)) original(.clk(clk),.ce(ce),.arst_n(arst_n),.in_gray(gray),.in_valid(iv),.in_de(de),.in_hs(hs),.in_vs(vs),.in_sof(sof),.filter_enable(request!=0),.out_gray(),.median_gray(old_m),.raw_gray(old_raw),.out_valid(old_valid),.out_de(old_de),.out_hs(old_hs),.out_vs(old_vs),.out_sof(old_sof),.out_filter_enable(),.out_x(old_x),.out_y(old_y),.center_x(old_cx),.center_y(old_cy));
 reg[24:0] gold[0:921599];reg[175:0] expect_now,expected[0:10],got,held;
 reg[4095:0] root,path;reg[63:0] expected_frame=0;reg[1:0] expected_filter=0;
 integer f,xx,yy,pos,j,n,seed,checks=0,pixels=0,supported=0,raw_edges=0,stalls=0,mode_seen[0:3];
 integer slot=0,stall_length,stall_lengths[1:4];reg[31:0] random_state=32'h20261020;
 reg check_on=0;reg[7:0] eg,em,er,es;reg ew,ev;reg[11:0] ex,ey,ecx,ecy,esx,esy;
 task tick;begin
  held={cy,cx,sy,sx,y,x,fid,filter,os,ov,oh,od,support,window_support,m,g,selected,raw};
  @(posedge clk);#1;
  if(check_on)begin
   if(ce)begin
    for(j=10;j>0;j=j-1)expected[j]=expected[j-1];expected[0]=expect_now;
    got=0;got[7:0]=raw;got[15:8]=g;got[23:16]=m;got[24]=window_support;got[25]=support;
    got[26]=od;got[27]=oh;got[28]=ov;got[29]=os;got[31:30]=filter;got[95:32]=fid;
    got[127:120]=selected;got[139:128]=sx;got[151:140]=sy;got[163:152]=cx;got[175:164]=cy;
    // Coordinate slots without an accepted pixel may retain the last coordinate.
    if(expected[10][26])begin got[107:96]=x;got[119:108]=y;end
    if(got!==expected[10])$fatal(1,"STREAM_N10_VALUE_TAG_SUPPORT slot=%0d got=%h expected=%h",slot,got,expected[10]);
    if({m,window_support,od,oh,ov,os,x,y,cx,cy}!=={old_m,old_valid,old_de,old_hs,old_vs,old_sof,old_x,old_y,old_cx,old_cy})$fatal(1,"MEDIAN_REFERENCE_CHANGED slot=%0d",slot);
    if(od&&raw!==old_raw)$fatal(1,"RAW_REFERENCE_CHANGED");
    checks=checks+1;
    if(od)begin pixels=pixels+1;mode_seen[filter]=mode_seen[filter]+1;end
    if(window_support)supported=supported+1;
    if(od&&filter==0&&(x<2||y<2)&&support)raw_edges=raw_edges+1;
   end else begin
    if({cy,cx,sy,sx,y,x,fid,filter,os,ov,oh,od,support,window_support,m,g,selected,raw}!==held)$fatal(1,"STREAM_CE_FREEZE");
    stalls=stalls+1;
   end
  end
  @(negedge clk);
 end endtask
 task drive(input integer px,input integer py,input reg valid_pixel,input reg[24:0] data);
 begin
  iv=valid_pixel;de=valid_pixel;hs=!valid_pixel;vs=!sof;gray=valid_pixel?data[7:0]:8'ha5;
  er=valid_pixel?gray:0;ew=valid_pixel&&data[24];eg=ew?data[15:8]:0;em=ew?data[23:16]:0;
  ex=valid_pixel?px:0;ey=valid_pixel?py:0;ecx=ew?px-1:0;ecy=ew?py-1:0;
  ev=(expected_filter==0)?valid_pixel:(expected_filter==3)?0:ew;
  es=valid_pixel?((expected_filter==0)?er:(expected_filter==1)?em:(expected_filter==2)?eg:0):0;
  esx=ev?((expected_filter==0)?ex:ecx):0;esy=ev?((expected_filter==0)?ey:ecy):0;
  expect_now=0;expect_now[7:0]=er;expect_now[15:8]=eg;expect_now[23:16]=em;
  expect_now[24]=ew;expect_now[25]=ev;expect_now[26]=de;expect_now[27]=hs;expect_now[28]=vs;expect_now[29]=sof;
  expect_now[31:30]=expected_filter;expect_now[95:32]=expected_frame;expect_now[107:96]=ex;expect_now[119:108]=ey;
  expect_now[127:120]=es;expect_now[139:128]=esx;expect_now[151:140]=esy;expect_now[163:152]=ecx;expect_now[175:164]=ecy;
  slot=slot+1;
  random_state={random_state[30:0],random_state[31]^random_state[21]^random_state[1]^random_state[0]};
  if(random_state[3:0]<3)begin
   stall_length=1+random_state[5:4];stall_lengths[stall_length]=stall_lengths[stall_length]+1;
   ce=0;repeat(stall_length)tick;
  end
  ce=1;tick;
 end endtask
 initial begin
  if(!$value$plusargs("ROOT=%s",root))$fatal(1,"ROOT_REQUIRED");
  for(j=0;j<11;j=j+1)begin expected[j]=0;expected[j][27]=1;expected[j][28]=1;end
  for(j=0;j<4;j=j+1)mode_seen[j]=0;
  for(j=1;j<=4;j=j+1)stall_lengths[j]=0;
  repeat(4)tick;arst_n=1;repeat(4)tick;check_on=1;
  for(f=0;f<FRAMES;f=f+1)begin
   seed=(WIDTH==1280)?9:f;
   $sformat(path,"%0s/%0dx%0d_%0d.hex",root,WIDTH,HEIGHT,seed);$readmemh(path,gold,0,WIDTH*HEIGHT-1);
   expected_filter=(WIDTH==1280)?2:(f==0)?1:(f==1)?2:(f==2)?0:(f==3)?3:(f==4)?2:1;
   request=expected_filter;frame_id=64'd100+f;expected_frame=frame_id;sof=1;
   drive(0,0,0,0);request=3;frame_id=99999;
   // Multi-cycle SOF must not change the already latched filter or frame ID.
   repeat(2)drive(0,0,0,0);sof=0;drive(0,0,0,0);
   for(yy=0;yy<HEIGHT;yy=yy+1)begin
    for(xx=0;xx<WIDTH;xx=xx+1)begin
     pos=yy*WIDTH+xx;request=(xx+yy)%4;frame_id=99999;
     drive(xx,yy,1,gold[pos]);
    end
    repeat(5)drive(0,0,0,0);
   end
   // Short inter-frame gap retains old pipeline tail during the next SOF.
   drive(0,0,0,0);
  end
  if(RESTART!=0)begin
   if(WIDTH!=13||HEIGHT!=9)$fatal(1,"RESTART_TEST_DIMENSIONS");
   $sformat(path,"%0s/13x9_0.hex",root);$readmemh(path,gold,0,WIDTH*HEIGHT-1);
   expected_frame=500;expected_filter=1;frame_id=500;request=1;sof=1;drive(0,0,0,0);sof=0;
   // Four rows leave valid old windows in flight. New SOF immediately follows.
   for(yy=0;yy<4;yy=yy+1)for(xx=0;xx<WIDTH;xx=xx+1)drive(xx,yy,1,gold[yy*WIDTH+xx]);
   expected_frame=501;expected_filter=2;frame_id=501;request=2;sof=1;drive(0,0,0,0);
   // A separated SOF interval re-arms; there is never an accepted SOF pixel.
   sof=0;drive(0,0,0,0);sof=1;drive(0,0,0,0);sof=0;drive(0,0,0,0);
   for(yy=0;yy<HEIGHT;yy=yy+1)begin
    for(xx=0;xx<WIDTH;xx=xx+1)drive(xx,yy,1,gold[yy*WIDTH+xx]);
    repeat(5)drive(0,0,0,0);
   end
  end
  repeat(20)drive(0,0,0,0);
  if(RESTART==0)begin
   if(pixels!=WIDTH*HEIGHT*FRAMES||supported!=(WIDTH-2)*(HEIGHT-2)*FRAMES||stalls==0)$fatal(1,"STREAM_COUNTS pixels=%0d support=%0d",pixels,supported);
  end else if(pixels!=WIDTH*HEIGHT*(FRAMES+1)+WIDTH*4||supported!=(WIDTH-2)*(HEIGHT-2)*(FRAMES+1)+(WIDTH-2)*2)$fatal(1,"RESTART_COUNTS pixels=%0d support=%0d",pixels,supported);
  for(j=1;j<=4;j=j+1)if(stall_lengths[j]==0)$fatal(1,"MISSING_RANDOM_STALL_LENGTH length=%0d",j);
  if(WIDTH!=1280)begin
   for(j=0;j<4;j=j+1)if(mode_seen[j]==0)$fatal(1,"MISSING_FILTER_MODE");
   if(raw_edges==0)$fatal(1,"NONE_BORDER_LOST");
  end
  $display("PASS_GAUSSIAN_STREAM width=%0d height=%0d frames=%0d restart=%0d pixels=%0d supported=%0d checks=%0d stalls=%0d raw_border=%0d n_to_n10=1",WIDTH,HEIGHT,FRAMES,RESTART,pixels,supported,checks,stalls,raw_edges);
  $display("RANDOM_CE seed=20261020 lengths1to4=%0d,%0d,%0d,%0d",stall_lengths[1],stall_lengths[2],stall_lengths[3],stall_lengths[4]);$finish;
 end
 initial begin #3000000000;$fatal(1,"STREAM_WATCHDOG");end
endmodule
