"""Run official I3 STA on a fresh clone; never alter the final implementation."""
from pathlib import Path
import shutil,subprocess,json,hashlib,datetime
root=Path(__file__).resolve().parents[1];w=root/'efinity/m31_sobel_controls_i3'
r=root/'reports/m31_sobel_controls_i3/final_audit';r.mkdir(parents=True,exist_ok=True)
clone=w/'work'/('audit_'+datetime.datetime.now().strftime('%Y%m%d_%H%M%S'));clone.mkdir(parents=True)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def snap():
 return {p.relative_to(w).as_posix():{'bytes':p.stat().st_size,'sha256':sha(p),'mtime_ns':p.stat().st_mtime_ns} for d in ('outflow','work_pnr') for p in (w/d).rglob('*') if p.is_file()}
before=snap()
for d in ('outflow','work_pnr'):shutil.copytree(w/d,clone/d)
for n in ('Ti60_Demo.xml','Ti60_Demo.peri.xml','Ti60_Demo_I3.sdc'):shutil.copy2(w/n,clone/n)
clone_initial={k:sha(clone/k) for k in before}
assert all(v['sha256']==clone_initial[k] for k,v in before.items())
(clone/'work_pnr/sdc_file_list').write_text(str(clone/'Ti60_Demo_I3.sdc')+'\n')
shutil.copy2(root/'scripts/m31_sobel_controls_audit.tcl',clone/'audit.tcl')
command=['E:/Efinity/2025.1/bin/efx_sta.exe','--prj','Ti60_Demo','--output_dir','outflow','--tclsh','audit.tcl']
x=subprocess.run(command,cwd=clone,capture_output=True)
(r/'audit.log').write_bytes(x.stdout+x.stderr)
reports=[]
for f in sorted((clone/'outflow').glob('m31_*.rpt')):
 shutil.copy2(f,r/f.name);reports.append({'path':f.name,'bytes':f.stat().st_size,'sha256':sha(f)})
after=snap()
(r/'binding.json').write_text(json.dumps({'exit_code':x.returncode,'original_unchanged':before==after,'original_before':before,'original_after':after,'clone':str(clone),'clone_initial_hashes':clone_initial,'sdc_sha256':sha(clone/'Ti60_Demo_I3.sdc'),'tcl_sha256':sha(clone/'audit.tcl'),'command':command,'audit_log_sha256':sha(r/'audit.log'),'reports':reports},indent=2))
assert before==after
assert x.returncode==0 and b'M31_AUDIT_COMPLETE' in x.stdout and b'ERROR' not in x.stdout+x.stderr
assert len(reports)==94,len(reports)
print('M31_AUDIT_PASS reports',len(reports))
