"""Full official build only of the independent diagnostic, with input/output binding."""
from pathlib import Path
import hashlib,json,subprocess,datetime
ROOT=Path(__file__).resolve().parents[1];W=ROOT/'efinity/m5b0r_ddr_address_diag_i3';R=ROOT/'reports/m5b0r_ddr_admission/build'
def rec(p):return dict(path=p.relative_to(ROOT).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def inputs():
 paths=[W/'M5B0R_DdrDiag.xml',W/'M5B0R_DdrDiag.peri.xml',W/'M5B0R_DdrDiag.sdc']+list((W/'ip/DdrCtrl').glob('*'))
 paths += [ROOT/'rtl/m5b0r_ddr_admission'/n for n in ('m5b0r_top.sv','m5b0r_monitor.sv','m5b0r_diagnostic.sv','m5b0r_transaction.sv')]
 return [rec(p) for p in sorted(paths) if p.is_file()]
R.mkdir(parents=True,exist_ok=True);before=inputs();(R/'inputs_before.json').write_text(json.dumps(before,indent=2))
cmd=['cmd','/c',str(ROOT/'scripts/m5b0r_compile.bat')];start=datetime.datetime.now(datetime.timezone.utc).isoformat()
with (R/'compile.log').open('wb') as f:r=subprocess.run(cmd,cwd=ROOT,stdout=f,stderr=subprocess.STDOUT)
after=inputs();(R/'inputs_after.json').write_text(json.dumps(after,indent=2))
outputs=[rec(p) for folder in ('outflow','work_pnr') for p in sorted((W/folder).rglob('*')) if p.is_file()]
(R/'result.json').write_text(json.dumps(dict(command=cmd,start=start,end=datetime.datetime.now(datetime.timezone.utc).isoformat(),exit_code=r.returncode,outputs=outputs),indent=2))
print('M5B0R_BUILD_EXIT',r.returncode,flush=True)
raise SystemExit(r.returncode)
