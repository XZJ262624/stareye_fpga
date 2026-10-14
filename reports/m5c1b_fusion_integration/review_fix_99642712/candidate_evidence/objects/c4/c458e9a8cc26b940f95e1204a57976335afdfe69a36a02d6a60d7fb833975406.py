from pathlib import Path
import re,json,hashlib,bisect
F=Path(__file__).resolve().parent.parent;R=F.parents[2];A=F/'resource_area_experiment';B=F/'fresh_i3_build_bound';D=A/'alias_diagnostic';D.mkdir(exist_ok=False)
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def parse(p):
 s=re.sub(r'/\*.*?\*/',lambda m:'\n'*m[0].count('\n'),p.read_text(),flags=re.S);cells={};nl=[m.start() for m in re.finditer('\n',s)]
 for m in re.finditer(r'^    (EFX_\w+)\s+(\\\S+|\w+)\s+\((.*?)\)\s*;',s,re.M|re.S):
  n=m[2].lstrip('\\');cells[n]=dict(type=m[1],ports={a:re.sub(r'\s+',' ',b).strip() for a,b in re.findall(r'\.(\w+)\((.*?)\)',m[3],re.S)},line=bisect.bisect_left(nl,m.start())+1)
 params={}
 for n,k,v in re.findall(r'defparam \\(\S+) \.(\w+) = ([^;]+);',s):params.setdefault(n,{})[k]=v
 return cells,params
old=B/'mirror/efinity/m5c_fusion_i3/outflow/Ti60_Demo.map.v';new=A/'mirror/efinity/m5c_fusion_i3/outflow/Ti60_Demo.map.v';oc,op=parse(old);nc,np=parse(new);gate=json.loads((A/'EXACT_SELECTOR_GATE.json').read_text());rows=[]
for pin in gate['missing']:
 n=pin.rsplit('|',1)[0];a=oc[n];matches=[]
 for name,c in nc.items():
  if c['type']=='EFX_FF' and c['ports'].get('D')==a['ports'].get('D'):
   matches.append(dict(name=name,cell=c,params=np.get(name),same_control={k:a['ports'].get(k)==c['ports'].get(k) for k in ['D','CE','CLK','SR']},same_params=op[n]==np.get(name)))
 rows.append(dict(old_pin=pin,old=a,old_params=op[n],same_D_candidates=matches))
report=dict(status='READONLY_CANDIDATES_NOT_CONSTRAINT_APPROVAL',bindings=[rec(old),rec(new),rec(A/'EXACT_SELECTOR_GATE.json')],rows=rows)
(D/'MISSING_PIN_CANDIDATES.json').write_text(json.dumps(report,indent=2));print([(x['old_pin'],[(y['name'],y['same_control'],y['same_params']) for y in x['same_D_candidates']]) for x in rows[:3]]);print('rows',len(rows),'unique_sameD',sum(len(x['same_D_candidates'])==1 for x in rows))
