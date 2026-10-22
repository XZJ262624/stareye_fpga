from common import *
import shutil
old=R/json.loads((O/'ACTIVE_PHYSICAL.json').read_text())['path'];archive=old/'STA_FAILURE_PRESERVED';archive.mkdir()
for p in [P/'Ti60_Demo_I3.sdc']+list((P/'outflow').glob('canny_*'))+[P/'outflow/Ti60_Demo.route.rpt',P/'outflow/Ti60_Demo.place.rpt']:
 shutil.copyfile(p,archive/p.name)
src=(P/'work_pnr').resolve();dst=(archive/'work_pnr').resolve();assert src.is_relative_to(R.resolve()) and dst.is_relative_to(R.resolve()) and not dst.exists();shutil.move(src,dst)
save(archive/'FAILURE.json',dict(status='FAIL_MISSING_PHYSICAL_ALIAS_LAUNCH_SELECTORS',setup=-0.816,hold=0.012,reason='Offer bundle active_descriptor fields alias to lease_identity physical FF; initial prefix-based source enumeration omitted them',rtl_change=False,source_manifest=rec(O/'SOURCE_MANIFEST.json'),files=[rec(p) for p in archive.iterdir() if p.is_file()]))
new=O/('physical_rebind_'+time.strftime('%Y%m%d_%H%M%S'));new.mkdir();save(O/'ACTIVE_PHYSICAL.json',dict(path=new.relative_to(R).as_posix(),project=P.relative_to(R).as_posix(),map_interface_reused=old.relative_to(R).as_posix(),map=rec(P/'outflow/Ti60_Demo.map.v'),prior_failure=rec(archive/'FAILURE.json')))
print('PRESERVED',archive)
