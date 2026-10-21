"""Reproduce the current standalone full720p test, or compile/elaborate100us only."""
from common import *
import argparse
a=argparse.ArgumentParser();a.add_argument('--frames',type=int,choices=[8,72],default=72);a.add_argument('--probe100us',action='store_true');opt=a.parse_args();frames=opt.frames
W=O/('video_current_'+('probe_'if opt.probe100us else'full_')+time.strftime('%Y%m%d_%H%M%S'));W.mkdir();T=R/'tb/shape_standalone';P=R/'efinity/shape_standalone_i3';K=R/'reports/gaussian_cap_remote_v2_20261021/package/gaussian_matrix_gold';X=O/'full720p_oracle';src=[R/n for n in json.loads((O/'COMPILE_SOURCE_FILES.json').read_text())]+[T/n for n in['m5c1b_ddr_service_model.sv','reference_shape_osd.sv','tb_standalone_system720p_v3.sv']];deps=src+[P/'src/lcd_para.v',Path(__file__),Path(__file__).parent/'common.py',O/'COMPILE_SOURCE_FILES.json',X/'expected.hex',X/'expected_valid.hex',X/'ORACLE_BINDING.json']+[K/f'f2_{i}_{h}.hex'for h in[64,80]for i in range(8)];pre=[rec(p)for p in deps];save(W/'INPUTS_PRE.json',pre)
try:
 tests=[]
 for n,c in[('vlib',[str(M/'vlib.exe'),'work']),('vmap_create',[str(M/'vmap.exe'),'-c']),('vmap_work',[str(M/'vmap.exe'),'-modelsimini','modelsim.ini','work',(W/'work').as_posix()])]:tests.append(execute(W,n,c))
 tests.append(execute(W,'compile',[str(M/'vlog.exe'),'-modelsimini','modelsim.ini','-sv','-work','work','+incdir+'+(P/'src').as_posix(),*map(str,src)]))
 body='run 100 us\nputs {PASS_STANDALONE_CURRENT_COMPILE100US_ONLY}\n'if opt.probe100us else'run -all\n';(W/'run.do').write_text('onerror {quit -code 11}\nonbreak {quit -code 12}\n'+body+'quit -code 0\n')
 marker='PASS_STANDALONE_CURRENT_COMPILE100US_ONLY'if opt.probe100us else'PASS_STANDALONE_SYSTEM720P'
 tests.append(execute(W,'native',[str(M/'vsim.exe'),'-c','-novopt','-onfinish','exit','-modelsimini',(W/'modelsim.ini').as_posix(),'-lib','work','tb_standalone_system720p_v3','-gCAMERA_FRAMES='+str(frames),'+GOLDROOT='+K.as_posix(),'+EXPECTEDROOT='+X.as_posix(),'-wlf','NUL','-do','do {'+(W/'run.do').as_posix()+'}'],marker,timeout=120 if opt.probe100us else 1800 if frames==8 else 7200))
 save(W/'RESULT.json',dict(passed=True,frames=frames,compile_elaborate_100us_only=opt.probe100us,full_qualification=not opt.probe100us and frames==72,tests=tests))
 if opt.probe100us:save(O/'CURRENT_RUNNER_COMPILE100US_RECEIPT.json',dict(passed=True,result=rec(W/'RESULT.json'),scope='Current self-contained reproduction helper compiles and elaborates same final productionSUT/TB/oracle for100us only; full72 actual run has separate runner/input receipts.'))
 print('STANDALONE_CURRENT_RUNNER_COMPLETE',frames,'probe_only',opt.probe100us,flush=True)
finally:
 post=[rec(p)for p in deps];save(W/'INPUTS_POST.json',post);assert pre==post
