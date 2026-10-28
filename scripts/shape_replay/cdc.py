from common import *
W=R/json.loads((O/'ACTIVE_PHYSICAL.json').read_text())['path']
raw=re.sub(r'/\*.*?\*/','',(P/'outflow/Ti60_Demo.map.v').read_text().split('endmodule',1)[0],flags=re.S)
cells={m[2].lstrip('\\'):dict(re.findall(r'\.(\w+)\s*\(([^()]*)\)',m[3])) for m in re.finditer(r'^    (EFX_\w+)\s+(\\\S+|\w+)\s+\((.*?)\)\s*;',raw,re.M|re.S)}
def net(x):return re.sub(r'\s+','',x).lstrip('\\')
def family(prefix,port):return sorted(n+'|'+port for n in cells if n.startswith(prefix) and n.endswith('~FF') and port in cells[n])
pins={n+'|'+p for n,ps in cells.items() for p in ps};drivers={net(ps['Q']):n for n,ps in cells.items() if 'Q' in ps and 'CLK' in ps}
lutdrivers={net(ps['O']):n for n,ps in cells.items() if 'O' in ps and 'I0' in ps}
groups=[];rules=[];proof=[]
def group(label,ps):
 ps=sorted(set(ps));assert ps,label
 assert all(p in pins for p in ps),(label,[p for p in ps if p not in pins])
 groups.append(dict(name=label,pins=ps,clocks={p:net(cells[p.rsplit('|',1)[0]]['CLK']) for p in ps}));return '$'+label
def bounded(label,source,dest):
 a=group(label+'_source',source);b=group(label+'_dest',dest)
 rules.extend([f'set_max_delay -from {a} -to {b} 5.0',f'set_false_path -hold -from {a} -to {b}'])
for fifo in ('camera_fifo','display_fifo'):
 for p,g in [('rgs1','rg'),('wgs1','wg')]:
  ds=family('u_shape_system/u_m5b1/video/'+fifo+'/'+p+'[','D');ss=[]
  for pin in ds:
   d=pin.rsplit('|',1)[0];lut=lutdrivers[net(cells[d]['D'])];lp=cells[lut]
   assert re.search(r'defparam\s+'+re.escape(lut)+r"\.LUTMASK\s*=\s*16'h8888;",raw),(pin,lut)
   ready_index=(0 if g=='rg' else 1) if fifo=='camera_fifo' else (2 if g=='rg' else 3)
   reset_net='u_shape_system/u_m5b1/fifo_ready['+str(ready_index)+']'
   ins=[net(lp['I0']),net(lp['I1'])];assert ins.count(reset_net)==1,(pin,lp)
   pointer_net=next(v for v in ins if v!=reset_net)
   src=drivers.get(pointer_net);bit=int(re.search(r'\[(\d+)\]~FF$',d)[1])
   expected='u_shape_system/u_m5b1/video/'+fifo+'/'+g+'['+str(bit)+']~FF'
   binary='u_shape_system/u_m5b1/video/'+fifo+'/'+('rp' if g=='rg' else 'wp')+'[9]~FF'
   assert src==expected or (bit==9 and src==binary),(pin,src)
   ss.append(src+'|CLK');proof.append(dict(destination=pin,source=src+'|CLK',direct_Q_to_D=False,reset_gate=lut,LUTMASK='8888',gate_I0=net(lp['I0']),gate_I1=net(lp['I1']),gray_bit=bit,msb_binary_alias=(src==binary),identity='D=registered_Gray_bit AND receiver_reset_ready; Gray[9]=Binary[9]. While receiver ready D equals registered Gray; no ordinary binary lower bit included.',launch_clock=net(cells[src]['CLK']),capture_clock=net(cells[d]['CLK'])))
  bounded(fifo+'_'+p,ss,ds)
