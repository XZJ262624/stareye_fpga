from pathlib import Path
import json,re,hashlib,subprocess,sys,difflib
A=Path(__file__).resolve().parent;R=A.parents[3];P=A/'mirror/efinity/m5c_fusion_i3'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
log=A/'audit_v4_preserved_failure.log';assert not log.exists()
with log.open('wb') as f:r=subprocess.run([sys.executable,'-B',str(A/'audit_current_timing_v4.py')],stdout=f,stderr=subprocess.STDOUT)
assert r.returncode==1 and 'and net==st' in log.read_text()
(A/'AUDIT_V4_FAILURE_RECEIPT.json').write_text(json.dumps(dict(exit=r.returncode,log=rec(log),helper=rec(A/'audit_current_timing_v4.py'),status='NONPASS_DSP_CURRENT_NATIVE_NET_NAME_MISMATCH'),indent=2))
s=(P/'outflow/Ti60_Demo.map.v').read_text();m=re.search(r'^    EFX_LUT4 LUT__114087 .*?;.*$',s,re.M);assert m
line=m[0];assert r'.I0(\u_m5b1/fusion/write_mask )' in line and r'.O(\u_m5b1/fusion/reader/n151 [1])' in line and "LUTMASK=16'h5555" in line
c=json.loads((A/'QUERY03_PRELIMINARY_CLASSIFICATION.json').read_text());proof=[]
for bit in [6,8]:
 pin=f'u_m5b1/fusion/reader/mult_23|B[{bit}]';logical='u_m5b1/fusion/reader/n151[1]';native='u_m5b1/fusion/reader/n155';reports=[]
 for mode in ['setup','hold']:
  item=next(x for x in c['rows'] if x['pin']==pin and x['mode']==mode)
  assert item['native_net']==native and item['logical']['net']==logical
  p=P/f'outflow/v5_B{bit}_{mode}.rpt';text=p.read_text();blocks=re.split(r'\+{4} Path \d+ \+{4,}',text)[1:];assert len(blocks)==36 and re.search(r'Timing Model\s*:\s*I3',text)
  for b in blocks:
   lines=b.splitlines();i=next(i for i,l in enumerate(lines) if l.startswith('LUT__114087|out '))
   assert lines[i-1].startswith('LUT__114087|in[0] ') and lines[i-2].startswith('u_m5b1/fusion/write_mask ')
   assert lines[i+1].startswith(native+' ') and lines[i+2].startswith(pin+' ')
   assert float(re.search(r'^Slack\s*:\s*([+-]?[0-9.]+)',b,re.M)[1])>=0
  reports.append(dict(mode=mode,paths=len(blocks),report=rec(p)))
 proof.append(dict(pin=pin,logical_net=logical,native_net=native,physical_driver='LUT__114087|out',mapped_primitive=line,reports=reports))
p=A/'DSP_NATIVE_NET_ALIAS_PROOF.json';assert not p.exists();p.write_text(json.dumps(dict(status='PASS_EXACT_TWO_PIN_SAME_LUT_DRIVER_NATIVE_RENAME',records=proof,map=rec(P/'outflow/Ti60_Demo.map.v'),native=rec(P/'v4_pin_nets.txt'),generator=rec(Path(__file__)),boundary='Only B6/B8 exact current native wire rename: same LUT__114087 inverter output is shown immediately before each physical DSP B endpoint in all 144 current I3 setup/hold paths. No arbitrary-net equivalence, no relaxation of through timing or mapped same-clock predicate.'),indent=2))
old=A/'audit_current_timing_v4.py';text=old.read_text();needle="st['classification']=='REGISTERED_SAME_CLOCK' and net==st['net']";assert text.count(needle)==1
insert="""
dsp_alias_proof=json.loads((F/'DSP_NATIVE_NET_ALIAS_PROOF.json').read_text())
assert dsp_alias_proof['status']=='PASS_EXACT_TWO_PIN_SAME_LUT_DRIVER_NATIVE_RENAME'
for x in [dsp_alias_proof['map'],dsp_alias_proof['native']]+[r['report'] for e in dsp_alias_proof['records'] for r in e['reports']]:assert rec(R/x['path'])==x
dsp_aliases={e['pin']:(e['logical_net'],e['native_net']) for e in dsp_alias_proof['records']}
assert set(dsp_aliases)=={f'u_m5b1/fusion/reader/mult_23|B[{i}]' for i in [6,8]}
"""
new=text.replace('def classify(pin,mode):',insert+'\ndef classify(pin,mode):').replace(needle,"st['classification']=='REGISTERED_SAME_CLOCK' and (net==st['net'] or dsp_aliases.get(pin)==(st['net'],net))")
q=A/'audit_current_timing_v5.py';assert not q.exists();q.write_text(new)
(A/'AUDIT_V5_DERIVATION.json').write_text(json.dumps(dict(parent=rec(old),derived=rec(q),proof=rec(p),diff=''.join(difflib.unified_diff(text.splitlines(True),new.splitlines(True)))),indent=2));print(rec(p))
