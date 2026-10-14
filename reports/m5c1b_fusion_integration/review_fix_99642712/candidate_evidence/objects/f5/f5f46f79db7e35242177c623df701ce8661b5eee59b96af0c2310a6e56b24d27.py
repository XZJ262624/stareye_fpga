from pathlib import Path
import functools
s=Path('reports/m5c1b_fusion_integration/review_fix_99642712/resource_diagnostic/analyze_area_alias.py').read_text(encoding='utf-8-sig');s=s[:s.index("old=B/")].replace('D.mkdir(exist_ok=False)','None');exec(compile(s,__file__,'exec'))
rows=[]
for label,base,targets in [('old',B,['\\u_m5b1/fusion/n21773','\\u_m5b1/video/camera_fifo/n697 [9]','ceg_net649']),('new',A,['\\u_m5b1/fusion/n19065','\\u_m5b1/video/camera_fifo/n686 [9]','ceg_net85'])]:
 cells,params=parse(base/'mirror/efinity/m5c_fusion_i3/outflow/Ti60_Demo.map.v');drivers={}
 for n,c in cells.items():
  for k in ['O','Q','CO']:
   if k in c['ports']:drivers[c['ports'][k]]=(n,k)
 @functools.lru_cache(None)
 def support(net):
  if net not in drivers:return frozenset([net])
  n,k=drivers[net];c=cells[n]
  if c['type']=='EFX_FF':return frozenset([net])
  assert c['type'].startswith('EFX_LUT') or c['type']=='EFX_ADD',c
  return frozenset().union(*(support(v) for p,v in c['ports'].items() if p not in ['O','Q','CO']))
 for net in targets:
  supp=sorted(support(net));rows.append(dict(label=label,net=net,support=supp));print(label,net,len(supp),supp[:10])
(D/'CONE_SUPPORT.json').write_text(json.dumps(rows,indent=2))
