"""Completion gate adds executed negative tests and Git/protection scope to validation."""
import json,re,subprocess
from pathlib import Path
from m5a_streaming_canny_validate import validate,R,ROOT,load
from m3_sobel_core_validate import need,check_record
def review():
 result=validate();faults=load(R/'RTL_FAULT_RESULTS.json');cli=load(R/'EVIDENCE_NEGATIVE_RESULTS.json')
 need(faults['status']=='PASS' and faults['count']==20 and len(faults['cases'])==20,'RTL fault coverage')
 need(faults['production_sources_before']==faults['production_sources_after'],'fault test modified production')
 for row in faults['production_sources_after']+[faults['script']]:check_record(ROOT,row)
 required={'directions_45_135_swapped','angle_equality_wrong','nms_wrong_neighbor','nms_direction_one_early','nms_direction_one_late','high_low_threshold_swapped','zero_magnitude_strong','unconnected_weak_kept','four_neighbors_only','previous_frame_strong_leak','raw_background_one_late','rgb_channel_swap','boundary_false_red','midframe_mode_switch','legacy_mag_changed','osd_priority_lost','nms_platform_both_inclusive','packet_ram_ignores_ce','window_ram_ignores_ce','hdmi_wrong_red_lane'}
 need({x['name'] for x in faults['cases']}==required,'RTL mutation set')
 for case in faults['cases']:
  for row in case['sources']+[case['compile_log'],case['log']]:check_record(ROOT,row)
  compile_log=(ROOT/case['compile_log']['path']).read_text(errors='replace');log=(ROOT/case['log']['path']).read_text(errors='replace')
  need('-- Compiling module' in compile_log and '** Error:' not in compile_log,'mutant did not compile')
  need(case['exit_code']!=0 and case['rejected'] and '** Fatal:' in log and 'Loading work.tb_m5a_' in log,'mutant not executed/rejected')
 need(cli['status']=='PASS' and cli['negative_count']==24 and len(cli['cases'])==25,'CLI negative coverage')
 for row in cli['sources']:check_record(ROOT,row)
 need(cli['cases'][0]['name']=='positive' and cli['cases'][0]['exit_code']==0,'CLI positive')
 for case in cli['cases']:
  for k in ('bundle','artifact'):
   if k in case:check_record(ROOT,case[k])
  if case['name']!='positive':need(case['exit_code']!=0,'CLI negative accepted')
 g=['git','-c','safe.directory=F:/Projects/stareye_fpga'];run=lambda *a:subprocess.check_output(g+list(a),cwd=ROOT)
 branch=run('branch','--show-current').decode().strip();head=run('rev-parse','HEAD').decode().strip()
 need(branch=='codex/m5a-streaming-canny' and head=='95bf83f7172ecdf11ee9b8deb3e2c1bba535a56d','Git baseline changed')
 need(not run('diff','--cached','--name-only'),'index was staged')
 original=set(load(R/'PROTECTED_BASELINES_BEFORE.json')['untracked_files']);current=set(run('ls-files','--others','--exclude-standard','-z').decode().strip('\0').split('\0'))
 need(original<=current,'historical untracked files removed/hidden')
 result.update(completion='M5A_OFFLINE_DEVELOPMENT_AND_FULL_I3_BUILD_COMPLETE_HARDWARE_PENDING',rtl_faults=20,evidence_negatives=24,git=dict(branch=branch,head=head,index_empty=True,committed=False,old_untracked_preserved=len(original)),hardware='NOT_TESTED_NO_PROGRAMMER_NO_DOWNLOAD_NO_FLASH',root_independent_review='Required separately before user final delivery')
 return result
if __name__=='__main__':
 try:
  result=review();(R/'DELEGATE_FINAL_GATE.json').write_text(json.dumps(result,indent=2));print('M5A_FINAL_GATE_PASS faults=20 evidence_negatives=24 hardware=pending')
 except Exception as e:print('M5A_FINAL_GATE_FAIL',str(e));raise
