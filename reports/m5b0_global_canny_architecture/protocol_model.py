"""Executable ownership/identity/publication contract; no HDL/CDC timing claims."""
import argparse
from dataclasses import dataclass
import json
from pathlib import Path

@dataclass(frozen=True)
class Descriptor:
    epoch:int
    frame_id:int
    threshold_hi:int=64
    threshold_lo:int=32
    median:bool=True
    mode:int=5
    support_radius:int=3


class Protocol:
    def __init__(self,w=4,h=3):
        self.w=w;self.h=h;self.epoch=1;self.state='IDLE';self.desc=None
        self.snap=['FREE','FREE'];self.slot=None;self.result=[None,None]
        self.lease=set();self.ready=None;self.previous=None;self.quarantine=False
        self.timeout=False;self.error=None;self.converged=False;self.dropped=0
        self.copy_slot=None
    def request(self):
        if self.quarantine or self.state!='IDLE' or 'FREE' not in self.snap:
            self.dropped+=1;return False
        self.slot=self.snap.index('FREE');self.snap[self.slot]='ARMED';self.state='ARMED';return True
    def frame_start(self,desc):
        assert self.state=='ARMED' and desc.epoch==self.epoch
        assert desc.threshold_lo==desc.threshold_hi//2
        assert desc.support_radius==(3 if desc.median else 2)
        self.desc=desc;self.count=0;self.state='CAPTURE';self.snap[self.slot]='CAPTURE'
        self.error=None;self.timeout=False;self.converged=False
    def pixel(self,frame_id,x,y,value,config=None):
        assert self.state=='CAPTURE'
        if frame_id!=self.desc.frame_id or x!=self.count%self.w or y!=self.count//self.w or value not in (0,1,2) or (config is not None and config!=self.desc):
            self.error='FRAME_FORMAT_OR_IDENTITY'
        self.count+=1
    def capture_done(self,writes_drained,responses_ok=True):
        assert self.state=='CAPTURE'
        if not writes_drained:return False
        if self.count!=self.w*self.h or not responses_ok or self.error:
            self.error=self.error or 'INCOMPLETE_OR_AXI_ERROR';self.snap[self.slot]='FREE';self.state='IDLE';return False
        self.snap[self.slot]='FROZEN';self.state='BUSY';return True
    def pair_done(self,forward_changed,reverse_changed,outstanding=0,pipeline=0):
        assert self.state=='BUSY'
        if outstanding or pipeline:return False
        if forward_changed or reverse_changed:return False
        self.converged=True;self.state='CONVERGED';return True
    def reserve_result(self):
        assert self.state=='CONVERGED'
        # One descriptor mailbox: keep its payload and ready stable until ACK.
        if self.ready is not None:return False
        unavailable=self.lease|({self.ready} if self.ready is not None else set())
        free=[i for i in (0,1) if i not in unavailable]
        if not free:return False
        self.copy_slot=free[0];self.state='COPYING';return True
    def publish(self,copy_drained=True,responses_ok=True,epoch=None):
        assert self.state=='COPYING' and self.copy_slot is not None
        if not copy_drained:return False
        if not responses_ok or epoch not in (None,self.epoch):
            self.abort('RESULT_ERROR');return False
        i=self.copy_slot
        assert i not in self.lease and i!=self.ready
        self.result[i]=self.desc;self.ready=i;self.copy_slot=None
        self.snap[self.slot]='FREE';self.state='IDLE';return True
    def consume_at_sof(self):
        if self.ready is None:return None
        i=self.ready;self.ready=None;self.lease.add(i);self.previous=i;return i
    def release(self,i):
        self.lease.remove(i)
    def age(self,i,current):
        d=self.result[i]
        if d is None or d.epoch!=current.epoch or current.frame_id<d.frame_id:return None
        return min((1<<32)-1,current.frame_id-d.frame_id)
    def abort(self,reason='WATCHDOG',drained=True):
        self.timeout=reason=='WATCHDOG';self.error=reason;self.converged=False
        self.copy_slot=None
        self.quarantine=not drained
        self.snap[self.slot]='QUARANTINE' if not drained else 'FREE'
        self.state='IDLE'
    def reset(self):
        self.epoch+=1;self.state='IDLE';self.quarantine=True
        self.result=[None,None];self.ready=None;self.previous=None;self.lease=set()
        self.snap=['QUARANTINE','QUARANTINE'];self.converged=False
        self.copy_slot=None
    def drain_ack(self):
        assert self.state=='IDLE'
        self.quarantine=False;self.snap=['FREE','FREE']


def capture(p,frame_id=10):
    assert p.request();d=Descriptor(p.epoch,frame_id);p.frame_start(d)
    for y in range(p.h):
        for x in range(p.w):p.pixel(frame_id,x,y,2 if x==y==0 else 1)
    return d


