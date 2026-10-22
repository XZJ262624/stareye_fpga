from common import *
q=json.loads((O/'SYSTEM_RESULT.json').read_text());assert q['passed'];verify([q['result']['log']])
s=(R/q['result']['log']['path']).read_text()
healthy=[dict(zip(('filter','high','mode','good','cyan'),map(int,x))) for x in re.findall(r'REAL_HEALTHY filter=(\d+) high=(\d+) mode=(\d+) good=(\d+) cyan=(\d+)',s)]
assert healthy and all(x['good']==921600 for x in healthy),healthy
assert {(1,64,2),(1,64,3),(2,64,4),(2,64,5),(2,64,6),(2,80,6)} <= {(x['filter'],x['high'],x['mode']) for x in healthy}
assert all(x['cyan']==1391 for x in healthy if x['filter']==2 and x['high']==64 and x['mode']==6)
assert all(x['cyan']==0 for x in healthy if x['high']==80)
summary={k:int(v) for k,v in re.findall(r'(\w+)=(\d+)',re.search(r'PASS_CANNY_SYSTEM.*',s)[0])}
assert summary['stable']==42 and summary['pixel_gold']==42*921600 and summary['publications']==5 and summary['off']>=1
stages={}
for line in s.splitlines():
 if 'REAL_HEALTHY' in line:
  mode=int(re.search(r'mode=(\d+)',line)[1]);stages.setdefault(mode,len(stages))
assert stages[3]<stages[4]<stages[5]<stages[6],stages
save(O/'SYSTEM_ACCEPTANCE.json',dict(passed=True,healthy=healthy,all_healthy_full_pixels=921600,summary=summary,log=q['result']['log'],scope='Actual new canny_system, GAU/MED frontend, LCD register, fusion display and OSD with DDR transaction service model. Stable full local/tap pixel gold; all 5 global publications checked over 921600 bits against independent BFS. Exact promotion coordinates additionally covered by FUSION_PIXEL_RESULT with synthetic direct reference.',request_cadence=dict(test_cycles=2000000,production_cycles=96000000),limitations=['Accelerated request cadence only; no production frame-rate claim.','Modes 2..6 exercised by full SUT; RAW/MAG and all seven controls covered by reused local/controls gates.','No hardware sensor orientation or physical DDR eye/PVT verification.']))
print('SYSTEM_STRICT_FULL_FRAME_ACCEPTANCE',summary)
