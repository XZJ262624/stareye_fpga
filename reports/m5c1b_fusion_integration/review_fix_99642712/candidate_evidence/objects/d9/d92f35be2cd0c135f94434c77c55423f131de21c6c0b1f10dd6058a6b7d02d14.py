from pathlib import Path
import json,hashlib,xml.etree.ElementTree as ET
A=Path(__file__).resolve().parent;R=A.parents[3];P=A/'mirror/efinity/m5c_fusion_i3'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
m=json.loads((A/'COPY_MANIFEST.json').read_text());assert len(m['records'])==101
sources=[rec(R/x['copy']['path']) for x in m['records']]
names=['work_pnr/Ti60_Demo.lbf','outflow/Ti60_Demo.lpf','outflow/Ti60_Demo_or.ini','outflow/Ti60_Demo.map.v','outflow/Ti60_Demo.vdb','outflow/Ti60_Demo.troutingtraces','outflow/Ti60_Demo.interface.io','outflow/Ti60_Demo.pt.sdc']
arch=json.loads((A/'route/POST_NATIVE_ARCHIVE.json').read_text())['records'];db=[]
for n in names:
 p=P/n;x=rec(p);old=next(v for v in arch if v['original']['path']==x['path']);assert x==old['original'];assert rec(R/old['archive']['path'])==old['archive'];db.append(dict(current=x,route_archive=old['archive']))
root=ET.parse(P/'Ti60_Demo.xml').getroot();ns={'e':'http://www.efinixinc.com/enf_proj'}
params=lambda section:{x.get('name'):x.get('value') for x in root.findall('e:'+section+'/e:param',ns)}
sec=params('security');assert sec.get('enable_bitstream_encrypt','off')=='off' and sec.get('enable_bitstream_auth','off')=='off'
old=R/'reports/m5c1b_fusion_integration/offline_artifact_retry_20261014'
plan=dict(status='PREPARATION_ONLY_NOT_EXECUTED_REQUIRES_WORK_FULL_STA_APPROVAL',proposed_directory='reports/m5c1b_fusion_integration/review_fix_99642712/offline_area_artifact',sources101=sources,database8=db,project_bitstream_parameters=params('bitstream_generation'),security=sec,command=['cmd','/c',r'call E:\Efinity\2025.1\bin\setup.bat && call E:\Efinity\2025.1\bin\efx_run.bat Ti60_Demo.xml --flow pgm'],native_timeout_seconds=1200,derivation_parents=[rec(old/n) for n in ['prepare.py','options_preflight.py','run_conversion.py','seal_v2.py']],requirements=['New isolated mirror only; copy exact current qualified technical101 and eight whitelisted DB inputs, not prior artifacts.','Rebase only eleven settings.json base_path to new mirror, inverse normalized config equality and source/raw SHA receipts.','Require sealed current area route/STA/backend coverage and every manifest hash before execution.','Full pre/post content archives; native exit/timeout/owner persisted immediately before postprocessing assertions.','Validate generated do_program/run_usbif false and actual efx_pgm argv in project outflow log; no Programmer/USB/JTAG/Flash/key changes.','Produce four bit/hex conversion files only; exact package-relative ignore entries, no root ignore modification or Git staging.','Bind current area XML/SDC, actual route resources and qualification; old root SOURCE101 records remain historical versions, not rewritten.'],generator=rec(Path(__file__)))
p=A/'NEXT_OFFLINE_AREA_CONVERSION_PLAN.json';assert not p.exists();p.write_text(json.dumps(plan,indent=2));print(rec(p))
