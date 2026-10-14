from pathlib import Path
import re,json,hashlib,sys
O=Path(__file__).resolve().parent
P=Path(sys.argv[1]);out=O/sys.argv[2]
s=re.sub(r'/\*.*?\*/','',P.read_text(),flags=re.S)
pins=set();names=set()
for m in re.finditer(r'^    (EFX_\w+)\s+(\\\S+|\w+)\s+\((.*?)\)\s*;',s,re.M|re.S):
 name=m[2].lstrip('\\');assert name not in names;names.add(name)
 pins.update(name+'|'+p for p in re.findall(r'\.(\w+)\(',m[3]))
sdc=O/'mirror/efinity/m5c_fusion_i3/Ti60_Demo_I3.sdc';txt=sdc.read_text();groups=[];missing=[]
for m in re.finditer(r'set (\w+) \[m5b1_exact \{(.*?)\} (\w+)\]',txt,re.S):
 patterns=re.findall(r'\{(\^.*?\$)\}',m[2])
 literal=[]
 for p in patterns:
  q=re.sub(r'\\(.)',r'\1',p[1:-1]);assert '^'+re.escape(q)+'$'==p,(q,p)
  if q not in pins:missing.append(q)
  literal.append(q)
 assert len(set(literal))==len(literal)
 groups.append(dict(name=m[1],count=len(literal),pins=literal))
assert len(groups)==56,len(groups)
r=dict(status='PASS_EXACT_MAPPED_SELECTORS' if not missing else 'FAIL_MISSING',map=str(P),map_sha256=hashlib.sha256(P.read_bytes()).hexdigest(),sdc_sha256=hashlib.sha256(sdc.read_bytes()).hexdigest(),groups=groups,missing=missing)
out.write_text(json.dumps(r,indent=2));print(r['status'],len(groups),missing);assert not missing

