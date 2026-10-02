"""Mutate in-memory evidence only; never edit implementation or real reports."""
from pathlib import Path
import copy, json, re
from m1_hdmi_i3_evidence import flow_status, standard_timing, path_report, coverage, binding
ROOT=Path(__file__).resolve().parents[1]
REP=ROOT/'reports/m1_hdmi_i3'
results=[]
def rejected(name, fn):
    try:
        fn()
    except (ValueError, KeyError, TypeError, FileNotFoundError):
        results.append({'fixture':name,'rejected':True})
    else:
        raise AssertionError('Accepted invalid evidence: '+name)
flow=(REP/'compile.log').read_text()
for name, bad in [('flow_failed',flow.replace('PASS','FAIL',1)), ('flow_missing',flow.replace('map :','absent :')), ('flow_malformed',flow.replace('PASS','PA SS',1)), ('flow_duplicate',flow+'\n map : PASS\n')]:
    rejected(name,lambda bad=bad:flow_status(bad,['map','interface','pnr','pgm']))
standard=(REP/'Ti60_HDMI_1080P_Test.timing.rpt').read_text()
rejected('standard_version_suffix',lambda:standard_timing(standard.replace('Version: 2025.1.110.5.9','Version: 2025.1.110.5.90')))
rejected('standard_I3L_model',lambda:standard_timing(standard.replace('Timing Model: I3','Timing Model: I3L')))
for kind, value in [('setup','1.656'),('hold','0.098')]:
    rejected('standard_negative_'+kind,lambda value=value:standard_timing(standard.replace(value,'-'+value)))
    rejected('standard_missing_'+kind,lambda kind=kind:standard_timing(standard.replace('Setup (Max)' if kind=='setup' else 'Hold (Min)','MISSING')))
for group in ('internal','serializer'):
    for kind in ('setup','hold'):
        text=(REP/f'm1_hdmi_i3_{group}_{kind}.rpt').read_text()
        for case, bad in [('negative',re.sub(r'(Slack\s*:\s*)([\d.]+)',r'\g<1>-1.000',text,count=1)),('missing_slack',text.replace('Slack         :','Missing       :',1)),('malformed',re.sub(r'(Slack\s*:\s*)[\d.]+',r'\g<1>NaN',text,count=1)),('wrong_model',text.replace('Timing Model: I3','Timing Model: C4')),('I3L_model',text.replace('Timing Model: I3','Timing Model: I3L')),('version_suffix',text.replace('Version: 2025.1.110.5.9','Version: 2025.1.110.5.90'))]:
            rejected(f'{group}_{kind}_{case}',lambda bad=bad,kind=kind,group=group:path_report(bad,kind,group=='serializer'))
        if group=='serializer':
            rejected('missing_endpoint_'+kind,lambda text=text,kind=kind:path_report(text.replace('tmds_lvds_tx_data0[0]','tmds_lvds_tx_data0[1]'),kind,True))
check=(REP/'m1_hdmi_i3_check_timing.rpt').read_text()
rejected('unconstrained_internal',lambda:coverage(check.replace('unconstrained_internal_endpoints (0)','unconstrained_internal_endpoints (1)')))
base=json.loads((REP/'final_implementation_binding.json').read_text())
binding(base,ROOT)
for name, mutate in [
    ('stale_original',lambda d:d['original_before'][0].update(sha256='0'*64)),
    ('stale_report',lambda d:d['reports'][0].update(sha256='0'*64)),
    ('stale_clone',lambda d:d['clone_initial_pairs'][0]['copy'].update(sha256='0'*64)),
    ('missing_snapshot',lambda d:d.update(original_before=[],original_after=[])),
    ('missing_report',lambda d:d['reports'].pop()),
    ('failed_sta_exit',lambda d:d.update(exit_code=1)),
    ('missing_sta_exit',lambda d:d.pop('exit_code')),
    ('malformed_sta_exit',lambda d:d.update(exit_code=False)),
    ('stale_bit',lambda d:d['bitstream'].update(sha256='0'*64))]:
    data=copy.deepcopy(base); mutate(data)
    rejected(name,lambda data=data:binding(data,ROOT))
(REP/'negative_fixture_results.json').write_text(json.dumps({'positive_binding_passed':True,'negative_fixtures':results,'count':len(results)},indent=2))
print(f'PASS: real binding + {len(results)} negative fixtures rejected')
