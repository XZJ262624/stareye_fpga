from pathlib import Path
import hashlib,json
R=Path.cwd();O=R/'reports/m5c_pair_capture_20261016/formatter_revision';O.mkdir(exist_ok=False)
p=R/'rtl/m5c_pair_diag/m5c_pair_controller.sv';b=p.read_bytes();(O/'controller_before.sv').write_bytes(b);s=b.decode()
a=s.index(' function [127:0] meta_word');z=s.index(' end endfunction',a)+len(' end endfunction')
old=s[a:z];(O/'old_function.txt').write_text(old)
new=''' function [127:0] meta_word(input [5:0] wordno,input completion);
 begin
  meta_word=128'd0;
  case(wordno)
   0:begin meta_word[31:0]=1;meta_word[63:32]=failure==0?13:2;meta_word[127:64]=1;end
   1:begin meta_word[63:0]={60'd0,attempts};meta_word[127:64]=acquired?session:0;end
   2:begin meta_word[63:0]=acquired?token:0;meta_word[127:64]=acquired?{63'd0,slot}:0;end
   3:meta_word=completion?(acquired?identity[127:0]:128'd0):descriptor[127:0];
   4:meta_word=completion?(acquired?identity[255:128]:128'd0):descriptor[255:128];
   5:if(completion)begin meta_word[63:0]=acquired?identity[319:256]:0;meta_word[95:64]=failure==0?CURRENT_BYTES:0;meta_word[127:96]=failure==0?REFERENCE_CLASS_BYTES:0;end else meta_word=descriptor[383:256];
   6:if(completion)begin meta_word[31:0]=failure==0?REFERENCE_MASK_BYTES:0;meta_word[63:32]=failure;end else meta_word=descriptor[511:384];
   7:if(!completion)meta_word=descriptor[639:512];
   8:if(!completion)meta_word=descriptor[767:640];
   9:if(!completion)meta_word=identity[127:0];
   10:if(!completion)meta_word=identity[255:128];
   11:if(!completion)meta_word={source_id,identity[319:256]};
   12:if(!completion)meta_word={sof_tick,current_seq};
   13:if(!completion)meta_word={descriptor[639:576],eof_tick};
   14:if(!completion)meta_word={16'd720,16'd1280,descriptor[735:640]};
   15:if(!completion)begin meta_word[31:0]=CURRENT_BYTES;meta_word[63:32]=b_commits;meta_word[127:64]=current_seq-descriptor[383:320];end
   16:if(!completion)begin meta_word[63:0]=sof_tick-descriptor[575:512];meta_word[95:64]=CURRENT_BYTES;meta_word[127:96]=REFERENCE_CLASS_BYTES;end
   17:if(!completion)begin meta_word[31:0]=REFERENCE_MASK_BYTES;meta_word[95:64]=74400000;meta_word[127:96]=96000000;end
   default:meta_word=0;
  endcase
 end endfunction'''
s=s[:a]+new.replace('\n','\r\n')+s[z:];p.write_bytes(s.encode())
(O/'DERIVATION.json').write_text(json.dumps(dict(before_sha256=hashlib.sha256(b).hexdigest(),after_sha256=hashlib.sha256(p.read_bytes()).hexdigest(),scope='Combinational formatter only, same 128bit word and FORMAT cycles; pending exact differential.'),indent=2))
# Direct randomized old/new combinational functions, all legal word slots and both modes.
tb='''`timescale 1ns/1ps
module tb_pair_formatter_equivalence;
 localparam CURRENT_BYTES=921600,REFERENCE_CLASS_BYTES=230400,REFERENCE_MASK_BYTES=115200;
 reg [31:0] failure,b_commits;reg [3:0] attempts;reg acquired,slot;
 reg [63:0] session,token,source_id,current_seq,sof_tick,eof_tick;
 reg [319:0] identity;reg [767:0] descriptor;
 integer t,i,w,c;reg [31:0] seed=32'h31415926;
'''+old.replace('meta_word','old_word')+'\n'+new.replace('meta_word','new_word')+'''
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
'''
(R/'tb/m5c_pair_diag/tb_pair_formatter_equivalence.sv').write_text(tb)
