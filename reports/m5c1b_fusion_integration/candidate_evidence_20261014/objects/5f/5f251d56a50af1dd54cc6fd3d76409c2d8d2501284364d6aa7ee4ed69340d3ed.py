from pathlib import Path
import re,json,sys,collections,hashlib
O=Path(__file__).resolve().parent;P=Path(sys.argv[1]);D=O/sys.argv[2];raw=P.read_text();cells={};users=collections.defaultdict(list)
def norm(x):return re.sub(r'\s+\[','[',x.strip().lstrip('\\'))
for m in re.finditer(r'^    EFX_LUT4\s+(\\\S+|\w+)\s+\((.*?)\)\s*/\*.*?LUTMASK=16\x27h([0-9a-f]+)',raw,re.M|re.S):
 pp={k:norm(v) for k,v in re.findall(r'\.(\w+)\((.*?)\)',m[2],re.S)};n=pp['O'];mask=int(m[3],16);cells[n]=dict(cell=m[1],ports=pp,mask=m[3]);
 for k,v in pp.items():
  if k!='O' and any(((mask>>i)^(mask>>(i^(1<<int(k[1:])))))&1 for i in range(16)):users[v].append(n)
# Canonical output D endpoints from independent primitive inventory.
a=json.loads((D/'RGB_REFACTORED_CONE.json').read_text());ends={x['data_net']:x['endpoint'] for x in a['rgb']}
def paths(start):
 todo=collections.deque([start]);prev={start:None};found=[]
 while todo:
  n=todo.popleft()
  if n in ends:
   chain=[];v=n
   while prev[v] is not None:chain.append(dict(net=v,**cells[v]));v=prev[v]
   found.append(dict(endpoint=ends[n],path=list(reversed(chain))))
  for v in users[n]:
   if v not in prev:prev[v]=n;todo.append(v)
 return found
sources=['u_fusion_display/fusion/align/read_data[0]','u_fusion_display/fusion/align/read_data[1]','u_fusion_display/fusion/align/read_data[2]','fusion_frame_ok','fusion_eligible','u_m5a_stream/local_edge','u_m5a_stream/local_x[0]','final_y[0]','u_m5a_stream/u_final_packet/read_data[28]','u_m5a_stream/u_final_packet/read_data[29]','u_m5a_stream/u_final_packet/read_data[30]','fusion_enable']
rows={s:paths(s) for s in sources};(D/'RGB_LUT_PATH_WITNESS.json').write_text(json.dumps(dict(map=a['map'],sources=rows,scope='Actual LUT truth-table-essential pin paths. Each edge can affect its LUT output; this is structural path evidence, not globally sensitized/formal sequential equivalence.'),indent=2));print({k:len(v) for k,v in rows.items()})

