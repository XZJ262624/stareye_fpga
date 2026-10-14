from pathlib import Path
import json,hashlib
A=Path(__file__).resolve().parent; R=A.parents[3]
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
c=json.loads((A/'QUERY03_PRELIMINARY_CLASSIFICATION.json').read_text())
rows=[x for x in c['rows'] if x['classification']=='CURRENT_VENDOR_NATIVE_CONSTANT']
assert len(rows)==len({x['pin'] for x in rows})==14
assert all(x['logical'] is None and x['native_net'] in ('gnd','vcc') and x['group']=='global_D_setup' for x in rows)
assert sum(x['pin'].startswith('ddr3_ctl_axi/') for x in rows)==13
assert sum(x['pin']=='dsi_resetn_o~FF|D' for x in rows)==1
for n in ['native','map','targets']:assert rec(R/c[n]['path'])==c[n]
p=A/'CURRENT_VENDOR_CONSTANT_BINDING.json';assert not p.exists()
p.write_text(json.dumps(dict(status='CURRENT_TYPED_NATIVE_CONSTANTS_EXPLICIT',records=rows,classification=rec(A/'QUERY03_PRELIMINARY_CLASSIFICATION.json'),native=c['native'],map=c['map'],targets=c['targets'],query=rec(A/'queries/03_connections.tcl'),native_result=rec(A/'sta_03_connections/RESULT.json'),generator=rec(Path(__file__)),boundary='These fourteen current physical FF D pins resolve to actual native gnd/vcc. Generic map lacks their internal FF objects. This is physical constant classification, not encrypted-IP functional verification, and no old pin whitelist is used.'),indent=2))
print('CURRENT_VENDOR_CONSTANTS',len(rows),rec(p))
