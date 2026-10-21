"""Bit-expanded mapped cones for all new sequential/control and DSP inputs."""
from pathlib import Path
import sys,re,json,hashlib,functools,collections
sys.setrecursionlimit(10000)
R=Path(__file__).resolve().parents[2];F=Path(sys.argv[1]);P=F/'mirror/efinity/shape_standalone_i3';p=P/'outflow/Ti60_Demo.map.v';raw=p.read_text();s=re.sub(r'/\*.*?\*/','',raw.split('endmodule',1)[0],flags=re.S)
widths={}
for m in re.finditer(r'\b(?:wire|input|output)\s+\[(\d+):(\d+)\]\s*(.*?);',s,re.S):
 for n in m[3].split(','):widths[n.strip().lstrip('\\')]=(int(m[1]),int(m[2]))
def bits(expr):
 expr=expr.strip()
 if expr.startswith('{') and expr.endswith('}'):return [b for x in expr[1:-1].split(',') for b in bits(x)]
 m=re.fullmatch(r"(\d+)'[bhd][0-9a-fxXzZ]+",expr)
 if m:return ['CONST']*int(m[1])
 if re.fullmatch(r'\d+',expr):return ['CONST']
 m=re.fullmatch(r'(\\\S+\s+|[a-zA-Z_$][\w$]*)(?:\[(\d+)(?::(\d+))?\])?',expr+' ' if expr.startswith('\\') and not re.search(r'\s',expr) else expr)
 assert m,expr
 n=m[1].strip().lstrip('\\')
 if m[2] is not None:
  hi=int(m[2]);lo=int(m[3] or m[2]);return [f'{n}[{i}]' for i in range(hi,lo+(-1 if hi>=lo else 1),-1 if hi>=lo else 1)]
 if n in widths:
  hi,lo=widths[n];return [f'{n}[{i}]' for i in range(hi,lo-1,-1)]
 return [n]
cells={};params={};drivers={};graph={}
for m in re.finditer(r'defparam\s+(\\\S+|\w+)\s*\.(\w+)\s*=\s*([^;]+);',s):params.setdefault(m[1].lstrip('\\'),{})[m[2]]=m[3].strip()
for m in re.finditer(r'^    (EFX_\w+)\s+(\\\S+|\w+)\s+\((.*?)\)\s*;',s,re.M|re.S):cells[m[2].lstrip('\\')]=dict(kind=m[1],ports={k:bits(v) for k,v in re.findall(r'\.(\w+)\((.*?)\)',m[3],re.S)})
for name,c in cells.items():
 kind=c['kind'];ports=c['ports']
 if kind in ['EFX_LUT4','EFX_ADD']:
  ins=[n for k,v in ports.items() if k in ['I0','I1','I2','I3','CI'] for n in v]
  for k in ['O','CO']:
   for n in ports.get(k,[]):graph[n]=ins
 elif kind in ['EFX_FF','EFX_SRL8','EFX_RAM10']:
  for n in ports.get('RDATA' if kind=='EFX_RAM10' else 'Q',[]):drivers[n]=(ports['RCLK' if kind=='EFX_RAM10' else 'CLK'][0],name,kind)
 elif kind=='EFX_DPRAM10':
  for side in ['A','B']:
   for n in ports.get('RDATA'+side,[]):drivers[n]=(ports['CLK'+side][0],name,kind)
 elif kind=='EFX_DSP48':
  regs={k:v for k,v in params[name].items() if k.endswith('_REG')}
  if regs and all(v=="1'b0" for v in regs.values()):
   ins=[n for k,v in ports.items() if k in ['A','B','C','CASCIN','OP','SHIFT_ENA'] for n in v]
   for n in ports.get('O',[])+ports.get('CASCOUT',[]):graph[n]=ins
  else:
   for n in ports.get('O',[]):drivers[n]=(ports['CLK'][0],name,kind)
 else:raise AssertionError(kind)
for m in re.finditer(r'^    assign\s+(.*?)\s*=\s*(.*?)\s*;',s,re.M|re.S):
 a,b=bits(m[1]),bits(m[2]);assert len(a)==len(b)
 for x,y in zip(a,b):graph[x]=[y]
@functools.lru_cache(None)
def roots(n):
 if n=='CONST':return frozenset()
 if n in drivers:return frozenset([drivers[n]])
 if n not in graph:return frozenset([('UNKNOWN_OR_PRIMARY',n,'unknown')])
 return frozenset(x for v in graph[n] for x in roots(v))
selected={n for n,c in cells.items() if 'u_shape_system/' in n and '/u_m5b1/' not in n and c['kind'] in ['EFX_FF','EFX_RAM10','EFX_DSP48']}
groups=json.loads((F/'CURRENT_EXACT_GROUPS.json').read_text())['groups'];allowed={p for g in groups if not g['name'].endswith('_source') for p in g['pins']};allowed.update(f'u_shape_system/u_controls/key_meta[{i}]~FF|D' for i in range(2));records=[];unknown=[];cross=[]
for name in sorted(selected):
 c=cells[name];ports=c['ports'];kind=c['kind']
 if kind=='EFX_FF':rules={k:ports['CLK'][0] for k in ['D','CE','SR']}
 elif kind=='EFX_RAM10':rules={k:ports['WCLK'][0] for k in ['WCLKE','WE','WADDREN','WDATA','WADDR']};rules.update({k:ports['RCLK'][0] for k in ['RE','RST','RADDREN','RADDR']})
 elif kind=='EFX_DSP48':
  if ports['CLK'][0]=='CONST':assert all(v=="1'b0" for k,v in params[name].items() if k.endswith('_REG'))
  rules={k:ports['CLK'][0] if ports['CLK'][0]!='CONST' else 'clk_pixel' for k in ['A','B','C','CASCIN','OP','SHIFT_ENA','CE','RST']}
 else:raise AssertionError(kind)
 for port,clock in rules.items():
  for index,net in enumerate(reversed(ports.get(port,[]))):
   pin=name+'|'+port+(f'[{index}]' if len(ports[port])>1 else '');src=sorted(roots(net));foreign=[x for x in src if x[0]!=clock];row=dict(pin=pin,kind=kind,net=net,destination_clock=clock,roots=src,classification='CONSTANT' if not src else 'SAME_CLOCK' if not foreign else 'EXACT_DECLARED_BOUNDARY' if pin in allowed else 'UNRESOLVED')
   records.append(row)
   if any(x[0]=='UNKNOWN_OR_PRIMARY' for x in src) and row['classification']!='EXACT_DECLARED_BOUNDARY':unknown.append(row)
   if foreign:cross.append(row)
out=dict(status='PASS_MAPPED_NEW_CONES_ONLY_NATIVE_TIMING_PENDING' if not unknown and all(x['classification']=='EXACT_DECLARED_BOUNDARY' for x in cross) else 'UNRESOLVED_MAPPED_NEW_CONES',map_sha256=hashlib.sha256(p.read_bytes()).hexdigest(),selected_cells=len(selected),records=records,crossings=cross,unknown=unknown,counts=dict(collections.Counter(x['classification'] for x in records)),dsp_params={n:params[n] for n in selected if cells[n]['kind']=='EFX_DSP48'})
(F/'STANDALONE_PIXEL_MAPPED_CONES_V2.json').write_text(json.dumps(out,indent=2));print(out['status'],out['counts'],'unknown',len(unknown))
