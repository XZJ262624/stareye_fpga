from pathlib import Path
import json,hashlib,re
R=Path.cwd();F=R/'reports/m5c_pair_capture_20261016/pair_only_revision_v2';F.mkdir();p=R/'rtl/m5c_pair_diag/m5c_pair_backend.sv';old=p.read_bytes();(F/'backend_before.sv').write_bytes(old);s=old.decode().replace("\r\n","\n")
def rep(a,b):
 global s
 assert a in s,a;s=s.replace(a,b)
a=s.index(' localparam IDLE=');z=s.index(' reg packet_start',a);s=s[:a]+''' localparam IDLE=0,HEADER=1,CAPTURE=2,CAPWAIT=3,FREEZE=4,ENGINE=5,ENGINE_WAIT=6,
  STATS=7,STATS_WAIT=8,DRAIN=14,FAULT_REPORT=16,FAULT_IDLE=17,
  RESERVE_WAIT=18,BIND=19,BIND_WAIT=20,TELEMETRY=23,TELEMETRY_WAIT=24;
'''+s[z:]
for line in [' reg [7:0] export_type;',' wire export_active=(state>=EXPORT_START&&state<=EXPORT_FINISH)||state==EXPORT_PREFETCH;',' wire uart_read_accept=transfer_segment_accept&&!transfer_segment_write&&uart_owned;',' wire uart_read_done=transfer_segment_done&&!transfer_segment_write&&uart_owned;',' wire uart_acquire=state==UART_ACQUIRE;',' wire export_timeout=export_active&&export_age>=EXPORT_CYCLES;',' wire [31:0] export_base=export_type==2?class_base:(latest_slot?32\'h010c9000:32\'h010ac000);']:
 rep(line,'')
