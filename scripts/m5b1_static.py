"""Validate isolated project provenance, protected files, ports and warnings."""
from pathlib import Path
import json,hashlib,xml.etree.ElementTree as ET,re,collections,subprocess
R=Path(__file__).resolve().parents[1];O=R/'reports/m5b1_global_canny_i3';W=R/'efinity/m5b1_global_canny_i3';S=R/'efinity/m5a_streaming_canny_i3';NS={'e':'http://www.efinixinc.com/enf_proj'}
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def main():
 baseline=json.loads((O/'BASELINE_PROTECTION.json').read_text());allowed={'.gitattributes','.gitignore'}
 changes=[r['path'] for r in baseline['tracked'] if r['path'] not in allowed and (not (R/r['path']).exists() or rec(R/r['path'])!=r)]
 missing=[p for p in baseline['untracked'] if not (R/p).exists()];assert not changes and not missing,(changes,missing)
 management=[]
 for row in baseline['tracked']:
  if row['path'] in allowed:
   data=(R/row['path']).read_bytes();assert hashlib.sha256(data[:row['bytes']]).hexdigest()==row['sha256'],'Existing attributes/ignore rules were changed'
   management.append(dict(before=row,after=rec(R/row['path']),policy='append only; original byte prefix unchanged'))
 provenance=json.loads((O/'M5A_INPUT_COPY.json').read_text());changed=[];copies=[]
 permitted={'efinity/m5b1_global_canny_i3/example_top.v','efinity/m5b1_global_canny_i3/Ti60_Demo.xml','efinity/m5b1_global_canny_i3/Ti60_Demo_I3.sdc','rtl/m5b1_global_canny/m5a_copy/m5a_stream_top.v'}
 for row in provenance['files']:
  assert rec(R/row['source']['path'])==row['source'],row['source']['path']
  current=rec(R/row['copy']['path']);diff=current!=row['copy'];copies.append(dict(source=row['source'],current=current,modified=diff))
  if diff:changed.append(current['path'])
 assert set(changed)==permitted,changed
 tree=ET.parse(W/'Ti60_Demo.xml');old=ET.parse(S/'Ti60_Demo.xml')
 names=[n.get('name') for n in tree.findall('.//e:design_file',NS)];oldnames=[n.get('name').replace('../../rtl/m5a_streaming_canny/','../../rtl/m5b1_global_canny/m5a_copy/') for n in old.findall('.//e:design_file',NS)]
 removed={'src/axi/axi4_ctrl.v','src/axi/AXI4_AWARMux.v','src/ddr_rw_ctrl.v'};added={'../../rtl/m5b1_global_canny/'+p.name for p in (R/'rtl/m5b1_global_canny').glob('*.sv')}
 assert set(names)==(set(oldnames)-removed)|added and len(names)==len(set(names))
 for name in names:assert (W/name).resolve().is_file() and (W/name).resolve().is_relative_to(R)
 assert ET.tostring(tree.find('e:device_info',NS))==ET.tostring(old.find('e:device_info',NS))
 assert [n.attrib for n in tree.findall('.//e:ip',NS)]==[n.attrib for n in old.findall('.//e:ip',NS)]
 def header(p):return p.read_text().split(');',1)[0]
 assert header(W/'example_top.v')==header(S/'example_top.v'),'top interface/parameters changed'
 sdc=(W/'Ti60_Demo_I3.sdc').read_text();assert not re.search(r'set_false_path[^\n]*get_clocks|set_clock_groups',sdc)
 assert rec(W/'Ti60_Demo.peri.xml')['sha256']==rec(S/'Ti60_Demo.peri.xml')['sha256']
 def warnings(p):
  lines=[l for l in p.read_text(errors='replace').splitlines() if l.startswith('WARNING')]
  def norm(l):
   l=re.sub(r'[A-Z]:[^\r\n]*?\\([^\\/():]+\.(?:sv|v))\(\d+\)',r'\1',l)
   l=re.sub(r'\(F:[^\r\n]*?\.(?:sv|v):\d+\)','(SOURCE)',l)
   return l
  return lines,collections.Counter(map(norm,lines))
 current,wc=warnings(W/'outflow/Ti60_Demo.map.out');oldlines,wo=warnings(S/'outflow/Ti60_Demo.map.out');delta=list((wc-wo).elements())
 known=[l for l in current if ('rtl\\m5b1_global_canny\\' in l)]
 reasons={
  'm5b1_video_dma.sv':'20-bit frame offsets are bounded to 0..921600 and advance by 2048 only below final burst; 21-bit arithmetic carry is zero.',
  'm5b1_transfer.sv':'Boundary beats are 1..256 for aligned addresses; boundary minus one fits 8 bits. Real arbiter rejects illegal alignment/length/range.',
  'm5b1_uart.sv':'CRC serializer deliberately selects low byte after right shift; all 580 production-baud serial bytes match independent host CRC/payload.',
  "u_m5b1/video/slot_id":'Four 64-bit frame identities need async reads; logic storage intentional and included in resource gate.',
  "u_m5b1/arbiter/waiting":'Three constant-index counters intentionally map to FF/logic.',
  "u_m5a_stream/frame_tags":'Eight 192-bit stable pipeline tags intentionally use logic storage, verified by full-frame tap/tag tests.'}
 annotated=[]
 for line in known:
  hits=[explain for key,explain in reasons.items() if key in line];assert hits,line
  assert not re.search(r'latch|multiple drivers',line,re.I),line
  annotated.append(dict(warning=line,explanation=hits[-1]))
 result=dict(status='PASS_STATIC_SCOPE_AND_PROVENANCE',protected_tracked=len(baseline['tracked']),protected_changes=changes,authorized_append_only_management=management,historical_untracked=len(baseline['untracked']),historical_untracked_missing=missing,copy_count=len(copies),copies=copies,approved_modified_copies=changed,xml_design_files=names,removed_legacy_transaction_files=sorted(removed),new_production_modules=sorted(added),top_ports_parameters_identical=True,peri_pins_PLL_identical=True,DDR_IP_parameters_ROM_identical=True,broad_clock_domain_false_paths=0,map_report=rec(W/'outflow/Ti60_Demo.map.out'),warning_count=len(current),normalized_new_warnings=delta,new_RTL_warnings=annotated)
 (O/'STATIC_AUDIT.json').write_text(json.dumps(result,indent=2));print('STATIC_PASS protected',len(baseline['tracked']),'untracked',len(baseline['untracked']),'copies',len(copies),'new warning categories',len(delta))
if __name__=='__main__':main()
