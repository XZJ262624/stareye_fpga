from pathlib import Path
import re,json,hashlib
O=Path(__file__).resolve().parent
sdc=O/'mirror/efinity/m5c_fusion_i3/Ti60_Demo_I3.sdc';log=O/'place/tool.log'
expected={}
for m in re.finditer(r'set (\w+) \[m5b1_exact \{(.*?)\} (\w+)\]',sdc.read_text(),re.S):
 expected[m[3]]={re.sub(r'\\(.)',r'\1',p[1:-1]) for p in re.findall(r'\{(\^.*?\$)\}',m[2])}
seen={};errors=[]
for line in log.read_text(errors='replace').splitlines():
 if line.startswith('M5B1_CDC_PINS '):
  _,name,count,pins=line.split(' ',3);actual=pins.split();assert len(actual)==int(count) and len(set(actual))==len(actual),(name,count)
  if name not in expected or set(actual)!=expected[name]:errors.append(name)
  seen[name]=actual
assert len(expected)==56
missing=sorted(set(expected)-set(seen));r=dict(status='PASS_NATIVE_EXACT_OBJECTS' if not missing and not errors else 'INCOMPLETE_OR_FAIL',groups=len(seen),missing=missing,mismatches=errors,log_sha256=hashlib.sha256(log.read_bytes()).hexdigest(),sdc_sha256=hashlib.sha256(sdc.read_bytes()).hexdigest(),actual=seen)
(O/'NATIVE_SELECTOR_GATE.json').write_text(json.dumps(r,indent=2));print(r['status'],len(seen),missing,errors)
assert not missing and not errors
