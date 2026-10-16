"""Current-map literal discovery; RAM native positions explicitly remain pending."""
from pathlib import Path
import re,json,hashlib
R=Path(__file__).resolve().parents[1];B=R/'reports/m5c_shadow_stats_20261016/physical_133645'
P=B/'mirror/efinity/m5c_fusion_i3/outflow/Ti60_Demo.map.v';S=B/'mirror/efinity/m5c_fusion_i3/Ti60_Demo_I3.sdc'
raw=P.read_bytes();s=re.sub(r'/\*.*?\*/','',raw.decode(),flags=re.S);cells={}
for m in re.finditer(r'^    (EFX_\w+)\s+(\\\S+|\w+)\s+\((.*?)\)\s*;',s,re.M|re.S):
 name=m[2].lstrip('\\');assert name not in cells
 cells[name]=dict(kind=m[1],ports=dict(re.findall(r'\.(\w+)\((.*?)\)',m[3],re.S)))
groups=[];missing=[];ram_pending=[]
for m in re.finditer(r'set (\w+) \[m5b1_exact \{(.*?)\} (\w+)\]',S.read_text(),re.S):
 pins=[]
 for pattern in re.findall(r'\{(\^.*?\$)\}',m[2]):
  pin=re.sub(r'\\(.)',r'\1',pattern[1:-1]);assert '^'+re.escape(pin)+'$'==pattern
  pins.append(pin);name,port=pin.rsplit('|',1);cell=cells.get(name)
  if cell and cell['kind'] in ('EFX_RAM10','EFX_DPRAM10') and '[' in port:ram_pending.append(pin)
  elif not cell or port not in cell['ports']:missing.append(pin)
 groups.append(dict(name=m[1],pins=pins))
out=dict(status='DISCOVERY_NOT_NATIVE_QUALIFICATION',map_sha256=hashlib.sha256(raw).hexdigest(),sdc_sha256=hashlib.sha256(S.read_bytes()).hexdigest(),groups=groups,missing_nonvector=missing,native_ram_pending=ram_pending)
(B/'SELECTOR_DISCOVERY.json').write_text(json.dumps(out,indent=2));print('groups',len(groups),'missing',len(missing),'RAM_pending',len(ram_pending));print('\n'.join(missing))
