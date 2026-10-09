"""Explicit M5B.0R proposed payload whitelist, with SHA; no git add/commit."""
from pathlib import Path
import hashlib,json,sys
ROOT=Path(__file__).resolve().parents[1];R=ROOT/'reports/m5b0r_ddr_admission';MANIFEST=R/'PROPOSED_GIT_SCOPE.json'
def paths():
 items=[ROOT/'docs'/(n+'.md') for n in ('STATUS','HANDOFF','MILESTONES','DECISIONS','AI_WORKFLOW','REVIEW_PROTOCOL')]
 items += [ROOT/'AGENTS.md',ROOT/'.gitattributes']
 w=ROOT/'efinity/m5b0r_ddr_address_diag_i3'
 items += [w/n for n in ('M5B0R_DdrDiag.xml','M5B0R_DdrDiag.peri.xml','M5B0R_DdrDiag.sdc')]
 items += [p for p in (w/'ip/DdrCtrl').iterdir() if p.is_file()]
 items += list((ROOT/'rtl/m5b0r_ddr_admission').glob('*.sv'))
 items += list((ROOT/'tb/m5b0r_ddr_admission').glob('*.sv'))+[ROOT/'tb/m5b0r_ddr_admission/run.do']
 items += [p for p in (ROOT/'scripts').glob('m5b0r*') if p.suffix in {'.py','.bat'} and p.name!='m5b0r_probe.bat']
 items += [p for p in R.iterdir() if p.is_file() and p!=MANIFEST and (p.suffix in {'.md','.json','.txt'} or p.name.startswith('FINAL_'))]
 items += [R/'build'/n for n in ('inputs_before.json','inputs_after.json','result.json')]
 items += list((R/'final_audit').glob('*.rpt'))+[R/'final_audit/binding.json']
 items += [R/'sim'/(name+'_results.json') for name in ('diagnostic','arbiter','monitor')]
 items += [R/'root_review'/n for n in ('REPLAY_RESULTS.json','NEGATIVE_RESULTS.json','SCOPE_GIT_RESULTS.json')]
 return sorted(set(items))
def rec(p):return dict(path=p.relative_to(ROOT).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def main():
 if len(sys.argv)>1:
  assert sys.argv[1]=='--verify'
  b=json.loads(MANIFEST.read_text());assert b['files']==[rec(p) for p in paths()]
  assert b['file_count']==len(b['files']) and b['total_workspace_bytes']==sum(x['bytes'] for x in b['files'])
  print('M5B0R_SCOPE_PASS',b['file_count'],b['total_workspace_bytes']);return
 records=[rec(p) for p in paths()]
 for v in records:
  parts=Path(v['path']).parts
  assert not set(parts)&{'outflow','work','work_pnr','work_syn','reference','tools','negative_cases','cache','.git'}
  assert Path(v['path']).suffix.lower() not in {'.bit','.zip','.log','.lock','.wlf','.vcd','.fst','.db','.vdb'}
  if Path(v['path']).suffix=='.bin':assert v['path'].endswith('/ip/DdrCtrl/ddr3_controller.bin')
 result=dict(status='FROZEN_CANDIDATE_PAYLOAD',head='02841e20e297e4e6fdd14db0762a91d7089232fb',branch='codex/m5b0r-ddr-admission',file_count=len(records),total_workspace_bytes=sum(x['bytes'] for x in records),files=records,manifest_policy='This manifest is committed in addition to the listed payload; excluded from its own hash/count/bytes to avoid a circular hash claim. Commit scope is files plus this manifest.',bin_exception='DDR IP source ROM, identical to M2, not bitstream or generated database',excluded_local_evidence='outflow/work databases, raw logs, negative clones, first failed build, temporary STA selector helper; retained locally, never deleted',line_endings='SHA256 and sizes describe exact workspace bytes. M5B.0R paths have -text attributes. Stage explicit paths with command-local core.autocrlf=false; verify every staged blob equals these bytes before commit. No repository/global Git config change.')
 MANIFEST.write_text(json.dumps(result,indent=2));print('PROPOSED_SCOPE',len(records),result['total_workspace_bytes'])
if __name__=='__main__':main()
