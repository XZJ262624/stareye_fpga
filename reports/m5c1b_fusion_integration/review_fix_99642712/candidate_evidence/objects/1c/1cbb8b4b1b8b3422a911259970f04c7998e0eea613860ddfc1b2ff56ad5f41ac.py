from pathlib import Path
import json,re,hashlib,collections
A=Path(__file__).resolve().parent;R=A.parents[3];P=A/'mirror/efinity/m5c_fusion_i3'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def bits(e):
 e=e.strip()
 if e.startswith('{'):return sum((bits(x) for x in e[1:-1].split(',')),[])
 m=re.fullmatch(r"(\d+)'b([01]+)",e)
 if m:return [('vcc' if b=='1' else 'gnd') for b in m[2].zfill(int(m[1]))]
 m=re.fullmatch(r'(\\\S+\s+|[\w$]+)\[(\d+)(?::(\d+))?\]',e)
 if m:
  hi=int(m[2]);lo=int(m[3] or m[2]);return [m[1].strip().lstrip('\\')+f'[{i}]' for i in range(hi,lo-1,-1)]
 n=e.lstrip('\\').strip()
 if n in widths:return [f'{n}[{i}]' for i in range(widths[n][0],widths[n][1]-1,-1)]
 return [n]
diff=json.loads((A/'RAM_PHYSICAL_CONSTANT_DIFFERENCES_CURRENT.json').read_text());assert not diff['nonram_disagreements']
native={k:v.strip('{}') for k,v in (l.split('\t',1) for l in (P/'v4_pin_nets.txt').read_text().splitlines())}
raw=(P/'outflow/Ti60_Demo.map.v').read_text();drivers={};cells={};widths={}
for w in re.finditer(r'\bwire\s+\[(\d+):(\d+)\]\s*(.*?);',raw,re.S):
 for n in w[3].split(','):widths[n.strip().lstrip('\\')]=(int(w[1]),int(w[2]))
for m in re.finditer(r'^    (EFX_\w+)\s+(\\\S+|\w+)\s+\((.*?)\)\s*/\*(.*?)\*/\s*;',raw,re.M|re.S):
 kind,name=m[1],m[2].lstrip('\\');ports={k:v for k,v in re.findall(r'\.(\w+)\((.*?)\)',m[3],re.S)};cells[name]=m[0]
 for out in ['Q'] if kind=='EFX_FF' else ['O','CO'] if kind in ['EFX_LUT4','EFX_ADD'] else []:
  if out in ports:
   for n in bits(ports[out]):drivers[n]=(kind,name,out)
paths={}
for mode in ['setup','hold']:
 p=P/f'outflow/v2_RAM_{mode}.rpt';s=p.read_text();assert re.search(r'Timing Model\s*:\s*I3',s)
 paths[mode]={re.search(r'^Path End\s*:\s*(\S+)',b,re.M)[1]:b for b in re.split(r'\+{4} Path \d+ \+{4,}',s)[1:]}
proof=[];unknown=[]
for x in diff['records']:
 name,portbit=x['pin'].split('|');port=portbit.split('[')[0];cell=cells[name];assert cell==x['mapped_instance'];config_widths={k:int(v) for k,v in re.findall(r'(READ_WIDTH|WRITE_WIDTH)=(\d+)',cell)};assert set(config_widths.values())<={16,20}
 vector=list(reversed(bits(x['generic_port_connection'])));assert len(vector)==9
 actual={int(re.search(r'\[(\d+)\]$',p)[1]):n for p,n in native.items() if p.startswith(name+'|'+port+'[')};assert set(actual)==set(range(8))|{9}
 table=[]
 for logical in range(9):
  physical=9 if logical==0 else logical-1;pin=name+'|'+port+f'[{physical}]';ln=vector[logical];nn=actual[physical];evidence=[]
  if ln in ['gnd','vcc']:assert ln==nn;cls='EXACT_CONSTANT'
  elif ln==nn:cls='EXACT_NATIVE_LOGICAL_NET'
  else:
   d=drivers.get(ln);assert d,(ln,pin)
   kind,driver,out=d;nativeout='out' if kind=='EFX_LUT4' else out
   ok=True
   for mode in ['setup','hold']:
    b=paths[mode].get(pin,'');lines=b.splitlines();idx=next((i for i,l in enumerate(lines) if l.startswith(pin+' ')),None)
    good=idx is not None and idx>=2 and lines[idx-1].startswith(nn+' ') and lines[idx-2].startswith(driver+'|'+nativeout+' ')
    if not good:ok=False
    evidence.append(dict(mode=mode,verified=good,lines=lines[idx-2:idx+1] if idx is not None else []))
   cls='SAME_PRIMITIVE_OUTPUT_NATIVE_RENAME' if ok else 'UNKNOWN';
   if not ok:unknown.append(dict(pin=pin,logical_net=ln,native_net=nn,driver=d,evidence=evidence))
  table.append(dict(logical_bit=logical,physical_bit=physical,logical_net=ln,native_net=nn,classification=cls,evidence=evidence))
 assert next(t for t in table if t['physical_bit']==int(re.search(r'\[(\d+)\]',portbit)[1]))['classification']=='EXACT_CONSTANT'
 proof.append(dict(difference_pin=x['pin'],widths=config_widths,address_width=9,mapped_instance=cell,address_table=table))
p=A/'RAM_ADDRESS_MAPPING_PROOF.json';assert not p.exists();p.write_text(json.dumps(dict(status='PASS_CURRENT_COMPLETE_RAM_ADDRESS_PIN_MAPPING' if not unknown else 'NONPASS_CURRENT_RAM_ADDRESS_MAPPING',records=proof,unique_differences=len(proof),unknown=unknown,map=rec(P/'outflow/Ti60_Demo.map.v'),native=rec(P/'v4_pin_nets.txt'),reports=[rec(P/f'outflow/v2_RAM_{m}.rpt') for m in ['setup','hold']],generic_model=dict(path='E:/Efinity/2025.1/sim_models/verilog/efx_ram10.v',sha256=hashlib.sha256(Path('E:/Efinity/2025.1/sim_models/verilog/efx_ram10.v').read_bytes()).hexdigest()),generator=rec(Path(__file__)),boundary='Observed current 512x16/20 RAM native address bit numbering: generic bit0 maps physical9, generic bits1..8 map physical0..7. Every bit is checked against actual native constant, identical net or same mapped primitive output shown in current setup/hold path. No old whitelist or same-count inference.'),indent=2));print('RAM_CURRENT_MAPPING',len(proof),'unknown',len(unknown));assert not unknown
