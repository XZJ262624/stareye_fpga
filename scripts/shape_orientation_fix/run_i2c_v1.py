from common import *
W=O/('i2c_'+time.strftime('%H%M%S'));W.mkdir();T=R/'tb/shape_orientation_fix';P=R/'efinity/shape_orientation_fix_i3'
src=[T/'reference_lut.v',T/'tb_orientation_i2c.sv',P/'src/cmos_i2c/i2c_timing_ctrl_reg16_dat16.v',P/'src/cmos_i2c/I2C_AR0135_1280720_Config.v']
pre=[rec(p)for p in src];save(W/'INPUTS_PRE.json',pre)
for label,cmd in [('vlib',[str(M/'vlib.exe'),'work']),('vmap_create',[str(M/'vmap.exe'),'-c']),('vmap_work',[str(M/'vmap.exe'),'-modelsimini','modelsim.ini','work',(W/'work').as_posix()])]:execute(W,label,cmd)
execute(W,'compile',[str(M/'vlog.exe'),'-sv',*map(str,src)])
(W/'run.do').write_text('onerror {quit -code 11}\nonbreak {quit -code 12}\nrun -all\nquit -code 0\n')
result=execute(W,'positive',[str(M/'vsim.exe'),'-c','-novopt','-onfinish','exit','work.tb_orientation_i2c','-wlf','NUL','-do','do run.do'],'PASS_ORIENTATION_REAL_I2C',timeout=180)
# Recompile the original table in this isolated library, keep the same acceptance oracle.
old=R/'efinity/shape_standalone_i3/src/cmos_i2c/I2C_AR0135_1280720_Config.v'
execute(W,'mutant_compile',[str(M/'vlog.exe'),'-sv',str(old)])
cmd=[str(M/'vsim.exe'),'-c','-novopt','-onfinish','exit','work.tb_orientation_i2c','-wlf','NUL','-do','do run.do']
with(W/'negative.log').open('wb')as f:
 p=subprocess.run(cmd,cwd=W,stdout=f,stderr=subprocess.STDOUT,timeout=120,creationflags=subprocess.CREATE_NO_WINDOW)
text=(W/'negative.log').read_text(errors='replace');assert 'ORIENTATION_DELTA_MISSING' in text and 'PASS_ORIENTATION_REAL_I2C' not in text
with(W/'negative_serial.log').open('wb')as f:
 q=subprocess.run(cmd+['+SERIAL_NEGATIVE'],cwd=W,stdout=f,stderr=subprocess.STDOUT,timeout=120,creationflags=subprocess.CREATE_NO_WINDOW)
text=(W/'negative_serial.log').read_text(errors='replace');assert 'SERIAL_WRITE_MISMATCH index=18 got=2030408000 expected=203040c000' in text and 'PASS_ORIENTATION_REAL_I2C' not in text
verify(pre);save(W/'INPUTS_POST.json',[rec(p)for p in src]);save(O/'I2C_GATE_RECEIPT.json',dict(passed=True,positive=result,negative=dict(rejected=True,exit=p.returncode,reason='ORIENTATION_DELTA_MISSING',log=rec(W/'negative.log')),serial_negative=dict(rejected=True,exit=q.returncode,reason='SERIAL_WRITE_MISMATCH index=18',log=rec(W/'negative_serial.log')),inputs=pre,production_SIMU_EN=0,production_clock_hz=96000000,production_i2c_hz=50000,all_256_LUT_entries_compared=True,serial_writes=23,orientation_writes=1,read_reply_fixture='0754; not actual hardware measurement',scope='Real production sequencer output pins and slave ACKs. No sensor image behavior simulated.'))
print('PASS_ORIENTATION_I2C_GATE',flush=True)
