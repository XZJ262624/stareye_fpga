from common import *
import xml.etree.ElementTree as ET
W=R/json.loads((O/'ACTIVE_PHYSICAL.json').read_text())['path']
physical=json.loads((W/'FINAL_RESULT.json').read_text());assert physical['passed']
for x in (physical['bit'],physical['native_bit']):assert rec(R/x['path'])==x
verify(json.loads((W/'BIT_INPUTS.json').read_text()))
changes=[]
for x in json.loads((W/'PRODUCTION_INPUTS.json').read_text()):
 now=rec(R/x['path'])
 if now!=x:
  assert x['path']=='efinity/shape_replay_i3/Ti60_Demo.xml',(x,now)
  changes.append(dict(before=x,after=now))
# Recreate only the initial project XML in memory from immutable preparation
# inputs; no production file is rewritten during reconciliation.
s=(R/'efinity/canny_replay_i3/Ti60_Demo.xml').read_text().replace('canny_replay_i3','shape_replay_i3')
s=re.sub(r'    <efx:design_file name="F:/Projects/stareye_fpga/rtl/.*?\n','',s)
entries=''.join(f'    <efx:design_file name="{p.as_posix()}" version="'+('system_verilog' if p.suffix=='.sv' else 'default')+'" library="default" />\n' for p in sorted(T.rglob('*')) if p.suffix in ('.v','.sv'))
s=s.replace('    <efx:top_vhdl_arch',entries+'    <efx:top_vhdl_arch').replace('rtl/canny_replay','rtl/shape_replay')
initial=next(x for x in json.loads((W/'INPUTS_BEFORE_MAP.json').read_text()) if x['path'].endswith('Ti60_Demo.xml'))
if (W/'PROJECT_BEFORE_MAP.xml').exists():
 raw=(W/'PROJECT_BEFORE_MAP.xml').read_bytes();assert hashlib.sha256(raw).hexdigest()==initial['sha256'];s=raw.decode('utf8')
else:assert hashlib.sha256(s.replace('\n','\r\n').encode()).hexdigest()==initial['sha256']
a=ET.fromstring(s);b=ET.parse(P/'Ti60_Demo.xml').getroot()
allowed={'last_change','last_run_state','last_run_flow','config_result_in_sync','design_ood','place_ood','route_ood'}
metadata={k:dict(before=a.attrib.get(k),after=b.attrib.get(k)) for k in set(a.attrib)|set(b.attrib) if a.attrib.get(k)!=b.attrib.get(k)}
assert set(metadata)<=allowed,metadata
for k in allowed:a.attrib.pop(k,None);b.attrib.pop(k,None)
def semantic(n):return (n.tag,sorted(n.attrib.items()),(n.text or '').strip(),[semantic(c) for c in n])
assert semantic(a)==semantic(b)
save(O/'FINAL_BUILD_BINDING.json',dict(passed=True,changed_production_files=changes,xml_technical_equal=True,xml_metadata_changes=metadata,physical=rec(W/'FINAL_RESULT.json'),database_files=len(json.loads((W/'BIT_INPUTS.json').read_text())),initial_map_inputs=rec(W/'INPUTS_BEFORE_MAP.json')))
print('BUILD_BINDING_PASS',metadata)
