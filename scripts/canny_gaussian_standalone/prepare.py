"""Derive isolated edge demonstration; never modify any parent input."""
from pathlib import Path
import re,json,hashlib,shutil,xml.etree.ElementTree as ET,time
R=Path(__file__).resolve().parents[2]; O=R/'reports/canny_gaussian_standalone_fast_20261022'
P=R/'efinity/canny_gaussian_standalone_i3'; T=R/'rtl/canny_gaussian_standalone'
O.mkdir(parents=True,exist_ok=True); P.mkdir(parents=True,exist_ok=True); T.mkdir(parents=True,exist_ok=True)
parents=[];derivations=[]
def rec(p):return dict(path=p.relative_to(R).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def get(p):
 p=R/p;parents.append(rec(p));return p.read_text()
def put(p,s):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(s,encoding='utf8')
def cut(s,a,b):return s[:s.index(a)]+s[s.index(b,s.index(a)):]
def sub(s,a,b):assert a in s,a;return s.replace(a,b)
base=R/'efinity/gaussian_shape_cap_i3'
for p in sorted(base.rglob('*')):
 if not p.is_file() or any(x.startswith(('work_','outflow','__pycache__')) for x in p.relative_to(base).parts):continue
 if p.suffix not in ('.v','.sv','.vh','.svh','.xml','.sdc','.json','.bin'):continue
 d=P/p.relative_to(base);d.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,d);parents.append(rec(p))
for folder in ('m5a_copy','m5c','filter'):
 for p in (R/'rtl/gaussian_integration'/folder).iterdir():
  if p.is_file() and p.suffix in ('.v','.sv','.vh') and p.name!='m5b1_uart.sv':
   d=T/folder/p.name;d.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,d);parents.append(rec(p))
for name in ('m5c_pair_diag_lease.sv','m5c_pair_arbiter.sv'):
 put(T/'core'/name,get('rtl/gaussian_integration/pair/'+name))

# Remove pair transport and UART, retaining the production job lifecycle,
# reservation, binding, metadata-B publication and actual transfer engine.
s=get('rtl/gaussian_integration/pair/m5c_pair_backend.sv')
s=s[s.index('module '):];s=s.replace('m5c_pair_backend','canny_backend')
s=cut(s,' input pair_local_rst_n,',' input ui_clk,')
s=cut(s,' input diag_ready,',' output uart_tx,')
s=sub(s,'output reg telemetry_take,','output telemetry_take,') if 'output reg telemetry_take,' in s else s
s=cut(s,' reg packet_start,',' wire tx_busy,')
s=cut(s,' wire pair_buffer_write;',' wire want_reserve=')
s=s.replace('&&!pair_hold&&!pair_selected&&!pair_fail_selected','')
s=s.replace('pair_retain_owner?pair_release:fusion_release','fusion_release').replace('pair_retain_owner?pair_retire:fusion_retire','fusion_retire')
s=s.replace('fusion_read_accept||(pair_hold&&transfer_segment_accept&&!transfer_segment_write)','fusion_read_accept')
s=s.replace('fusion_read_done||(pair_hold&&transfer_segment_done&&!transfer_segment_write)','fusion_read_done')
for a,b in [('pair_hold?pair_tx_start:transfer_start','transfer_start'),('pair_hold?pair_tx_cancel:transfer_cancel','transfer_cancel'),('pair_hold?pair_tx_write:transfer_write','transfer_write'),('pair_hold?pair_tx_addr:transfer_address','transfer_address'),('pair_hold?pair_tx_len:eng_selected?eng_tx_length:8\'d31',"eng_selected?eng_tx_length:8'd31"),('pair_hold?pair_tx_data:eng_selected?eng_tx_data:cap_data','eng_selected?eng_tx_data:cap_data')]:s=sub(s,a,b)
s=cut(s,' reg [2047:0] stats;',' assign job_busy=')
s=sub(s,' assign job_busy='," // UART is deliberately idle; no packet engine or pair owner exists.\n assign uart_tx=1'b1;\n assign job_busy=")
s=cut(s,'  if(pair_reference_read)begin','  if(state==CAPTURE')
s=s.replace('stats<=0;byte_index<=0;packet_start<=0;packet_abort<=0;','').replace('telemetry_take<=0;','').replace('packet_start<=0;packet_abort<=0;','')
s=cut(s,'    IDLE:if(','    RESERVE_WAIT:')
s=sub(s,'    RESERVE_WAIT:','    IDLE:begin end\n    RESERVE_WAIT:')
s=cut(s,'    STATS:begin','    FAULT_REPORT:')
s=sub(s,'    FAULT_REPORT:', '''    // Cancellation is issued in STATS and retained through real drain.
    // Returning to IDLE requires the original writer/transfer/arm fences;
    // there is no synthetic UART DONE or DDR acknowledgment.
    STATS:state<=STATS_WAIT;
    STATS_WAIT:if(!writer_owned&&!tx_busy&&!eng_busy&&!arm_busy&&cap_empty&&!descriptor_valid)
      state<=stop?FAULT_IDLE:IDLE;
    FAULT_REPORT:''')
