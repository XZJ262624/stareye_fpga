from pathlib import Path
import json,re,hashlib
A=Path(__file__).resolve().parent;R=A.parents[3];P=A/'mirror/efinity/m5c_fusion_i3'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
proof=json.loads((A/'RAM_ADDRESS_MAPPING_PROOF.json').read_text());old=json.loads((A/'RAM_PHYSICAL_CONSTANT_DIFFERENCES_CURRENT.json').read_text())
assert proof['status']=='PASS_CURRENT_COMPLETE_RAM_ADDRESS_PIN_MAPPING' and not proof['unknown']
assert {x['difference_pin'] for x in proof['records']}=={x['pin'] for x in old['records']} and len(proof['records'])==len(old['records'])
for x in [proof['map'],proof['native'],proof['generator']]+proof['reports']:assert rec(R/x['path'])==x
assert all(len(x['address_table'])==9 and all(t['classification']!='UNKNOWN' for t in x['address_table']) for x in proof['records'])
log=(A/'sta_05_clock_pairs/tool.log').read_text();pairs=re.findall(r'^CLOCK_PAIR (\d+) (\S+) (\S+)',log,re.M);sources={a for _,a,_ in pairs};dest={b for _,_,b in pairs};assert sources==dest and {(a,b) for _,a,b in pairs}=={(a,b) for a in sources for b in dest} and len(pairs)==len(sources)**2
rows=[]
for index,a,b in pairs:
 for mode in ['setup','hold']:
  p=P/f'outflow/clock_{index}_{mode}.rpt'
  if not p.exists():
   seg=log.split(f'CLOCK_PAIR {index} {a} {b}',1)[1].split('CLOCK_PAIR ',1)[0];j=1 if mode=='setup' else 2;seg=seg.split(f'FRESH_REPORT_BEGIN 05_clock_pairs {j}',1)[1].split(f'FRESH_REPORT_END 05_clock_pairs {j}',1)[0];assert seg.count('No timing path is found')==1
   rows.append(dict(index=int(index),source=a,destination=b,mode=mode,status='EXPLICIT_NATIVE_NO_TIMING_PATH'));continue
  s=p.read_text();assert re.search(r'Timing Model\s*:\s*I3',s);paths=re.split(r'\+{4} Path \d+ \+{4,}',s)[1:];assert paths
  for block in paths:
   launch=re.search(r'^Launch Clock\s*:\s*(\S+)',block,re.M)[1];capture=re.search(r'^Capture Clock\s*:\s*(\S+)',block,re.M)[1];assert launch==a and capture==b,(p,launch,capture,a,b);assert float(re.search(r'^Slack\s*:\s*([+-]?[0-9.]+)',block,re.M)[1])>=0
  rows.append(dict(index=int(index),source=a,destination=b,mode=mode,status='ACTUAL_PATH_CLOCKS_MATCH_PAIR',path_count=len(paths),report=rec(p)))
p=A/'CLOCK_RAM_FINAL_COMPLETION.json';assert not p.exists();p.write_text(json.dumps(dict(status='PASS_CURRENT_RAM_FULL_MAPPING_AND_ACTUAL_CLOCK_PAIR_PATHS',ram=rec(A/'RAM_ADDRESS_MAPPING_PROOF.json'),ram_differences=len(proof['records']),ram_address_bit_checks=sum(len(x['address_table']) for x in proof['records']),clock_pairs=len(pairs),clock_sources=sorted(sources),clock_destinations=sorted(dest),clock_rows=rows,log=rec(A/'sta_05_clock_pairs/tool.log'),generator=rec(Path(__file__))),indent=2));print('RAM_BITS',sum(len(x['address_table']) for x in proof['records']),'TIMED_PAIR_REPORTS',sum(x['status']=='ACTUAL_PATH_CLOCKS_MATCH_PAIR' for x in rows),'EXPLICIT_NO_PATH',sum(x['status']=='EXPLICIT_NATIVE_NO_TIMING_PATH' for x in rows))
