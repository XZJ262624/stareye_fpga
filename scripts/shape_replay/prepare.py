from pathlib import Path
import json,hashlib,shutil,re
R=Path(__file__).resolve().parents[2];O=R/'reports/shape_replay_20261028';T=R/'rtl/shape_replay';P=R/'efinity/shape_replay_i3'
def rec(p):return dict(path=p.relative_to(R).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def put(p,s):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(s,encoding='utf8')
def save(p,x):put(p,json.dumps(x,ensure_ascii=False,indent=2)+'\n')
assert not T.exists() and not P.exists()
parents=[]
for root in (R/'rtl/canny_replay',R/'efinity/canny_replay_i3'):
 parents += [rec(p) for p in sorted(root.rglob('*')) if p.is_file() and not any(x.startswith(('work_','outflow')) for x in p.relative_to(root).parts)]
wide=json.loads((R/'reports/shape_wide_roi_fast_20261022/SOURCE_MANIFEST.json').read_text())
for x in wide:
 if not x['path'].endswith('Ti60_Demo.xml'):assert rec(R/x['path'])==x,x
save(O/'PROTECTED_PARENTS.json',parents+[rec(R/x['path']) for x in wide])
save(O/'WIDE_XML_METADATA_NOTE.json',dict(previous=next(x for x in wide if x['path'].endswith('Ti60_Demo.xml')),current=rec(R/'efinity/shape_wide_roi_i3/Ti60_Demo.xml'),note='Current parent XML protected as found; historical manifest differs only here; no parent writes.'))
for root in (T,P,R/'tb/shape_replay'):root.mkdir(parents=True,exist_ok=True)
for sub in ('src','ip'):shutil.copytree(R/'efinity/canny_replay_i3'/sub,P/sub)
for f in ('Ti60_Demo.xml','Ti60_Demo.peri.xml','Ti60_Demo.pt.sdc'):shutil.copy2(R/'efinity/canny_replay_i3'/f,P/f)
for f in ('m5b1_async_fifo.sv','m5b1_mailbox.sv','m5b1_failstop.sv','replay_video_dma.sv','replay_arbiter.sv','replay_frontend.sv'):shutil.copy2(R/'rtl/canny_replay'/f,T/f)
for d in ('gaussian_m5a','filter'):shutil.copytree(R/'rtl/shape_standalone'/d,T/d)
shutil.copy2(R/'rtl/shape_standalone/shape/shape_stream_adapter_contract_v2.sv',T/'shape_stream_adapter_contract_v2.sv')
for f in ('shape_osd.sv','shape_recognizer_epoch.sv'):shutil.copy2(R/'rtl/shape_wide_roi'/f,T/f)
s=(R/'rtl/canny_replay/replay_controls.sv').read_text().replace('module replay_controls','module shape_replay_controls').replace('output reg edge_mode','output reg [1:0] view_index').replace('edge_mode<=0','view_index<=2').replace('edge_mode<=!edge_mode','view_index<=view_index==2?0:view_index+1\'b1')
s=s.replace('    if(!stable[i]&&!long_sent[i])begin','''    // The accepted release above owns held/long_sent on this edge. Old
    // stable still says pressed until NBA; do not overwrite its clear or
    // emit a long command at the same release boundary.
    if(!stable[i]&&!long_sent[i]&&!(key_sync[i]&&debounce[i]==DEBOUNCE-1))begin''')
put(T/'shape_replay_controls.sv',s)
s=(R/'rtl/shape_standalone/shape_standalone_system.sv').read_text().replace('module shape_standalone_system #(parameter DEBOUNCE_CYCLES=1488000,LONG_CYCLES=74400000)', 'module shape_replay_system #(parameter DEBOUNCE_CYCLES=1920000,LONG_CYCLES=57600000,CLIP_FRAMES=32)')
s=s.replace('source_generation!=64\'hffffffffffffffff&&!standalone_time_fault', 'source_generation!=64\'hffffffffffffffff&&!standalone_time_fault')
s=s.replace('shape_display_config==config_generation', 'shape_display_config==source_generation')
s=s.replace('    shape_standalone_frontend u_m5b1(','''    wire [1:0] command,replay_state;wire command_valid,clip_valid;
    wire [5:0] recorded,play_index;wire [14:0] pixel_status;
    replay_frontend #(.CLIP_FRAMES(CLIP_FRAMES)) u_m5b1(.command(command),.command_valid(command_valid),.replay_state(replay_state),.recorded(recorded),.play_index(play_index),.clip_valid(clip_valid),.pixel_status(pixel_status),''')
a=s.index('    shape_standalone_controls #');b=s.index('    m5a_stream_top #',a)
s=s[:a]+'''    wire [1:0] view_index,view_data;reg [1:0] sent_view;
    reg view_send;wire view_busy,view_valid;
    shape_replay_controls #(.DEBOUNCE(DEBOUNCE_CYCLES),.LONG_PRESS(LONG_CYCLES)) u_controls(
     .clk(ui_clk),.rst_n(rst_n),.key_n(key_n),.command_valid(command_valid),.command(command),.view_index(view_index));
    always @(posedge ui_clk or negedge rst_n)
     if(!rst_n)begin view_send<=0;sent_view<=3;end
     else begin view_send<=0;if(!view_busy&&!view_send&&view_index!=sent_view)begin view_send<=1;sent_view<=view_index;end end
    m5b1_mailbox #(.WIDTH(2)) view_box(.sclk(ui_clk),.dclk(pix_clk),.arst_n(rst_n),
     .send(view_send),.sdata(sent_view),.busy(view_busy),.valid(view_valid),.ddata(view_data),.take(source_sof));
    reg [2:0] view_mode;reg [63:0] generation;
    reg source_armed,source_clip;
    wire first_source=lcd_de&&source_armed;
    wire incoming_clip=pixel_status[1];
    wire context_change=first_source&&m5b1_lcd_qualified&&incoming_clip!=source_clip;
    wire [2:0] offered_mode=view_data==0?0:view_data==1?5:6;
    // On the first DE the adapter sees the NEXT tag on this same edge.
    // Replay identity may repeat; standalone_sequence remains independent.
    assign source_generation=(context_change&&generation!=64'hffffffffffffffff)?generation+1'b1:generation;
    assign config_generation=generation;assign source_mode=view_mode;assign source_threshold=64;
    always @(posedge pix_clk or negedge pix_rst_n)
     if(!pix_rst_n)begin view_mode<=6;generation<=0;source_armed<=0;source_clip<=0;end
     else begin
      if(source_sof)begin
       source_armed<=1;
       if(view_valid&&offered_mode!=view_mode)begin view_mode<=offered_mode;if(generation!=64'hffffffffffffffff)generation<=generation+1'b1;end
      end
      if(first_source)begin source_armed<=0;if(m5b1_lcd_qualified)source_clip<=incoming_clip;end
      if(context_change&&generation!=64'hffffffffffffffff)generation<=generation+1'b1;
     end
    (* async_reg="true" *) reg [1:0] fault_sync;
    always @(posedge pix_clk or negedge pix_rst_n)if(!pix_rst_n)fault_sync<=0;else fault_sync<={fault_sync[0],led[3]};
''' +s[b:]
s=s.replace('shape_osd u_osd(', 'shape_osd u_osd(.replay_status(pixel_status),.replay_fault(fault_sync[1]||shape_raster_fault),')
put(T/'shape_replay_system.sv',s)
s=(R/'efinity/shape_wide_roi_i3/example_top.v').read_text().replace('shape_standalone_system u_shape_system','shape_replay_system u_shape_system');put(P/'example_top.v',s)
# Extend the original one-stage OSD with a separate second header above ROI.
s=(T/'shape_osd.sv').read_text().replace('module shape_osd(input clk,', 'module shape_osd(input [14:0] replay_status,input replay_fault,input clk,')
insert=''' reg [14:0] replay_frame_status;wire [1:0] replay_state=replay_frame_status[1:0];
 wire [5:0] replay_number=replay_state==1?replay_frame_status[13:8]:replay_frame_status[7:2]+1'b1;
 wire [11:0] rx=x-16,ry=y-48;reg [7:0] replay_symbol;reg [34:0] replay_bitmap;reg replay_ink;
 always @*begin
  replay_symbol=" ";
  case(rx[9:4])
   0:replay_symbol=replay_fault?"E":replay_state==0?"L":replay_state==1?"R":"P";
   1:replay_symbol=replay_fault?"R":replay_state==0?"I":replay_state==1?"E":replay_state==2?"L":"A";
   2:replay_symbol=replay_fault?"R":replay_state==0?"V":replay_state==1?"C":replay_state==2?"A":"U";
   3:replay_symbol=replay_fault?"O":replay_state==0?"E":replay_state==1?" ":replay_state==2?"Y":"S";
   4:replay_symbol=replay_fault?"R":replay_state==3?"E":" ";
   6:replay_symbol=replay_state==0?" ":48+replay_number/10;7:replay_symbol=replay_state==0?" ":48+replay_number%10;
   8:replay_symbol=replay_state==0?" ":"-";9:replay_symbol=replay_state==0?" ":"3";10:replay_symbol=replay_state==0?" ":"2";
   13:replay_symbol=replay_frame_status[14]?"C":"N";14:replay_symbol=replay_frame_status[14]?"L":"O";
   15:replay_symbol=replay_frame_status[14]?"I":" ";16:replay_symbol=replay_frame_status[14]?"P":"C";
   17:replay_symbol=replay_frame_status[14]?" ":"L";18:replay_symbol=replay_frame_status[14]?" ":"I";19:replay_symbol=replay_frame_status[14]?" ":"P";
  endcase
  replay_bitmap=font(replay_symbol);replay_ink=0;
  if(x>=16&&x<336&&y>=48&&y<76&&rx[3:0]<10)replay_ink=replay_bitmap[34-(ry>>2)*5-(rx[3:0]>>1)];
 end
'''
s=s.replace(' always @(posedge clk or negedge rst_n) begin',insert+' always @(posedge clk or negedge rst_n) begin')
s=s.replace('if(!rst_n) begin x<=0;', 'if(!rst_n) begin replay_frame_status<=0;x<=0;')
s=s.replace('   de_d<=de;vs_d<=vs;', '   de_d<=de;vs_d<=vs;if(de&&x==0&&y==0)replay_frame_status<=replay_status;')
s=s.replace('   else if(((x==160', "   else if(x>=12&&x<340&&y>=44&&y<80)out_rgb<=replay_ink?(replay_fault?24'hff3030:24'h00ff80):24'h101018;\n   else if(((x==160")
put(T/'shape_osd.sv',s)
s=(P/'Ti60_Demo.xml').read_text().replace('canny_replay_i3','shape_replay_i3');s=re.sub(r'    <efx:design_file name="F:/Projects/stareye_fpga/rtl/.*?\n','',s)
entries=''.join(f'    <efx:design_file name="{p.as_posix()}" version="'+('system_verilog' if p.suffix=='.sv' else 'default')+'" library="default" />\n' for p in sorted(T.rglob('*')) if p.suffix in ('.v','.sv'))
s=s.replace('    <efx:top_vhdl_arch',entries+'    <efx:top_vhdl_arch').replace('rtl/canny_replay','rtl/shape_replay');put(P/'Ti60_Demo.xml',s)
put(P/'Ti60_Demo_I3.sdc',(R/'efinity/canny_replay_i3/Ti60_Demo_I3.sdc').read_text().split('# REPLAY_EXACT_CDC_INSERT')[0]+'# REPLAY_EXACT_CDC_INSERT\n')
for name in ('common.py','map.py','cdc.py','physical_finish.py'):
 s=(R/'scripts/canny_replay'/name).read_text().replace('canny_replay_20261028','shape_replay_20261028').replace('canny_replay_i3','shape_replay_i3').replace('rtl/canny_replay','rtl/shape_replay').replace('canny_replay_', 'shape_replay_').replace('StarEye_Canny_Replay.bit','StarEye_Shape_Replay.bit').replace("O/'PARENT_PRODUCTION_MANIFEST.json'","O/'PROTECTED_PARENTS.json'")
 if name=='cdc.py':s=s.replace('u_m5b1/','u_shape_system/u_m5b1/').replace('u_controls/key_meta','u_shape_system/u_controls/key_meta')
 put(R/'scripts/shape_replay'/name,s)
save(O/'PREPARE_RESULT.json',dict(passed=True,replay_source='byte-identical DMA/arbiter/frontend/FIFO/mailbox/failstop',recognizer='byte-identical wideROI',adapter='byte-identical contract_v2',filter='byte-identical shape_standalone gaussian_m5a'))
print('SHAPE_REPLAY_PREPARED')
