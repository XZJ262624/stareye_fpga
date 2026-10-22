from common import *
s=(P/'Ti60_Demo_I3.sdc').read_text();raw=re.sub(r'/\*.*?\*/','',(P/'outflow/Ti60_Demo.map.v').read_text().split('endmodule',1)[0],flags=re.S)
cells={m[2].lstrip('\\'):set(re.findall(r'\.(\w+)\s*\(',m[3])) for m in re.finditer(r'^    (EFX_\w+)\s+(\\\S+|\w+)\s+\((.*?)\)\s*;',raw,re.M|re.S)}
pins={n+'|'+p for n,ps in cells.items() for p in ps}
groups=[]
for m in re.finditer(r'set (\w+) \[m5b1_exact \{(.*?)\}\s*(\w+)\]',s,re.S):
 pats=re.findall(r'\{(\^.*?)\}',m[2]);ok=[];missing=[]
 for pat in pats:
  literal=re.sub(r'\\(.)',r'\1',pat[1:-1]);assert re.fullmatch(pat,literal)
  matches=[literal] if literal in pins else []
  (ok if len(matches)==1 else missing).append(pat)
 groups.append(dict(name=m[1],ok=ok,missing=missing))
save(O/'CDC_MAP_INSPECTION.json',dict(cells=len(cells),groups=groups))
for g in groups:
 if g['missing']:print(g['name'],len(g['ok']),len(g['missing']),g['missing'][:5])
