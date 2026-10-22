from common import *
F=R/json.loads((O/'ACTIVE_PHYSICAL.json').read_text())['path'];P=R/json.loads((O/'ACTIVE_PHYSICAL.json').read_text())['project']
native={p:v.strip('{}')for p,v in(line.rstrip('\n').split('\t',1)for line in(P/'typed_native_connections.tsv').open())};cells=json.loads((F/'MAPPED_ALL_CELLS.json').read_text());raw=(P/'outflow/Ti60_Demo.map.v').read_text();params={}
for m in re.finditer(r'defparam\s+(\\\S+|\w+)\s*\.(\w+)\s*=\s*([^;]+);',raw):params.setdefault(m[1].lstrip('\\'),{})[m[2]]=m[3].strip()
rows=[]
for name,c in cells.items():
 if c['type']!='EFX_DSP48':continue
 rows.append(dict(name=name,register_parameters={k:v for k,v in params[name].items()if k.endswith('_REG')},mapped_controls={k:c['ports'].get(k)for k in['CLK','CE','RST']},native_controls={k:native.get(name+'|'+k)for k in['CLK','CE','RST']}))
save(F/'DSP_CLOCK_INSPECTION.json',dict(records=rows));print(json.dumps(rows,indent=2))
