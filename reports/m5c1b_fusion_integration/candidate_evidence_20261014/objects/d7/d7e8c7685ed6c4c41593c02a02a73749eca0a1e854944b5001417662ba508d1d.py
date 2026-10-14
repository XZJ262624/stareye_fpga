"""Structural CDC audit of mapped FF/SRL/RAM ports, including CE and SR.

This supplements (never replaces) final physical STA. Unknown fanin is exposed
explicitly. RAM data is a clock-domain boundary only for reviewed FIFO memories.
"""
from pathlib import Path
import re,json,hashlib,collections,functools,time,sys
sys.setrecursionlimit(10000)
R=Path('F:/Projects/stareye_fpga');B=Path(__file__).resolve().parent;O=B/sys.argv[1];P=B/'mirror/efinity/m5c_fusion_i3/outflow/Ti60_Demo.map.v'

if len(sys.argv)>2:P=Path(sys.argv[2]).resolve()

def main():
 O.mkdir(exist_ok=False)
 (O/'runner_at_start.py').write_bytes(Path(__file__).read_bytes())
 raw=P.read_bytes();s=re.sub(r'/\*.*?\*/','',raw.decode(),flags=re.S);widths={}
 physical_ram={};timing_binding=None
 if '--timing-db' in sys.argv:
  db=Path(sys.argv[sys.argv.index('--timing-db')+1]);binding=json.loads((db/'RESULT.json').read_text())
  assert binding['inputs']['outflow/Ti60_Demo.map.v']==dict(bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest()),'Timing DB map mismatch'
  netfile=db/'database/m5c1b_telemetry_pin_nets.txt'
  for line in netfile.read_text().splitlines():
   physical_pin,net=line.split('\t');physical_ram.setdefault((physical_pin.split('|')[0],net),[]).append(physical_pin)
  timing_binding=dict(result=str(db/'RESULT.json'),pin_nets=str(netfile),sha256=hashlib.sha256(netfile.read_bytes()).hexdigest())
 for m in re.finditer(r'\b(?:wire|input|output)\s+\[(\d+):(\d+)\]\s*(.*?);',s,re.S):
  for n in m[3].split(','):widths[n.strip().lstrip('\\')]=(int(m[1]),int(m[2]))
 def bits(expr):
  expr=expr.strip()
  if expr.startswith('{') and expr.endswith('}'):return [b for x in expr[1:-1].split(',') for b in bits(x)]
  m=re.fullmatch(r"(\d+)'[bhd][0-9a-fxXzZ]+",expr)
  if m:return ['CONST']*int(m[1])
  if re.fullmatch(r'\d+',expr):return ['CONST']
  m=re.fullmatch(r'(\\\S+\s+|[a-zA-Z_$][\w$]*)(?:\[(\d+)(?::(\d+))?\])?',expr+' ' if expr.startswith('\\') and not re.search(r'\s',expr) else expr)
  if not m:raise AssertionError(('unparsed expression',expr))
  n=m[1].strip().lstrip('\\')
  if m[2] is not None:
   hi=int(m[2]);lo=int(m[3] or m[2]);return [f'{n}[{i}]' for i in range(hi,lo+(-1 if hi>=lo else 1),-1 if hi>=lo else 1)]
  if n in widths:
   hi,lo=widths[n];return [f'{n}[{i}]' for i in range(hi,lo-1,-1)]
  return [n]
 cells=[];drivers={};graph={};constants={'CONST'}
 for m in re.finditer(r'^    (EFX_\w+)\s+(\\\S+|\w+)\s+\((.*?)\)\s*;',s,re.M|re.S):
  kind,name,body=m.groups();ports={k:bits(v) for k,v in re.findall(r'\.(\w+)\((.*?)\)',body,re.S)};name=name.lstrip('\\');cells.append((kind,name,ports))
  if kind in ('EFX_LUT4','EFX_ADD'):
   ins=[b for k,v in ports.items() if k in ('I0','I1','I2','I3','CI') for b in v]
   for pin in ('O','CO'):
    for net in ports.get(pin,[]):graph[net]=ins
  elif kind in ('EFX_FF','EFX_SRL8','EFX_RAM10'):
   out='RDATA' if kind=='EFX_RAM10' else 'Q';clk=ports['RCLK' if kind=='EFX_RAM10' else 'CLK'][0]
   for net in ports.get(out,[]):drivers[net]=(clk,name,kind)
  elif kind=='EFX_DPRAM10':
   for side in ('A','B'):
    for net in ports.get('RDATA'+side,[]):drivers[net]=(ports['CLK'+side][0],name,kind)
  elif kind=='EFX_DSP48':
   # Audit every data/control input as well; registered or combinational DSP
   # output does not hide an asynchronous input behind a nominal clock label.
   for net in ports.get('O',[]):drivers[net]=(ports['CLK'][0],name,kind)
  else:
   if kind not in ('EFX_DSP48',):raise AssertionError(('unknown primitive',kind))
 for m in re.finditer(r'^    assign\s+(.*?)\s*=\s*(.*?)\s*;',s,re.M|re.S):
  lhs,rhs=bits(m[1]),bits(m[2]);assert len(lhs)==len(rhs),(m.group(),len(lhs),len(rhs))
  for a,b in zip(lhs,rhs):graph[a]=[b]
 @functools.lru_cache(None)
 def origins(net,depth=0):
  if net in constants:return frozenset()
  if net in drivers:return frozenset([drivers[net]])
  if depth>=512:return frozenset([('UNKNOWN_DEPTH',net,'unknown')])
  if net not in graph:return frozenset([('UNDRIVEN_OR_PRIMARY',net,'unknown')])
  return frozenset(v for n in graph[net] for v in origins(n,depth+1))
 manifest=json.loads((R/'reports/m5b1_global_canny_i3/review_fix_264962e0/final/CDC_PIN_MANIFEST.json').read_text()) # old exact endpoint whitelist is only the starting discovery baseline
 allowed={p for v in manifest['groups'].values() for p in v if p.endswith(('|D','|SR'))};cross=[];unknown=[];ram=[];checked=collections.Counter();new_srl=[]
 for kind,name,ports in cells:
  new=name.startswith(('u_m5b1/','m5b1_cam_reset[','u_fusion_display/','fusion_'));crop=name.startswith('u_Sensor_Image_XYCrop/')
  if not new and not crop:continue
  if kind in ('EFX_LUT4','EFX_ADD'):continue
  if kind=='EFX_SRL8':new_srl.append(name)
  if kind=='EFX_DSP48':
   rules={k:ports['CLK'][0] for k in ('A','B','C','CASCIN','OP','SHIFT_ENA','CE','RST')}
  elif kind=='EFX_DPRAM10':
   ram.append(dict(name=name,write_clock=ports['CLKA'][0],read_clock=ports['CLKB'][0],kind=kind))
   rules={k+side:ports['CLK'+side][0] for side in ('A','B') for k in ('CLKE','WE','RST','ADDREN','WDATA','ADDR')}
  elif kind=='EFX_RAM10':
   wc,rc=ports['WCLK'][0],ports['RCLK'][0];ram.append(dict(name=name,write_clock=wc,read_clock=rc))
   rules={k:wc for k in ('WCLKE','WE','WADDREN','WDATA','WADDR')};rules.update({k:rc for k in ('RE','RST','RADDREN','RADDR')})
  else:rules={k:ports['CLK'][0] for k in ('D','CE','SR','A')}
  for pin,clk in rules.items():
   if pin not in ports:continue
   checked[kind+'|'+pin]+=len(ports[pin])
   # Mapped concatenations are MSB first; timing DB exposes vector bit ports.
   # Keep each bit's actual source cone rather than an aggregate RAM WDATA pin.
   for bit_index,net in enumerate(reversed(ports[pin])):
    sources=set(origins(net));foreign=sorted(v for v in sources if v[0]!=clk and not v[0].startswith(('UNKNOWN','UNDRIVEN')));unk=sorted(v for v in sources if v[0].startswith(('UNKNOWN','UNDRIVEN')))
    endpoint=name+'|'+pin+(f'[{bit_index}]' if len(ports[pin])>1 else '')
    if foreign and physical_ram and pin=='WDATA' and name.startswith('u_m5b1/telemetry/mem'):
     actual=physical_ram.get((name,net),[]);assert len(actual)==1,('RAM physical pin resolution',name,net,actual)
     endpoint=actual[0]
    if foreign:cross.append(dict(endpoint=endpoint,destination_clock=clk,sources=foreign,approved=endpoint in allowed))
    if unk:unknown.append(dict(endpoint=endpoint,pin=pin,sources=unk))
 # Discovery records every new RAM/SRL. No blanket CDC exemption is applied.
 for row in ram:
  row['reviewed_boundary_kind']='fifo' if 'fifo/' in row['name'] else 'fusion_cache' if '/fusion/cache/' in row['name'] else 'same_domain' if row['write_clock']==row['read_clock'] else 'UNREVIEWED'
 # Encrypted vendor cells intentionally hide their internal mapped drivers.
 # Retain that boundary as UNKNOWN, with exact affected count and examples.
 protected=re.search(r'protected_cell protected_inst\s*\((.*?)\)\s*;',s,re.S)
 protected_nets=set(b for _,v in re.findall(r'\.(\\\S+\s+|\w+)\((.*?)\)',protected[1],re.S) for b in bits(v)) if protected else set()
 summarized={}
 for row in unknown:
  for state,net,kind in row['sources']:
   key=state+':'+net
   category='ENCRYPTED_VENDOR_BOUNDARY' if net in protected_nets else 'PRIMARY_ASYNC_PLL_STATUS' if net in ('sys_pll_lock','ddr_pll_lock','dsi_pll_lock','lvds_pll_lock') else 'CONSTRAINED_CAMERA_INPUT' if net in ('cmos_href','cmos_vsync') else 'UNKNOWN_INTERNAL'
   v=summarized.setdefault(key,dict(net=net,category=category,affected_endpoints=0,examples=[]));v['affected_endpoints']+=1
   if len(v['examples'])<3:v['examples'].append(row['endpoint'])
 result=dict(map=dict(path=P.relative_to(R).as_posix(),bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest()),primitive_counts=dict(collections.Counter(k for k,_,_ in cells)),audited_ports=dict(checked),cross_domain=cross,unknown_fanin=list(summarized.values()),unknown_internal=[v for v in summarized.values() if v['category']=='UNKNOWN_INTERNAL'],unapproved_crossings=[v for v in cross if not v['approved']],ram=ram,new_srl=new_srl,status='PENDING_EXACT_NEW_ENDPOINT_REVIEW',scope='All new M5C1B FF/SRL/RAM D/CE/SR/address/data controls and isolated camera crop reset; LUT4/ADD/assign fanin. Primary/encrypted vendor boundaries remain explicit UNKNOWN, never silently safe. Vendor internals require the complete Efinity STA database.')
 # Inventory every telemetry sequential input cone, including UI-local RAM
 # ports. Cross-domain-only lists cannot prove absence of residual source
 # cones after retiming the snapshot into UI registers.
 telemetry_cells=[];telemetry_inputs=[]
 for kind,name,ports in cells:
  if not name.startswith(('u_m5b1/telemetry','u_m5b1/fusion/','u_fusion_display/','fusion_')) or kind in ('EFX_LUT4','EFX_ADD'):continue
  telemetry_cells.append(dict(kind=kind,name=name,ports=ports))
  if kind=='EFX_RAM10':
   rules={k:ports['WCLK'][0] for k in ('WCLKE','WE','WADDREN','WDATA','WADDR')}
   rules.update({k:ports['RCLK'][0] for k in ('RE','RST','RADDREN','RADDR')})
  elif kind=='EFX_DPRAM10':rules={k+side:ports['CLK'+side][0] for side in ('A','B') for k in ('CLKE','WE','RST','ADDREN','WDATA','ADDR')}
  else:rules={k:ports['CLK'][0] for k in ('D','CE','SR','A')}
  for pin,clk in rules.items():
   for bit_index,net in enumerate(reversed(ports.get(pin,[]))):
    source=sorted(origins(net));endpoint=name+'|'+pin+(f'[{bit_index}]' if len(ports[pin])>1 else '')
    telemetry_inputs.append(dict(endpoint=endpoint,destination_clock=clk,net=net,sources=source,
     foreign=[v for v in source if v[0]!=clk and not v[0].startswith(('UNKNOWN','UNDRIVEN'))],
     unknown=[v for v in source if v[0].startswith(('UNKNOWN','UNDRIVEN'))]))
 telemetry_inventory=dict(status='MAPPED_INPUT_INVENTORY_NOT_PHYSICAL_STA',map=result['map'],cells=telemetry_cells,inputs=telemetry_inputs)
 (O/'SEQUENTIAL_BOUNDARIES.json').write_text(json.dumps(telemetry_inventory,indent=2))
 # Explicit logical-bit aliases and actual drivers: constants are distinguished from missing/unknown.
 logical={}
 mapped_constants={n:int(v) for n,v in re.findall(r'FF Output: (.+?)\(=([01])\)',P.with_suffix('.rpt').read_text())}
 used_nets={n for _,_,pp in cells for ns in pp.values() for n in ns}
 canonical_drivers={re.sub(r'^i\d+/','',n):n for n in drivers}
 specs=[('offered_descriptor','fusion_descriptor',768),('offered_SID','fusion_session',64),('capture_reply_SID','u_m5b1/fusion/cap_sid',64),('reader_nonce_alias','u_m5b1/fusion/commit_session',64),('reference_SID','fusion_ref_session',64),('display_dsession','u_fusion_display/dsession',64),('frame_cookie','u_fusion_display/fusion/frame_cookie',64),('accepted_descriptor','u_fusion_display/descriptor',768),('UI_active_descriptor','u_m5b1/telemetry_descriptor',768),('UI_active_SID','u_m5b1/telemetry_session',64),('lease_identity','u_m5b1/lease_identity',320)]
 for bank in range(8):
  specs += [(f'bank{bank}_source_row12',f'u_m5b1/fusion/cache/bank[{bank}].ready_box/held',12),(f'bank{bank}_destination_row12',f'u_m5b1/fusion/cache/row_tag[{bank}]',12)]
 for bank in range(4):specs.append((f'row_cookie{bank}',f'u_fusion_display/fusion/row_cookie[{bank}]',64))
 for label,base,width in specs:
  entries=[]
  for i in range(width):
   net=f'{base}[{i}]';resolved=canonical_drivers.get(net,net);source=sorted(origins(resolved));state='ACTIVE'
   if net in mapped_constants:state='OPTIMIZED_CONSTANT';source=[]
   elif source and any(v[0].startswith(('UNKNOWN','UNDRIVEN')) for v in source):state='UNUSED_LOGICAL_NAME' if net not in used_nets and net not in graph else 'UNKNOWN_USED'
   entries.append(dict(bit=i,net=net,resolved_net=resolved,sources=source,state=state,constant_value=mapped_constants.get(net)))
  logical[label]=dict(width=width,active=sum(bool(x['sources']) and not any(v[0].startswith(('UNKNOWN','UNDRIVEN')) for v in x['sources']) for x in entries),constant=sum(not x['sources'] for x in entries),unknown=sum(any(v[0].startswith(('UNKNOWN','UNDRIVEN')) for v in x['sources']) for x in entries),bits=entries,state_counts=dict(collections.Counter(x['state'] for x in entries)))
 logical['promotion']=dict(net='fusion_promoted',sources=sorted(origins('fusion_promoted')),immediate_fanin=graph.get('fusion_promoted'),immediate_consumers=[dict(net=n,inputs=v) for n,v in graph.items() if 'fusion_promoted' in v])
 (O/'LOGICAL_BIT_DRIVERS.json').write_text(json.dumps(dict(map=result['map'],logical=logical),indent=2))

 # Trace surviving combinational promotion fanout to actual sequential inputs.
 users=collections.defaultdict(list)
 for kind,name,pp in cells:
  for pin,ns in pp.items():
   if pin not in ('Q','O','CO','RDATA','RDATAA','RDATAB'):
    for n in ns:users[n].append((kind,name,pin,pp))
 queue=collections.deque(['fusion_promoted']);visited={'fusion_promoted'};reached=[]
 while queue:
  net=queue.popleft()
  for kind,name,pin,pp in users[net]:
   if kind in ('EFX_LUT4','EFX_ADD'):
    for outpin in ('O','CO'):
     for n in pp.get(outpin,[]):
      if n not in visited:visited.add(n);queue.append(n)
   else:reached.append(dict(kind=kind,cell=name,pin=pin,net=net))
 (O/'PROMOTION_FANOUT.json').write_text(json.dumps(dict(map=result['map'],promotion_immediate_fanin=graph.get('fusion_promoted'),visited_comb_nets=len(visited),sequential_endpoints=reached,rgb_endpoints=[x for x in reached if 'rgb' in x['cell'].lower()],note='Structural survival only, not reachability equivalence or physical timing'),indent=2))

 # Counter mapping may duplicate/factor the promotion LUT for RGB separately.
 rgb_rows=[]
 def ancestors(net):
  seen=set();todo=[net]
  while todo:
   n=todo.pop()
   if n in seen:continue
   seen.add(n);todo.extend(graph.get(n,[]))
  return seen
 prom_anc=ancestors('fusion_promoted')
 for kind,name,pp in cells:
  if kind!='EFX_FF' or not name.startswith('osd_rgb['):continue
  dest=pp['D'][0];anc=ancestors(dest);common=anc&prom_anc
  rgb_rows.append(dict(endpoint=name+'|D',data_net=dest,promotion_common_nets=sorted(common),common_registered_origins=sorted({drivers[n] for n in common if n in drivers}),promotion_immediate_inputs_shared=sorted(set(graph.get('fusion_promoted',[]))&common),all_registered_origins=sorted(origins(dest))))
 keys=['u_fusion_display/session','u_fusion_display/fusion/frame_ok','u_fusion_display/fusion/row_complete','u_fusion_display/fusion/frame_identity','u_fusion_display/fusion/frame_cookie','u_fusion_display/fusion/row_cookie','u_fusion_display/fusion/align','fusion_descriptor','fusion_session','u_m5b1/fusion/commit_session']
 key_cells={k:[dict(kind=t,name=n,ports=pp) for t,n,pp in cells if t=='EFX_FF' and (n.startswith(k+'[') or n==k+'~FF' or n.startswith(k+'/'))] for k in keys}
 alias_names=['u_m5b1/video/camera_fifo/rg[9]~FF','u_m5b1/video/camera_fifo/rp[9]~FF','u_m5b1/video/camera_fifo/rgs1[9]~FF']
 aliases=[dict(kind=t,name=n,ports=pp,d_origins=sorted({v for net in pp.get('D',[]) for v in origins(net)})) for t,n,pp in cells if n in alias_names]
 (O/'RGB_REFACTORED_CONE.json').write_text(json.dumps(dict(map=result['map'],promotion_graph={n:graph[n] for n in sorted(prom_anc) if n in graph},rgb=rgb_rows,key_cells=key_cells,camera_alias=aliases,note='Shared actual predicate cones, not exhaustive Boolean or physical timing proof; paired with source-bound finite pixel/UART proof.'),indent=2))

 # Proposed exact pin groups from reviewed mailbox/reset structures. These
 # do not become timing exceptions or CDC PASS merely by matching a name.
 groups=collections.defaultdict(list);unclassified=[]
 held_routes=[('u_m5b1/background/cap_descriptor[','u_m5b1/background/capture/descriptor_box/held['),
  ('u_m5b1/fusion/req_data[','u_m5b1/fusion/request_box/held['),
  ('u_m5b1/fusion/rel_data[','u_m5b1/fusion/release_box/held['),
  ('fusion_descriptor[','u_m5b1/fusion/offer_box/held['),('fusion_session[','u_m5b1/fusion/offer_box/held['),
  ('u_m5b1/telemetry/raw_stage[','u_m5b1/telemetry/held['),('u_m5b1/telemetry/source_guard[','u_m5b1/telemetry/held[')]
 for row in result['unapproved_crossings']:
  ep=row['endpoint'];sources=row['sources'];category=None
  # Reviewed telemetry bundled source. Enumerate only actual FF sampling/
  # enable and payload RAM write ports; no clock/reset/address exception.
  telemetry_endpoint=re.fullmatch(r'u_m5b1/(?:telemetry_ready~FF\|(?:D|CE)|telemetry_header\[\d+\]~FF\|(?:D|CE)|telemetry_fault~FF\|CE|telemetry/(?:word_index\[\d+\]~FF\|(?:D|CE)|mail_take~FF\|D|building~FF\|(?:D|CE)|frozen_(?:rejected_jobs|protocol_faults)\[\d+\]~FF\|CE|mem__D\$[\w]+\|(?:WE|WDATA)(?:\[\d+\])?))',ep)
  if telemetry_endpoint and all(v[1].startswith('u_m5b1/telemetry/held[') and v[2]=='EFX_FF' for v in sources):category='new_bundled_data'
  if ep.endswith('|D'):
   cap=re.fullmatch(r'u_m5b1/fusion/cap_sid\[(\d+)\]~FF\|D',ep)
   if cap and sources==[('clk_pixel',f'fusion_session[{cap[1]}]~FF','EFX_FF')]:category='new_bundled_data'
   toggle=re.fullmatch(r'u_m5b1/fusion/(cap_ack|cap_req|revoke_ack|revoke_req)_sync\[0\]~FF\|D',ep)
   if toggle and len(sources)==1 and sources[0][1]=='u_m5b1/fusion/'+toggle[1]+'~FF' and sources[0][2]=='EFX_FF':category='new_toggle_first_stage'
   status_sources={
    'u_m5b1/fusion/cap_drain_sync[0]~FF|D':{'u_m5b1/fusion/cap_ack_sync[1]~FF','u_m5b1/fusion/cap_req~FF','u_m5b1/fusion/cap_send_pending~FF'},
    'u_m5b1/fusion/context_fault_sync[0]~FF|D':{'fusion_context_tail_fault~FF','u_m5b1/fusion/context_protocol_fault~FF'}}
   if ep in status_sources and {v[1] for v in sources}==status_sources[ep] and all(v[0]=='clk_pixel' and v[2]=='EFX_FF' for v in sources):category='new_status_first_stage'
   if re.fullmatch(r'fusion_(?:descriptor|session)\[\d+\]~FF\|D',ep) and all(re.fullmatch(r'u_m5b1/(?:telemetry_descriptor|lease_identity|telemetry_session)\[\d+\]~FF',v[1]) and v[2]=='EFX_FF' for v in sources):category='new_bundled_data'
   for dst,src in held_routes:
    if ep.startswith(dst) and all(v[1].startswith(src) and v[2]=='EFX_FF' for v in sources):category='new_bundled_data'
   bank=re.match(r'u_m5b1/fusion/cache/row_tag\[(\d+)\]\[',ep)
   if bank and all(v[1].startswith(f'u_m5b1/fusion/cache/bank[{bank[1]}].ready_box/held[') and v[2]=='EFX_FF' for v in sources):category='new_bundled_data'
   if re.fullmatch(r'fusion_(?:export|ddr_error|hardstop|stop)_sync\[0\]~FF\|D',ep):category='new_status_first_stage'
   if ep=='u_m5b1/telemetry/inflight_sync[0]~FF|D':category='new_status_first_stage'
   m=re.fullmatch(r'(u_m5b1/(?:fusion|telemetry)/.+)/(req|ack)_sync\[0\]~FF\|D',ep)
   if m and all(v[1]==m[1]+'/'+m[2]+'~FF' and v[2]=='EFX_FF' for v in sources):category='new_toggle_first_stage'
  if ep.endswith('|SR') and re.search(r'/(?:srelease|drelease|pixel_release|offer_release)\[[01]\]~FF\|SR$',ep) and all(v[1]=='rstn_sys~FF' and v[2]=='EFX_FF' for v in sources):category='new_reset_release_async_entry'
  if category:groups[category].append(ep)
  else:unclassified.append(row)
 proposed=dict(status='CLASSIFIED_FOR_CONSTRAINT_REVIEW_NOT_CDC_PASS',map=result['map'],groups={k:sorted(v) for k,v in groups.items()},unclassified=unclassified,
  contract='Bundled source held remains immutable through destination acceptance/ack; constrain setup max_delay5ns and hold only. Only first-stage control D and explicit release-chain asynchronous SR entries are false-path candidates. Ordinary second-stage data/reset consumers are never blanket exceptions.')
 proposed['physical_ram_pin_resolution']=timing_binding
 indexed={n:(k,p) for k,n,p in cells};chains=[]
 roots={ep.split('|')[0].replace('[1]~FF','[0]~FF') for key in ('new_status_first_stage','new_toggle_first_stage','new_reset_release_async_entry') for ep in groups[key]}
 for first in sorted(roots):
  second=first.replace('[0]~FF','[1]~FF');fk,fp=indexed.get(first,('MISSING',{}));sk,sp=indexed.get(second,('MISSING',{}))
  fanin=set(v for net in sp.get('D',[]) for v in origins(net))
  chain_ok=fk==sk=='EFX_FF' and fp.get('CLK')==sp.get('CLK') and fanin=={(fp['CLK'][0],first,'EFX_FF')}
  chains.append(dict(first=first,second=second,first_kind=fk,second_kind=sk,second_d_sources=sorted(fanin),pass_distinct_same_clock_ffs=chain_ok))
 proposed['physical_release_and_sync_chains']=chains
 proposed['bad_physical_chains']=[v for v in chains if not v['pass_distinct_same_clock_ffs']]
 text=['# Proposed M5C1B exact CDC supplement. Apply only after bound input freeze ends.',
  '# Held-bus max delay5ns bounds bit arrival spread below a receiving period.',
  '# Request traverses two receiving FFs before valid/data capture; source holds',
  '# until destination take and synchronized ack. Hold exception is asynchronous only.',
  '# Ordinary released-reset consumer SR paths remain timed.']
 def pinlist(name,pins):
  text.append('set '+name+' [m5b1_exact {')
  text.extend(' {^'+re.escape(pin)+'$}' for pin in sorted(set(pins)))
  text.append('} '+name+']')
 def ep_is_cap(ep):return re.fullmatch(r'u_m5b1/fusion/cap_sid\[\d+\]~FF\|D',ep) is not None
 bundles=collections.defaultdict(lambda:dict(source=set(),destination=set()))
 for row in result['unapproved_crossings']:
  if row['endpoint'] not in groups['new_bundled_data']:continue
  owners=({'u_m5b1/fusion/actual_pix_offered_sid'} if ep_is_cap(row['endpoint']) else {'u_m5b1/fusion/active_tuple'} if re.fullmatch(r'fusion_(?:descriptor|session)\[\d+\]~FF\|D',row['endpoint']) else {v[1].split('/held[')[0] for v in row['sources']});assert len(owners)==1
  bundle=bundles[next(iter(owners))];bundle['destination'].add(row['endpoint'])
  # Installed Efinity STA exposes FF launch objects as CLK, as established by
  # baseline exact-pin timing reports; physical clock-to-Q+data is audited too.
  bundle['source'].update(v[1]+'|CLK' for v in row['sources'])
 for i,(owner,bundle) in enumerate(sorted(bundles.items())):
  name=f'm5c1b_held_{i}';text.append('# '+owner)
  pinlist(name+'_source',bundle['source']);pinlist(name+'_destination',bundle['destination'])
  text.append(f'set_max_delay -from ${name}_source -to ${name}_destination 5.0')
  text.append(f'set_false_path -hold -from ${name}_source -to ${name}_destination')
 for category in ('new_status_first_stage','new_toggle_first_stage','new_reset_release_async_entry'):
  name='m5c1b_'+category;pinlist(name,groups[category]);text.append('set_false_path -to $'+name)
 (O/'NEW_CDC_CONSTRAINTS_PROPOSED.sdc').write_text('\n'.join(text)+'\n')
 (O/'CANDIDATE_PIN_MANIFEST.json').write_text(json.dumps(proposed,indent=2))
 (O/'CDC_STRUCTURAL_AUDIT.json').write_text(json.dumps(result,indent=2));print('CDC_STRUCTURE',len(cross),'crossings',len(unknown),'unknown',len(result['unapproved_crossings']),'unapproved',flush=True)
 print('DISCOVERY_ONLY',O,'not CDC PASS',flush=True)
if __name__=='__main__':main()
