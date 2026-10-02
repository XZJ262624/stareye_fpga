from pathlib import Path
import os,shutil,subprocess,json,hashlib
root=Path('F:/Projects/stareye_fpga'); w=root/'efinity/m2_ar0135_ddr_hdmi_i3'; r=root/'reports/m2_ar0135_ddr_hdmi_i3/final_audit'; r.mkdir(parents=True,exist_ok=True); clone=w/'work/audit_final'; clone.mkdir(parents=True,exist_ok=True)
def snap():
 return {p.relative_to(w).as_posix():{'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest().upper(),'mtime_ns':p.stat().st_mtime_ns} for d in ['outflow','work_pnr'] for p in (w/d).rglob('*') if p.is_file()}
before=snap()
for d in ['outflow','work_pnr']: shutil.copytree(w/d,clone/d,dirs_exist_ok=True)
for n in ['Ti60_Demo.xml','Ti60_Demo.peri.xml','Ti60_Demo_I3.sdc']: shutil.copy2(w/n,clone/n)
(clone/'work_pnr/sdc_file_list').write_text(str(clone/'Ti60_Demo_I3.sdc')+'\n')
shutil.copy2(root/'scripts/m2_ar0135_ddr_hdmi_i3_audit.tcl',clone/'audit.tcl')
x=subprocess.run(['E:/Efinity/2025.1/bin/efx_sta.exe','--prj','Ti60_Demo','--output_dir','outflow','--tclsh','audit.tcl'],cwd=clone,capture_output=True)
(r/'audit.log').write_bytes(x.stdout+x.stderr)
for f in (clone/'outflow').glob('m2_*.rpt'): shutil.copy2(f,r/f.name)
after=snap(); assert before==after
(r/'binding.json').write_text(json.dumps({'exit_code':x.returncode,'original_unchanged':before==after,'original_before':before,'original_after':after,'clone':str(clone),'sdc_sha256':hashlib.sha256((clone/'Ti60_Demo_I3.sdc').read_bytes()).hexdigest().upper(),'tcl_sha256':hashlib.sha256((clone/'audit.tcl').read_bytes()).hexdigest().upper()},indent=2))
assert x.returncode==0, 'STA process failed'
assert b'ERROR' not in x.stdout+x.stderr, 'STA errors in log'
assert b'M2_AUDIT_COMPLETE' in x.stdout
assert len(list(r.glob('m2_*.rpt')))>=20
print('AUDIT_EXIT',x.returncode)
