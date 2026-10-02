from pathlib import Path
import hashlib,json,subprocess,datetime
root=Path('F:/Projects/stareye_fpga'); w=root/'efinity/m2_ar0135_ddr_hdmi_i3'; r=root/'reports/m2_ar0135_ddr_hdmi_i3/final_build'; r.mkdir(parents=True,exist_ok=True)
def rec(p): return {'path':p.relative_to(w).as_posix(),'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest().upper()}
files=[p for p in w.rglob('*') if p.is_file() and not any(x.startswith('work') or x in ['outflow','ipm'] for x in p.relative_to(w).parts)]
before=[rec(p) for p in files]; (r/'build_input_before.json').write_text(json.dumps(before,indent=2))
(r/'project_before.xml').write_bytes((w/'Ti60_Demo.xml').read_bytes())
start=datetime.datetime.now(datetime.timezone.utc).isoformat()
with (r/'compile.log').open('wb') as f: x=subprocess.run(['cmd','/c',str(root/'scripts/m2_ar0135_ddr_hdmi_i3_compile.bat')],stdout=f,stderr=subprocess.STDOUT,cwd=root)
(r/'project_after.xml').write_bytes((w/'Ti60_Demo.xml').read_bytes())
after=[rec(p) for p in files]; (r/'build_input_after.json').write_text(json.dumps(after,indent=2))
outputs=[rec(p) for folder in ['outflow','work_pnr'] for p in (w/folder).rglob('*') if p.is_file()]
(r/'build_result.json').write_text(json.dumps({'start':start,'end':datetime.datetime.now(datetime.timezone.utc).isoformat(),'exit_code':x.returncode,'command':'scripts/m2_ar0135_ddr_hdmi_i3_compile.bat','inputs_changed':[a['path'] for a,b in zip(before,after) if a!=b],'outputs':outputs},indent=2))
print('COMPILE_EXIT',x.returncode)
