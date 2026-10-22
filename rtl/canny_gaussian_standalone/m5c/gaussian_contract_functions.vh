// Deliberately no preprocessor guard: these functions belong to each module.
function [159:0] gauss_config;
 input [63:0] g;input [11:0] w,h;input [7:0] hi,lo;input [1:0] f;
 reg active;reg [2:0] radius;
 begin active=f!=2'd0;radius=active?3'd3:3'd2;
  gauss_config={g,8'd2,8'd2,w,h,hi,lo,active,radius,8'd1,f,26'd0};end
endfunction
function gauss_config_valid;
 input [159:0] c;
 begin gauss_config_valid=c[159:96]!=64'hffffffffffffffff&&c[95:88]==2&&c[87:80]==2&&
  c[79:68]!=0&&c[67:56]!=0&&c[47:40]=={1'b0,c[55:49]}&&c[35:28]==1&&
  c[27:26]!=3&&c[25:0]==0&&c[39]==(c[27:26]!=0)&&c[38:36]==(c[27:26]==0?3'd2:3'd3);end
endfunction
function gauss_descriptor_valid;
 input [767:0] d;input [11:0] w,h;
 reg [159:0] c;
 begin c=d[735:576];gauss_descriptor_valid=gauss_config_valid(c)&&d[308]&&
  d[743:736]==2&&d[751:744]==1&&d[767:752]==0&&d[319:311]==0&&
  d[283:276]==2&&d[295:284]==w&&d[307:296]==h&&c[79:68]==w&&c[67:56]==h&&
  d[263:256]==c[55:48]&&d[271:264]==c[47:40]&&d[272]==c[39]&&d[275:273]==c[38:36]&&
  d[310:309]==c[27:26]&&d[447:384]==c[159:96]&&d[575:512]==d[255:192];end
endfunction
