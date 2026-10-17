from pathlib import Path
import json,hashlib,datetime
R=Path.cwd();O=R/'reports/m5c_pair_capture_20261016/sid_revision';O.mkdir(exist_ok=False)
def rec(p):
 b=p.read_bytes();return dict(path=str(p.relative_to(R)),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
rows=[]
def edit(rel,changes):
 p=R/rel;b=p.read_bytes();(O/p.name).write_bytes(b);s=b.decode();old=rec(p)
 for a,z in changes:
  assert a in s,(rel,a);s=s.replace(a,z)
 p.write_bytes(s.encode());rows.append(dict(before=old,after=rec(p)))
edit('rtl/m5c_pair_diag/m5c_pair_system.sv',[
 ('pair_request_take,pair_request_data;','pair_request_take;\r\n wire [63:0] pair_request_data;'),
 ('reg pair_send;','wire pair_send=fusion_request&&pair_cov&&!pair_wait_expired_pix&&!pair_terminal_pix[1]&&!pair_request_busy;'),
 ('begin pair_send<=0;pair_terminal_pix<=0;','begin pair_terminal_pix<=0;'),
 ('pair_terminal};pair_send<=0;','pair_terminal};'),
 ('   if(pair_cov&&!pair_request_busy&&!pair_wait_expired_pix)pair_send<=1;',''),
 ('.WIDTH(1)) pair_request_box','.WIDTH(64)) pair_request_box'),
 ('.sdata(1\'b1)', '.sdata(fusion_request_seq)'),
 ('.pair_request_take(pair_request_take),.active_pair_descriptor', '.pair_request_take(pair_request_take),.pair_request_session(pair_request_data),.active_pair_descriptor')])
edit('rtl/m5c_pair_diag/m5c_pair_backend.sv',[
 ('input [63:0] pair_session,','input [63:0] pair_session,pair_request_session,'),
 ('pair_selected=pair_request&&fusion_acquire&&exported&&','pair_selected=pair_request&&pair_request_session==pair_session&&fusion_acquire&&exported&&'),
 ('assign pair_request_take=pair_selected;','// Consume a stale or evaluated request without changing ordinary fusion acquire.\r\n assign pair_request_take=pair_request&&(pair_terminal||pair_wait_expired||pair_request_session<pair_session||(pair_request_session==pair_session&&fusion_acquire));')])
edit('tb/m5c_pair_diag/tb_pair_backend_legacy_recovery.sv',[(".pair_request(1'b0),",".pair_request(1'b0),.pair_request_session(64'd0),")])
(O/'DERIVATION.json').write_text(json.dumps(dict(changes=rows,scope='Full64 request sampled on the real fusion_request edge; stale requests acknowledged without counting capture attempts or blocking normal acquire. Native verification pending.'),indent=2))
