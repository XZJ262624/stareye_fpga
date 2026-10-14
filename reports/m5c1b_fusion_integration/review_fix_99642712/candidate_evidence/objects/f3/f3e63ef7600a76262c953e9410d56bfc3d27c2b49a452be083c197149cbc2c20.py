from pathlib import Path
import json,re,hashlib,time,functools,bisect,sys
sys.setrecursionlimit(10000)
F=Path(__file__).resolve().parent.parent;R=F.parents[2];A=F/'resource_area_experiment';B=F/'fresh_i3_build_bound';D=A/'alias_diagnostic';start=time.monotonic();LIMIT=350000;TIME=90

def parse(p):
 s=re.sub(r'/\*.*?\*/','',p.read_text(),flags=re.S);cells={};params={};driver={}
 for m in re.finditer(r'^    (EFX_\w+)\s+(\\\S+|\w+)\s+\((.*?)\)\s*;',s,re.M|re.S):
  n=m[2].lstrip('\\');ports={a:re.sub(r'\s+',' ',b).strip() for a,b in re.findall(r'\.(\w+)\((.*?)\)',m[3],re.S)};assert n not in cells;cells[n]=dict(type=m[1],ports=ports)
  for k in ['O','Q','CO']:
   if k in ports:assert ports[k] not in driver;driver[ports[k]]=(n,k)
 for n,k,v in re.findall(r'defparam (\\\S+|\w+)\s*\.(\w+) = ([^;]+);',s):params.setdefault(n.lstrip('\\'),{})[k]=v
 return cells,params,driver
maps=[parse(x/'mirror/efinity/m5c_fusion_i3/outflow/Ti60_Demo.map.v') for x in [B,A]];targets=['\\u_m5b1/fusion/n21773','\\u_m5b1/fusion/n19065'];leaves=[];cones=[]
for mi,(cells,params,driver) in enumerate(maps):
 seen=set();order=[];cn=[]
 def walk(net):
  if net in seen:return
  seen.add(net)
  if net in ["1'b0","1'b1"]:return
  if net not in driver or cells[driver[net][0]]['type']=='EFX_FF':order.append(net);return
  n,k=driver[net];c=cells[n];assert c['type'] in ['EFX_LUT4','EFX_ADD'];cn.append(dict(name=n,**c,params=params[n]))
  for port in ['I0','I1','I2','I3','CI']:
   if port in c['ports']:walk(c['ports'][port])
 ff=cells['u_m5b1/session_fault~FF'];
 for pin in ['D','CE','SR','Q']:walk(ff['ports'][pin])
 leaves.append(order);cones.append(cn)
ce_order=json.loads((D/'CE_BDD_ATTEMPT1.json').read_text())['variable_order']; all_leaves=set(leaves[0]+leaves[1]);order=[x for x in ce_order if x in all_leaves]+[x for x in dict.fromkeys(leaves[0]+leaves[1]) if x not in ce_order];rank={n:i for i,n in enumerate(order)};nodes=[None,None];unique={};cache={}
def mk(v,l,h):
 if l==h:return l
 key=(v,l,h)
 if key in unique:return unique[key]
 assert len(nodes)<LIMIT,'NODE_LIMIT_NONPASS';assert time.monotonic()-start<TIME,'TIME_LIMIT_NONPASS'
 z=len(nodes);nodes.append(key);unique[key]=z;return z
def ite(i,t,e):
 if i==1:return t
 if i==0:return e
 if t==e:return t
 if t==1 and e==0:return i
 key=(i,t,e)
 if key in cache:return cache[key]
 v=min(nodes[x][0] for x in key if x>1)
 lo=[];hi=[]
 for x in key:
  if x>1 and nodes[x][0]==v:lo.append(nodes[x][1]);hi.append(nodes[x][2])
  else:lo.append(x);hi.append(x)
 z=mk(v,ite(*lo),ite(*hi));cache[key]=z;return z
roots=[];status='NONPASS';error=None
try:
 for mi,(cells,params,driver) in enumerate(maps):
  @functools.lru_cache(None)
  def calc(net):
   if net=="1'b0":return 0
   if net=="1'b1":return 1
   if net in rank:return mk(rank[net],0,1)
   n,k=driver[net];c=cells[n];ps=c['ports'];pa=params[n]
   if c['type']=='EFX_LUT4':
    mask=int(pa['LUTMASK'].split("'h")[1],16);args=[calc(ps.get('I'+str(i),"1'b0")) for i in range(4)]
    def lut(depth,offset):
     if depth<0:return (mask>>offset)&1
     return ite(args[depth],lut(depth-1,offset+(1<<depth)),lut(depth-1,offset))
    return lut(3,0)
   raise AssertionError(('unexpected',c['type']))
  ff=cells['u_m5b1/session_fault~FF'];pp=params['u_m5b1/session_fault~FF'];assert pp['SR_SYNC']=="1'b0";assert pp['SR_VALUE']=="1'b0"
  d=calc(ff['ports']['D']);ce=calc(ff['ports']['CE']);sr=calc(ff['ports']['SR']);q=calc(ff['ports']['Q'])
  if pp['D_POLARITY']=="1'b0":d=ite(d,0,1)
  if pp['CE_POLARITY']=="1'b0":ce=ite(ce,0,1)
  if pp['SR_POLARITY']=="1'b0":sr=ite(sr,0,1)
  roots.append(ite(sr,0,ite(ce,d,q)))
 status='PASS_SESSION_FAULT_NEXT_STATE_MITER_EQUAL' if roots[0]==roots[1] else 'FAIL_SESSION_FAULT_NEXT_STATE_DIFFERENCE'
except BaseException as e:error=repr(e)
leafrows=[]
for n in order:
 rr=[]
 for cells,params,driver in maps:
  if n in driver:
   cn,k=driver[n];rr.append(dict(cell=cn,port=k,type=cells[cn]['type'],params=params.get(cn),ports=cells[cn]['ports']))
  else:rr.append(dict(unclassified_boundary=n))
 leafrows.append(dict(net=n,old=rr[0],new=rr[1]))
report=dict(status=status,error=error,seconds=time.monotonic()-start,node_limit=LIMIT,time_limit=TIME,nodes=len(nodes),roots=roots,variable_order=order,leaves=leafrows,cones=cones,boundary='Actual asynchronous-SR/CE/D-polarity FF next-state miter over identically named FF Q/PI cutpoints; not full sequential implementation equivalence. All masks from actual mapped cells; LUT index I3..I0 per installed efx_lut4. Camera D/CE separate unresolved.',models=[dict(path=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest()) for p in [Path('E:/Efinity/2025.1/sim_models/verilog/efx_lut4.v'),Path('E:/Efinity/2025.1/sim_models/verilog/efx_ff.v')]])
p=D/'SESSION_FAULT_BDD_ATTEMPT2.json';assert not p.exists();p.write_text(json.dumps(report,indent=2));print(status,error,len(nodes),time.monotonic()-start)
