from common import *
import shutil
F=R/json.loads((O/'ACTIVE_PHYSICAL.json').read_text())['path'];V=R/json.loads((O/'ACTIVE_TESTS.json').read_text())['path']
S=F/'superseded';S.mkdir();files=set()
files.update(R/x['path'] for x in json.loads((F/'BIT_INPUTS.json').read_text()))
files.update(p for p in (P/'outflow').iterdir() if p.is_file())
files.update(R/x['path'] for x in json.loads((F/'PRODUCTION_INPUTS.json').read_text()))
files.add(O/'artifacts/StarEye_Shape_Replay.bit')
manifest=[]
for p in sorted(files):
 d=S/p.relative_to(R);d.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,d);manifest.append(dict(source=rec(p),preserved=rec(d)))
save(F/'SUPERSEDED_INPUTS.json',manifest)
save(V/'STOP_REASON.json',dict(status='BLOCKED_BY_CONFIRMED_CONTROL_BUG',reason='Release held<=0 is overwritten by old stable pressed counter increment. Repeated short presses accumulate and third K1 short emits long command1. Main resume can return LIVE instead of PLAY and wait indefinitely for play_index change.',reproduction='reports/shape_replay_20261028/control_probe_20261028_190845/probe.log',action='Stop only owned original vsim36520 and vsimk25780; preserve raw FAIL, fix only new shape_replay controls, rerun affected integration and fresh physical. Original BIT superseded, not hardware-qualified.',created_unix=time.time()))
print('PRESERVED',len(manifest))
