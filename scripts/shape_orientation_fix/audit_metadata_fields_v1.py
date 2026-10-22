from standalone_physical_runtime import *
F,P=active();c=json.loads((F/'MAPPED_ALL_CELLS.json').read_text());cones=json.loads((F/'STANDALONE_PIXEL_MAPPED_CONES_V2.json').read_text());rows={r['pin']:r for r in cones['records']};assert not cones['unknown'];native={k:v.strip('{}')for k,v in(line.rstrip('\n').split('\t',1)for line in(P/'typed_native_connections.tsv').open())};fifo={};current={}
for name,x in c.items():
 if x['type']!='EFX_FF':continue
 m=re.search(r'/u_shape/tags(?:_\d+)?\[(\d+)\]\[(\d+)\]~FF$',name)
 if m:assert(int(m[1]),int(m[2]))not in fifo;fifo[int(m[1]),int(m[2])]=name
 m=re.search(r'/u_shape/current_tag\[(\d+)\]~FF$',name)
 if m:assert int(m[1])not in current;current[int(m[1])]=name
used=set(range(128))|{128}|set(range(192,256));assert len(fifo)==386 and len(current)==193 and set(current)==used and set(fifo)=={(slot,b)for slot in[0,1]for b in used}
def source(bit):return 'u_shape_system/'+(f'standalone_sequence[{bit}]'if bit<64 else f'source_generation[{bit-64}]'if bit<128 else'm5b1_lcd_epoch[0]'if bit==128 else f'm5b1_lcd_frame_id[{bit-192}]')
def field(bit):return 'display_seq'if bit<64 else'config_generation'if bit<128 else'epoch'if bit<192 else'frame_id'
proof=[];cp=[]
for(slot,bit),name in sorted(fifo.items()):
 x=c[name];assert x['ports']['D']==native[name+'|D']==source(bit);assert x['ports']['CLK']==native[name+'|CLK']=='clk_pixel';assert x['ports']['Q']==native[name+'|Q']
 for k in['D','CE','SR']:
  row=rows[name+'|'+k];assert row['classification']in['SAME_CLOCK','CONSTANT']and all(r[0]=='clk_pixel'for r in row['roots'])
 proof.append(dict(slot=slot,bit=bit,field=field(bit),cell=name,source_net=source(bit),native={k:native[name+'|'+k]for k in['D','CE','SR','CLK','Q']}))
for bit,name in sorted(current.items()):
 assert native[name+'|CLK']=='clk_pixel'
 for k in['D','CE','SR']:
  row=rows[name+'|'+k];assert row['classification']in['SAME_CLOCK','CONSTANT']and all(r[0]=='clk_pixel'for r in row['roots'])
 roots={r[1]for r in rows[name+'|D']['roots']};required={fifo[s,bit]for s in[0,1]};assert required<=roots
 cp.append(dict(bit=bit,field=field(bit),cell=name,both_slot_sources=sorted(required),native={k:native[name+'|'+k]for k in['D','CE','SR','CLK','Q']}))
Q=R/'rtl/shape_standalone';system=Q/'shape_standalone_system.sv';front=Q/'frontend/shape_standalone_frontend.sv';stop=Q/'frontend/m5b1_failstop.sv';adapter=Q/'shape/shape_stream_adapter_contract_v2.sv';s=system.read_text();f=front.read_text();z=stop.read_text();a=adapter.read_text();assert'assign display_seq=standalone_sequence'in s and'.source_display_seq(display_seq)'in s and'config_generation!=64\'hffffffffffffffff'in s
assert'.source_frame_id(m5b1_lcd_frame_id),.source_epoch(m5b1_lcd_epoch),.source_config(source_generation),.source_display_seq(display_seq)'in s
assert'm5b1_lcd_epoch<=m5b1_epoch'in s and'.epoch(m5b1_epoch)'in s and'.epoch(epoch)'in f and"assign epoch=64'd1"in z and'incoming_tag={source_frame_id,source_epoch,source_config,source_display_seq}'in a
save(F/'METADATA_FIELD_MAPPING.json',dict(passed=True,status='PASS_COMPLETE_NEW_STANDALONE579_METADATA_FF_SOURCE_AND_NATIVE_CONES_TIMING_PENDING',fifo_FFs=386,current_tag_FFs=193,fifo=proof,current_tag=cp,constant_fifo_bits=[dict(slot=slot,bit=b,field='epoch',constant=0)for slot in[0,1]for b in range(129,192)],constant_current_tag_bits=list(range(129,192)),source_bindings=[rec(p)for p in[system,front,stop,adapter]],bindings=[rec(P/'outflow/Ti60_Demo.map.v'),rec(P/'typed_native_connections.tsv'),rec(F/'STANDALONE_PIXEL_MAPPED_CONES_V2.json')],unknown=[]));print('STANDALONE579_METADATA_SOURCE_NATIVE_PASS',flush=True)
