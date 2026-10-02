from pathlib import Path
import json,hashlib,re,xml.etree.ElementTree as ET
from m1_hdmi_i3_evidence import require, flow_status, standard_timing, path_report, coverage, binding
r=Path('F:/Projects/stareye_fpga'); w=r/'efinity/m1_hdmi_i3'; p=r/'reports/m1_hdmi_i3'; o=w/'outflow'
def sha(f):return hashlib.sha256(f.read_bytes()).hexdigest().upper()
def statements(f):return [x.strip() for x in f.read_text().splitlines() if x.strip() and not x.lstrip().startswith('#')]
def endpoints(f):
    text=f.read_text(); text=text.split('++++ Path 1')[0]
    return set(re.findall(r'\|\s*(tmds_lvds_tx_data[012]\[\d\])\s*\|',text))
stage=json.loads((p/'stage_exitcodes.json').read_text())
require(all(type(stage.get(k)) is int and stage[k]==0 for k in ('configure','compile','timing_audit_and_restore')), 'failed/missing outer flow')
flow_status((p/'compile.log').read_text(), ['map','interface','pnr','pgm'])
flow_status((p/'timing_audit.log').read_text(), ['pnr','pgm'])
internal=standard_timing((o/'Ti60_HDMI_1080P_Test.timing.rpt').read_text())
audits={}
for group in ('internal','serializer'):
    for kind in ('setup','hold'):
        audits[group+'_'+kind]=path_report((p/('m1_hdmi_i3_'+group+'_'+kind+'.rpt')).read_text(), kind, group=='serializer')
for kind in ('setup','hold'):
    require(internal[kind]==audits['internal_'+kind]['minimum_slack_ns'], 'final standard and isolated internal report disagree')
v={
    'flow_status_checked':True,
    'internal_positive_setup_hold':True,
    'all_30_TMDS_positive_setup_hold':True,
    'timing_coverage_checked':coverage((p/'m1_hdmi_i3_check_timing.rpt').read_text()),
    'final_implementation_binding_verified':binding(json.loads((p/'final_implementation_binding.json').read_text()),r),
    'actual_sdc_matches_regenerated_statements':statements(w/'Ti60_HDMI_1080P_Test_I3.sdc')==statements(o/'Ti60_HDMI_1080P_Test.pt.sdc'),
    'final_standard_report_is_I3':'Timing Model: I3' in (o/'Ti60_HDMI_1080P_Test.timing.rpt').read_text(),
    'archived_standard_report_matches_final':sha(o/'Ti60_HDMI_1080P_Test.timing.rpt')==sha(p/'Ti60_HDMI_1080P_Test.timing.rpt'),
    'serializer_setup_endpoint_count':len(endpoints(p/'m1_hdmi_i3_serializer_setup.rpt')),
    'serializer_hold_endpoint_count':len(endpoints(p/'m1_hdmi_i3_serializer_hold.rpt')),
    'no_false_paths_or_async_clock_groups':not any('set_false_path' in x or 'set_clock_groups' in x for x in statements(w/'Ti60_HDMI_1080P_Test_I3.sdc')),
    'bit_matches_recorded_sha256':sha(o/'Ti60_HDMI_1080P_Test.bit')==json.loads((p/'bitstream.json').read_text())['sha256'],
    'all_six_vendor_rtl_identical':all(x['equal'] for x in json.loads((p/'rtl_integrity.json').read_text())),
    'original_69_file_manifest_unchanged':json.loads((p/'original_diff.json').read_text())['same_full_manifest']
}
require(all(v.values()) and v['serializer_setup_endpoint_count']==v['serializer_hold_endpoint_count']==30, 'acceptance check failed')
v['parsed_timing']=audits
(p/'final_validation.json').write_text(json.dumps(v,indent=2))
files=[x for x in w.rglob('*') if x.is_file() and not x.name.endswith('.lock') and '__pycache__' not in x.parts and 'outflow' not in x.parts and 'work' not in x.parts and not any(y.startswith('work_') for y in x.parts)]
files += list((r/'scripts').glob('m1_hdmi_i3_*'))
files += [x for x in p.iterdir() if x.is_file() and x.name!='artifact_manifest.json']
(p/'artifact_manifest.json').write_text(json.dumps([{'path':str(x.relative_to(r)).replace('\\','/'),'bytes':x.stat().st_size,'sha256':sha(x)} for x in sorted(files)],indent=2))
print(json.dumps(v,indent=2)); print('Manifest files',len(files))
