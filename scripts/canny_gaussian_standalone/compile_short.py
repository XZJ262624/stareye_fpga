from common import *
import datetime
W=O/('short_'+time.strftime('%H%M%S'));W.mkdir()
ctx=json.loads((O/'NOTIFICATION_CONTEXT.json').read_text(encoding='utf-8-sig'));ctx.update(codex_checked_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),codex_observation='Astra正在实施并核对新隔离源码/必要编译');save(O/'NOTIFICATION_CONTEXT.json',ctx)
for label,cmd in [('vlib',[str(M/'vlib.exe'),'work']),('vmap_create',[str(M/'vmap.exe'),'-c']),('vmap_work',[str(M/'vmap.exe'),'-modelsimini','modelsim.ini','work',(W/'work').as_posix()])]:execute(W,label,cmd)
files=[R/p for p in json.loads((O/'COMPILE_FILES.json').read_text())]
# Vendor encrypted DDR/CSI/DSI are compiled by native Efinity, not this old
# ModelSim. The functional SUT uses the explicit DDR transaction model.
tests=[R/'tb/gaussian_demo/tb_gaussian_kernel.sv',R/'tb/gaussian_demo/tb_gaussian_stream.sv']+[R/'tb/gaussian_integration'/n for n in ['tb_gaussian_controls.sv','tb_gaussian_config.sv','tb_gaussian_chain.sv']]+list((R/'tb/gaussian_integration/reference').glob('*.v'))
inc=[R/'rtl/canny_gaussian_standalone/m5c',P/'src']+list((P/'ip').iterdir())
save(W/'INPUTS.json',[rec(p) for p in files+tests]);execute(W,'compile',[str(M/'vlog.exe'),'-modelsimini','modelsim.ini','-sv','-work','work',*['+incdir+'+str(p) for p in inc],*[str(p) for p in files+tests]])
(W/'run.do').write_text('onerror {quit -code 11}\nonbreak {quit -code 12}\nrun -all\nquit -code 0\n')
results=[]
def sim(name,top,args,marker):
 d=W/name;d.mkdir();results.append(execute(d,'sim',[str(M/'vsim.exe'),'-c','-novopt','-onfinish','exit','-modelsimini','../modelsim.ini','-lib','work',top,*args,'-wlf','NUL','-do','do {'+(W/'run.do').as_posix()+'}'],marker,1800))
D=R/'reports/gaussian_demo_20261020';G=R/'reports/gaussian_integration_20261020'
sim('kernel','tb_gaussian_kernel',['+DATA='+str(D/'data/kernel.hex'),'+COUNT='+str(json.loads((D/'DATA_MANIFEST.json').read_text())['kernel_vectors'])],'PASS_GAUSSIAN_KERNEL')
sim('stream','tb_gaussian_stream',['+ROOT='+str(D/'data')],'PASS_GAUSSIAN_STREAM')
sim('stream_restart','tb_gaussian_stream',['-gRESTART=1','+ROOT='+str(D/'data')],'PASS_GAUSSIAN_STREAM')
sim('controls','tb_gaussian_controls',[],'PASS_GAUSSIAN_CONTROLS')
sim('config','tb_gaussian_config',['+VECTORS='+str(G/'data/config_vectors.hex')],'PASS_GAUSSIAN_CONFIG')
sim('chain','tb_gaussian_chain',['+ROOT='+str(G/'data/small')],'PASS_GAUSSIAN_CHAIN')
verify(json.loads((W/'INPUTS.json').read_text()));save(O/'SHORT_RESULT.json',dict(passed=True,path=W.relative_to(R).as_posix(),results=results));print('SHORT_PASS',flush=True)
