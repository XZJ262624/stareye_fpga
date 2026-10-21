from common import *
import sys
sys.path.insert(0,str(R/'scripts/gaussian_integration/stage2'));from spatial_gold import spatial
Q=O/'components_new128';H=R/'reports/gaussian_integration_20261020/cap_host_gate_20261020';records=json.loads((H/'NEW128_RESULTS.json').read_text())['records'];before=[rec(Path(__file__)),rec(R/'scripts/gaussian_integration/stage2/spatial_gold.py'),rec(H/'NEW128_RESULTS.json')]+[r['gray'] for r in records];verify(before);save(Q/'GOLD_INPUTS_PRE.json',before);outputs=[]
for r in records:
 gray=(R/r['gray']['path']).read_bytes();words,edge=spatial(gray,544,416,2,64);assert hashlib.sha256(b''.join(w.to_bytes(13,'little') for w in words)).hexdigest()==r['full_spatial_102bit_little_endian_sha256'];p=Q/f'gray_gold_{r["id"]:03}.hex';assert not p.exists();p.write_text(''.join(f'{v:026x}\n' for v in words));outputs.append(rec(p));save(Q/'GOLD_PROGRESS.json',dict(completed=len(outputs),total=128));print('GOLD128',r['id'],flush=True)
verify(before);save(Q/'GOLD_INPUTS_POST.json',before);save(Q/'GOLD_RECEIPT.json',dict(passed=True,status='PASS_ALL128_FULL102BIT_GOLD_EQUALS_FROZEN_HOST_HASH',outputs=outputs,sources=before));print('NEW128_GOLD_COMPLETE',flush=True)
