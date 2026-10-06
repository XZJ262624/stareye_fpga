from pathlib import Path
import os,sys
from projectdb.db import EfxProjectDatabase
from projectdb.defines import DesignFile
root=Path(__file__).resolve().parents[1];work=root/'efinity/m31_sobel_controls_i3';os.chdir(work)
p=EfxProjectDatabase();assert p.load('Ti60_Demo.xml')
assert (p.device_family,p.device_model,p.device_timing_model)==('Titanium','Ti60F225','I3')
existing={x.filepath for x in p.design_file_list}
p.design_file_list=list(p.design_file_list)+[DesignFile('../../rtl/m31_sobel_controls/'+x.name,'default','default') for x in sorted((root/'rtl/m31_sobel_controls').glob('*.v')) if '../../rtl/m31_sobel_controls/'+x.name not in existing]
assert p.save('Ti60_Demo.xml')
sys.path.append(os.environ['EFXPT_HOME']+'/bin')
from api_service.design import DesignAPI
d=DesignAPI(True);d.load('Ti60_Demo.peri.xml')
d.delete_gpio('lcd_de_o');d.delete_gpio('lcd_pclk_o')
d.create_input_gpio('key_n',1,0)
for i,pin in enumerate(('N2','M2')):
 name='key_n['+str(i)+']'
 d.assign_pkg_pin(name,pin,False)
 d.set_property(name,{'IO_STANDARD':'1.8_V_LVCMOS','IN_REG':'BYPASS','PULL_OPTION':'NONE'})
assert d.check_design(),d.get_design_check_issue()
d.save();d.generate(True)
print('M31_CONFIGURE_PASS official GPIO N2 M2 1.8V')
