from pathlib import Path
import importlib.util,json,hashlib
R=Path.cwd();D=R/'reports/m5c_pair_admission_20261018/implementation';p=R/'scripts/m5c_pair_decode_pack5.py'
s=importlib.util.spec_from_file_location('trusted',p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
out=[]
for path in ['lifecycle_160429/case0','lifecycle_160429/case1','queue_v2_160916/case0']:
 f=D/path/'system_uart.hex';b=bytes(int(x,16) for x in f.read_text().split());v=m.decode_pair(b,test_sizes=(1600,512,512));out.append(dict(run=path,raw_sha256=hashlib.sha256(b).hexdigest(),result=v))
(D/'SOFTWARE_WIRE_INTERIM.json').write_text(json.dumps(dict(decoder_sha256=hashlib.sha256(p.read_bytes()).hexdigest(),records=out),indent=2));print([(x['run'],x['result']['pair_count'],x['result']['wire_bytes']) for x in out])
