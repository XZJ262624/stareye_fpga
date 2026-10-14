from pathlib import Path
import json,re,hashlib
p=Path('reports/m5c1b_fusion_integration/review_fix_99642712/resource_diagnostic/prove_area_ce_bdd.py');s=p.read_text(encoding='utf-8-sig');exec(compile(s[:s.index('maps=[')],__file__,'exec'));maps=[parse(x/'mirror/efinity/m5c_fusion_i3/outflow/Ti60_Demo.map.v') for x in [B,A]];lines=[];leaf={};cache={};idx=0;cone=[]
def var():
 global idx
 idx+=1;return 'n'+str(idx)
def node(inputs,rows):
 v=var();lines.append('.names '+' '.join(inputs+[v]));lines.extend(rows);return v
zero=node([],[]);one=node([],['1'])
def calc(mi,net):
 key=(mi,net)
 if key in cache:return cache[key]
 cells,params,driver=maps[mi]
 if net=="1'b0":return zero
 if net=="1'b1":return one
 if net not in driver or cells[driver[net][0]]['type']=='EFX_FF':
  if net not in leaf:leaf[net]='v'+str(len(leaf))
  return leaf[net]
 n,k=driver[net];c=cells[n];assert c['type']=='EFX_LUT4',c;mask=int(params[n]['LUTMASK'].split("'h")[1],16);args=[calc(mi,c['ports'].get('I'+str(j),"1'b0")) for j in range(4)];rows=[''.join(str((i>>j)&1) for j in range(4))+' 1' for i in range(16) if (mask>>i)&1];v=node(args,rows);cache[key]=v;cone.append(dict(side=mi,name=n,cell=c,params=params[n]));return v
outputs=[]
for mi,(cells,params,driver) in enumerate(maps):
 f=cells['u_m5b1/session_fault~FF'];pa=params['u_m5b1/session_fault~FF'];assert pa['SR_SYNC']=="1'b0" and pa['SR_VALUE']=="1'b0";sig={k:calc(mi,f['ports'][k]) for k in ['D','CE','SR','Q']}
 for k in ['D','CE','SR']:
  if pa[k+'_POLARITY']=="1'b0":sig[k]=node([sig[k]],['0 1'])
 outputs.append(node([sig[k] for k in ['SR','CE','D','Q']],['011- 1','00-1 1']))
lines.append('.names '+' '.join(outputs+['miter']));lines+=['01 1','10 1'];out=D/'SESSION_FAULT_MITER.blif';out.write_text('.model session_fault_miter\n.inputs '+' '.join(leaf.values())+'\n.outputs miter\n'+'\n'.join(lines)+'\n.end\n');(D/'SESSION_FAULT_SAT_INPUTS.json').write_text(json.dumps(dict(leaves=leaf,cones=cone,leaf_boundary='Same named FF Q and actual interface outputs; sequential FF reset/CE polarity modeled at compared single register, no global compiler equivalence.',miter_sha256=hashlib.sha256(out.read_bytes()).hexdigest()),indent=2));print(len(leaf),len(cone),out)