s=s.replace('packet_abort<=1;','')
s=s.replace('STATS=7,STATS_WAIT=8,DRAIN=14,FAULT_REPORT=16,FAULT_IDLE=17,\n  RESERVE_WAIT=18,BIND=19,BIND_WAIT=20,TELEMETRY=23,TELEMETRY_WAIT=24;', 'STATS=7,STATS_WAIT=8,DRAIN=14,FAULT_REPORT=16,FAULT_IDLE=17,\n  RESERVE_WAIT=18,BIND=19,BIND_WAIT=20;')
s=s.replace('// UART fault telemetry is independent of the quarantined DDR transaction.','// Fail-stop retains the quarantined DDR owner; only cold reconfiguration recovers.')
put(T/'core/canny_backend.sv',s)

s=get('rtl/gaussian_integration/shape/shape_pair_system_guard.sv').replace('shape_pair_system_guard','canny_system')
s=s.replace('wire job_busy,publish_toggle,bg_fault;','wire job_busy,publish_toggle,bg_fault,job_rejected_event;')
s=cut(s,' input pair_source_tap_valid,',' input ui_clk,')
s=cut(s,' input diag_ready,',' output [7:0] aid,')
s=cut(s,' (* async_reg="true" *)reg [1:0] pair_ui_release,',' wire run,stop,ack,')
s=cut(s,' wire telemetry_ready,',' assign bwp=')
s=sub(s,' m5c_pair_backend #(.DIAGNOSTICS(DIAGNOSTICS)) background(', ' canny_backend #(.DIAGNOSTICS(DIAGNOSTICS)) background(')
s=cut(s,'background(.pair_local_rst_n(','.ui_clk(ui_clk),.pix_clk(pix_clk)') if False else s
a=s.index(' canny_backend #'); b=s.index('.ui_clk(ui_clk),.pix_clk(pix_clk)',a)
s=s[:a]+' canny_backend #(.DIAGNOSTICS(DIAGNOSTICS)) background('+s[b:]
s=cut(s,'  .diag_ready(','  .uart_tx(')
s=s.replace('.telemetry_pending(telemetry_pending),.telemetry_descriptor(telemetry_descriptor),.telemetry_session(telemetry_session)',".telemetry_pending(1'b0),.telemetry_descriptor(),.telemetry_session()")
s=cut(s,' m5c_pair_capture #',' m5c_bg_mux ')
s=s.replace('.pair_write_permission({pair_metadata_write,pair_current_write}),.pair_read_permission({pair_metadata_read,pair_current_read})',".pair_write_permission(2'b00),.pair_read_permission(2'b00)")
put(T/'core/canny_system.sv',s)

