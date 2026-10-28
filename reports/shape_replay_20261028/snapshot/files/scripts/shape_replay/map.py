from common import *
W=O/('physical_'+time.strftime('%Y%m%d_%H%M%S'));W.mkdir(parents=True)
save(O/'ACTIVE_PHYSICAL.json',dict(path=W.relative_to(R).as_posix()))
save(W/'INPUTS_BEFORE_MAP.json',[rec(p) for d in (T,P) for p in sorted(d.rglob('*')) if p.is_file()])
(W/'PROJECT_BEFORE_MAP.xml').write_bytes((P/'Ti60_Demo.xml').read_bytes())
result=W/'FINAL_RESULT.json';watch(W,'shape_replay_physical',result)
prefix='call E:\\Efinity\\2025.1\\bin\\setup.bat && '
try:
 for stage in ('map','interface'):
  execute(W/stage,stage,['cmd.exe','/d','/c',prefix+'call E:\\Efinity\\2025.1\\bin\\efx_run.bat Ti60_Demo.xml --flow '+stage],None,cwd=P)
  assert re.search(r'\b'+stage+r'\s*:\s*PASS\b',(W/stage/(stage+'.log')).read_text(errors='replace'))
 save(W/'MAP_RESULT.json',dict(passed=True))
except Exception as e:
 save(result,dict(status='FAIL_MAP',passed=False,running=False,error=str(e)));raise
print('MAP_INTERFACE_PASS',flush=True)
