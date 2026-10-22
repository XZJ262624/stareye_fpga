"""Run only after Work accepts REGISTERED_DSP_EXACT_COVERAGE_V4."""
from common import *
import sys
assert sys.argv[1:]==['--work-approved-v4-proof']
F=R/json.loads((O/'ACTIVE_PHYSICAL.json').read_text())['path'];assert json.loads((F/'REGISTERED_DSP_EXACT_COVERAGE_V4.json').read_text())['passed'];assert json.loads((O/'PHYSICAL_CLOSED_RECEIPT.json').read_text())['passed']
save(O/'PHYSICAL_STAGE_COMPLETE.json',dict(passed=True,status='PASS_FRESH_PHYSICAL_WITH_REGISTERED_DSP_V4_COVERAGE',physical=F.relative_to(R).as_posix(),clock_recovery=rec(F/'REGISTERED_DSP_EXACT_COVERAGE_V4.json'),prior_failure=rec(O/'MANAGER_EXCEPTION.json'),source_or_constraint_changes=[],native_queries_rerun=[],hardware_next=False))
W=O/'delivery_recovery_v2';W.mkdir()
save(W/'AUTHORIZATION_AND_SCOPE.json',dict(work_accepted_v4_proof=True,allowed='Offline image generation and candidate proposal only',prior_followon_stopped=True,old_failure_preserved=True,hardware_next=False))
try:
 for name in ['generate_offline_image_v2.py','seal_delivery_v1.py']:
  phase=json.loads((O/'PHASE_RESULT.json').read_text());phase.update(status='RUNNING',running=True,phase=name,heartbeat=time.time());save(O/'PHASE_RESULT.json',phase);heartbeat(name,manager_pid=os.getpid())
  execute(W,name.removesuffix('.py'),[str(E/'python311/bin/python.exe'),'-B',str(Path(__file__).parent/name)],timeout=1800)
 save(W/'RESULT.json',dict(passed=True,running=False,no_hardware=True,no_git_mutation=True))
 print('ORIENTATION_ALL_AUTHORIZED_OFFLINE_WORK_COMPLETE_V2',flush=True)
except Exception as e:
 save(W/'RESULT.json',dict(passed=False,running=False,error=repr(e)));raise
