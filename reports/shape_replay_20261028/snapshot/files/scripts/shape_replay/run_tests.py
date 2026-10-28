from common import *
W=O/('tests_'+time.strftime('%Y%m%d_%H%M%S'));W.mkdir(parents=True);save(O/'ACTIVE_TESTS.json',dict(path=W.relative_to(R).as_posix()))
final=W/'FINAL_RESULT.json';watch(W,'shape_replay_tests',final)
files=sorted(T.rglob('*.sv'))+sorted(T.rglob('*.v'))+sorted((R/'tb/shape_replay').glob('*.sv'))+[P/'src/lcd_driver.v']
K=R/'reports/gaussian_cap_remote_v2_20261021/package/gaussian_matrix_gold';D=R/'reports/shape_wide_roi_fast_20261022/test_data'
inputs=[rec(p) for p in files]+[rec(P/'src/lcd_para.v')]+[rec(K/f'f2_{i}_64.hex') for i in range(3)]+[rec(p) for p in sorted(D.glob('*'))]
save(W/'INPUTS.json',inputs)
try:
 execute(W,'vlib',[str(M/'vlib.exe'),'work'])
 execute(W,'vlog',[str(M/'vlog.exe'),'-sv','-work','work','+incdir+'+str(P/'src')]+[str(p) for p in files])
 results=[]
 for name,top,args,marker in [('controls','tb_shape_controls',[],'SHAPE_CONTROLS_PASS'),('repeated_short','tb_repeated_short',[],'REPEATED_SHORT_PASS'),('boundary41','tb_wide_recognizer',['+ROOT='+str(D)],'PASS_WIDE_RECOGNIZER'),('integration720p','tb_shape_replay',['+GOLDROOT='+str(K)],'SHAPE_REPLAY_PASS')]:
  put(W/(name+'.do'),'onerror {quit -code 11}\nonbreak {quit -code 12}\nrun -all\nquit -code 0\n')
  results.append(execute(W,name,[str(M/'vsim.exe'),'-c','-novopt','-onfinish','exit','work.'+top]+args+['-wlf','NUL','-do','do {'+(W/(name+'.do')).as_posix()+'}'],marker))
 verify(inputs);save(final,dict(passed=True,status='PASS',running=False,results=results,inputs=rec(W/'INPUTS.json')));time.sleep(12)
except Exception as e:
 save(final,dict(passed=False,status='FAIL',running=False,error=str(e)));time.sleep(12);raise
print('TESTS_PASS',flush=True)
