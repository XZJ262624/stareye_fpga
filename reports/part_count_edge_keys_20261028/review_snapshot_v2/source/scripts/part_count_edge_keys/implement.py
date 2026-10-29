from pathlib import Path
R=Path(__file__).resolve().parents[2];D=R/'rtl/part_count_edge_keys'
def edit(n,fn):
 p=D/n;p.write_text(fn(p.read_text(encoding='utf8')),encoding='utf8')
def controls(s):
 s=s.replace('reg [LW-1:0] held;reg armed,long_seen;reg [2:0] pending;','reg [LW-1:0] held;reg armed,long_seen;')
 s=s.replace('pending<=0;','').replace('    if(sof&&pending!=0)begin event_valid<=1;event_code<=pending;end\n','')
 s=s.replace('      if(pending!=0&&!sof)event_fault<=1;\n      else pending<=long_seen?BOTH_LONG:seen==1?KEY0:seen==2?KEY1:BOTH_SHORT;', '      event_valid<=1;event_code<=long_seen?BOTH_LONG:seen==1?KEY0:seen==2?KEY1:BOTH_SHORT;')
 assert 'pending' not in s
 return s.replace('// KEY0=key_n[0], KEY1=key_n[1]. Board silk mapping is an integration task.','// K1=N2=key_n[0] decrement; K2=M2=key_n[1] increment.\n// A single long hold emits exactly one single event on release, no autorepeat.\n// Any overlapping debounced gesture suppresses single events. SOF is unused.\n// event_valid/event_code are held through CE stalls and consumed once on CE.')
edit('part_keys_controls.sv',controls)
def core(s):
 s=s.replace('output [63:0] generation,output reg view,output count_valid,have_value,busy,','input [63:0] generation,output count_valid,have_value,busy,')
 s=s.replace(" assign generation=64'd1;\n",'')
 s=s.replace('reg toggle_pending;reg [63:0] ep,','reg [63:0] cfg,ep,')
 s=s.replace('wire context_change=ep!=live_epoch;','wire context_change=ep!=live_epoch||cfg!=generation;')
 s=s.replace('view<=0;toggle_pending<=0;ep<=0;','cfg<=0;ep<=0;')
 s=s.replace('   if(source_sof&&toggle_pending)begin view<=!view;toggle_pending<=0;end\n','').replace('   if(event_valid&&(event_code==1||event_code==2))toggle_pending<=!toggle_pending;\n','')
 s=s.replace("if(ticks==64'hffffffffffffffff||", "if(generation==64'hffffffffffffffff||ticks==64'hffffffffffffffff||")
 s=s.replace('if(context_change)begin ep<=live_epoch;','if(context_change)begin cfg<=generation;ep<=live_epoch;')
 s=s.replace('event_valid&&event_code==3','event_valid&&event_code==4').replace("32'h454f5001","32'h454b5901")
 return s
edit('part_keys_core.sv',core)
edit('part_keys_confirm.sv',lambda s:s.replace('if(epoch!=ep||config_id!=cfg)have_value<=0;','// Threshold changes revoke CURRENT and confirmation, preserving LAST.\n    // Epoch change retains the original history reset policy.\n    if(epoch!=ep)have_value<=0;'))
def adapter(s):
 s=s.replace('input wire final_de,','input wire [7:0] source_high,input wire source_view,\n output wire [7:0] aligned_high,output wire aligned_view,\n input wire final_de,')
 # Add display metadata above the unchanged256-bit identity fields.
 s=s.replace('[255:0] tags','[264:0] tags').replace('[255:0] current_tag','[264:0] current_tag').replace('[255:0] incoming_tag={','[264:0] incoming_tag={source_high,source_view,').replace('[255:0] selected_tag','[264:0] selected_tag')
 s=s.replace('assign {aligned_frame_id,','assign {aligned_high,aligned_view,aligned_frame_id,')
 return s
edit('part_keys_adapter.sv',adapter)
def osd(s):
 s=s.replace('input count_valid,','input [7:0] high_threshold,\n input count_valid,')
 s=s.replace('reg vh,vld,','reg [7:0] hi;wire [7:0] lo=hi>>1;\n reg vh,vld,')
 s=s.replace('"EDGE H48 L24 CLOSE 3X3                          ":"RAW  H48 L24 CLOSE 3X3                          "','"MSK H048 L024 CLOSE 3X3                         ":"RAW H048 L024 CLOSE 3X3                         "')
 s=s.replace('   if(row==1)case(slot)', '   if(row==2)case(slot)\n    5:symbol=48+hi/100;6:symbol=48+(hi/10)%10;7:symbol=48+hi%10;\n    10:symbol=48+lo/100;11:symbol=48+(lo/10)%10;12:symbol=48+lo%10;\n    default:begin end\n   endcase\n   if(row==1)case(slot)')
 s=s.replace('if(!rst_n)begin vh<=0;','if(!rst_n)begin hi<=48;vh<=0;').replace('if(sof)begin vh<=view;','if(sof)begin hi<=high_threshold;vh<=view;')
 return s
edit('part_keys_osd.sv',osd)
def system(s):
 s=s.replace('part_count_controls','part_keys_controls').replace('part_count_stream_adapter','part_keys_adapter')
 s=s.replace(' wire [63:0] generation,count_frame,count_seq,count_tick;',' wire [63:0] generation,count_frame,count_seq,count_tick;\n wire [7:0] high_threshold,aligned_high;wire aligned_view,config_fault;\n part_keys_config config_control(.clk(pix_clk),.rst_n(pix_rst_n),.ce(1\'b1),.source_sof(source_sof),.event_valid(event_valid),.event_code(event_code),.high_threshold(high_threshold),.generation(generation),.view(view),.changed(),.config_fault(config_fault));')
 s=s.replace('.threshold(8\'d48)', '.threshold(high_threshold)')
 s=s.replace('.source_display_seq(display_seq),\n  .final_de', '.source_display_seq(display_seq),.source_high(high_threshold),.source_view(view),.aligned_high(aligned_high),.aligned_view(aligned_view),\n  .final_de')
 s=s.replace('.event_fault(event_fault||time_fault||adapter_fault)', '.event_fault(event_fault||time_fault||adapter_fault||config_fault)')
 s=s.replace('.display_seq(aligned_seq),.generation(generation),.view(view),','.display_seq(aligned_seq),.generation(generation),')
 s=s.replace('wire aligned_view,config_fault;','wire aligned_view,config_fault,view;').replace(' wire view,count_valid,',' wire count_valid,')
 s=s.replace('.y(final_y),.view(view),','.y(final_y),.view(aligned_view),.high_threshold(aligned_high),')
 return s
edit('part_keys_system.sv',system)
for n in ('physical_common.py','build_physical_v1.py'):
 s=(R/'scripts/part_count_edge_open'/n).read_text(encoding='utf8').replace('part_count_edge_open','part_count_edge_keys').replace('20261027','20261028').replace('StarEye_CountEdgeOpen','StarEye_CountEdgeKeys')
 (R/'scripts/part_count_edge_keys'/n).write_text(s,encoding='utf8')
print('KEYS_IMPLEMENTED')
