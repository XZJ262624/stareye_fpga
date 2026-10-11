"""Replay the bounded repair cases with immutable per-case receipts."""
from pathlib import Path
import argparse,subprocess,sys,json,hashlib
R=Path(__file__).resolve().parents[1]
O=R/'reports/m5b1_global_canny_i3/review_fix_264962e0'

def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())

def main():
 ap=argparse.ArgumentParser();ap.add_argument('group',choices=['core','negative','recovery']);ap.add_argument('--run',required=True);a=ap.parse_args()
 jobs=[]
 if a.group=='core':
  for case in ['transfer_cancel','backend_edges','engine_abort','tag_qualification']:
   jobs.append((case,'m5b1_review_repro.py',['--case',case]))
  for mode in range(3):jobs.append((f'cancel_{mode}','m5b1_review_repro.py',['--case','cancel','--mode',str(mode)]))
 if a.group=='negative':
  for mutant,case,marker in [('lcd_register','connection','REVIEW_R1_LCD_SAMPLE'),('unqualified_tap','connection','QUALIFIED_BEFORE_RASTER_ACQUISITION'),('no_local_cancel','cancel','REVIEW_R3_UNACCEPTED_BUSY'),('abort_zero_payload','engine_abort','CANCEL_OWNED_W_CHANGED'),('live_metadata','engine_abort','CANCEL_OWNED_W_CHANGED'),('freeze_take_race','backend_edges','FREEZE_TIMEOUT_CONSUMED_DESCRIPTOR')]:
   jobs.append((mutant,'m5b1_review_repro.py',['--case',case,'--mutant',mutant,'--expect-failure',marker]))
 if a.group=='recovery':
  for mode in range(3):jobs.append((f'recovery_{mode}','m5b1_repair_extra_sim.py',['--test','cancel_recovery','--mode',str(mode)]))
  jobs.append(('capture_drain','m5b1_repair_extra_sim.py',['--test','capture_drain']))
 receipt=O/'final'/f'review_{a.group}_{a.run}.json';assert not receipt.exists()
 rows=[]
 for label,script,args in jobs:
  name=f'final_{a.run}_{label}';path=O/name/'result.json';assert not path.exists()
  subprocess.run([sys.executable,'-B',str(R/'scripts'/script),*args,'--name',name],cwd=R,check=True)
  d=json.loads(path.read_text());assert d['status']==('EXPECTED_REPRODUCTION' if a.group=='negative' else 'PASS')
  assert all(rec(R/x['path'])==x for x in d['sources'])
  rows.append(dict(case=label,evidence=rec(path)))
 receipt.write_text(json.dumps(dict(status='PASS',group=a.group,cases=rows,runner=rec(Path(__file__))),indent=2))

if __name__=='__main__':main()
