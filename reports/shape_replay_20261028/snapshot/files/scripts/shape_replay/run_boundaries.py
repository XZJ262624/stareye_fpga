from common import *
W=O/('boundaries_'+time.strftime('%Y%m%d_%H%M%S'));W.mkdir(parents=True);save(O/'ACTIVE_BOUNDARIES.json',dict(path=W.relative_to(R).as_posix()))
final=W/'FINAL_RESULT.json';watch(W,'shape_replay_boundaries',final)
files=sorted(T.rglob('*.sv'))+sorted(T.rglob('*.v'))+[R/'tb/shape_replay/tb_retire_clip.sv',R/'tb/shape_replay/tb_context_boundary.sv',P/'src/lcd_driver.v']
K=R/'reports/gaussian_cap_remote_v2_20261021/package/gaussian_matrix_gold';inputs=[rec(p) for p in files]+[rec(P/'src/lcd_para.v')]+[rec(K/f'f2_{i}_64.hex') for i in range(3)];save(W/'INPUTS.json',inputs)
try:
 execute(W,'vlib',[str(M/'vlib.exe'),'work']);execute(W,'vlog',[str(M/'vlog.exe'),'-sv','-work','work','+incdir+'+str(P/'src')]+[str(p) for p in files])
 results=[]
 for name,top,marker in [('retirement','tb_retire_clip','RETIRE_CLIP_PASS'),('context','tb_context_boundary','CONTEXT_BOUNDARY_PASS')]:
  put(W/(name+'.do'),'onerror {quit -code 11}\nonbreak {quit -code 12}\nrun -all\nquit -code 0\n')
  results.append(execute(W,name,[str(M/'vsim.exe'),'-c','-novopt','-onfinish','exit','work.'+top,'+GOLDROOT='+str(K),'-wlf','NUL','-do','do {'+(W/(name+'.do')).as_posix()+'}'],marker))
 verify(inputs);save(final,dict(passed=True,status='PASS',running=False,results=results,inputs=rec(W/'INPUTS.json')));time.sleep(12)
except Exception as e:
 save(final,dict(passed=False,status='FAIL',running=False,error=str(e)));time.sleep(12);raise
