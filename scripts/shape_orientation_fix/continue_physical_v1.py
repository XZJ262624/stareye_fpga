from common import *
F=R/json.loads((O/'ACTIVE_PHYSICAL.json').read_text())['path'];W=F/'orientation_manager';W.mkdir()
try:
 for script,args in [('prepare_query_v2.py',[]),('build_physical_v2.py',['query']),('pixel_mapped_cones_v2_derived.py',[str(F)]),('build_physical_v2.py',['place']),('build_physical_v2.py',['route']),('run_full_sta_manager_v1.py',[]),('final_audit_manager_v1.py',[]),('audit_native_clocks_v3.py',[])]:
  label=script.removesuffix('.py')+('_'+args[0] if args and args[0]in['query','place','route']else'')
  heartbeat(label,manager_pid=os.getpid())
  execute(W,label,[str(E/'python311/bin/python.exe'),'-B',str(Path(__file__).parent/script),*args],timeout=10800)
 save(O/'PHYSICAL_STAGE_COMPLETE.json',dict(passed=True,status='PASS_FRESH_ORIENTATION_PHYSICAL_OFFLINE_IMAGE_PENDING',physical=F.relative_to(R).as_posix(),hardware_next=False))
 print('ORIENTATION_FRESH_PHYSICAL_COMPLETE',flush=True)
except Exception as e:
 save(O/'MANAGER_EXCEPTION.json',dict(status='REQUIRES_WRITER_INSPECTION',error=repr(e),physical=F.relative_to(R).as_posix(),hardware_next=False));raise
