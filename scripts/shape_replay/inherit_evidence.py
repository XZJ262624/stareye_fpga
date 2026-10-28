from common import *
old=R/'reports/canny_replay_20261028';selected=[]
for run,names in [('suite_20261028_175410',['controls','guard','replay32']),('suite_20261028_175717',['fault1','fault2','fault3','fault4','fault5','fault6','720p','pixels'])]:
 w=old/run;inputs=json.loads((w/'INPUTS.json').read_text());bindings=[]
 for x in inputs:
  src=R/x['path'];raw=src.read_bytes();historical=False
  if hashlib.sha256(raw).hexdigest()!=x['sha256']:
   assert run=='suite_20261028_175410' and x['path']=='tb/canny_replay/tb_replay.sv',x
   raw=raw.replace(b'display_offset!=0&&dut.video.frame_used&&!dut.stop&&!dut.video_fault&&!dut.quarantine',b'display_offset!=0&&dut.video.frame_used')
   raw=raw.replace(b'wait(recorded>=(CF==2?1:2))',b'wait(recorded>=2)')
   assert hashlib.sha256(raw).hexdigest()==x['sha256'],x
   historical=True
  dst=O/'inherited_inputs'/run/x['path'];dst.parent.mkdir(parents=True,exist_ok=True);dst.write_bytes(raw)
  assert dst.stat().st_size==x['bytes'] and hashlib.sha256(raw).hexdigest()==x['sha256']
  bindings.append(dict(original=x,frozen_copy=rec(dst),historical_fixture_reconstructed=historical))
 for name in names:
  r=json.loads((w/(name+'_RESULT.json')).read_text());assert r['passed'];assert rec(R/r['log']['path'])==r['log']
  selected.append(dict(run=run,case=name,result=rec(w/(name+'_RESULT.json')),log=r['log'],inputs=rec(w/'INPUTS.json')))
 save(O/'inherited_inputs'/run/'BINDING.json',dict(passed=True,inputs=bindings))
save(O/'INHERITED_REPLAY_EVIDENCE.json',dict(passed=True,cases=selected,scope='Unchanged replay DMA/arbiter/frontend/FIFO/mailbox/failstop. CF32 at8192B proves32slot order and loop. Full720p parent usesCF2. New merged integration usesCF3; productionCF32 is not a32frame full720p simulation claim.',fixture_revision='First selected group passed controls/guard/replay32 but whole group later failed fault1 because normal partial-display assertion disallowed specified hardstop. Remaining group corrected only real-fault exemption and CF2 cancellation scheduling; productionRTL unchanged. Exact earlier TB bytes reconstructed and SHA-verified. No failed final receipt relabelled PASS.'))
print('INHERITED_BOUND',len(selected))
