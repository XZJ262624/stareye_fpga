from common import *
W=O/'delivery_manager';W.mkdir();start=time.time()
while not(O/'PHYSICAL_STAGE_COMPLETE.json').exists():
 assert not(O/'MANAGER_EXCEPTION.json').exists(),(O/'MANAGER_EXCEPTION.json').read_text()
 assert time.time()-start<10800
 save(W/'WAIT_STATE.json',dict(running=True,phase='WAIT_FRESH_PHYSICAL',pid=os.getpid(),updated_unix=time.time()))
 time.sleep(10)
assert json.loads((O/'PHYSICAL_STAGE_COMPLETE.json').read_text())['passed']
try:
 for name in ['generate_offline_image_v1.py','seal_delivery_v1.py']:
  heartbeat(name,manager_pid=os.getpid())
  execute(W,name.removesuffix('.py'),[str(E/'python311/bin/python.exe'),'-B',str(Path(__file__).parent/name)],timeout=1800)
 save(W/'RESULT.json',dict(passed=True,running=False,scope='Offline artifact generation and exact candidate proposal only; no Git or hardware.'))
 print('ORIENTATION_ALL_AUTHORIZED_OFFLINE_WORK_COMPLETE',flush=True)
except Exception as e:
 save(W/'RESULT.json',dict(passed=False,running=False,error=repr(e)));raise
