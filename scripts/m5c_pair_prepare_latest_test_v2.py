from pathlib import Path
import hashlib,json
R=Path.cwd();p=R/'tb/m5c_pair_diag/tb_pair_latest_descriptor.sv';b=p.read_bytes();s=b.decode();s=s.replace('module tb_pair_latest_descriptor;','module tb_pair_latest_descriptor_v2;')
s=s.replace('integer events=0,edges=0,k,j;reg preaccept;','integer events=0,edges=0,k,j;reg preaccept;\nwire old_commit=rst&&!stop&&!old_core.halted&&!old_core.protocol_fault&&pub&&old_core.writing[slot]&&!old_core.nw[slot]&&old_core.nr[slot]&&old_core.nlv&&(old_core.nls==slot);')
s=s.replace(' preaccept=accept;',' preaccept=accept;\n if(accept!==old_commit)$fatal(1,"ORIGINAL_COMMIT_ACCEPT_MISMATCH");')
s=s.replace(' else if(accept)begin oldslot[slot]<=descriptor;latest<=descriptor;events=events+1;end',' else begin\n if(old_commit)oldslot[slot]<=descriptor;\n if(accept)begin latest<=descriptor;events=events+1;end\n end')
a=' resetcore;reservejob(64\'h900000009);bindjob;publishcheck(1);'
z=''' // This edge creates nfault but the original core still commits its publication.
 resetcore;reservejob(64'h900000009);bindjob;bad_done=1;publishcheck(1);bad_done=0;
 if(!faulta||!lva)$fatal(1,"SAME_EDGE_NFAULT_PUBLICATION_NOT_COMMITTED");publishcheck(0);
 resetcore;reservejob(64'ha0000000a);bindjob;publishcheck(1);'''
assert a in s;s=s.replace(a,z);q=R/'tb/m5c_pair_diag/tb_pair_latest_descriptor_v2.sv';q.write_text(s)
o=R/'reports/m5c_pair_capture_20261016/latest_descriptor_test_v2';o.mkdir(exist_ok=False)
(o/'DERIVATION.json').write_text(json.dumps(dict(parent=str(p.relative_to(R)),parent_sha256=hashlib.sha256(b).hexdigest(),derived=str(q.relative_to(R)),derived_sha256=hashlib.sha256(q.read_bytes()).hexdigest(),change='Old descriptor oracle now driven by original-core actual writing->ready commit transition and original sequential clock qualification, independently compared to new output every edge. Added same-edge nfault and publication then following-edge fault rejection.'),indent=2))
