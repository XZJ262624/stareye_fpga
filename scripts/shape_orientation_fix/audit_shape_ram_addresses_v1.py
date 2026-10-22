"""Derive address permutations from native read nets, verify every write driver/path."""
from pathlib import Path
import sys,json,re,hashlib
R=Path(__file__).resolve().parents[2];F=Path(sys.argv[1]);P=F/'mirror/efinity/shape_orientation_fix_i3';N=P/'typed_native_connections.tsv';native=dict((p,v.strip('{}')) for p,v in (line.rstrip('\n').split('\t',1) for line in N.open()));raw=(P/'outflow/Ti60_Demo.map.v').read_text().split('endmodule',1)[0];widths={};cells={};drivers={};params={}
def bits(expr):
 e=expr.strip()
 if e.startswith('{'):return [b for x in e[1:-1].split(',') for b in bits(x)]
 m=re.fullmatch(r"(\d+)'b([01]+)",e)
 if m:return ['vcc' if b=='1' else 'gnd' for b in m[2].zfill(int(m[1]))]
 m=re.fullmatch(r'(\\\S+\s+|[\w$]+)\[(\d+)(?::(\d+))?\]',e)
 if m:return [m[1].strip().lstrip('\\')+f'[{i}]' for i in range(int(m[2]),int(m[3] or m[2])-1,-1)]
 n=e.lstrip('\\').strip()
 return [f'{n}[{i}]' for i in range(widths[n][0],widths[n][1]-1,-1)] if n in widths else [n]
for m in re.finditer(r'\bwire\s+\[(\d+):(\d+)\]\s*(.*?);',raw,re.S):
 for n in m[3].split(','):widths[n.strip().lstrip('\\')]=(int(m[1]),int(m[2]))
for m in re.finditer(r'^    (EFX_\w+)\s+(\\\S+|\w+)\s+\((.*?)\)\s*/\*.*?\*/\s*;',raw,re.M|re.S):
 kind,name=m[1],m[2].lstrip('\\');ports={k:v for k,v in re.findall(r'\.(\w+)\((.*?)\)',m[3],re.S)};cells[name]=dict(kind=kind,ports=ports)
 for out in ['Q'] if kind=='EFX_FF' else ['O','CO'] if kind in ['EFX_LUT4','EFX_ADD'] else []:
  for n in bits(ports[out]) if out in ports else []:drivers[n]=(kind,name,out)
for m in re.finditer(r'defparam\s+(\\\S+|\w+)\s*\.(READ_WIDTH|WRITE_WIDTH)\s*=\s*(\d+);',raw):params.setdefault(m[1].lstrip('\\'),{})[m[2]]=int(m[3])
shape=[n for n,c in cells.items() if c['kind']=='EFX_RAM10' and '/u_shape/' in n];assert len(shape)==2
plan=json.loads((F/'BATCHED_ENDPOINT_PLAN.json').read_text());paths={};bindings=[]
def rec(p):return dict(path=p.relative_to(R).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
for mode in ['setup','hold']:
 paths[mode]={}
 for batch in plan['batches']:
  if batch['kind']!='RAM' or batch['mode']!=mode:continue
  p=P/f'outflow/{batch["label"]}.rpt';txt=p.read_text();assert re.search(r'Timing Model\s*:\s*I3',txt);bindings.append(rec(p))
  for block in re.split(r'\+{4} Path \d+ \+{4,}',txt)[1:]:
   end=re.search(r'^Path End\s*:\s*(\S+)',block,re.M)[1]
   if end.split('|')[0] in shape:paths[mode][end]=block
records=[];constant_differences=[]
for name in sorted(shape):
 c=cells[name];assert params[name]['READ_WIDTH']==params[name]['WRITE_WIDTH'] and params[name]['READ_WIDTH'] in [8,16]
 read=list(reversed(bits(c['ports']['RADDR'])));physical={int(re.search(r'\[(\d+)\]$',p)[1]):net for p,net in native.items() if p.startswith(name+'|RADDR[')};mapping={}
 for logical,net in enumerate(read):
  matches=[i for i,v in physical.items() if v==net];assert len(matches)==1,(name,logical,net,matches);mapping[logical]=matches[0]
 assert len(set(mapping.values()))==len(read)==len(physical)
 table=[]
 for port in ['RADDR','WADDR']:
  logicalbits=list(reversed(bits(c['ports'][port])));assert len(logicalbits)==len(read)
  actual={int(re.search(r'\[(\d+)\]$',p)[1]):net for p,net in native.items() if p.startswith(name+'|'+port+'[')};assert set(actual)==set(mapping.values())
  for i,ln in enumerate(logicalbits):
   physicalbit=mapping[i];pin=name+'|'+port+f'[{physicalbit}]';nn=actual[physicalbit];proof=[]
   if ln in ['gnd','vcc']:
    assert nn==ln and all(pin not in paths[m] for m in ['setup','hold']);category='EXACT_NATIVE_CONSTANT_AFTER_ADDRESS_PERMUTATION'
    if i!=physicalbit:constant_differences.append(pin)
   else:
    for mode in ['setup','hold']:
     block=paths[mode][pin];slack=float(re.search(r'^Slack\s*:\s*([-\d.]+)',block,re.M)[1]);assert slack>=0
     if ln!=nn:
      kind,driver,out=drivers[ln];driverpin=driver+'|'+('out' if kind=='EFX_LUT4' else out);lines=block.splitlines();index=next(j for j,line in enumerate(lines) if line.startswith(pin+' '));assert lines[index-1].startswith(nn+' ') and lines[index-2].startswith(driverpin+' '),(pin,ln,nn,driverpin,lines[index-2:index+1]);proof.append(dict(mode=mode,slack=slack,driver_lines=lines[index-2:index+1]))
     else:proof.append(dict(mode=mode,slack=slack,same_logical_native_net=True))
    category='SAME_LOGICAL_NET' if ln==nn else 'SAME_MAPPED_PRIMITIVE_OUTPUT_NATIVE_ALIAS'
   table.append(dict(port=port,logical_bit=i,physical_bit=physicalbit,logical_net=ln,native_net=nn,classification=category,evidence=proof))
 records.append(dict(cell=name,width=params[name]['READ_WIDTH'],logical_to_physical=mapping,table=table))
assert len(constant_differences)==len(set(constant_differences))
out=dict(status='PASS_ALL_CURRENT_SHAPE_RAM_ADDRESS_BITS_AND_CONSTANT_RENUMBERING',records=records,resolves_pins=constant_differences,bindings=[rec(P/'outflow/Ti60_Demo.map.v'),rec(N)]+bindings,scope='Read address permutation independently derived by unique actual native scan nets; all logical write bits checked at corresponding physical pin by exact net or same primitive output in both current setup/hold paths. Covers width8 and width16, not assumed from old pin numbers. Two physical bit7 constants are the logical width8 bit9 zero, not missing timing paths.')
q=F/'SHAPE_RAM_ADDRESS_MAPPING.json';assert not q.exists();q.write_text(json.dumps(out,indent=2));print(out['status'],constant_differences)
