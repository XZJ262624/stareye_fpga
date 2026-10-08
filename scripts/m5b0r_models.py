"""Independent offline address/QoS models. No DDR or board access."""
from pathlib import Path
import argparse,json,math,hashlib,subprocess
ROOT=Path(__file__).resolve().parents[1]
REPORT=ROOT/'reports/m5b0r_ddr_admission'
POINTS=[0]+[1<<i for i in range(4,29)]+[0x00fffff0,0x01073800,0x010e6ff0,0x00073800,0x000e6ff0,0x01400000,0x01c00000,0x1ffffff0,0x00c00000,0x010007f0,0x01000800,0x01000ff0]
def canary(a,inv=False):
 return tuple((a^k)^(0xffffffff if inv else 0) for k in (0x01234567,0x76543210,0x89abcdef,0xfedcba98))
def address_test(mapping,compare=True):
 mem={}
 for a in POINTS:mem[mapping(a)]=canary(a)
 for a in POINTS:
  if compare and mem.get(mapping(a))!=canary(a):return True
 for a in POINTS:
  if a<0x01000000:mem[mapping(a)]=canary(a,True)
 for a in POINTS:
  if compare and mem.get(mapping(a))!=canary(a,a<0x01000000):return True
 return False

def addresses(negative=False):
 faults={f'drop_bit_{i}':address_test(lambda a,i=i:a&~(1<<i),not negative) for i in range(4,29)}
 faults.update({k:address_test(f,not negative) for k,f in {
  'truncate_16MiB':lambda a:a&0xffffff,
  'scale2_wrap_512MiB':lambda a:(a*2)%0x20000000,
  'scale16_wrap_512MiB':lambda a:(a*16)%0x20000000}.items()})
 assert all(faults.values()),'canary comparator mutation detected by acceptance'
 invisible={k:address_test(f) for k,f in {
  'coupled_divide16_point_units':lambda a:a//16,
  'coupled_xor_bit28':lambda a:a^(1<<28)}.items()}
 assert not any(invisible.values())
 assert len(POINTS)==len(set(POINTS))==38
 assert all(a%16==0 and a+16<=0x20000000 for a in POINTS)
 return dict(status='PASS_SOFTWARE_ONLY',detected_faults=faults,
  unobservable_mappings={k:'INCONCLUSIVE' for k in invisible},points=[hex(a) for a in POINTS],
  candidate_bytes=946176,bursts_2048=462,transactions=9967,write_beats=356927,read_beats=357128,total_transfer_bytes=11424880,
  boundary='point mapping algebra; response/errors/partial burst/data lane faults validated by separate HDL tests; not physical DDR proof')

def protocol_tests():
 # Independent executable transaction specification, not a controller model.
 def verify(a=0x1000000,n=128,bid=5,bresp=0,rid=5,rresp=0,last=127,data_match=True,completed=True):
  if a%16 or n<1 or n>128 or a+n*16>0x20000000 or (a&4095)+n*16>4096:return 'ILLEGAL_COMMAND'
  if not completed:return 'WATCHDOG'
  if bid!=5 or bresp:return 'WRITE_RESPONSE_ERROR'
  if rid!=5 or rresp:return 'READ_RESPONSE_ERROR'
  if last!=n-1:return 'RLAST_ERROR'
  if not data_match:return 'DATA_ERROR'
  return 'PASS'
 cases={
  'healthy':({},'PASS'), 'burst_4K_cross':({'a':0x1000ff0},'ILLEGAL_COMMAND'),
  'capacity_overflow':({'a':0x1ffffff0},'ILLEGAL_COMMAND'),
  'bad_BID':({'bid':6},'WRITE_RESPONSE_ERROR'),'BRESP':({'bresp':2},'WRITE_RESPONSE_ERROR'),
  'bad_RID':({'rid':6},'READ_RESPONSE_ERROR'),'RRESP':({'rresp':2},'READ_RESPONSE_ERROR'),
  'early_RLAST':({'last':0},'RLAST_ERROR'),'late_RLAST':({'last':128},'RLAST_ERROR'),
  'burst_data_slip':({'data_match':False},'DATA_ERROR'),'missing_response':({'completed':False},'WATCHDOG')}
 result={k:dict(expected=e,actual=verify(**v)) for k,(v,e) in cases.items()}
 assert all(v['expected']==v['actual'] for v in result.values())
 return dict(status='PASS_SOFTWARE_SPEC_ONLY',cases=result,boundary='Executable error specification; independent of HDL bus model; not real AXI or DDR proof')

