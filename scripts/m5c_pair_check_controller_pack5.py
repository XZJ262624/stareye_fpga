from pathlib import Path
import sys,json,hashlib,importlib.util
R=Path(__file__).resolve().parents[1];W=Path(sys.argv[1]).resolve();spec=importlib.util.spec_from_file_location('d',R/'scripts/m5c_pair_decode_pack5.py');d=importlib.util.module_from_spec(spec);spec.loader.exec_module(d);results=[]
for case in range(6):
 p=W/f'wire{case}.hex';raw=bytes.fromhex(p.read_text());r=dict(case=case,wire_bytes=len(raw),wire_sha256=hashlib.sha256(raw).hexdigest())
 if case<4:
  r['decode']=d.decode_pair(raw,test_sizes=(1600,512,512));pk=d.packets(raw)
  for z in pk:
   if z['type'] in (7,8,9):
    b=z['payload'][24:];base={7:0x1000000,8:0x10ac000,9:0}[z['type']];assert b==bytes((i%3)|4|((i%2)<<4) for i in range(len(b))) if z['type']==9 else b==bytes(((base+i)^0x5a)&255 for i in range(len(b)))
  assert r['decode']['pair_count']==(case==0)
 else:
  try:d.packets(raw)
  except d.ProtocolError as e:assert str(e)=='TRUNCATED_PACKET';r['expected_rejection']=str(e)
  else:raise AssertionError('timeout fragment accepted')
 results.append(r)
(W/'SOFTWARE_ORACLE.json').write_text(json.dumps(dict(status='PASS_PARAMETERIZED_ACTUAL_TRANSFER_PACKETIZER',results=results,decoder_sha256=hashlib.sha256((R/'scripts/m5c_pair_decode_pack5.py').read_bytes()).hexdigest(),checker_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),scope='Actual RTL byte acceptance, shared synchronous memory model. Reduced plane lengths; no full720p/system/pin UART claim.'),indent=2));print('PASS',W)
