"""One-shot exact baseline derivation; refuses non-baseline inputs."""
from pathlib import Path
import json,hashlib,difflib
R=Path(__file__).resolve().parents[1];B=R/'reports/m5c_shadow_stats_20261016'
base=json.loads((B/'BASELINE.json').read_text());original={x['path']:x for x in base['technical']}
changes=[]
def edit(path,fn):
 p=R/path;old=p.read_bytes();assert hashlib.sha256(old).hexdigest()==original[path]['sha256']
 text=old.decode();nl='\r\n' if '\r\n' in text else '\n';new=fn(text.replace('\r\n','\n')).replace('\n',nl).encode();p.write_bytes(new)
 changes.append(dict(path=path,before=hashlib.sha256(old).hexdigest(),after=hashlib.sha256(new).hexdigest(),diff=''.join(difflib.unified_diff(old.decode().splitlines(True),new.decode().splitlines(True)))))
def row(s):
 s=s.replace(' output fused_edge,promoted,output reg frame_ok,',' output diag_shadow_valid,diag_shadow64,diag_shadow128,diag_strong_loss,diag_illegal,\n output fused_edge,promoted,output reg frame_ok,')
 marker=' integer k;\n'
 block=''' // Passive schema2 shadow; no output feeds the production datapath/control.
 // Reuse the ORIGINAL row_complete/y/cookie lifetime. A new row clears all
 // its tiles before completion; no independent narrowed identity is stored.
 reg [19:0] shadow_tiles[0:3];
 reg shadow_illegal[0:3],shadow_strong_loss[0:3];
 integer sk;
 wire shadow_geometry=WIDTH==1280&&HEIGHT==720&&final_x<1280&&final_y<720;
 assign diag_shadow_valid=shadow_geometry&&row_complete[obank]&&row_y[obank]==final_y&&row_cookie[obank]==frame_cookie;
 assign diag_shadow64=shadow_geometry?shadow_tiles[obank][final_x[10:6]]:1'b0;
 assign diag_shadow128=shadow_geometry?(shadow_tiles[obank][{final_x[10:7],1'b0}]&&shadow_tiles[obank][{final_x[10:7],1'b1}]):1'b0;
 assign diag_strong_loss=shadow_strong_loss[obank];
 assign diag_illegal=shadow_illegal[obank];
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin
   for(sk=0;sk<4;sk=sk+1)begin shadow_tiles[sk]<=0;shadow_illegal[sk]<=0;shadow_strong_loss[sk]<=0;end
  end else if(context_block||context_tail_fault)begin
   for(sk=0;sk<4;sk=sk+1)begin shadow_tiles[sk]<=0;shadow_illegal[sk]<=0;shadow_strong_loss[sk]<=0;end
  end else if(ce&&tap_valid&&tap_x<1280)begin
   if(tap_x==0)begin
    shadow_tiles[bank]<={19'h7ffff,pixel_equal};
    shadow_illegal[bank]<=current_class==3||ref_class==3;
    shadow_strong_loss[bank]<=ref_class==2&&current_class!=2;
   end else begin
    if(!pixel_equal)shadow_tiles[bank][tap_x[10:6]]<=0;
    if(current_class==3||ref_class==3)shadow_illegal[bank]<=1;
    if(ref_class==2&&current_class!=2)shadow_strong_loss[bank]<=1;
   end
  end
 end
'''
 assert s.count(marker)==1;return s.replace(marker,block+marker)
edit('rtl/m5c_fusion/m5c_row_fusion.sv',row)
def display(s):
 s=s.replace(' output frame_done,output [479:0] telemetry_snapshot);',' output diag_shadow_valid,diag_shadow64,diag_shadow128,diag_strong_loss,diag_illegal,\n output frame_done,output [479:0] telemetry_snapshot);')
 return s.replace('  .fused_edge(fused_edge),.promoted(promoted)', '  .diag_shadow_valid(diag_shadow_valid),.diag_shadow64(diag_shadow64),.diag_shadow128(diag_shadow128),.diag_strong_loss(diag_strong_loss),.diag_illegal(diag_illegal),\n  .fused_edge(fused_edge),.promoted(promoted)')
