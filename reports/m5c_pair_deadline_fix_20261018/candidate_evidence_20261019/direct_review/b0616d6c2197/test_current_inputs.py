from pathlib import Path
import json,hashlib,datetime
from current_inputs import capture,identity
F=Path(__file__).resolve().parent;D=F/('metadata_test_'+datetime.datetime.now().strftime('%H%M%S'));D.mkdir();(D/'provenance').mkdir()
files={};old=[]
for i in range(63):
 name=f'input{i}.txt';p=D/name;p.write_bytes(('CURRENT'+str(i)).encode());files[name]=identity(p);old.append(dict(path=name,original=dict(bytes=0,sha256='0'*64)))
(D/'manifest.json').write_text(json.dumps(dict(files=files)));(D/'provenance/ORIGINAL_63_INPUTS.json').write_text(json.dumps(old));tool={'fixture':'pure_host_no_native'}
a=capture(D,'full','pre',tool);b=capture(D,'full','post',tool);assert a['records']==b['records'] and all(x['bytes']>0 for x in a['records'])
capture(D,'bad','pre',tool);(D/'input0.txt').write_text('MUTATED')
try:capture(D,'bad','post',tool)
except AssertionError as e:assert 'CURRENT_INPUT_CHANGED' in str(e);negative=str(e)
else:raise AssertionError('MUTATION_NOT_REJECTED')
(D/'RESULT.json').write_text(json.dumps(dict(status='PASS_PURE_HOST_CURRENT_INPUTS',count=63,historical_hashes_intentionally_wrong=True,changed_current_rejected=negative,native=False),indent=2));print(D)
