from pathlib import Path
import hashlib,json,subprocess,datetime,sys
root=Path(__file__).resolve().parents[1]; work=root/'efinity/m31_sobel_controls_i3'
report=root/'reports/m31_sobel_controls_i3/build'; report.mkdir(parents=True,exist_ok=True)
def record(p): return {'path':p.relative_to(root).as_posix(),'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
def inputs():
    return sorted([record(p) for base in (work,root/'rtl/m31_sobel_controls',root/'rtl/m3_sobel_core') for p in base.rglob('*') if p.is_file() and not any(x in ('outflow','work_syn','work_pnr','work_pt','ipm','work','cache') for x in p.relative_to(base).parts)],key=lambda x:x['path'])
before=inputs(); (report/'input_before.json').write_text(json.dumps(before,indent=2))
(report/'project_before.xml').write_bytes((work/'Ti60_Demo.xml').read_bytes())
start=datetime.datetime.now(datetime.timezone.utc).isoformat()
with (report/'compile.log').open('wb') as f:
    result=subprocess.run(['cmd','/c',str(root/'scripts/m31_sobel_controls_compile.bat')],stdout=f,stderr=subprocess.STDOUT,cwd=root)
after=inputs(); (report/'input_after.json').write_text(json.dumps(after,indent=2))
(report/'project_after.xml').write_bytes((work/'Ti60_Demo.xml').read_bytes())
outputs=[record(p) for d in ('outflow','work_pnr') for p in (work/d).rglob('*') if p.is_file()]
(report/'result.json').write_text(json.dumps({'start':start,'end':datetime.datetime.now(datetime.timezone.utc).isoformat(),'exit_code':result.returncode,'command':'scripts/m31_sobel_controls_compile.bat','before_count':len(before),'after_count':len(after),'outputs':outputs},indent=2))
print('M31_BUILD_EXIT',result.returncode); sys.exit(result.returncode)
