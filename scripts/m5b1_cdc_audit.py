"""Structural CDC audit of mapped FF/SRL/RAM ports, including CE and SR.

This supplements (never replaces) final physical STA. Unknown fanin is exposed
explicitly. RAM data is a clock-domain boundary only for reviewed FIFO memories.
"""
from pathlib import Path
import re,json,hashlib,collections,functools
R=Path(__file__).resolve().parents[1];O=R/'reports/m5b1_global_canny_i3/review_fix_264962e0/final';P=R/'efinity/m5b1_global_canny_i3/outflow/Ti60_Demo.map.v'
def main():
 raw=P.read_bytes();s=re.sub(r'/\*.*?\*/','',raw.decode(),flags=re.S);widths={}
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
  else:raise AssertionError(('unknown primitive',kind))
 for m in re.finditer(r'^    assign\s+(.*?)\s*=\s*(.*?)\s*;',s,re.M|re.S):
  lhs,rhs=bits(m[1]),bits(m[2]);assert len(lhs)==len(rhs),(m.group(),len(lhs),len(rhs))
  for a,b in zip(lhs,rhs):graph[a]=[b]
 @functools.lru_cache(None)
 def origins(net,depth=0):
  if net in constants:return frozenset()
  if net in drivers:return frozenset([drivers[net]])
  if depth>=80:return frozenset([('UNKNOWN_DEPTH',net,'unknown')])
  if net not in graph:return frozenset([('UNDRIVEN_OR_PRIMARY',net,'unknown')])
  return frozenset(v for n in graph[net] for v in origins(n,depth+1))
 manifest=json.loads((O/'CDC_PIN_MANIFEST.json').read_text());assert hashlib.sha256(raw).hexdigest()==manifest['map_sha256']
 allowed={p for v in manifest['groups'].values() for p in v if p.endswith(('|D','|SR'))};cross=[];unknown=[];ram=[];checked=collections.Counter();new_srl=[]
 for kind,name,ports in cells:
  new=name.startswith(('u_m5b1/','m5b1_cam_reset['));crop=name.startswith('u_Sensor_Image_XYCrop/')
  if not new and not crop:continue
  if kind in ('EFX_LUT4','EFX_ADD'):continue
  if kind=='EFX_SRL8':new_srl.append(name)
  if kind=='EFX_RAM10':
   wc,rc=ports['WCLK'][0],ports['RCLK'][0];ram.append(dict(name=name,write_clock=wc,read_clock=rc))
   rules={k:wc for k in ('WCLKE','WE','WADDREN','WDATA','WADDR')};rules.update({k:rc for k in ('RE','RST','RADDREN','RADDR')})
  else:rules={k:ports['CLK'][0] for k in ('D','CE','SR','A')}
  for pin,clk in rules.items():
   if pin not in ports:continue
   checked[kind+'|'+pin]+=len(ports[pin]);sources=set(v for net in ports[pin] for v in origins(net));foreign=sorted(v for v in sources if v[0]!=clk and not v[0].startswith(('UNKNOWN','UNDRIVEN')));unk=sorted(v for v in sources if v[0].startswith(('UNKNOWN','UNDRIVEN')))
   endpoint=name+'|'+pin
   if foreign:cross.append(dict(endpoint=endpoint,destination_clock=clk,sources=foreign,approved=endpoint in allowed))
   if unk:unknown.append(dict(endpoint=endpoint,pin=pin,sources=unk))
 assert not new_srl,new_srl
 assert len(ram)==35 and sum(r['write_clock']!=r['read_clock'] for r in ram)==21,ram
 for r in ram:
  if 'fifo/' in r['name']:assert r['write_clock']!=r['read_clock']
  else:assert r['write_clock']==r['read_clock']=='clk_sys'
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
 result=dict(map=dict(path=P.relative_to(R).as_posix(),bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest()),primitive_counts=dict(collections.Counter(k for k,_,_ in cells)),audited_ports=dict(checked),cross_domain=cross,unknown_fanin=list(summarized.values()),unknown_internal=[v for v in summarized.values() if v['category']=='UNKNOWN_INTERNAL'],unapproved_crossings=[v for v in cross if not v['approved']],ram=ram,new_srl=new_srl,scope='All new M5B1 FF/SRL/RAM D/CE/SR/address/data controls and isolated camera crop reset; LUT4/ADD/assign fanin. Primary/encrypted vendor boundaries remain explicit UNKNOWN, never silently safe. Vendor internals require the complete Efinity STA database.')
 (O/'CDC_STRUCTURAL_AUDIT.json').write_text(json.dumps(result,indent=2));print('CDC_STRUCTURE',len(cross),'crossings',len(unknown),'unknown',len(result['unapproved_crossings']),'unapproved',flush=True)
 assert not result['unapproved_crossings'],result['unapproved_crossings'][:10]
 assert not result['unknown_internal'],result['unknown_internal']
if __name__=='__main__':main()
