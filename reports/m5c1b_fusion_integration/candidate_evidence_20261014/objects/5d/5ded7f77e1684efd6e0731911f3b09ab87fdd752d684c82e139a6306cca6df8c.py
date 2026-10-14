"""Structural CDC audit of mapped FF/SRL/RAM ports, including CE and SR.

This supplements (never replaces) final physical STA. Unknown fanin is exposed
explicitly. RAM data is a clock-domain boundary only for reviewed FIFO memories.
"""
from pathlib import Path
import re,json,hashlib,collections,functools,time,sys
sys.setrecursionlimit(10000)
R=Path('F:/Projects/stareye_fpga');B=Path(__file__).resolve().parent;O=B/'full_inventory';P=B/'mirror/efinity/m5c_fusion_i3/outflow/Ti60_Demo.map.v'

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
 rows=[];summary=collections.Counter()
 for kind,name,ports in cells:
  if kind in ('EFX_LUT4','EFX_ADD'):continue
  if kind=='EFX_FF':rules={k:ports['CLK'][0] for k in ('D','CE','SR')}
  elif kind=='EFX_SRL8':rules={k:ports['CLK'][0] for k in ('D','CE','A')}
  elif kind=='EFX_RAM10':rules={k:ports['WCLK'][0] for k in ('WDATA','WADDR','WE','WCLKE','WADDREN')};rules.update({k:ports['RCLK'][0] for k in ('RADDR','RE','RST','RADDREN')})
  elif kind=='EFX_DPRAM10':rules={k+side:ports['CLK'+side][0] for side in ('A','B') for k in ('WDATA','ADDR','WE','CLKE','RST','ADDREN')}
  elif kind=='EFX_DSP48':rules={k:ports['CLK'][0] for k in ('A','B','C','CASCIN','OP','SHIFT_ENA','CE','RST')}
  else:raise AssertionError(kind)
  for pin,clk in rules.items():
   for i,net in enumerate(reversed(ports.get(pin,[]))):
    src=sorted(origins(net));classification='CONSTANT' if not src else 'REGISTERED_SAME_CLOCK' if all(v[0]==clk for v in src) else 'CROSS_CLOCK' if all(v[0] not in ('UNDRIVEN_OR_PRIMARY','UNKNOWN_DEPTH') for v in src) else 'PRIMARY_OR_UNRESOLVED_EXPLICIT'
    endpoint=name+'|'+pin+(f'[{i}]' if len(ports[pin])>1 else '')
    rows.append(dict(endpoint=endpoint,kind=kind,port=pin,clock=clk,net=net,classification=classification,sources=src));summary[kind+'|'+pin+'|'+classification]+=1
 (O/'ALL_SEQUENTIAL_INPUTS.json').write_text(json.dumps(dict(map_sha256=hashlib.sha256(raw).hexdigest(),pins=rows,counts=summary,boundary='Structural classification only. Primary/encrypted macro sources remain explicit; no inferred timing waiver. Current actual native timing reports determine timing.'),indent=2));print('ALL_INPUTS',len(rows),dict(summary),flush=True)
if __name__=='__main__':main()
