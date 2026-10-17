from pathlib import Path
import re,json,hashlib,collections,sys
F=Path(sys.argv[1]).resolve();P=F/'mirror/efinity/m5c_pair_diag_i3/outflow/Ti60_Demo.map.v';S=F/'mirror/efinity/m5c_pair_diag_i3/Ti60_Demo_I3.sdc'
raw=P.read_bytes();s=re.sub(r'/\*.*?\*/','',raw.decode().split('\nendmodule')[0],flags=re.S);cells=[];pins=set();counts=collections.Counter()
for m in re.finditer(r'^    (EFX_\w+)\s+(\\\S+|\w+)\s+\((.*?)\)\s*;',s,re.M|re.S):
 kind,name,body=m.groups();name=name.lstrip('\\');ports=dict(re.findall(r'\.(\w+)\((.*?)\)',body,re.S));counts[kind]+=1
 pins.update(name+'|'+k for k in ports)
 if kind not in ('EFX_LUT4','EFX_ADD'):cells.append(dict(kind=kind,name=name,ports=ports))
groups=[]
for m in re.finditer(r'set (\w+) \[m5b1_exact \{(.*?)\} (\w+)\]',S.read_text(),re.S):
 patterns=re.findall(r'\{(\^.*?\$)\}',m[2]);literal=[re.sub(r'\\(.)',r'\1',p[1:-1]) for p in patterns];missing=[p for p in literal if p not in pins];groups.append(dict(name=m[1],pins=literal,missing=missing))
new=[c for c in cells if 'pair_' in c['name'] and not '/pair_lease/' in c['name']]
r=dict(status='DISCOVERY_ONLY_NOT_NATIVE_OR_TIMING',map_sha256=hashlib.sha256(raw).hexdigest(),sdc_sha256=hashlib.sha256(S.read_bytes()).hexdigest(),primitive_counts=dict(counts),old_groups=groups,new_sequential=new,limitations='RAM physical pin spelling requires native query. Missing generic pins are not accepted; exact SDC proposal follows actual driver proof.')
(F/'SELECTOR_DISCOVERY_V2.json').write_text(json.dumps(r,indent=2));print(json.dumps(dict(counts=dict(counts),missing={g['name']:len(g['missing']) for g in groups if g['missing']},new_sequential=len(new)),indent=2))
