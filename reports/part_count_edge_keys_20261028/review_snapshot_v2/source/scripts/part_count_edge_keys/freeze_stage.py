from pathlib import Path
import json,hashlib,re,difflib,sys
R=Path(__file__).resolve().parents[2];O=R/'reports/part_count_edge_keys_20261028'
def rec(p):return dict(path=p.relative_to(R).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def save(n,v):(O/n).write_text(json.dumps(v,indent=2,ensure_ascii=False)+'\n',encoding='utf8')
parents=json.loads((O/'PARENT_PRODUCTION_MANIFEST.json').read_text());paths=[]
replacement={'part_count_controls':'part_keys_controls','part_count_stream_adapter':'part_keys_adapter',**{'part_open_'+n:'part_keys_'+n for n in ('system','core','confirm','osd')}}
diffs=[];unchanged=[]
for r in parents:
 p=R/r['path'];assert rec(p)==r
 if p.is_relative_to(R/'efinity/part_count_edge_open_i3'):
  q=R/'efinity/part_count_edge_keys_i3'/p.relative_to(R/'efinity/part_count_edge_open_i3')
  if q.name not in ('example_top.v','Ti60_Demo.xml'):assert q.read_bytes()==p.read_bytes();unchanged.append(dict(parent=r,new=rec(q)))
 elif p.stem in replacement:q=R/'rtl/part_count_edge_keys'/(replacement[p.stem]+p.suffix)
 else:q=p
 paths.append(q)
 if p!=q and q.read_bytes()!=p.read_bytes():diffs.extend(difflib.unified_diff(p.read_text(encoding='utf8').splitlines(True),q.read_text(encoding='utf8').splitlines(True),fromfile=p.relative_to(R).as_posix(),tofile=q.relative_to(R).as_posix()))
paths.append(R/'rtl/part_count_edge_keys/part_keys_config.sv')
diffs.extend(difflib.unified_diff([],paths[-1].read_text(encoding='utf8').splitlines(True),fromfile='/dev/null',tofile=paths[-1].relative_to(R).as_posix()))
save('PRODUCTION_MANIFEST.json',[rec(p) for p in sorted(set(paths))]);(O/'SOURCE_DIFF_TECHNICAL_PARENT.patch').write_text(''.join(diffs),encoding='utf8')
save('PRESERVATION.json',dict(passed=True,parent_sources=len(parents),unchanged_project=unchanged,algorithms_reused_without_copy=['part_open_ccl','part_open_morph','part_open_frame_guard','part_open_capture','part_open_bank_ram','GAU2 m5a','DDR/FIFO/frontend'],new_cdc=False))
receipts=[]
for names in (['unit','core'],['video'],['osd']):
 candidates=[]
 for p in O.glob('tests_*/FINAL_RESULT.json'):
  v=json.loads(p.read_text(encoding='utf8'))
  if v.get('passed') and all(any(x['name']==n for x in v['results']) for n in names):candidates.append(p)
 if not candidates and '--video-pending' in sys.argv and names==['video']:continue
 assert candidates,names
 p=sorted(candidates)[-1];v=json.loads(p.read_text(encoding='utf8'))
 for r in v['inputs']:
  # Sources unused by unit/core (OSD renderer) may have changed after unit
  # pass; require fresh unit receipt in normal sealing rather than waive hash.
  assert rec(R/r['path'])==r,r['path']
 receipts.append(rec(p))
pending=not any('video' in json.loads((R/r['path']).read_text(encoding='utf8'))['results'][-1]['name'] for r in receipts)
save('STAGE1_RESULT.json',dict(passed=True,status='PASS_DIRECTED_VIDEO_PENDING' if pending else 'PASS_DIRECTED_AND720P',video_pending=pending,tests=receipts,production=rec(O/'PRODUCTION_MANIFEST.json'),hardware=False))
print('KEYS_STAGE1',len(paths),len(receipts))
