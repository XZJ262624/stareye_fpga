"""Create a NEW standalone I3 DDR diagnostic via official project/interface APIs."""
from pathlib import Path
import os,sys,json,shutil,hashlib,xml.etree.ElementTree as ET
from projectdb.db import EfxProjectDatabase
from projectdb.defines import DesignFile,Parameter,ParameterType
ROOT=Path(__file__).resolve().parents[1];OLD=ROOT/'efinity/m2_ar0135_ddr_hdmi_i3'
WORK=ROOT/'efinity/m5b0r_ddr_address_diag_i3';REPORT=ROOT/'reports/m5b0r_ddr_admission'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
WORK.mkdir(parents=True,exist_ok=True);(WORK/'ip/DdrCtrl').mkdir(parents=True,exist_ok=True)
assert not (WORK/'outflow/M5B0R_DdrDiag.bit').exists(),'implemented project: do not reconfigure'
copied=[]
for n in ('DdrCtrl.sv','DdrCtrl_define.svh','ddr3_controller.vh','ddr3_controller.bin','ddr3_device_ID.vh'):
 src=OLD/'ip/DdrCtrl'/n;dst=WORK/'ip/DdrCtrl'/n;shutil.copy2(src,dst)
 copied.append(dict(source=src.relative_to(ROOT).as_posix(),destination=dst.relative_to(ROOT).as_posix(),sha256=sha(src)))
settings=json.loads((OLD/'ip/DdrCtrl/settings.json').read_text())
(REPORT/'M2_DDR_SETTINGS_PROVENANCE.json').write_text(json.dumps(settings,indent=2))
settings['args'][settings['args'].index('--base_path')+1]=str(WORK/'ip')
(WORK/'ip/DdrCtrl/settings.json').write_text(json.dumps(settings,indent=2))
shutil.copy2(OLD/'Ti60_Demo.xml',WORK/'M5B0R_DdrDiag.xml')
shutil.copy2(OLD/'Ti60_Demo.peri.xml',WORK/'M5B0R_DdrDiag.peri.xml')
db=EfxProjectDatabase();assert db.load(str(WORK/'M5B0R_DdrDiag.xml'))
db.project_name='M5B0R_DdrDiag';db.design_top_module_name='m5b0r_top'
db.device_family='Titanium';db.device_model='Ti60F225';db.device_timing_model='I3'
db.project_sw_version='2025.1.110.5.9';db.ip_instance_list=[]
names=('m5b0r_top.sv','m5b0r_monitor.sv','m5b0r_diagnostic.sv','m5b0r_transaction.sv')
db.design_file_list=[DesignFile('../../rtl/m5b0r_ddr_admission/'+n,'system_verilog','default') for n in names]+[DesignFile('ip/DdrCtrl/DdrCtrl.sv','system_verilog','default')]
db.synthesis_param_list=[p for p in db.synthesis_param_list if p.name!='include']+[Parameter('include','ip/DdrCtrl',ParameterType.STRING)]
db.set_debugger_param(Parameter('auto_instantiation','off',ParameterType.BOOL),overwrite=True)
db.set_debugger_param(Parameter('profile','',ParameterType.STRING),overwrite=True)
db.synthesis_verilog_dyn_param_list=[];db.synthesis_verilog_macro_list=[]
db.timing_constraint_file_list=['M5B0R_DdrDiag.sdc']
db.project_attr_list=[('last_run_state',''),('last_run_flow',''),('design_ood','new'),('place_ood','new'),('route_ood','new')]
assert db.save(str(WORK/'M5B0R_DdrDiag.xml'))
# Periphery XML rename through structured XML before the official API owns it.
pt=WORK/'M5B0R_DdrDiag.peri.xml';tree=ET.parse(pt);tree.getroot().set('name','M5B0R_DdrDiag');tree.write(pt,encoding='utf-8',xml_declaration=True)
os.chdir(WORK);sys.path.append(os.environ['EFXPT_HOME']+'/bin')
from api_service.design import DesignAPI
d=DesignAPI(True);d.load(str(pt))
keep={'addr','ba','cas','cke','clk_24m','clk_n','clk_p','cs','dm','dq','dqs','dqs_n','led_o','odt','ras','reset','verf0','vref1','we'}
for n in list(d.get_all_gpio_name()):
 if n.split('[')[0] not in keep:d.delete_gpio(n)
for typ in d.get_block_type():
 if 'MIPI' in typ or 'LVDS' in typ:
  for n in list(d.get_all_block_name(typ)):d.delete_block(n,typ)
for n in ('dsi_pll','lvds_pll'):d.delete_block(n,'PLL')
for i in (1,2,3):d.set_property('sys_pll',f'CLKOUT{i}_EN','0','PLL')
d.set_property('clk_24m','CONN_TYPE','NONE')
d.set_property('sys_pll','REFCLK_SOURCE','CORE','PLL')
d.set_property('sys_pll','CORE_CLK_PIN','clk_24m','PLL')
assert d.check_design(),d.get_design_check_issue()
d.save();d.generate(True)
from m5b0r_constraints import main as constraints
constraints()
# Verify retained DDR physical configuration and DDR PLL are EXACTLY equal.
ns={'p':'http://www.efinixinc.com/peri_design_db'}
old=ET.parse(OLD/'Ti60_Demo.peri.xml').getroot();new=ET.parse(pt).getroot()
def canon(e):return (e.tag,sorted(e.attrib.items()),tuple(canon(x) for x in e))
def byname(root,tag):return {e.attrib['name']:e for e in root.findall('.//p:'+tag,ns)}
og,ng=byname(old,'comp_gpio'),byname(new,'comp_gpio')
assert all(canon(og[n])==canon(v) for n,v in ng.items() if n!='clk_24m')
op,np=byname(old,'pll'),byname(new,'pll');assert canon(op['ddr_pll'])==canon(np['ddr_pll'])
for r in copied:assert sha(ROOT/r['source'])==sha(ROOT/r['destination'])==r['sha256']
assert settings['conf']==json.loads((OLD/'ip/DdrCtrl/settings.json').read_text())['conf']
(REPORT/'CONFIGURATION.json').write_text(json.dumps(dict(status='PASS_OFFICIAL_API',device='Titanium/Ti60F225/FBGA225/I3',ddr_config_equal=True,ddr_pll_equal=True,retained_gpio_equal_except_ref_clock=True,sys_reference_change='24MHz GPIO normal core input to CORE PLL reference; same sys96 and DDR192/384; final clock routing requires PNR/STA review',debug_auto='off',copied=copied),indent=2))
print('M5B0R_CONFIGURE_PASS')
