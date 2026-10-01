from pathlib import Path
import os, sys, json
from projectdb.db import EfxProjectDatabase
from projectdb.defines import Parameter, ParameterType
work = Path('F:/Projects/stareye_fpga/efinity/m0_led_i3')
os.chdir(work)
p = EfxProjectDatabase()
assert p.load('LED_8bit_Test.xml')
p.device_family = 'Titanium'
p.device_model = 'Ti60F225'
p.device_timing_model = 'I3'
p.project_sw_version = '2025.1.110.5.9'
p.set_debugger_param(Parameter('auto_instantiation','off',ParameterType.BOOL), overwrite=True)
p.set_debugger_param(Parameter('profile','',ParameterType.STRING), overwrite=True)
assert p.save('LED_8bit_Test.xml')
sys.path.append(os.environ['EFXPT_HOME'] + '/bin')
from api_service.design import DesignAPI
d = DesignAPI(True)
d.load('LED_8bit_Test.peri.xml')
assert d.check_design(), d.get_design_check_issue()
print('PROJECT_API_TARGET',p.device_family,p.device_model,p.device_timing_model)
print('PLL_CLOCK',json.dumps(d.calc_pll_clock('pll_inst1')))
for signal in ['clk'] + [f'led_data[{i}]' for i in range(8)]:
    print('PIN',signal,d.get_pkg_pin(signal),d.get_resource(signal))
d.save()
d.generate(True)
print('OFFICIAL_INTERFACE_GENERATION_PASS')

# Use the newly generated official I3 clock template in the actual flow.
# Copy it outside outflow so subsequent Interface Designer regeneration is safe.
import shutil
shutil.copyfile('outflow/LED_8bit_Test.pt.sdc','LED_8bit_Test_I3.sdc')
p.timing_constraint_file_list = ['LED_8bit_Test_I3.sdc']
assert p.save('LED_8bit_Test.xml')
print('ACTUAL_SDC LED_8bit_Test_I3.sdc')
