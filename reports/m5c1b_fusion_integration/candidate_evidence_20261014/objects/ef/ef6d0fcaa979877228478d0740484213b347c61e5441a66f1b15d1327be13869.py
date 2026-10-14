from pathlib import Path
import json,re,hashlib,difflib
F=Path(__file__).resolve().parent;R=F.parents[2];P=F/'mirror/efinity/m5c_fusion_i3'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def put(n,x):
 p=F/n;assert not p.exists();p.write_text(json.dumps(x,indent=2))
st={x['endpoint']:x for x in json.loads((F/'full_inventory/ALL_SEQUENTIAL_INPUTS.json').read_text())['pins']}
native=dict(line.split('\t',1) for line in (P/'v4_pin_nets.txt').read_text().splitlines());native={k:v.strip('{}') for k,v in native.items()}
raw=(P/'outflow/Ti60_Demo.map.v').read_text();evidence=[]
for pin,net in sorted(native.items()):
 if net not in ['gnd','vcc'] or pin not in st or st[pin]['classification']=='CONSTANT':continue
 cell,port=pin.split('|');assert re.fullmatch(r'[RW]ADDR\[\d+\]',port),pin
 token='EFX_RAM10 \\'+cell+' ';i=raw.index(token);j=raw.index('*/ ;',i)+4;instance=raw[i:j]
 match=re.search(r'\.'+port.split('[')[0]+r'\((.*?)\)',instance,re.S);assert match,pin
 assert 'READ_WIDTH=' in instance and 'WRITE_WIDTH=' in instance
 evidence.append(dict(pin=pin,native_net=net,logical=st[pin],primitive='EFX_RAM10',generic_port_connection=match[1],mapped_instance=instance,classification='NATIVE_PHYSICAL_RAM_CONSTANT_WITH_LOGICAL_MAPPING_DIFFERENCE'))
assert len(evidence)==36
put('RAM_PHYSICAL_CONSTANT_DIFFERENCES.json',dict(status='EXACT36_NATIVE_PHYSICAL_CONSTANTS',records=evidence,native=rec(P/'v4_pin_nets.txt'),mapped=rec(P/'outflow/Ti60_Demo.map.v'),scope='Native physical pin connection is authoritative for this pin. Generic logical address port bit numbering is a separate RAM mode representation; no unproved exact bit-remapping formula asserted. No non-RAM override.'))
old=F/'audit_current_timing.py';text=old.read_text()
put('AUDIT_V1_FAILURE_RECEIPT.json',dict(status='FAIL_SOFTWARE_CLASSIFIER_ASSUMPTION_NOT_TIMING_FAILURE',helper=rec(old),failure='Assertion at native constant branch: generic logical RAM address classification is REGISTERED_SAME_CLOCK for 36 actual native constant physical address pins.',preserved_global_D=rec(F/'GLOBAL_D_COVERAGE_CURRENT.json')))
new=text.replace("p=F/name;assert not p.exists();p.write_text(json.dumps(a,indent=2))","p=F/name\n if p.exists():\n  assert name=='GLOBAL_D_COVERAGE_CURRENT.json' and json.loads(p.read_text())==a;return\n p.write_text(json.dumps(a,indent=2))")
new=new.replace('def classify(pin,mode):',"ram_difference={x['pin']:x for x in json.loads((F/'RAM_PHYSICAL_CONSTANT_DIFFERENCES.json').read_text())['records']};assert len(ram_difference)==36\ndef classify(pin,mode):")
needle="  assert st is None or st['classification']=='CONSTANT',(pin,st,net)"
replacement="  if pin in ram_difference:\n   ev=ram_difference[pin];assert ev['native_net']==net and ev['logical']==st and ev['primitive']=='EFX_RAM10'\n   return dict(pin=pin,classification=ev['classification'],native_net=net,structural=st,mapping_evidence=ev)\n"+needle
assert new.count(needle)==1;new=new.replace(needle,replacement)
p=F/'audit_current_timing_v2.py';assert not p.exists();p.write_text(new)
put('AUDIT_V2_DERIVATION.json',dict(parent=rec(old),derived=rec(p),exact_override=rec(F/'RAM_PHYSICAL_CONSTANT_DIFFERENCES.json'),diff=''.join(difflib.unified_diff(text.splitlines(True),new.splitlines(True),fromfile=old.name,tofile=p.name)),scope='Only 36 enumerated EFX_RAM10 physical WADDR/RADDR constant differences; all other native/logical disagreements retain original assertion. Existing global D output verified byte-content-equivalent without rewriting.'))
print('PREPARED EXACT RAM OVERRIDE',len(evidence))
