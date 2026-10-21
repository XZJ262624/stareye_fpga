// Test-only file I/O portability; no datapath or oracle changes.
function [23:0] portable_dec3(input integer index);
 reg [7:0] h,t,u;
 begin
  if(index<0 || index>999)$fatal(1,"DATA_INDEX_RANGE %0d",index);
  h=8'd48+index/100;t=8'd48+(index/10)%10;u=8'd48+index%10;
  portable_dec3={h,t,u};
 end
endfunction
task portable_require_file(input [4095:0] filename);
 integer handle;
 begin
  handle=$fopen(filename,"r");
  if(handle==0)$fatal(1,"INPUT_FILE_UNREADABLE path=%0s",filename);
  $fclose(handle);
 end
endtask
