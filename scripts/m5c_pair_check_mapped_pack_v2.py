from pathlib import Path
import json,re,hashlib,sys,importlib.util
R=Path.cwd();F=Path(sys.argv[1]).resolve();P=F/'mirror/efinity/m5c_pair_diag_i3';mp=P/'outflow/Ti60_Demo.map.v';sdc=P/'Ti60_Demo_I3.sdc'
assert json.loads((F/'map/RESULT.json').read_text())['status']=='PASS_STAGE'
b=mp.read_bytes();s=re.sub(r'/\*.*?\*/','',b.decode().split('\nendmodule')[0],flags=re.S);cells={};pins=set()
for m in re.finditer(r'^    (EFX_\w+)\s+(\\\S+|\w+)\s+\((.*?)\)\s*;',s,re.M|re.S):
 name=m[2].lstrip('\\');ports=dict(re.findall(r'\.(\w+)\((.*?)\)',m[3],re.S));assert name not in cells;cells[name]=dict(kind=m[1],ports=ports);pins.update(name+'|'+k for k in ports)
groups=[];missing=[]
for m in re.finditer(r'set (\w+) \[m5b1_exact \{(.*?)\} (\w+)\]',sdc.read_text(),re.S):
 patterns=re.findall(r'\{(\^.*?\$)\}',m[2]);actual=[]
 for p in patterns:
  q=re.sub(r'\\(.)',r'\1',p[1:-1]);assert '^'+re.escape(q)+'$'==p
  if q not in pins:missing.append(q)
  actual.append(q)
 assert len(actual)==len(set(actual));groups.append(dict(name=m[1],pins=actual,count=len(actual)))
# Real structure witnesses only, not RTL/fullchip equivalence or physical timing.
features={}
for key,fragment,kind,minimum in [('capture_words','/pair_capture/pack[','EFX_FF',128),('held_sid','/pair_capture/arm_box/held[','EFX_FF',64),('current_fifo','/pair_capture/fifo/mem','EFX_RAM10',1),('shared_buffer','/background/export_mem','EFX_RAM10',1),('controller','/background/pair_controller/','EFX_FF',100),('class_delay','pair_class_delay','EFX_RAM10',1)]:
 rows=[dict(name=n,**v) for n,v in cells.items() if fragment in n and v['kind']==kind];features[key]=dict(count=len(rows),minimum=minimum,pass_gate=len(rows)>=minimum,objects=rows)
# Actual complete pack[127:0] to dual-clock FIFO WDATA, not merely FF-name count.
wd=[];ram_rows=features['current_fifo']['objects']
for ram in ram_rows:
 assert ram['ports']['WCLK']=='clk_pixel' and ram['ports']['RCLK']=='clk_sys'
 expr=ram['ports']['WDATA']
 for m in re.finditer(r'\\u_m5b1/pair_capture/pack\s*\[(\d+)(?::(\d+))?\]',expr):
  hi=int(m[1]);lo=int(m[2]) if m[2] else hi;wd.extend(range(min(hi,lo),max(hi,lo)+1))
 assert re.sub(r'[\s{},]', '', re.sub(r'\\u_m5b1/pair_capture/pack\s*\[\d+(?::\d+)?\]', '', expr))=='',expr
assert sorted(wd)==list(range(128)),('PACK_WDATA_BIT_COVERAGE',wd)
features['capture_words']['actual_fifo_WDATA_unique_bits']=sorted(wd)
features['capture_words']['scope']='Full128pack storage/WDATA including tail identity/tick words; controls normally timed, RAM genuine PIXwrite/UIread.'
status='PASS_EXACT_CURRENT_OBJECTS_AND_FEATURE_PRESENCE' if not missing and all(x['pass_gate'] for x in features.values()) else 'FAIL_OBJECT_OR_FEATURE_MISSING'
r=dict(status=status,map_sha256=hashlib.sha256(b).hexdigest(),sdc_sha256=hashlib.sha256(sdc.read_bytes()).hexdigest(),groups=groups,missing=missing,features=features,scope='Literal mapped pins and feature presence only. Full functional current-plane oracle and physical timing/CDC/consumer classification pending.')
(F/'G1_MAPPED_OBJECTS.json').write_text(json.dumps(r,indent=2));print(status,[(k,v['count']) for k,v in features.items()],missing);assert status.startswith('PASS')
