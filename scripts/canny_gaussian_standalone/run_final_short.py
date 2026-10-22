from common import *
W=O/('final_short_'+time.strftime('%H%M%S'));W.mkdir()
ref=R/'tb/canny_gaussian_standalone/reference_gaussian_osd.sv';ref.write_text((R/'rtl/gaussian_integration/shape/shape_osd.sv').read_text().replace('module shape_osd','module reference_gaussian_osd'))
for label,cmd in [('vlib',[str(M/'vlib.exe'),'work']),('vmap_create',[str(M/'vmap.exe'),'-c']),('vmap_work',[str(M/'vmap.exe'),'-modelsimini','modelsim.ini','work',(W/'work').as_posix()])]:execute(W,label,cmd)
files=list((R/'rtl/canny_gaussian_standalone').rglob('*.v'))+list((R/'rtl/canny_gaussian_standalone').rglob('*.sv'))+[ref,R/'tb/canny_gaussian_standalone/tb_osd.sv',R/'tb/m5c_fusion_core/tb_m5c_age_guard.sv',R/'tb/gaussian_integration/tb_gaussian_boundary.sv',R/'tb/shape_orientation_fix/reference_lut.v',R/'tb/shape_orientation_fix/tb_orientation_i2c.sv',P/'src/cmos_i2c/i2c_timing_ctrl_reg16_dat16.v',P/'src/cmos_i2c/I2C_AR0135_1280720_Config.v']
save(W/'INPUTS.json',[rec(p) for p in files]);execute(W,'compile',[str(M/'vlog.exe'),'-modelsimini','modelsim.ini','-sv','-work','work','+incdir+'+str(R/'rtl/canny_gaussian_standalone/m5c'),*[str(p) for p in files]])
(W/'run.do').write_text('onerror {quit -code 11}\nonbreak {quit -code 12}\nrun -all\nquit -code 0\n');results=[]
for name,top,marker in [('age','tb_m5c_age_guard','M5C_PASS age_guard'),('boundary','tb_gaussian_boundary','PASS_GAUSSIAN_BOUNDARY'),('i2c','tb_orientation_i2c','PASS_ORIENTATION_REAL_I2C'),('osd','tb_canny_osd','PASS_CANNY_OSD')]:
 d=W/name;d.mkdir();results.append(execute(d,'sim',[str(M/'vsim.exe'),'-c','-novopt','-onfinish','exit','-modelsimini','../modelsim.ini','-lib','work',top,'-wlf','NUL','-do','do {'+(W/'run.do').as_posix()+'}'],marker,600))
verify(json.loads((W/'INPUTS.json').read_text()));save(O/'FINAL_SHORT_RESULT.json',dict(passed=True,results=results));print('FINAL_SHORT_PASS',flush=True)
