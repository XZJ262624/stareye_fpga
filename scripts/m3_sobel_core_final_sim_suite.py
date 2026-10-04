"""Bind real fresh simulation runs to their exact sources and generated evidence."""
from pathlib import Path
import hashlib,json,subprocess,sys,datetime
from m3_sobel_core_sim import ROOT,REPORT,TB
def rec(p):return {'path':str(p),'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
sources=sorted((ROOT/'rtl/m3_sobel_core').glob('*.v'))+sorted(TB.glob('*.sv'))
sources += [ROOT/'scripts'/n for n in ('m3_sobel_core_sim.py','m3_sobel_core_video_sim.py','m3_sobel_core_mapped_sim.py','m3_sobel_core_final_sim_suite.py')]
project=ROOT/'efinity/m3_sobel_core_i3'
sources += [project/n for n in ('src/lcd_driver.v','src/lcd_para.v','ip/R0_FIFO_8/R0_FIFO_8.v','outflow/Ti60_Demo.map.v')]
sources += [Path('E:/Efinity/2025.1/sim_models/verilog')/('efx_'+n+'.v') for n in ('ff','lut4','add','srl8','ram10')]
before=[rec(p) for p in sources];start=datetime.datetime.now(datetime.timezone.utc).isoformat();commands=[]
for name in ('sim','video_sim','mapped_sim'):
    command=[sys.executable,'-B',str(ROOT/'scripts'/('m3_sobel_core_'+name+'.py'))]
    with (REPORT/('suite_'+name+'.log')).open('wb') as f:
        proc=subprocess.run(command,stdout=f,stderr=subprocess.STDOUT,cwd=ROOT)
    commands.append({'command':command,'exit_code':proc.returncode})
    if proc.returncode:raise RuntimeError('simulation suite failed '+name)
after=[rec(p) for p in sources];assert before==after
outputs=[rec(p) for p in sorted(REPORT.iterdir()) if p.is_file() and p.name not in ('binding.json','transcript')]
binding={'start':start,'end':datetime.datetime.now(datetime.timezone.utc).isoformat(),'source_before':before,'source_after':after,'commands':commands,'artifacts':outputs,'simulator':'ModelSim SE-64 10.1c; -novopt; installed executable; no license modification'}
(REPORT/'binding.json').write_text(json.dumps(binding,indent=2));print('M3_FINAL_SIM_SUITE_PASS',len(outputs))
