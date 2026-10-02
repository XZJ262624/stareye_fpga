from pathlib import Path
import os,sys,json,shutil
from projectdb.db import EfxProjectDatabase
from projectdb.defines import Parameter,ParameterType
work=Path('F:/Projects/stareye_fpga/efinity/m2_ar0135_ddr_hdmi_i3'); report=work.parents[1]/'reports/m2_ar0135_ddr_hdmi_i3'; os.chdir(work)
p=EfxProjectDatabase(); assert p.load('Ti60_Demo.xml'); p.device_family='Titanium'; p.device_model='Ti60F225'; p.device_timing_model='I3'; p.project_sw_version='2025.1.110.5.9'; p.set_debugger_param(Parameter('auto_instantiation','off',ParameterType.BOOL),overwrite=True); p.set_debugger_param(Parameter('profile','',ParameterType.STRING),overwrite=True); assert p.save('Ti60_Demo.xml')
sys.path.append(os.environ['EFXIPM_HOME']+'/bin')
from ipm_api_service.design import IPMDesignAPI
from gui.api_wrapper import ResultCode
api=IPMDesignAPI('Ti60F225','Titanium',work,True)
for mod,lib,name in [('W0_FIFO_8','memory','efx_fifo_top'),('DdrCtrl','memory_controller','efx_ddr3_soft_controller')]:
 old=json.loads((work/'ip'/mod/'settings.json').read_text()); conf=dict(old['conf'])
 if mod=='W0_FIFO_8': conf['FAMILY']='"TITANIUM"'
 else: conf.update(data_width='1',freq='384',row='15',col='10',bank='3',cas_latency='6',DDR3_DATA_RATE='2',READ_ENABLE_PIPELINE='7',PLL_OUT_SEL='4',tRFC='350',tXS='360',tRAS='37.5',tRCD='15',tRP='15',tREFI='7800',write_recovery='6',cwl='5')
 assert api.create_ip(mod,'efinixinc.com',lib,name)
 api.config_ip(mod,conf)
 ok,validated,templates=api.validate_ip(mod)
 (report/(mod+'_parameters.json')).write_text(json.dumps({'old':old['conf'],'requested':conf,'validated':str(validated),'templates':str(templates)},indent=2))
 assert ok,(mod,validated)
 assert api.generate_ip(mod)==ResultCode.SUCCESS
sys.path.append(os.environ['EFXPT_HOME']+'/bin')
from api_service.design import DesignAPI
d=DesignAPI(True); d.load('Ti60_Demo.peri.xml'); assert d.check_design(), d.get_design_check_issue(); d.save(); d.generate(True)
shutil.copyfile('outflow/Ti60_Demo.pt.sdc','Ti60_Demo_I3.sdc')
p=EfxProjectDatabase(); assert p.load('Ti60_Demo.xml'); p.timing_constraint_file_list=['Ti60_Demo_I3.sdc']; assert p.save('Ti60_Demo.xml')
print('CONFIGURE_COMPLETE')
