from pathlib import Path
R=Path.cwd();D=R/'reports/m5c_pair_admission_20261018/implementation'
s=(R/'scripts/m5c_pair_latest_queue.py').read_text().replace("'queue_'","'queue_mutant_'")
pos=s.index('inputs=[rec(p)')
s=s[:pos]+'''canonical_backend=R/'rtl/m5c_pair_diag/m5c_pair_backend.sv'
old=canonical_backend.read_bytes();needle=b'pair_effective_request_session==pair_session&&'
assert old.count(needle)==1
mutant=W/'m5c_pair_backend_mutant.sv';mutant.write_bytes(old.replace(needle,b'',1))
assert mutant.read_bytes().replace(b'pair_effective_request_valid&&fusion_acquire',b'pair_effective_request_valid&&'+needle+b'fusion_acquire',1)==old
(W/'MUTATION.json').write_text(json.dumps(dict(original=rec(canonical_backend),mutant=rec(mutant),single_change='remove full64 latest SID equality; inverse bytes exact'),indent=2))
sources=[mutant if p==canonical_backend else p for p in sources]
''' +s[pos:]
s=s.replace('sources+[base,Path(__file__)]','sources+[base,Path(__file__),canonical_backend]')
s=s.replace('for c in [0,1]','for c in [0]')
s=s.replace("ok=code==0 and '** Error' not in text and '** Fatal' not in text and (stage in ('vlib','compile') or 'LATEST_QUEUE_PASS' in text)","ok=code==0 and '** Error' not in text and ((stage in ('vlib','compile') and '** Fatal' not in text) or (stage not in ('vlib','compile') and text.count('** Fatal:')==1 and '** Fatal: LATEST_SID_STALE_ACQUIRE_SELECTED' in text and 'LATEST_QUEUE_PASS' not in text))")
s=s.replace('PASS_LATEST_QUEUE','PASS_EXPECTED_SINGLE_SID_GUARD_FATAL')
p=R/'scripts/m5c_pair_latest_queue_negative.py';assert not p.exists();p.write_text(s)