def qos(lmax_cycles=384,depth=8192,r_initial=4096,w_initial=2048,
 ui=96e6,pixel=74.4e6,camera=100e6,bus_bytes=16,rt_burst_beats=128,
 bg_burst_beats=32,bg_refill_cycles=512,bg_budget=8.99e6,cdc_cycles=4,extra_guard=64):
 assert min(ui,pixel,camera,bus_bytes,rt_burst_beats,bg_burst_beats,bg_refill_cycles,lmax_cycles)>0
 assert depth>0 and 0<=r_initial<=depth and 0<=w_initial<=depth and bg_budget>=0
 assert cdc_cycles>=0 and extra_guard>=0, "negative CDC or guard"
 assert bus_bytes*rt_burst_beats<=depth and bus_bytes*bg_burst_beats<=depth, "burst exceeds FIFO depth"
 r_guard=math.ceil(pixel*cdc_cycles/ui)+extra_guard
 w_guard=math.ceil(camera*cdc_cycles/ui)+extra_guard
 r_safe=max(0,r_initial-r_guard);w_safe=max(0,depth-w_initial-w_guard)
 r_stop=r_safe/pixel;w_stop=w_safe/camera;lmax=lmax_cycles/ui
 rt_bytes=bus_bytes*rt_burst_beats;bg_bytes=bus_bytes*bg_burst_beats
 # At most one issued BG and one opposing RT precede the urgent requester.
 completion=3*lmax;blackout=completion<min(r_stop,w_stop)
 # Lmax includes A/W/R/B and client backpressure. Necessity is stronger than
 # a single blackout calculation: queues must also recover in the long run.
 rt_util=(pixel+camera)/rt_bytes*lmax
 bg_util=bg_budget/bg_bytes*lmax
 guaranteed_per_rt=rt_bytes/(3*lmax) # conservative 2 RT + 1 BG schedule
 aggregate_ok=rt_util+bg_util<1
 fair_rt_ok=guaranteed_per_rt>max(pixel,camera)
 credit_ceiling=ui/bg_refill_cycles*bg_bytes
 sustainable=aggregate_ok and fair_rt_ok and bg_budget<=credit_ceiling
 return dict(status='CONDITIONAL_MATH_ONLY',depth_bytes=depth,
 r_initial_bytes=r_initial,w_initial_bytes=w_initial,ui_hz=ui,pixel_hz=pixel,
 camera_hz_assumption=camera,bus_bytes=bus_bytes,rt_burst_beats=rt_burst_beats,
 cdc_bound_cycles_assumption=cdc_cycles,extra_guard_bytes=extra_guard,
 r_guard_bytes=r_guard,w_guard_bytes=w_guard,r_max_stall_us=r_stop*1e6,w_max_stall_us=w_stop*1e6,
 backend_lmax_cycles_assumption=lmax_cycles,backend_lmax_us_assumption=lmax*1e6,
 rt_request_start_bound_us=2*lmax*1e6,rt_transaction_complete_bound_us=completion*1e6,
 blackout_safe_under_assumptions=blackout,sustainable_rt_service=sustainable,
 aggregate_rt_utilization=rt_util,bg_service_utilization_budget=bg_util,
 conservative_per_rt_service_MBps=guaranteed_per_rt/1e6,
 r_net_recovery_bytes_per_round=rt_bytes-pixel*completion,
 w_net_recovery_bytes_per_round=rt_bytes-camera*completion,
 r_recovery_bursts=math.ceil(pixel*completion/(rt_bytes-pixel*completion)) if rt_bytes>pixel*completion else None,
 w_recovery_bursts=math.ceil(camera*completion/(rt_bytes-camera*completion)) if rt_bytes>camera*completion else None,
 r_urgent_below_bytes=math.ceil(pixel*completion)+r_guard,
 w_urgent_above_bytes=depth-math.ceil(camera*completion)-w_guard,
 feasible_under_assumptions=blackout and sustainable,
 backend_lmax_required_below_us=min(r_stop,w_stop)/3*1e6,
 bg_max_beats=bg_burst_beats,bg_bytes_per_burst=bg_bytes,bg_refill_cycles=bg_refill_cycles,
 bg_budget_MBps=bg_budget/1e6,bg_credit_theoretical_ceiling_MBps=credit_ceiling/1e6,
 physical_backend_bound_proven=False,initial_prefill_proven=False,
 fifo_watermarks_connected_in_production=False,
 boundary='urgent+valid request origin; Lmax includes arbiter/client backpressure; all guarantees conditional, no physical proof')

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--negative',action='store_true')
 for name,default in [('lmax_cycles',384),('depth',8192),('r_initial',4096),('w_initial',2048),('ui',96e6),('pixel',74.4e6),('camera',100e6),('bus_bytes',16),('rt_burst_beats',128),('bg_burst_beats',32),('bg_refill_cycles',512),('bg_budget',8.99e6),('cdc_cycles',4),('extra_guard',64)]:
  ap.add_argument('--'+name.replace('_','-'),type=type(default),default=default)
 args=ap.parse_args()
 invalid=[]
 for kwargs in ({'cdc_cycles':-4},{'extra_guard':-10000},{'rt_burst_beats':1024},{'bg_burst_beats':1024}):
  try:qos(**kwargs)
  except AssertionError:invalid.append(kwargs)
  else:raise AssertionError('invalid configuration accepted')
 a=addresses(args.negative);protocol=protocol_tests();q=qos(**{k:v for k,v in vars(args).items() if k!='negative'});bad=qos(2048);empty=qos(r_initial=0);longterm_bad=qos(1632)
 assert qos()['feasible_under_assumptions'] and not bad['feasible_under_assumptions'] and not empty['feasible_under_assumptions']
 assert longterm_bad['blackout_safe_under_assumptions'] and not longterm_bad['sustainable_rt_service']
 REPORT.mkdir(exist_ok=True)
 (REPORT/'ADDRESS_SOFTWARE_RESULTS.json').write_text(json.dumps(a,indent=2))
 (REPORT/'PROTOCOL_SOFTWARE_RESULTS.json').write_text(json.dumps(protocol,indent=2))
 (REPORT/'QOS_MODEL.json').write_text(json.dumps(dict(example=q,unsafe_watchdog_as_bound=bad,empty_prefill=empty,blackout_safe_but_longterm_unsafe=longterm_bad,invalid_configurations_rejected=invalid,gate='NO_GO'),indent=2))
 print('M5B0R_MODELS_PASS',len(a['detected_faults']),'address faults; QOS conditional examples')
if __name__=='__main__':main()
