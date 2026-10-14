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
proof=json.loads((O/'rgb_factor_diagnostic/ELIGIBLE_SAT_PROOF.json').read_text());inp=json.loads((O/'rgb_factor_diagnostic/ELIGIBLE_MITER_INPUTS.json').read_text())
assert proof['status']=='PASS_SAME_MAP_ELIGIBLE_DUPLICATE_UNSAT_WITH_SANITY'
assert inp['map_sha']==hashlib.sha256(P.read_bytes()).hexdigest()
for x in proof['bindings']+[y[z] for y in proof['runs'] for z in ['log','input']]:
 q=Path(x['path']);q=q if q.is_absolute() else O.parents[3]/q;b=q.read_bytes();assert len(b)==x['bytes'] and hashlib.sha256(b).hexdigest()==x['sha256']
assert [x['actual'] for x in proof['runs']]==[['SATISFIABLE'],['UNSATISFIABLE'],['UNSATISFIABLE']]
assert all(x['exit']==0 and not x['timeout'] for x in proof['runs'])
rows={s:paths('n59756' if s=='fusion_eligible' else s) for s in sources}
assert len(rows)==12 and all(len(v)==16 for v in rows.values())
(D/'RGB_LUT_PATH_WITNESS.json').write_text(json.dumps(dict(map=a['map'],sources=rows,substitution=dict(original='fusion_eligible',actual='n59756',proof=proof,original_named_net_paths=len(paths('fusion_eligible')),invalidate_cell=cells['n60114'],following_cell=cells['n60115']),scope='Same-map complete eligible predicate UNSAT miter permits its combinational duplicate n59756. All essential LUT paths; no sequential crossing. Not globally sensitized/fullchip equivalence.'),indent=2));print({k:len(v) for k,v in rows.items()})
