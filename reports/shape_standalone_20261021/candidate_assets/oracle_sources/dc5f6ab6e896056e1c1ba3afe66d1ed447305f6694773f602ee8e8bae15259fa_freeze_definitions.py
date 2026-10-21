"""Freeze held-out grayscale truth and arithmetic boundaries before predictions."""
from pathlib import Path
import json,hashlib,time
R=Path(__file__).resolve().parents[3];Q=R/'reports/gaussian_integration_20261020/cap_host_gate_20261020';Q.mkdir(exist_ok=False)
def record(p):return dict(path=p.relative_to(R).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
cases=[]
for scale,w in enumerate([84,130,220,260]):
 for pos,(cx,cy) in enumerate([(216,168),(296,168),(216,216),(296,216)]):
  for noise_i,noise in enumerate([0,1,2,4]):
   kind='circle' if (pos+noise_i)%2==0 else 'rect';i=len(cases)
   cases.append(dict(id=i,kind=kind,truth=1 if kind=='circle' else 2,cx=cx,cy=cy,w=w,h=w if kind=='circle' else max(84,min(260,round(w*[1,.8,1.2,1][noise_i]))),angle=0 if kind=='circle' else [-2,-1,1,2][noise_i],contrast=[72,112,160][(scale+pos+noise_i)%3],noise=noise,seed=931701+i))
for family in ['top_foreign','bottom_foreign','symmetric_foreign','cap_bar','middle_segments','ring_double','ellipse_truncated','text_shadow']:
 for j in range(8):
  i=len(cases);w=[130,164,220,260][j%4]
  cases.append(dict(id=i,kind=family,variant=j,truth=0,cx=256,cy=192,w=w,h=w,angle=0,contrast=[72,112,160][j%3],noise=[0,1,2,4][j%4],seed=931701+i,foreign_size=[4,6,8,10,12,14,16,18][j]))
assert len(cases)==128 and sum(c['truth']!=0 for c in cases)==64
boundaries=[]
def boundary(label,h,rows,expected,**extra):
 boundaries.append(dict(id=len(boundaries),label=label,height=h,width=h,rows=rows,expected_cap_allows=expected,**extra))
def row(r,w=12,e=12,center=0,segments=3):return dict(r=r,row_width=w,expected_width=e,center_error=center,segments=segments)
for h in [80,128,192,280]:
 k=(h+63)//64;positions=list(range(k))+list(range(h-1,h-k-1,-1))
 for delta in [-1,0,1]:boundary('budget_'+str(delta),h,[row(r) for r in positions[:k+delta]],delta<=0)
h=192;k=3
for label,r,allow in [('top_inside',2,True),('top_outside',3,False),('bottom_inside',189,True),('bottom_outside',188,False)]:boundary(label,h,[row(r)],allow)
for error in [16,17]:boundary('center_'+str(error),h,[row(0,center=error)],error==16)
for excess in [19,20]:boundary('width_excess_'+str(excess),h,[row(0,w=12+excess)],excess==19)
boundary('middle_third_segment',h,[row(96)],False)
boundary('saturated_seven_exceeds_five',280,[row(r) for r in [0,1,2,3,4,279,278,277]],False)
boundary('no_fragment_middle_two_segments',h,[row(96,segments=2)],True)
boundary('fresh_frame_no_carried_counter',h,[row(0)],True,prior_frame_fragment_count=7,scope='Independent classifier call initializes fresh count; no RTL CE/SOF protocol claim')
assert len(boundaries)==24
definition=dict(status='FROZEN_BEFORE_GOLD_OR_NEW_MODEL',created_unix=time.time(),width=544,height=416,ROI=[16,16,512,384],filter=2,high=64,positive=64,negative=64,cases=cases,boundaries=boundaries,gray_rule='Background220; foreground220-contrast. Deterministic noise ((x*1103515245+y*12345+seed*2654435761)>>12) mod(2*noise+1)-noise. Circle/rect geometry uses ROI coordinates. Negative foreign square x=cx +/- .32*w; cap y=cy +/- (h/2-size/2-2); cap bar width .7*w, height2+variant%4, y=cy-h/2+4. Middle extra vertical bars x=cx+/-w*.15. Ring inner radius .32*w; double circles radius .22*w and centers +/- .3*w. Ellipse h=.72*w or clipped circle at ROI x8. Text two bars and crossbar; shadow diagonal half-filled rectangle. Full generator implementation and independent gold bound at run PRE.',truth_rule='64 single circle/rectangle positives;64 geometry non-target or multiple-object negatives, all retained even if model disagrees. Tiny foreign objects are negative, never relabelled noise.',boundary_scope='24 host arithmetic cap-veto boundaries, not grayscale accuracy samples or RTL protocol/CE qualification.',generator=record(Path(__file__)))
p=Q/'DEFINITIONS_BEFORE_MODEL_GOLD.json';p.write_text(json.dumps(definition,indent=2));(Q/'DEFINITION_RECEIPT.json').write_text(json.dumps(dict(status=definition['status'],definition=record(p),positive=64,negative=64,boundaries=24),indent=2));print(record(p))
