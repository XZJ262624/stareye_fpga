from common import *
W=O/('system_'+time.strftime('%H%M%S'));W.mkdir();save(O/'ACTIVE_SYSTEM.json',dict(path=W.relative_to(R).as_posix()))
for label,cmd in [('vlib',[str(M/'vlib.exe'),'work']),('vmap_create',[str(M/'vmap.exe'),'-c']),('vmap_work',[str(M/'vmap.exe'),'-modelsimini','modelsim.ini','work',(W/'work').as_posix()])]:execute(W,label,cmd)
files=list((R/'rtl/canny_gaussian_standalone').rglob('*.sv'))+list((R/'rtl/canny_gaussian_standalone').rglob('*.v'))+[P/'src/lcd_driver.v',R/'tb/gaussian_integration/m5c1b_ddr_service_model.sv',R/'tb/canny_gaussian_standalone/tb_canny_system.sv']
save(W/'INPUTS.json',[rec(p) for p in files]+[rec(p) for p in (O/'data').iterdir()]);execute(W,'compile',[str(M/'vlog.exe'),'-modelsimini','modelsim.ini','-sv','-work','work','+incdir+'+str(R/'rtl/canny_gaussian_standalone/m5c'),'+incdir+'+str(P/'src'),*[str(p) for p in files]])
(W/'run.do').write_text('onerror {quit -code 11}\nonbreak {quit -code 12}\nrun -all\nquit -code 0\n')
args=['+GOLD='+str(O/'data/med.hex'),'+GAU='+str(O/'data/gau.hex'),'+GAU80='+str(O/'data/gau80.hex')]+['+'+k+'='+str(O/'data'/v) for k,v in [('MED_BFS','med_bfs.hex'),('GAU_BFS','gau_bfs.hex'),('GAU80_BFS','gau80_bfs.hex')]]
# Only request cadence accelerated for finite integration coverage. Pixel,
# camera, UI clocks, service384, full dimensions, TTL and engines unchanged.
r=execute(W,'sim',[str(M/'vsim.exe'),'-c','-novopt','-onfinish','exit','-modelsimini','modelsim.ini','-lib','work','tb_canny_system','-gBG_REQUEST_CYCLES=2000000',*args,'-wlf','NUL','-do','do {'+(W/'run.do').as_posix()+'}'],'PASS_CANNY_SYSTEM',7200)
verify(json.loads((W/'INPUTS.json').read_text()));save(O/'SYSTEM_RESULT.json',dict(passed=True,result=r,test_request_cycles=2000000,production_request_cycles=96000000));print('SYSTEM_PASS',flush=True)
