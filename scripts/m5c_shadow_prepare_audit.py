from pathlib import Path
import re,json,hashlib,shutil
R=Path(__file__).resolve().parents[1];B=R/'reports/m5c_shadow_stats_20261016/physical_133645';P=B/'mirror/efinity/m5c_fusion_i3/outflow/Ti60_Demo.map.v'
old=R/'reports/m5c_diagnostics/stage2_resource_bound_v3_20261015_181411';Q=B/'ram_native_query'
assert json.loads((Q/'RESULT.json').read_text())['status']=='PASS_NATIVE_PIN_QUERY_ONLY'
def rec(p):
 b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
native={}
for line in (Q/'tool.log').read_text().splitlines():
 if line.startswith('DIAG_RAM_PIN\t'):
  _,pin,net=line.split('\t');assert pin not in native;native[pin]=net
s=re.sub(r'/\*.*?\*/','',P.read_text(),flags=re.S);rows=[]
for m in re.finditer(r'^    EFX_RAM10\s+\\(u_diag_observer/\S+)\s+\((.*?)\)\s*;',s,re.M|re.S):
 name=m[1];expr=re.search(r'\.WDATA\((.*?)\)',m[2],re.S)[1].strip();assert expr.startswith('{') and expr.endswith('}')
 bits=[]
 for term in expr[1:-1].split(','):
  term=term.strip();z=re.fullmatch(r'(\\\S+\s*|\w+)\[(\d+)(?::(\d+))?\]',term);assert z,term
  net=z[1].strip().lstrip('\\');hi=int(z[2]);lo=int(z[3] or z[2]);bits.extend(f'{net}[{i}]' for i in range(hi,lo-1,-1))
 for i,net in enumerate(reversed(bits)):
  pins=[p for p,n in native.items() if p.startswith(name+'|WDATA[') and n==net];assert len(pins)==1,(name,net,pins)
  rows.append(dict(logical_pin=f'{name}|WDATA[{i}]',physical_pin=pins[0],net=net))
assert len(rows)==64 and len({x['physical_pin'] for x in rows})==64
(B/'CURRENT_NATIVE_RAM_BINDING.json').write_text(json.dumps(dict(status='PASS_CURRENT_NATIVE_NET_EXACT_BINDING',current_map_sha256=rec(P)['sha256'],rows=rows,bindings=[rec(P),rec(Q/'tool.log'),rec(Q/'RESULT.json'),rec(Path(__file__))]),indent=2))
helpers=[]
for n in ['audit_current_diag_v2.py','check_exact_selectors_v2.py','verify_native_selectors.py','inventory_all.py']:
 a=old/n;b=B/n;assert not b.exists();shutil.copyfile(a,b);helpers.append(dict(parent=rec(a),derived=rec(b),change='byteexact helper reuse; current inputs mandatory'))
(B/'AUDIT_DERIVATION.json').write_text(json.dumps(dict(helpers=helpers,binding=rec(B/'CURRENT_NATIVE_RAM_BINDING.json')),indent=2));print('BOUND_CURRENT_NATIVE_RAM',len(rows))
