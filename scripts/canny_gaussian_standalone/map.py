from common import *
W=O/('physical_'+time.strftime('%Y%m%d_%H%M%S'));W.mkdir()
save(O/'ACTIVE_PHYSICAL.json',dict(path=W.relative_to(R).as_posix(),project=P.relative_to(R).as_posix()))
sources=[rec(p) for d in [R/'rtl/canny_gaussian_standalone',P] for p in sorted(d.rglob('*')) if p.is_file() and not any(x.startswith(('work_','outflow')) for x in p.relative_to(d).parts)]
save(W/'INPUTS_BEFORE_MAP.json',sources)
for stage in ('map','interface'):
 execute(W/stage,'native',['cmd.exe','/d','/c',f'call E:\\Efinity\\2025.1\\bin\\setup.bat && call E:\\Efinity\\2025.1\\bin\\efx_run.bat Ti60_Demo.xml --flow {stage}'],None,7200,cwd=P)
 assert re.search(r'\b'+stage+r'\s*:\s*PASS\b',(W/stage/'native.log').read_text(errors='replace'))
save(O/'MAP_RESULT.json',dict(passed=True,physical=W.relative_to(R).as_posix()))
print('MAP_INTERFACE_PASS',flush=True)