def execute(out):
    passed=[]
    def ok(name,condition):
        assert condition,name;passed.append(name)
    p=Protocol();capture(p)
    ok('busy_request_dropped',not p.request())
    ok('last_W_not_B_fence',not p.capture_done(False))
    ok('freeze_after_all_B',p.capture_done(True) and p.snap[p.slot]=='FROZEN')
    ok('input_frozen_while_busy',not p.request())
    ok('late_pipeline_change_not_lost',not p.pair_done(False,False,pipeline=1))
    ok('inflight_AXI_not_convergence',not p.pair_done(False,False,outstanding=1))
    ok('OR_reduce_both_directions',not p.pair_done(True,False))
    ok('OR_reverse_change',not p.pair_done(False,True))
    ok('complete_zero_pair',p.pair_done(False,False))
    ok('reserve_before_copy',p.reserve_result() and p.state=='COPYING' and p.copy_slot not in p.lease)
    ok('copy_not_visible_to_consumer',p.consume_at_sof() is None)
    ok('final_copy_fence',not p.publish(False))
    ok('publish_only_after_fence',p.publish())
    i=p.consume_at_sof();ok('result_lease',i in p.lease)
    ok('age_same_epoch',p.age(i,Descriptor(p.epoch,73))==63)
    ok('age_epoch_mismatch_invalid',p.age(i,Descriptor(p.epoch+1,73)) is None)
    ok('age_wrap_backwards_invalid',p.age(i,Descriptor(p.epoch,9)) is None)
    capture(p,11);assert p.capture_done(True);p.abort()
    ok('watchdog_keeps_previous',p.previous==i and p.result[i].frame_id==10 and p.timeout and not p.converged)
    for case in ('missing_pixel','wrong_frame','wrong_xy','reserved11','midframe_config','AXI_response_error'):
        q=Protocol();q.request();d=Descriptor(q.epoch,20);q.frame_start(d)
        count=q.w*q.h-(1 if case=='missing_pixel' else 0)
        for n in range(count):
            q.pixel(21 if case=='wrong_frame' and n==2 else 20,(n%q.w+1)%q.w if case=='wrong_xy' and n==2 else n%q.w,n//q.w,3 if case=='reserved11' and n==2 else 1,Descriptor(q.epoch,20,80,40) if case=='midframe_config' and n==2 else d)
        ok(case,not q.capture_done(True,case!='AXI_response_error') and q.ready is None)
    q=Protocol();capture(q);assert q.capture_done(True);q.abort(drained=False)
    ok('timeout_inflight_quarantine',q.quarantine and not q.request())
    q.drain_ack();ok('timeout_after_drain_reusable',q.request())
    q.reset();ok('reset_old_results_invalid',q.ready is None and q.previous is None and not q.request())
    q.drain_ack();capture(q,1);assert q.capture_done(True);assert q.pair_done(False,False)
    assert q.reserve_result()
    ok('stale_epoch_completion_rejected',not q.publish(epoch=q.epoch-1))
    # Both result slots read leased => producer waits, never overwrites a reader.
    q=Protocol()
    for fid in (1,2):
        capture(q,fid);assert q.capture_done(True);assert q.pair_done(False,False);assert q.reserve_result();assert q.publish();q.consume_at_sof()
    capture(q,3);assert q.capture_done(True);assert q.pair_done(False,False)
    ok('both_result_slots_leased_stall',not q.reserve_result() and q.state=='CONVERGED' and q.copy_slot is None)
    q.release(0);ok('reader_release_required',q.reserve_result() and q.publish())
    q=Protocol();capture(q,1);assert q.capture_done(True);assert q.pair_done(False,False)
    assert q.reserve_result();assert q.publish();pending=q.ready
    capture(q,2);assert q.capture_done(True);assert q.pair_done(False,False)
    ok('pending_descriptor_not_overwritten',not q.reserve_result() and q.ready==pending and q.result[pending].frame_id==1)
    q.consume_at_sof()
    ok('pending_ACK_allows_next_copy',q.reserve_result() and q.copy_slot!=pending)
    q.abort(drained=False)
    ok('COPYING_abort_quarantines',q.quarantine and q.copy_slot is None and not q.request() and pending in q.lease)
    q.drain_ack();capture(q,3);assert q.capture_done(True);assert q.pair_done(False,False);assert q.reserve_result()
    q.reset()
    ok('COPYING_reset_invalidates',q.copy_slot is None and q.result==[None,None] and q.ready is None and not q.request())
    out.mkdir(parents=True,exist_ok=True)
    (out/'PROTOCOL_RESULTS.json').write_text(json.dumps(dict(status='PASS_CONTRACT_MODEL_ONLY',cases=passed,case_count=len(passed),cdc_timing_verified=False,rtl_verified=False),indent=2),encoding='utf-8')
    print('PROTOCOL PASS',len(passed),'contract cases; no HDL/CDC timing claim')

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--output',type=Path,default=Path(__file__).parent);execute(p.parse_args().output)