rep('latest_slot,latest_valid,exported','latest_slot,latest_valid');rep('offset,capture_age,export_age','offset,capture_age');rep('generation,uart_token','generation');rep('writer_owned,cancel_sent,uart_owned,uart_release,uart_cleanup_report','writer_owned,cancel_sent')
a=s.index(' reg [63:0] pair_export_job_floor');z=s.index(' assign pair_selected=',a);s=s[:a]+''' reg fresh_publication_seen;
 always @(posedge ui_clk or negedge pair_local_rst_n)
  if(!pair_local_rst_n)fresh_publication_seen<=0;
  else if(pair_selected)fresh_publication_seen<=0;
  else if(publication_accept)fresh_publication_seen<=1;
'''+s[z:]
rep('fusion_acquire&&exported&&\n  active_pair_descriptor==result_descriptor&&active_pair_descriptor[191:128]>pair_export_job_floor&&\n  active_pair_descriptor[191:128]>pair_last_selected_job&&','fusion_acquire&&fresh_publication_seen&&\n  active_pair_descriptor==result_descriptor&&');rep('&&!uart_owned','')
rep('assign export_exclusive=!exported','assign export_exclusive=1\'b0');rep('assign fusion_ack=acquire_ack&&!uart_acquire&&state!=UART_WAIT;','assign fusion_ack=acquire_ack;');rep('assign fusion_denied=acquire_denied&&state!=UART_WAIT;','assign fusion_denied=acquire_denied;')
a=s.index('  .acquire_valid(uart_acquire');z=s.index('  .latest_valid(',a);s=s[:a]+'''  .acquire_valid(fusion_acquire),.acquire_slot(fusion_slot),.acquire_uart(1'b0),.acquire_identity(fusion_identity),.acquire_token(fusion_token),
  .acquire_ack(acquire_ack),.acquire_denied(acquire_denied),
  .release_valid(pair_retain_owner?pair_release:fusion_release),.release_slot(fusion_slot),.release_uart(1'b0),.release_identity(fusion_identity),.release_token(fusion_token),
  .retire_valid(pair_retain_owner?pair_retire:fusion_retire),.retire_slot(fusion_slot),.retire_uart(1'b0),.retire_identity(fusion_identity),.retire_token(fusion_token),
  .read_accept(fusion_read_accept||(pair_hold&&transfer_segment_accept&&!transfer_segment_write)),.read_slot(fusion_slot),.read_uart(1'b0),.read_identity(fusion_identity),.read_token(fusion_token),
  .read_done(fusion_read_done||(pair_hold&&transfer_segment_done&&!transfer_segment_write)),.done_slot(fusion_slot),.done_uart(1'b0),.done_identity(fusion_identity),.done_token(fusion_token),
'''+s[z:]
rep('capture_timeout||export_timeout','capture_timeout');rep('||(state==EXPORT_READ)','');rep('(state==CAPTURE?class_base+offset:export_base+offset)','class_base+offset')
rep('pair_hold?pair_buffer_write:(state==EXPORT_READ_WAIT&&tx_read_beat)','pair_buffer_write');rep('pair_hold?pair_buffer_write_address:tx_beat[4:0]','pair_buffer_write_address');rep('pair_hold?pair_buffer_read_address:byte_index[8:4]','pair_buffer_read_address');rep('pair_hold?pair_buffer_write_data:rdata','pair_buffer_write_data')
rep("state==STATS_WAIT?stats[byte_index*8+:8]:export_head[byte_index[3:0]*8+:8]","stats[byte_index*8+:8]");rep('state==STATS_WAIT||state==EXPORT_BYTES||state==TELEMETRY_WAIT','state==STATS_WAIT||state==TELEMETRY_WAIT');rep("state==STATS_WAIT?8'd1:export_type","8'd1");rep("(state==STATS_WAIT||state==TELEMETRY_WAIT)?32'd256:(export_type==2?32'd230400:32'd115200)","32'd256")
rep('  if(pair_hold&&state==EXPORT_READ_WAIT)$fatal(1,"PAIR_SHARED_BUFFER_LEGACY_COLLISION");','  if(pair_selected&&publication_accept)$fatal(1,"PAIR_PUBLICATION_SELECTION_SAME_EDGE");\n  if(pair_leased[3]||pair_leased[1])$fatal(1,"PAIR_ONLY_UART_OWNER_NONZERO");')
rep("  if(state>=EXPORT_START&&state<=EXPORT_FINISH)begin read_permission[class_slot?1:0]=1;read_permission[latest_slot?5:4]=1;end",'')
for x in ['exported<=0;','export_age<=0;','export_type<=2;','uart_token<=0;','uart_owned<=0;','uart_release<=0;','uart_cleanup_report<=0;']:
 rep(x,'')
rep('   if(export_active)export_age<=export_age+1\'b1;','')
rep('      else if(!exported&&latest_valid&&!eng_failed&&!job_failed)begin export_type<=2;uart_token<=uart_token+1\'b1;state<=UART_ACQUIRE;export_age<=0;end','') if 'else if(!exported' in s and 'export_type<=2;' in s else None
# Reset substitutions also removed pieces of this obsolete branch; remove whole remaining line.
s='\n'.join(line for line in s.split('\n') if 'else if(!exported&&latest_valid' not in line)
a=s.index('    UART_ACQUIRE:');z=s.index('    FAULT_REPORT:',a);s=s[:a]+s[z:]
s='\n'.join(line for line in s.split('\n') if 'if(export_timeout&&!tx_busy)' not in line)
assert not re.search(r'\b(?:uart_owned|uart_release|uart_token|exported|export_age|export_type|EXPORT_READ|UART_WAIT)\b',s)
p.write_text(s)
def rec(q):b=q.read_bytes();return dict(path=q.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
(F/'DERIVATION.json').write_text(json.dumps(dict(status='IMPLEMENTED_PENDING_TEST',before=rec(F/'backend_before.sv'),after=rec(p),freeze=rec(R/'reports/m5c_pair_capture_20261016/WORK_PAIR_ONLY_UART_AMENDMENT.md'),scope='Only independent backend; retain originalstats/fulltuple/fusionowner/transfer/controller. Oldproductionreadonly. Newprofile1/4/6..10,no2/3/5.'),indent=2));print(rec(p))
