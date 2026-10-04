"""Real subprocess rejection tests using deliberately corrupted evidence files."""
from pathlib import Path
import copy,json,re,subprocess,sys
from m3_sobel_core_validate import ROOT,R,W,record,expected_reports
folder=R/'negative_cases';folder.mkdir(exist_ok=True)
timing=(R/'final_audit/m3_setup.rpt').read_text();coverage=(R/'final_audit/m3_check_timing.rpt').read_text();stages=(R/'build/compile.log').read_text()
cases=[]
def add(name,kind,text):cases.append((name,kind,text))
for name,value in [('negative_slack','-0.001'),('nan_slack','NaN'),('infinite_slack','Inf'),('invalid_slack','bad')]:
    add(name,'setup',re.sub(r'(^Slack\s*:\s*)\S+',lambda m:m[1]+value,timing,count=1,flags=re.M))
add('empty_timing','setup','')
add('wrong_model','setup',timing.replace('Timing Model: I3','Timing Model: C4'))
add('wrong_version','setup',timing.replace('2025.1.110.5.9','2023.1.150'))
add('wrong_check','hold',timing)
add('missing_path_end','setup',re.sub(r'^Path End[^\n]*\n','',timing,count=1,flags=re.M))
add('error_in_timing','setup',timing+'\nERROR injected failure\n')
for key in ('no_clock','unconstrained_internal_endpoints','multiple_clock'):
    add(key,'coverage',coverage.replace('checking '+key+' (0)','checking '+key+' (1)'))
add('inconsistent_coverage','coverage',coverage.replace('checking no_clock (0)','checking no_clock (1)',1))
add('missing_coverage','coverage',coverage.replace('checking no_clock','checking absent_clock'))
add('stage_fail','stages',re.sub(r'(pnr\s*:\s*)PASS',r'\1FAIL',stages))
add('stage_missing','stages',re.sub(r'^\s*pgm\s*:\s*PASS\s*$', '',stages,flags=re.M))
add('stage_duplicate','stages',stages+'\nmap : PASS\n')
for name,path in [('stale_bit',W/'outflow/Ti60_Demo.bit'),('stale_input',ROOT/'rtl/m3_sobel_core/sobel_3x3.v'),('stale_database',W/'work_pnr/Ti60_Demo.lbf')]:
    row=record(path);row['sha256']='0'*64;add(name,'record',json.dumps(row))
row=record(W/'outflow/Ti60_Demo.bit');row['bytes']+=1;add('wrong_size','record',json.dumps(row))
row['path']='reports/m3_sobel_core_i3/nonexistent_expected_artifact.bit';add('missing_artifact','record',json.dumps(row))
add('failed_build_exit','build_exit',json.dumps({'exit_code':1}))
add('missing_sta_report','report_set',json.dumps(sorted(expected_reports())[1:]))
hdmi=(R/'final_audit/m3_hdmi_setup.rpt').read_text()
add('missing_hdmi_lane','hdmi_setup',hdmi.replace('hdmi_txd0_o[0]','hdmi_txd0_o[1]'))
positive=[('setup',timing),('hold',(R/'final_audit/m3_hold.rpt').read_text()),('coverage',coverage),('stages',stages),('record',json.dumps(record(W/'outflow/Ti60_Demo.bit'))),('build_exit',json.dumps({'exit_code':0})),('report_set',json.dumps(sorted(expected_reports()))),('hdmi_setup',hdmi)]
controls=[]
for kind,text in positive:
    path=folder/('positive_'+kind+'.txt');path.write_text(text)
    command=[sys.executable,'-B',str(ROOT/'scripts/m3_sobel_core_validate.py'),'--fragment',kind,str(path)]
    proc=subprocess.run(command,capture_output=True,text=True)
    if proc.returncode!=0 or 'M3_FRAGMENT_PASS' not in proc.stdout:raise RuntimeError('positive control rejected '+kind)
    controls.append({'kind':kind,'command':command,'exit_code':proc.returncode,'diagnostic':proc.stdout.strip()})
diagnostics={'negative_slack':'negative/nonfinite slack','nan_slack':'negative/nonfinite slack','infinite_slack':'negative/nonfinite slack','invalid_slack':'invalid numeric slack','empty_timing':'wrong timing tool version','wrong_model':'wrong timing model/status','wrong_version':'wrong timing tool version','wrong_check':'wrong timing check type','missing_path_end':'incomplete timing path','error_in_timing':'timing error','no_clock':'coverage no_clock','unconstrained_internal_endpoints':'coverage unconstrained_internal_endpoints','multiple_clock':'coverage multiple_clock','inconsistent_coverage':'coverage no_clock','missing_coverage':'coverage no_clock','stage_fail':'missing/duplicate/failing build stage','stage_missing':'missing/duplicate/failing build stage','stage_duplicate':'missing/duplicate/failing build stage','stale_bit':'artifact hash/size mismatch','stale_input':'artifact hash/size mismatch','stale_database':'artifact hash/size mismatch','wrong_size':'artifact hash/size mismatch','missing_artifact':'missing ','failed_build_exit':'build exit failed','missing_sta_report':'report set incomplete','missing_hdmi_lane':'missing HDMI lane'}
result=[]
for name,kind,text in cases:
    path=folder/(name+'.txt');path.write_text(text)
    command=[sys.executable,'-B',str(ROOT/'scripts/m3_sobel_core_validate.py'),'--fragment',kind,str(path)]
    proc=subprocess.run(command,capture_output=True,text=True)
    if proc.returncode!=1 or 'M3_VALIDATION_FAIL' not in proc.stdout or diagnostics[name] not in proc.stdout:
        raise RuntimeError('negative case was accepted: '+name+' '+proc.stdout+proc.stderr)
    result.append({'case':name,'command':command,'exit_code':proc.returncode,'diagnostic':proc.stdout.strip(),'rejected':True})
(R/'negative_acceptance.json').write_text(json.dumps(result,indent=2))
(R/'positive_acceptance.json').write_text(json.dumps(controls,indent=2))
(R/'negative_binding.json').write_text(json.dumps({'sources':[record(Path(__file__)),record(ROOT/'scripts/m3_sobel_core_validate.py')],'artifacts':[record(R/'negative_acceptance.json'),record(R/'positive_acceptance.json')]},indent=2))
print('M3_ACCEPTANCE_NEGATIVE_PASS',len(result))
