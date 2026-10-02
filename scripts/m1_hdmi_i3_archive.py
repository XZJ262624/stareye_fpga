from pathlib import Path
import json,hashlib,re,shutil,xml.etree.ElementTree as ET
from m1_hdmi_i3_evidence import flow_status, require
root=Path('F:/Projects/stareye_fpga'); work=root/'efinity/m1_hdmi_i3'; out=work/'outflow'; rep=root/'reports/m1_hdmi_i3'
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest().upper()
j=json.loads((rep/'stage_exitcodes.json').read_text(encoding='utf-8-sig'))
require(all(type(j.get(k)) is int and j[k]==0 for k in ('configure','compile','timing_audit_and_restore')), 'historical outer flow failed/missing')
compile_status=flow_status((rep/'compile.log').read_text(), ['map','interface','pnr','pgm'])
restore_status=flow_status((rep/'timing_audit.log').read_text(), ['pnr','pgm'])
require('ACTUAL_TIMING_MODEL I3' in (rep/'timing_audit.log').read_text(), 'missing historical I3 selection')
for p in out.iterdir():
    if not p.name.startswith('m1_hdmi_i3_') and (p.suffix in ['.rpt','.csv','.sdc'] or p.name.endswith(('.map.out','.pgm.out','.warn.log','.err.log','.place.out','.route.out'))):
        shutil.copyfile(p,rep/p.name)
src=root/'document/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/06-FPGA_HDL_Basic-2023.2/07_Ti60_HDMI_1080P_Lvds_Test'
ns={'e':'http://www.efinixinc.com/enf_proj'}
rows=[]
for f in ET.parse(src/'Ti60_HDMI_1080P_Test.xml').findall('.//e:design_file',ns):
    n=f.get('name'); rows.append({'path':n,'original_sha256':sha(src/n),'copy_sha256':sha(work/n),'equal':sha(src/n)==sha(work/n)})
(rep/'rtl_integrity.json').write_text(json.dumps(rows,indent=2))
bit=out/'Ti60_HDMI_1080P_Test.bit'
(rep/'bitstream.json').write_text(json.dumps({'path':str(bit),'bytes':bit.stat().st_size,'sha256':sha(bit),'timing_model':'I3','tool_version':'2025.1.110.5.9','agent_did_not_program':True,'user_reported_M1_JTAG_PASS':True,'selected_download_path_hash_verified':False},indent=2))
j['compile_substages']=compile_status
j['compile_substages_evidence']='compile.log official flow status lines; numeric exits were not separately captured'
j['audit_restore_substages']={'explicit_I3_sta': {'evidence':'timing_audit.log ACTUAL_TIMING_MODEL I3; historical outer exit 0; standalone STA exit not captured'}, **restore_status}
(rep/'stage_exitcodes.json').write_text(json.dumps(j,indent=2))
v=(out/'Ti60_HDMI_1080P_Test.map.v').read_text(); a=v.index('    EFX_DSP48'); b=v.index('    EFX_LUT4',a)
(rep/'dsp_warning_evidence.txt').write_text(v[a:b])
warn=(out/'Ti60_HDMI_1080P_Test.warn.log').read_text()
(rep/'warning_summary.json').write_text(json.dumps({'synthesis_warning_lines':len(re.findall(r'^\[.*WARNING\]',warn,re.M)),'interface_warning':'clk_25M unused PLL reference; gpio_rule_alt_conn','source_rtl_modified':False,'notes':'Full warn.log archived; final summary warning line includes count, not additional unique root cause.'},indent=2))
print((rep/'bitstream.json').read_text());print('RTL',all(r['equal'] for r in rows))