s=get('rtl/gaussian_integration/shape/shape_osd.sv').replace('module shape_osd','module canny_osd')
s=s.replace(' input [1:0] shape_class,input shape_valid,\n','')
s=re.sub(r' reg \[7:0\] ssymbol;[^\n]*\n','',s)
s=cut(s,'  // Previous display-frame result.','  gsymbol=" ";')
s=cut(s,'  sbitmap=font(ssymbol);','  fbitmap=font(fsymbol);')
s=re.sub(r'   else if\(x>=444[^\n]*\n','',s)
put(T/'core/canny_osd.sv',s)

s=get('efinity/gaussian_shape_cap_i3/example_top.v')
s=s.replace('wire [1:0] shape_class,final_filter;wire shape_valid;','wire [1:0] final_filter;')
s=re.sub(r'^    wire \[63:0\] shape_display_config,shape_display_epoch;\n|^    wire shape_visible=.*\n','',s,flags=re.M)
s=cut(s,'    shape_pair_system_guard #','.ui_clk(w_ddr3_ui_clk)')
s=sub(s,'.ui_clk(w_ddr3_ui_clk),.cam_clk(cmos_pclk)', '    canny_system u_m5b1(.ui_clk(w_ddr3_ui_clk),.cam_clk(cmos_pclk)')
s=cut(s,"      .diag_ready(1'b0)",'      .aid(w_ddr3_aid)')
s=s.replace('shape_osd u_osd(.shape_class(shape_class),.shape_valid(shape_visible),','canny_osd u_osd(')
s=cut(s,'    shape_stream_adapter_contract_v2 u_shape(','    m5c_fusion_display ')
s=cut(s,'    // Complete class follows','\t//\tHDMI Interface.')
put(P/'example_top.v',s)
p=P/'src/cmos_i2c/I2C_AR0135_1280720_Config.v';s=p.read_text();assert s.count("16'h3040, 16'h8000")==1 or '3040' in s
s,n=re.subn(r"(3040[^\n]*?)8000",r'\g<1>C000',s);assert n==1,n;put(p,s)

# Explicit source closure, with only child paths in project XML.
p=P/'Ti60_Demo.xml';tree=ET.parse(p);ns={'e':'http://www.efinixinc.com/enf_proj'};info=tree.find('e:design_info',ns)
for f in list(info.findall('e:design_file',ns)):info.remove(f)
sources=sorted(T.rglob('*.v'))+sorted(T.rglob('*.sv'))+[P/'example_top.v']+sorted((P/'src').rglob('*.v'))
for f in sources:ET.SubElement(info,'{'+ns['e']+'}design_file',dict(name=f.as_posix(),version='system_verilog' if f.suffix=='.sv' else 'default',library='default'))
for e in tree.iter():
 for k,v in list(e.attrib.items()):
  e.set(k,v.replace('F:/Projects/stareye_fpga/rtl/gaussian_integration/m5c',(T/'m5c').as_posix()).replace(base.as_posix(),P.as_posix()))
# Native Efinity's parser requires the original project text/schema ordering.
# Keep that format and replace only explicit design_file/include paths.
original=(base/'Ti60_Demo.xml').read_text()
original=re.sub(r'^\s*<efx:design_file[^\n]*\n','',original,flags=re.M)
entries=''.join('    <efx:design_file name="'+f.as_posix()+'" version="'+('system_verilog' if f.suffix=='.sv' else 'default')+'" library="default" />\n' for f in sources)
original=original.replace('    <efx:top_vhdl_arch',entries+'    <efx:top_vhdl_arch')
original=original.replace('F:/Projects/stareye_fpga/rtl/gaussian_integration/m5c',(T/'m5c').as_posix())
put(p,original)
# Inherited full SDC is retained separately as input. Removed instance groups
# are pruned only after static mapped-cell verification, before place/route.
put(O/'PARENT_SOURCE_MANIFEST.json',json.dumps(list({x['path']:x for x in parents}.values()),indent=2))
put(O/'PHASE_RESULT.json',json.dumps(dict(status='RUNNING',phase='DERIVED_ISOLATED_SOURCE',running=True,updated_unix=time.time())))
put(O/'COMPILE_FILES.json',json.dumps([p.relative_to(R).as_posix() for p in sources],indent=2))
print('ISOLATED_SOURCE_READY',len(sources))
