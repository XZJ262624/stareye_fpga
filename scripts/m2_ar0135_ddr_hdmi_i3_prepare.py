from pathlib import Path
import hashlib,json,shutil
root=Path('F:/Projects/stareye_fpga'); src=root/'document/VF-Ti60F225_HDK_V2.1_20251009/07-FPGA_HDL_Image-2023.2/01-1_Ti60_AR0135_HDMI_1280720'; dst=root/'efinity/m2_ar0135_ddr_hdmi_i3'; report=root/'reports/m2_ar0135_ddr_hdmi_i3'; report.mkdir(parents=True,exist_ok=True)
def manifest(base):
 out={}
 for p in base.rglob('*'):
  if p.is_file():
   s=p.stat()
   try: h=hashlib.sha256(p.read_bytes()).hexdigest()
   except PermissionError: h='UNREADABLE_LOCKED'
   out[p.relative_to(base).as_posix()]={'size':s.st_size,'mtime_ns':s.st_mtime_ns,'sha256':h}
 return out
for name,base in [('original',src),('m0',root/'efinity/m0_led_i3'),('m1',root/'efinity/m1_hdmi_i3')]:
 (report/(name+'_before.json')).write_text(json.dumps(manifest(base),indent=2))
assert not dst.exists(); dst.mkdir()
for name in ['example_top.v','Ti60_Demo.xml','Ti60_Demo.peri.xml','Ti60_Demo.pt.sdc']: shutil.copy2(src/name,dst/name)
for name in ['src','ip']: shutil.copytree(src/name,dst/name,ignore=shutil.ignore_patterns('work_*','outflow','ipm','*.pickle'))
print('COPY_COMPLETE')

