from common import *
T=R/'tb/shape_wide_roi';W=O/('targeted_tests_'+time.strftime('%H%M%S'));W.mkdir(exist_ok=False)
parent=R/'rtl/shape_standalone/shape/shape_osd.sv';(T/'reference_wide_parent_osd.sv').write_text(parent.read_text().replace('module shape_osd(','module reference_wide_parent_osd('))
sources=[R/'rtl/shape_wide_roi/shape_recognizer_epoch.sv',R/'rtl/shape_wide_roi/shape_osd.sv',R/'rtl/shape_standalone/shape/shape_stream_adapter_contract_v2.sv',T/'reference_wide_parent_osd.sv',T/'tb_wide_recognizer.sv',T/'tb_wide_adapter_osd.sv']
deps=[rec(p) for p in sources]+[rec(p) for p in sorted((O/'test_data').glob('*'))];save(W/'INPUTS_PRE.json',deps)
results=[]
for label,cmd in [('vlib',[str(M/'vlib.exe'),'work']),('vmap_create',[str(M/'vmap.exe'),'-c']),('vmap_work',[str(M/'vmap.exe'),'-modelsimini','modelsim.ini','work',(W/'work').as_posix()])]:results.append(execute(W,label,cmd))
results.append(execute(W,'compile',[str(M/'vlog.exe'),'-modelsimini','modelsim.ini','-sv','-work','work',*map(str,sources)]))
(W/'run.do').write_text('onerror {quit -code 11}\nonbreak {quit -code 12}\nrun -all\nquit -code 0\n')
for name,marker in [('tb_wide_recognizer','PASS_WIDE_RECOGNIZER'),('tb_wide_adapter_osd','PASS_WIDE_ADAPTER_OSD')]:
 heartbeat(name);results.append(execute(W,name,[str(M/'vsim.exe'),'-c','-novopt','-onfinish','exit','-modelsimini','modelsim.ini','-lib','work',name,'+ROOT='+(O/'test_data').as_posix(),'-wlf','NUL','-do','do {'+(W/'run.do').as_posix()+'}'],marker))
verify(deps);save(W/'INPUTS_POST.json',deps);save(O/'TARGETED_TEST_RESULT.json',dict(passed=True,status='PASS_TARGETED_RTL_AND_TWO_FRAME_720P_ADAPTER_OSD',cases=41,results=results,limitations='2 full raster frames at unchanged production adapter plus actual recognizer/OSD; no new whole DDR/DMA/GAU system72 regression'))
print('WIDE_TARGETED_TESTS_COMPLETE',flush=True)
