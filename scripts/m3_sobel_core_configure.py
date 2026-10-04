from pathlib import Path
import os,sys,hashlib
from projectdb.db import EfxProjectDatabase
from projectdb.defines import DesignFile
root=Path(__file__).resolve().parents[1]
work=root/'efinity/m3_sobel_core_i3'
os.chdir(work)
sdchash=hashlib.sha256(Path('Ti60_Demo_I3.sdc').read_bytes()).hexdigest()
p=EfxProjectDatabase(); assert p.load('Ti60_Demo.xml')
assert (p.device_family,p.device_model,p.device_timing_model)==('Titanium','Ti60F225','I3')
sources=sorted((root/'rtl/m3_sobel_core').glob('*.v'))
existing={x.filepath for x in p.design_file_list}
p.design_file_list=list(p.design_file_list)+[DesignFile('../../rtl/m3_sobel_core/'+x.name,'default','default') for x in sources if '../../rtl/m3_sobel_core/'+x.name not in existing]
assert p.save('Ti60_Demo.xml')
sys.path.append(os.environ['EFXPT_HOME']+'/bin')
from api_service.design import DesignAPI
d=DesignAPI(True); d.load('Ti60_Demo.peri.xml')
assert d.check_design(),d.get_design_check_issue()
d.save(); d.generate(True)
assert hashlib.sha256(Path('Ti60_Demo_I3.sdc').read_bytes()).hexdigest()==sdchash
print('M3_CONFIGURE_PASS official projectdb and DesignAPI; baseline SDC unchanged')
