`timescale 1ns/1ps
module tb_pair_formatter_equivalence;
 localparam CURRENT_BYTES=921600,REFERENCE_CLASS_BYTES=230400,REFERENCE_MASK_BYTES=115200;
 reg [31:0] failure,b_commits;reg [3:0] attempts;reg acquired,slot;
 reg [63:0] session,token,source_id,current_seq,sof_tick,eof_tick;
 reg [319:0] identity;reg [767:0] descriptor;
 integer t,i,w,c;reg [31:0] seed=32'h31415926;
 function [127:0] old_word(input [5:0] wordno,input completion);
 reg [4095:0] m;
 begin
  m=0;m[31:0]=1;m[63:32]=failure==0?13:2;m[127:64]=1;m[191:128]={60'd0,attempts};
  m[255:192]=acquired?session:0;m[319:256]=acquired?token:0;m[383:320]=acquired?{63'd0,slot}:0;
  if(completion)begin
   m[703:384]=acquired?identity:0;m[735:704]=failure==0?CURRENT_BYTES:0;m[767:736]=failure==0?REFERENCE_CLASS_BYTES:0;m[799:768]=failure==0?REFERENCE_MASK_BYTES:0;m[831:800]=failure;
  end else begin
   m[1151:384]=descriptor;m[1471:1152]=identity;
   m[1535:1472]=source_id;m[1599:1536]=current_seq;m[1663:1600]=sof_tick;m[1727:1664]=eof_tick;
   m[1887:1728]=descriptor[735:576];m[1903:1888]=1280;m[1919:1904]=720;
   m[1951:1920]=CURRENT_BYTES;m[1983:1952]=b_commits;
   m[2047:1984]=current_seq-descriptor[383:320];m[2111:2048]=sof_tick-descriptor[575:512];
   m[2143:2112]=CURRENT_BYTES;m[2175:2144]=REFERENCE_CLASS_BYTES;m[2207:2176]=REFERENCE_MASK_BYTES;
   m[2271:2240]=74400000;m[2303:2272]=96000000;
  end
  old_word=m[wordno*128+:128];
 end endfunction
 function [127:0] new_word(input [5:0] wordno,input completion);
 begin
  new_word=128'd0;
  case(wordno)
   0:begin new_word[31:0]=1;new_word[63:32]=failure==0?13:2;new_word[127:64]=1;end
   1:begin new_word[63:0]={60'd0,attempts};new_word[127:64]=acquired?session:0;end
   2:begin new_word[63:0]=acquired?token:0;new_word[127:64]=acquired?{63'd0,slot}:0;end
   3:new_word=completion?(acquired?identity[127:0]:128'd0):descriptor[127:0];
   4:new_word=completion?(acquired?identity[255:128]:128'd0):descriptor[255:128];
   5:if(completion)begin new_word[63:0]=acquired?identity[319:256]:0;new_word[95:64]=failure==0?CURRENT_BYTES:0;new_word[127:96]=failure==0?REFERENCE_CLASS_BYTES:0;end else new_word=descriptor[383:256];
   6:if(completion)begin new_word[31:0]=failure==0?REFERENCE_MASK_BYTES:0;new_word[63:32]=failure;end else new_word=descriptor[511:384];
   7:if(!completion)new_word=descriptor[639:512];
   8:if(!completion)new_word=descriptor[767:640];
   9:if(!completion)new_word=identity[127:0];
   10:if(!completion)new_word=identity[255:128];
   11:if(!completion)new_word={source_id,identity[319:256]};
   12:if(!completion)new_word={sof_tick,current_seq};
   13:if(!completion)new_word={descriptor[639:576],eof_tick};
   14:if(!completion)new_word={16'd720,16'd1280,descriptor[735:640]};
   15:if(!completion)begin new_word[31:0]=CURRENT_BYTES;new_word[63:32]=b_commits;new_word[127:64]=current_seq-descriptor[383:320];end
   16:if(!completion)begin new_word[63:0]=sof_tick-descriptor[575:512];new_word[95:64]=CURRENT_BYTES;new_word[127:96]=REFERENCE_CLASS_BYTES;end
   17:if(!completion)begin new_word[31:0]=REFERENCE_MASK_BYTES;new_word[95:64]=74400000;new_word[127:96]=96000000;end
   default:new_word=0;
  endcase
 end endfunction
 initial begin
 for(t=0;t<1000;t=t+1)begin
 failure=t%3==0?0:$random(seed);b_commits=$random(seed);attempts=$random(seed);acquired=t%2;slot=t%3;
 session={$random(seed),$random(seed)};token={$random(seed),$random(seed)};
 source_id={$random(seed),$random(seed)};current_seq={$random(seed),$random(seed)};
 sof_tick={$random(seed),$random(seed)};eof_tick={$random(seed),$random(seed)};
 for(i=0;i<24;i=i+1)descriptor[i*32+:32]=$random(seed);
 for(i=0;i<10;i=i+1)identity[i*32+:32]=$random(seed);
 for(c=0;c<2;c=c+1)for(w=0;w<32;w=w+1)
 if(old_word(w,c)!==new_word(w,c))$fatal(1,"FORMATTER_WORD_DIFFERENCE trial=%0d word=%0d completion=%0d",t,w,c);
 end
 $display("PAIR_FORMATTER_EQ_PASS 64000_words");$finish;
 end
endmodule
