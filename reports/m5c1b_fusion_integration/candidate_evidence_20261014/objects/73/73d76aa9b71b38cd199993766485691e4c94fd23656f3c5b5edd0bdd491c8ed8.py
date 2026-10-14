from pathlib import Path
import json,hashlib,shutil,xml.etree.ElementTree as ET
F=Path(__file__).resolve().parent;R=F.parents[2];B=F.parent/'fresh_i3_build_20261014';C=F/'mirror';P=C/'efinity/m5c_fusion_i3';BP=B/'mirror/efinity/m5c_fusion_i3'
def rec(p):
 b=p.read_bytes();return dict(path=str(p.relative_to(R)) if p.is_relative_to(R) else str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def put(n,x):
 p=F/n;assert not p.exists();p.write_text(json.dumps(x,indent=2))
manifest=json.loads((B/'HANDBACK_MANIFEST.json').read_text());qualified={}
for x in manifest['records']:
 p=R/x['path'];z=rec(p);assert (z['bytes'],z['sha256'])==(x['bytes'],x['sha256']);qualified[p.resolve()]=x
sel=json.loads((F.parent/'final_source_selection_20261013_063600/SELECTED_SOURCE_IDENTITY.json').read_text())['records'];rows=[];settings=[]
for x in sel:
 p=R/x['adopted']['path'];z=rec(p);assert (z['bytes'],z['sha256'])==(x['adopted']['bytes'],x['adopted']['sha256']);q=C/x['target'];assert q.resolve().is_relative_to(C);q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,q)
 if q.name=='settings.json':
  a=json.loads(p.read_text());b=json.loads(p.read_text());i=b['args'].index('--base_path')+1;old=b['args'][i];b['args'][i]=str(P/'ip');q.write_text(json.dumps(b,indent=4)+'\n');check=json.loads(q.read_text());check['args'][i]=old;assert check==a;settings.append(dict(original=z,copy=rec(q),old=old,new=b['args'][i]))
 rows.append(dict(original=z,copy=rec(q)))
assert len(rows)==101 and len(settings)==11
whitelist=['work_pnr/Ti60_Demo.lbf','outflow/Ti60_Demo.lpf','outflow/Ti60_Demo_or.ini','outflow/Ti60_Demo.map.v','outflow/Ti60_Demo.vdb','outflow/Ti60_Demo.troutingtraces','outflow/Ti60_Demo.interface.io','outflow/Ti60_Demo.pt.sdc']
ar=json.loads((B/'route/POST_NATIVE_ARCHIVE.json').read_text())['records'];byname={x['original']['path']:x for x in ar};db=[]
for n in whitelist:
 p=BP/n;q=P/n;z=rec(p);assert p.resolve() in qualified;q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,q)
 hist=next(x for x in ar if (R/x['original']['path']).resolve()==p.resolve());assert z['sha256']==hist['archive']['sha256'];db.append(dict(original=z,copy=rec(q),qualified_manifest=qualified[p.resolve()],route_archive=hist['archive']))
assert not list(C.rglob('efx_pgm_settings.ini'))
root=ET.parse(P/'Ti60_Demo.xml').getroot();ns={'e':'http://www.efinixinc.com/enf_proj'};bit={e.get('name'):e.get('value') for e in root.findall('e:bitstream_generation/e:param',ns)};plan=json.loads((B/'NEXT_OFFLINE_ARTIFACT_CANDIDATE_PLAN.json').read_text());assert bit==plan['project_bitstream_parameters']
security={e.get('name'):e.get('value') for e in root.findall('e:security/e:param',ns)};assert security.get('enable_bitstream_encrypt','off')=='off' and security.get('enable_bitstream_auth','off')=='off'
tools=[]
for n in ['scripts/efx_run.py','scripts/efx_run_pgm.py','pgm/bin/efx_pgm/export_bitstream.py','bin/efx_pgm.exe','scripts/sw_version.txt','bin/efx_run.bat','bin/setup.bat']:tools.append(rec(Path('E:/Efinity/2025.1')/n))
put('INPUT_WHITELIST.json',dict(source=rows,settings=settings,database=db,qualified_build_manifest=rec(B/'HANDBACK_MANIFEST.json'),tools=tools,bitstream=bit,security=security,version=Path('E:/Efinity/2025.1/scripts/sw_version.txt').read_text(),freeze=rec(F.parent/'OFFLINE_BITSTREAM_EXECUTION_FREEZE_20261014.md')))
print('PREPARED',len(rows),len(settings),len(db),flush=True)
