from common import *
s=(R/'efinity/gaussian_shape_cap_i3/Ti60_Demo_I3.sdc').read_text()
raw=re.sub(r'/\*.*?\*/','',(P/'outflow/Ti60_Demo.map.v').read_text().split('endmodule',1)[0],flags=re.S)
cells={m[2].lstrip('\\'):dict(re.findall(r'\.(\w+)\s*\(([^()]*)\)',m[3])) for m in re.finditer(r'^    (EFX_\w+)\s+(\\\S+|\w+)\s+\((.*?)\)\s*;',raw,re.M|re.S)}
pins={n+'|'+p for n,ps in cells.items() for p in ps};records=[];removed=[]
def sel(pin):return '^'+re.escape(pin)+'$'
def family(prefix,port):return sorted(n+'|'+port for n in cells if n.startswith(prefix) and n.endswith('~FF') and port in cells[n])
# Synthesis coalesces repeated descriptor fields and renames the formerly
# exported telemetry_descriptor to its retained source active_descriptor.
# Enumerate the entire SAME held-data bundles in this actual fresh netlist.
bundles={
 'm5c1b_held_0_source':family('u_m5b1/background/capture/descriptor_box/held[','CLK'),
 'm5c1b_held_0_destination':family('u_m5b1/background/cap_descriptor[','D'),
 'm5c1b_held_1_source':family('u_m5b1/fusion/active_descriptor[','CLK')+family('u_m5b1/fusion/active_session[','CLK'),
 'm5c1b_held_1_destination':family('fusion_descriptor[','D')+family('fusion_session[','D')}
assert all(bundles.values()),{k:len(v) for k,v in bundles.items()}
def net(s):return re.sub(r'\s+','',s).lstrip('\\')
drivers={net(ps['Q']):n for n,ps in cells.items() if 'Q' in ps and 'CLK' in ps and n.endswith('~FF')}
types={m[2].lstrip('\\'):m[1] for m in re.finditer(r'^    (EFX_\w+)\s+(\\\S+|\w+)\s+\((.*?)\)\s*;',raw,re.M|re.S)}
def canonical(i):
 for low,high,target in [(512,575,192),(672,735,384),(624,631,256),(616,623,264),(602,603,309),(615,615,272),(612,614,273)]:
  if low<=i<=high:return target+i-low
 return i
def field(cell):
 i=int(re.search(r'\[(\d+)\]~FF$',cell)[1])
 if 'session[' in cell:return ('session',i)
 if 'lease_identity[' in cell:i=([448,384,64,128,0][i//64])+i%64
 return ('descriptor',canonical(i))
proof=[];launch=[]
for pin in bundles['m5c1b_held_1_destination']:
 dest=pin.rsplit('|',1)[0];dnet=net(cells[dest]['D']);src=drivers.get(dnet)
 assert src and src.startswith(('u_m5b1/fusion/active_descriptor[','u_m5b1/fusion/active_session[','u_m5b1/lease_identity[')),(dest,dnet,src)
 assert net(cells[src]['CLK'])=='clk_sys',(src,cells[src]['CLK'])
 assert net(cells[dest]['CLK'])=='clk_pixel',(dest,cells[dest]['CLK'])
 assert types[src]=='EFX_FF' and types[dest]=='EFX_FF',(src,dest)
 assert field(src)==field(dest),(src,field(src),dest,field(dest))
 launch.append(src+'|CLK');proof.append(dict(destination=pin,data_net=dnet,source=src+'|CLK',source_cell_type=types[src],destination_cell_type=types[dest],canonical_held_field=field(src),field_equivalence=True,direct_Q_to_D=True,source_clock='clk_sys',destination_clock='clk_pixel'))
bundles['m5c1b_held_1_source']=sorted(set(launch))
save(O/'OFFER_BUNDLE_DIRECT_DRIVERS.json',dict(passed=True,map=rec(P/'outflow/Ti60_Demo.map.v'),paths=proof,launch_count=len(set(launch))))
def replace(m):
 name=m[1];pats=re.findall(r'\{(\^.*?)\}',m[2]);before=[re.sub(r'\\(.)',r'\1',p[1:-1]) for p in pats]
 if name in bundles:
  kept=bundles[name];reason='Re-enumerate identical held-data bundle after net alias coalescing; all endpoints exact, max delay remains5ns'
 else:
  kept=[p for p in before if p in pins];missing=[p for p in before if p not in pins]
  for p in missing:
   assert name.startswith('pair_') or '/telemetry/' in p or p in ['u_m5b1/background/capture/over_sync[0]~FF|D','u_m5b1/background/dropped_sync[0]~FF|D','u_m5b1/video/camera_over_sync[0]~FF|D','u_m5b1/video/display_under_sync[0]~FF|D'],(name,p)
  reason='Only absent removed pair/telemetry or unconsumed diagnostics; retained synchronizers unchanged'
 records.append(dict(name=name,before=before,after=kept,reason=reason))
 if not kept:removed.append(name);return '# Removed diagnostic group '+name
 assert all(p in pins for p in kept)
 return 'set '+name+' [m5b1_exact {\n'+''.join(' {'+sel(p)+'}\n' for p in sorted(set(kept)))+'} '+m[3]+']'
s=re.sub(r'set (\w+) \[m5b1_exact \{(.*?)\}\s*(\w+)\]',replace,s,flags=re.S)
lines=[]
for l in s.splitlines():
 if l.startswith(('set_max_delay','set_false_path')) and any(re.search(r'\$'+re.escape(n)+r'\b',l) for n in removed):continue
 lines.append(l)
s='\n'.join(lines)+'\n';(P/'Ti60_Demo_I3.sdc').write_text(s)
save(O/'EXACT_CDC_BINDING.json',dict(passed=True,map=rec(P/'outflow/Ti60_Demo.map.v'),parent_sdc=rec(R/'efinity/gaussian_shape_cap_i3/Ti60_Demo_I3.sdc'),sdc=rec(P/'Ti60_Demo_I3.sdc'),groups=records,removed=removed))
print('CDC_BINDING',len(records),len(removed),sum(len(x['after']) for x in records))
