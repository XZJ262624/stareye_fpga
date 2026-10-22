from common import *
W=O/('backend_'+time.strftime('%H%M%S'));W.mkdir()
for label,cmd in [('vlib',[str(M/'vlib.exe'),'work']),('vmap_create',[str(M/'vmap.exe'),'-c']),('vmap_work',[str(M/'vmap.exe'),'-modelsimini','modelsim.ini','work',(W/'work').as_posix()])]:execute(W,label,cmd)
files=list((R/'rtl/canny_gaussian_standalone').rglob('*.sv'))+list((R/'rtl/canny_gaussian_standalone').rglob('*.v'))+[R/'tb/gaussian_integration/m5c1b_ddr_service_model.sv',R/'tb/canny_gaussian_standalone/tb_backend.sv']
save(W/'INPUTS.json',[rec(p) for p in files]);execute(W,'compile',[str(M/'vlog.exe'),'-modelsimini','modelsim.ini','-sv','-work','work','+incdir+'+str(R/'rtl/canny_gaussian_standalone/m5c'),*[str(p) for p in files]])
(W/'run.do').write_text('onerror {quit -code 11}\nonbreak {quit -code 12}\nrun -all\nquit -code 0\n')
r=execute(W,'sim',[str(M/'vsim.exe'),'-c','-novopt','-onfinish','exit','-modelsimini','modelsim.ini','-lib','work','tb_backend','-wlf','NUL','-do','do {'+(W/'run.do').as_posix()+'}'],'PASS_CANNY_BACKEND',5400)
verify(json.loads((W/'INPUTS.json').read_text()));save(O/'BACKEND_RESULT.json',dict(passed=True,result=r));print('BACKEND_PASS',flush=True)
