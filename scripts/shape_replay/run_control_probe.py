from common import *
W=O/('control_probe_'+time.strftime('%Y%m%d_%H%M%S'));W.mkdir();files=[T/'shape_replay_controls.sv',R/'tb/shape_replay/tb_repeated_short.sv'];save(W/'INPUTS.json',[rec(p) for p in files])
for p in files:(W/p.name).write_bytes(p.read_bytes())
try:
 execute(W,'vlib',[str(M/'vlib.exe'),'work'])
 execute(W,'vlog',[str(M/'vlog.exe'),'-sv','-work','work']+[str(p) for p in files])
 put(W/'probe.do','onerror {quit -code 11}\nonbreak {quit -code 12}\nrun -all\nquit -code 0\n')
 result=execute(W,'probe',[str(M/'vsim.exe'),'-c','-novopt','-onfinish','exit','work.tb_repeated_short','-wlf','NUL','-do','do {'+(W/'probe.do').as_posix()+'}'],'REPEATED_SHORT_PASS')
 save(W/'FINAL_RESULT.json',dict(passed=True,result=result))
except Exception as e:save(W/'FINAL_RESULT.json',dict(passed=False,error=str(e)));raise
