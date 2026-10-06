"""Independent completion gate: actual implementation plus executed fault tests."""
from pathlib import Path
import json,re,subprocess,hashlib
from m4_color_overlay_validate import validate,R,ROOT
from m3_sobel_core_validate import need,check_record
def review():
 result=validate();binding=json.loads((R/'negative_binding.json').read_text())
 for row in binding['sources']+binding['artifacts']+binding['production_sources_after']:check_record(ROOT,row)
 need(binding['production_sources_before']==binding['production_sources_after'],'fault tests changed production')
 cli=json.loads((R/'negative_acceptance.json').read_text());rtl=json.loads((R/'rtl_negative_acceptance.json').read_text())
 need(len(cli)==22 and cli[0]['name']=='positive' and cli[0]['exit_code']==0,'CLI positive/negative coverage')
 need(all(x['exit_code']!=0 for x in cli[1:]),'negative CLI silently passed')
 expected={'raw_delay_minus_one','raw_delay_plus_one','rgb_channel_swap','invalid_window_red','median_background','mag_corrupted','mag_depends_threshold','midframe_settings','osd_hidden','hdmi_wrong_red_lane'}
 need({x['name'] for x in rtl}==expected and len(rtl)==10,'RTL fault coverage')
 for x in rtl:
  need(x['exit_code']!=0 and x['rejected'],'RTL negative passed')
  for row in x['sources']+[x['log']]:check_record(ROOT,row)
  log=(ROOT/x['log']['path']).read_text(errors='replace');need('** Fatal:' in log and 'Loading work.' in log,'RTL failure not actually executed')
 # The protected file SET is checked as well as content/mtime, including locks.
 before=json.loads((R/'PROTECTED_BASELINES_BEFORE.json').read_text());old={x['path'] for x in before['files']+before['locked_unreadable']};bases=sorted({p.split('/')[0]+'/'+p.split('/')[1] for p in old});now={p.relative_to(ROOT).as_posix() for d in bases for p in (ROOT/d).rglob('*') if p.is_file()};need(now==old,'protected original file set changed')
 # Git remains on the isolated branch, with its original parent and no index writes.
 g=['git','-c','safe.directory=F:/Projects/stareye_fpga'];run=lambda *a:subprocess.check_output(g+list(a),cwd=ROOT)
 need(run('branch','--show-current').decode().strip()=='codex/m4-color-overlay','wrong branch')
 need(run('rev-parse','HEAD').decode().strip()=='3424514afe1721dc000495673c0ca757ea1f6372','HEAD changed')
 need(not run('diff','--cached','--name-only'),'unexpected staging')
 original_untracked=set(before['untracked_files']);current=set(run('ls-files','--others','--exclude-standard','-z').decode().strip('\0').split('\0'));need(original_untracked<=current,'historical untracked files removed/hidden')
 result.update(completion_verdict='M4_OFFLINE_AND_BUILD_PASS_HARDWARE_PENDING',cli_negative_cases=21,rtl_fault_tests=10,protected_file_set_unchanged=True,historical_untracked_files_preserved=len(original_untracked),git=dict(branch='codex/m4-color-overlay',head='3424514afe1721dc000495673c0ca757ea1f6372',index_empty=True,committed=False),delegate='GPT-6 Astra/ultra architecture, initial RTL/config/TB; usage limit then ROOT sole writer completed tests/build/audit and independently checked artifacts',hardware='NOT_TESTED_NO_PROGRAMMER_NO_DOWNLOAD_NO_FLASH')
 return result
if __name__=='__main__':
 result=review();(R/'ROOT_FINAL_REVIEW.json').write_text(json.dumps(result,indent=2));print('M4_FINAL_REVIEW_PASS cli=21 rtl=10 originals=2609+1_metadata_only hardware=pending')