edit('rtl/m5c_fusion/m5c_fusion_display.sv',display)
p=R/'rtl/m5c_diagnostics/m5c_diag_observer_v2.sv';s=p.read_bytes().decode().replace('\r\n','\n')
s=s.replace('module m5c_diag_observer_v2','module m5c_diag_observer_v3').replace(' input row_complete,row_equal,row_tag_good,input promoted,',' input shadow_valid,shadow64,shadow128,strong_loss_row,illegal_row,\n input row_complete,row_equal,row_tag_good,input promoted,')
s=s.replace(' reg [31:0] p0,p1,p2,p3,p4,reason;',' reg [31:0] p0,p1,p2,p3,p4,reason;\n reg [31:0] complete_fail,tag_fail,equal_fail,tile64_count,tile128_count,strong_loss_count,illegal_count;')
s=s.replace(' wire cyan=', ''' wire shadow_qualified=candidate&&row_complete&&row_tag_good&&shadow_valid;
 wire [6:0] shadow_events={shadow_qualified&&illegal_row,shadow_qualified&&strong_loss_row,
  shadow_qualified&&!illegal_row&&shadow128,shadow_qualified&&!illegal_row&&shadow64,
  candidate&&!row_equal,candidate&&!row_tag_good,candidate&&!row_complete};
 wire cyan=''' )
s=s.replace("aborted,1'b1,32'd1}","aborted,1'b1,32'd2}")
s=s.replace("   25:seal_data={32'd0,reason};", "   25:seal_data={32'd0,reason};\n   26:seal_data={tag_fail,complete_fail};27:seal_data={tile64_count,equal_fail};\n   28:seal_data={strong_loss_count,tile128_count};29:seal_data={32'd0,illegal_count};")
zero='complete_fail<=0;tag_fail<=0;equal_fail<=0;tile64_count<=0;tile128_count<=0;strong_loss_count<=0;illegal_count<=0;'
s=s.replace('   p0<=0;p1<=0;', '   '+zero+'\n   p0<=0;p1<=0;')
s=s.replace('      state<=CAPTURE;', '      '+zero+'\n      state<=CAPTURE;')
s=s.replace('      if(candidate)p0<=inc(p0);', '''      if(shadow_events[0])complete_fail<=inc(complete_fail);
      if(shadow_events[1])tag_fail<=inc(tag_fail);
      if(shadow_events[2])equal_fail<=inc(equal_fail);
      if(shadow_events[3])tile64_count<=inc(tile64_count);
      if(shadow_events[4])tile128_count<=inc(tile128_count);
      if(shadow_events[5])strong_loss_count<=inc(strong_loss_count);
      if(shadow_events[6])illegal_count<=inc(illegal_count);
      if((shadow_events[0]&&complete_fail==32'hffffffff)||(shadow_events[1]&&tag_fail==32'hffffffff)||
         (shadow_events[2]&&equal_fail==32'hffffffff)||(shadow_events[3]&&tile64_count==32'hffffffff)||
         (shadow_events[4]&&tile128_count==32'hffffffff)||(shadow_events[5]&&strong_loss_count==32'hffffffff)||
         (shadow_events[6]&&illegal_count==32'hffffffff))saturated<=1;
      if(candidate)p0<=inc(p0);''')
s=s.replace(' // synthesis translate_off',''' // synthesis translate_off
 always @(posedge clk)if(rst_n&&state==CAPTURE&&!kill&&owner_good&&candidate&&row_complete&&row_tag_good&&shadow_valid!==1'b1)
  $fatal(1,"SHADOW_VALID_MISSING");''')
new=R/'rtl/m5c_diagnostics/m5c_diag_observer_v3.sv';assert not new.exists();new.write_bytes(s.replace('\n','\r\n').encode());changes.append(dict(path=new.relative_to(R).as_posix(),parent=original['rtl/m5c_diagnostics/m5c_diag_observer_v2.sv'],after=hashlib.sha256(new.read_bytes()).hexdigest()))
def top(s):
 s=s.replace('    wire diag_ctx,','    wire diag_sv,diag_s64,diag_s128,diag_sl,diag_il;\n    wire diag_ctx,')
 s=s.replace('        .promoted(fusion_promoted),.frame_ok', '        .diag_shadow_valid(diag_sv),.diag_shadow64(diag_s64),.diag_shadow128(diag_s128),.diag_strong_loss(diag_sl),.diag_illegal(diag_il),\n        .promoted(fusion_promoted),.frame_ok')
 s=s.replace('m5c_diag_observer_v2 u_diag_observer','m5c_diag_observer_v3 u_diag_observer')
 s=s.replace('        .mode(display_mode),.admit_mode', '        .shadow_valid(diag_sv),.shadow64(diag_s64),.shadow128(diag_s128),.strong_loss_row(diag_sl),.illegal_row(diag_il),\n        .mode(display_mode),.admit_mode');return s
edit('efinity/m5c_fusion_i3/example_top.v',top)
edit('efinity/m5c_fusion_i3/Ti60_Demo.xml',lambda s:s.replace('m5c_diag_observer_v2.sv','m5c_diag_observer_v3.sv'))
(B/'IMPLEMENTATION_DERIVATION.json').write_text(json.dumps(dict(changes=changes,scope='Passive output-only row metadata and new schema2 observer; old observer_v2 preserved. Top/XML new version binding only.'),indent=2)+'\n')
print('IMPLEMENTED',len(changes),'files')
