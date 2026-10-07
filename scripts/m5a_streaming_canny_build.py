"""Two isolated full official I3 builds; never touches older engineering scopes."""
from pathlib import Path
import hashlib,json,subprocess,datetime,sys
ROOT=Path(__file__).resolve().parents[1]
R=ROOT/'reports/m5a_streaming_canny_i3'
VARIANTS=('m5a_streaming_canny_i3',)
def record(p): return {'path':p.relative_to(ROOT).as_posix(),'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
def inputs(work):
    return sorted([record(p) for base in (work,ROOT/'rtl/m5a_streaming_canny') for p in base.rglob('*') if p.is_file() and p.name!='.lock' and not any(x in ('outflow','work_syn','work_pnr','work_pt','ipm','work','cache') for x in p.relative_to(base).parts)],key=lambda x:x['path'])
def build(variant):
    work=ROOT/'efinity'/variant; report=R/variant/'build';report.mkdir(parents=True,exist_ok=True)
    before=inputs(work); (report/'input_before.json').write_text(json.dumps(before,indent=2))
    (report/'project_before.xml').write_bytes((work/'Ti60_Demo.xml').read_bytes())
    start=datetime.datetime.now(datetime.timezone.utc).isoformat()
    command=['cmd','/c',str(ROOT/'scripts/m5a_streaming_canny_compile.bat'),variant]
    with (report/'compile.log').open('wb') as f:
        result=subprocess.run(command,stdout=f,stderr=subprocess.STDOUT,cwd=ROOT)
    after=inputs(work); (report/'input_after.json').write_text(json.dumps(after,indent=2))
    (report/'project_after.xml').write_bytes((work/'Ti60_Demo.xml').read_bytes())
    outputs=[record(p) for d in ('outflow','work_pnr') for p in (work/d).rglob('*') if p.is_file()]
    (report/'result.json').write_text(json.dumps({'start':start,'end':datetime.datetime.now(datetime.timezone.utc).isoformat(),'exit_code':result.returncode,'command':command,'before_count':len(before),'after_count':len(after),'outputs':outputs},indent=2))
    print('M5A_BUILD_EXIT',variant,result.returncode,flush=True)
    if result.returncode: raise SystemExit(result.returncode)
if __name__=='__main__':
    for v in VARIANTS:build(v)