for name,dest in [('eof_box','eof_count'),('offer_box','offer_payload')]:
 ds=family('u_shape_system/u_m5b1/video/'+dest+'[','D');ss=[]
 for p in ds:
  d=p.rsplit('|',1)[0];n=drivers.get(net(cells[d]['D']));assert n and n.startswith('u_shape_system/u_m5b1/video/'+name+'/held['),(p,n)
  ss.append(n+'|CLK');proof.append(dict(destination=p,source=n+'|CLK',direct_Q_to_D=True,launch_clock=net(cells[n]['CLK']),capture_clock=net(cells[d]['CLK'])))
 bounded(name,ss,ds)
ds=family('u_shape_system/view_data[','D');ss=[]
for pin in ds:
 d=pin.rsplit('|',1)[0];src=drivers.get(net(cells[d]['D']))
 assert src and src.startswith('u_shape_system/view_box/held['),(pin,src)
 assert net(cells[src]['CLK'])=='clk_sys' and net(cells[d]['CLK'])=='clk_pixel'
 ss.append(src+'|CLK');proof.append(dict(destination=pin,source=src+'|CLK',direct_Q_to_D=True,launch_clock='clk_sys',capture_clock='clk_pixel',protocol='Held2bit view index with request/ack mailbox; pixel takes only at SOF'))
bounded('view_box',ss,ds)
first=[];resets=[]
for n,ps in cells.items():
 if n.startswith('u_shape_system/u_m5b1/video/'):
  if re.search(r'/(?:req_sync|ack_sync)\[0\]~FF$',n):first.append(n+'|D')
  if re.search(r'/(?:cam_run|pix_run|cf|pf|camera_over_sync|display_under_sync)\[0\]~FF$',n):first.append(n+'|D')
  if re.search(r'/(?:srelease|drelease|crelease|prelease|wrs|rrs)\[\d+\]~FF$',n):resets.append(n+'|SR')
 if re.match(r'u_shape_system/u_m5b1/fifo_ready\[\d+\]~FF$',n):resets.append(n+'|SR')
 if re.match(r'm5b1_cam_reset\[\d+\]~FF$',n):resets.append(n+'|SR')
 if re.match(r'u_shape_system/fault_sync\[0\]~FF$',n):first.append(n+'|D')
 if n.startswith('u_shape_system/view_box/'):
  if re.search(r'/(?:req_sync|ack_sync)\[0\]~FF$',n):first.append(n+'|D')
  if re.search(r'/(?:srelease|drelease)\[\d+\]~FF$',n):resets.append(n+'|SR')
 if n=='u_shape_system/u_m5b1/bridge/rs[0]~FF':first.append(n+'|D')
rules.append('set_false_path -to '+group('replay_first_stage',first))
rules.append('set_false_path -to '+group('replay_reset_release',resets))
for k in range(2):rules.append('set_false_path -from [get_ports {key_n['+str(k)+']}] -to '+group('replay_key'+str(k),['u_shape_system/u_controls/key_meta['+str(k)+']~FF|D']))
body='''# Replay exact CDC; no clock-wide false paths. Same 5ns pointer/bundle budget.
proc replay_exact {selectors label} {
 set result {}
 foreach selector $selectors {
  set one [get_pins -regexp $selector]
  if {[llength $one]!=1} {error "REPLAY_EXACT_MISSING $label $selector"}
  set result [concat $result $one]
 }
 return $result
}
'''
for g in groups:body+='set '+g['name']+' [replay_exact {\n'+''.join(' {'+'^'+re.escape(p)+'$'+'}\n' for p in g['pins'])+'} '+g['name']+']\n'
body+='\n'.join(rules)+'\n'
s=(P/'Ti60_Demo_I3.sdc').read_text().split('# REPLAY_EXACT_CDC_INSERT')[0]+'# REPLAY_EXACT_CDC_INSERT\n'+body;put(P/'Ti60_Demo_I3.sdc',s)
save(W/'EXACT_CDC_BINDING.json',dict(passed=True,groups=groups,held_data_proof=proof,map=rec(P/'outflow/Ti60_Demo.map.v'),sdc=rec(P/'Ti60_Demo_I3.sdc')))
print('CDC_GROUPS',len(groups),'PINS',sum(len(g['pins']) for g in groups),'HELD',len(proof),flush=True)
