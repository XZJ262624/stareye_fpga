from pathlib import Path
import json,re,hashlib,difflib
A=Path(__file__).resolve().parent;R=A.parents[3];O=R/'reports/m5c1b_fusion_integration/fresh_i3_build_20261014';P=A/'mirror/efinity/m5c_fusion_i3'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
assert json.loads((A/'CURRENT_QUERY_CHAIN_STATE.json').read_text())['status']=='ALL5_EXECUTED_PENDING_FULL_RECONCILIATION'
plan=[]
for n in ['QUERY_DERIVATION.json','QUERY02_DERIVATION.json','QUERY03_DERIVATION.json','QUERY04_DERIVATION.json','QUERY05_DERIVATION.json']:plan+=json.loads((A/n).read_text())['queries']
(A/'FULL_QUERY_DERIVATION.json').write_text(json.dumps(dict(queries=plan),indent=2))
struct=json.loads((A/'full_inventory/ALL_SEQUENTIAL_INPUTS.json').read_text());pins={x['endpoint']:x for x in struct['pins']};assert len(pins)==len(struct['pins'])
native={}
for line in (P/'v4_pin_nets.txt').read_text().splitlines():
 k,v=line.split('\t',1);assert k not in native;native[k]=v.strip('{}')
expect=json.loads((A/'CURRENT_CONNECTION_TARGETS.json').read_text())['targets'];assert set(native)==set(expect)
raw=(P/'outflow/Ti60_Demo.map.v').read_text();cells={}
for m in re.finditer(r'^    (EFX_\w+)\s+(\\\S+|\w+)\s+\((.*?)\)\s*/\*(.*?)\*/\s*;',raw,re.M|re.S):
 name=m[2].lstrip('\\');cells[name]=dict(kind=m[1],ports={k:v for k,v in re.findall(r'\.(\w+)\((.*?)\)',m[3],re.S)},instance=m[0],parameters=m[4])
diff=[];nonram=[]
for pin,net in native.items():
 st=pins.get(pin)
 if net not in ['gnd','vcc'] or st is None or st['classification']=='CONSTANT':continue
 name,port=pin.split('|');cell=cells.get(name)
 if st['kind']!='EFX_RAM10' or not port.startswith(('WADDR[','RADDR[')):nonram.append(dict(pin=pin,native_net=net,logical=st));continue
 assert cell and cell['kind']=='EFX_RAM10'
 diff.append(dict(pin=pin,native_net=net,logical=st,primitive='EFX_RAM10',generic_port_connection=cell['ports'][port.split('[')[0]],mapped_instance=cell['instance'],classification='NATIVE_PHYSICAL_RAM_CONSTANT_WITH_LOGICAL_MAPPING_DIFFERENCE'))
(A/'RAM_PHYSICAL_CONSTANT_DIFFERENCES_CURRENT.json').write_text(json.dumps(dict(status='CURRENT_NATIVE_MAP_COMPARISON_PENDING_AUDIT',records=diff,nonram_disagreements=nonram,native=rec(P/'v4_pin_nets.txt'),map=rec(P/'outflow/Ti60_Demo.map.v'),boundary='Current typed native physical net constant; generic vector port numbering can differ. No old whitelist or counts used.'),indent=2));assert not nonram,nonram
p=O/'audit_current_timing_v3.py';s=p.read_text();t=s.replace('R=F.parents[2]','R=F.parents[3]').replace("F/'QUERY_DERIVATION.json'","F/'FULL_QUERY_DERIVATION.json'").replace("F/'EXACT_SELECTOR_GATE.json'","F/'EXACT_SELECTOR_GATE_V2.json'").replace("F/'RAM_PHYSICAL_CONSTANT_DIFFERENCES.json'","F/'RAM_PHYSICAL_CONSTANT_DIFFERENCES_CURRENT.json'")
t=t.replace('assert len(pins)==61480',"assert len(pins)==len(struct['pins']) and struct['map_sha256']==hashlib.sha256((P/'outflow/Ti60_Demo.map.v').read_bytes()).hexdigest()")
t=t.replace('assert len(native)==1631',"assert set(native)==set(json.loads((F/'CURRENT_CONNECTION_TARGETS.json').read_text())['targets'])")
t=t.replace('assert len(ram_difference)==36',"assert not json.loads((F/'RAM_PHYSICAL_CONSTANT_DIFFERENCES_CURRENT.json').read_text())['nonram_disagreements']")
t=t.replace('assert len(expected)==18992 and len(rows)==18834 and len(missing)==158','assert expected and len(expected)==len(rows)+len(missing)')
q=A/'audit_current_timing_v4.py';assert not q.exists();q.write_text(t)
(A/'TIMING_AUDIT_DERIVATION.json').write_text(json.dumps(dict(parent=rec(p),derived=rec(q),counts=dict(current_inventory=len(pins),current_native_connections=len(native),current_RAMdifferences=len(diff)),changes='Current stageplan/map/targetsets dynamic exactcardinality; full ordinary/24bundle/1487/clockpairs/missingpin criteria unchanged. Current RAM differences only actual typedphysical constants and mapped instance evidence; no old whitelist.',diff=''.join(difflib.unified_diff(s.splitlines(True),t.splitlines(True)))),indent=2));print('AUDIT_PREPARED',len(pins),len(native),len(diff))
