from pathlib import Path
import json,hashlib
R=Path.cwd();O=R/'reports/m5c_pair_capture_20261016/latest_descriptor_revision';O.mkdir(exist_ok=False)
p=R/'rtl/m5c_fusion/m5c_pair_lease.sv';b=p.read_bytes();s=b.decode();(O/'lease_original.sv').write_bytes(b)
s=s.replace('module m5c_pair_lease(','module m5c_pair_diag_lease(').replace(' output reg protocol_fault,output reg event_rejected);',' output reg protocol_fault,output reg event_rejected,output publication_accept);')
s=s.replace(' reg halted;',' reg halted;\r\n reg publication_commit;\r\n assign publication_accept=rst_n&&!stop&&!halted&&!protocol_fault&&publication_commit;')
s=s.replace('  nw=writing;','  publication_commit=0;\r\n  nw=writing;')
s=s.replace('   nw[publish_slot]=0;nr[publish_slot]=1;nlv=1;nls=publish_slot;','   publication_commit=1;\r\n   nw[publish_slot]=0;nr[publish_slot]=1;nlv=1;nls=publish_slot;')
q=R/'rtl/m5c_pair_diag/m5c_pair_diag_lease.sv';q.write_bytes(s.encode())
# Exact inverse demonstrates no change to any original state expression/assignment.
inverse=s.replace('module m5c_pair_diag_lease(','module m5c_pair_lease(').replace(',output publication_accept);',');').replace('\r\n reg publication_commit;\r\n assign publication_accept=rst_n&&!stop&&!halted&&!protocol_fault&&publication_commit;','').replace('  publication_commit=0;\r\n','').replace('   publication_commit=1;\r\n','')
assert inverse.encode()==b
rows=[]
def edit(rel,changes):
 p=R/rel;before=p.read_bytes();(O/p.name).write_bytes(before);t=before.decode()
 for a,z in changes:assert a in t,a;t=t.replace(a,z)
 p.write_bytes(t.encode());rows.append(dict(path=rel,before_sha256=hashlib.sha256(before).hexdigest(),after_sha256=hashlib.sha256(p.read_bytes()).hexdigest()))
edit('rtl/m5c_pair_diag/m5c_pair_backend.sv',[
 ('frozen_extended,pair_descriptor[0:1]','frozen_extended,latest_descriptor'),
 ('wire lease_latest_valid,lease_latest_slot;','wire lease_latest_valid,lease_latest_slot,publication_accept;'),
 ('assign result_descriptor=pair_descriptor[lease_latest_slot];','assign result_descriptor=latest_descriptor;'),
 ('m5c_pair_lease lease(','m5c_pair_diag_lease lease('),
 ('.protocol_fault(lease_fault),.event_rejected(event_rejected)', '.protocol_fault(lease_fault),.event_rejected(event_rejected),.publication_accept(publication_accept)'),
 ('pair_descriptor[0]<=0;pair_descriptor[1]<=0;','latest_descriptor<=0;'),
 ('if(publication_ok)begin writer_owned<=0;pair_descriptor[class_slot]<=frozen_extended;end','if(publication_ok)writer_owned<=0;\r\n   if(publication_accept)latest_descriptor<=frozen_extended;')])
edit('efinity/m5c_pair_diag_i3/Ti60_Demo.xml',[("../../rtl/m5c_fusion/m5c_pair_lease.sv","../../rtl/m5c_pair_diag/m5c_pair_diag_lease.sv")])
(O/'DERIVATION.json').write_text(json.dumps(dict(original_lease_sha256=hashlib.sha256(b).hexdigest(),clone_sha256=hashlib.sha256(q.read_bytes()).hexdigest(),inverse_byte_exact=True,changes=rows,scope='Original lease logic byte-exact under symbol/output/additional combinational flag inverse. Real write eligibility includes reset/stop/halted/preedge protocol_fault and exact original publish branch; current-edge nfault is deliberately NOT added because original core commits that edge. Single descriptor updates exactly when latest slot commits a publication. Verification pending.'),indent=2))
