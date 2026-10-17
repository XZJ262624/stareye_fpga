# PREPARATION GENERATOR ONLY: writes this local preparation package. Do not execute in a fixed review snapshot. Use scripts/m5c_pair_read_evidence.py for read-only validation.
from pathlib import Path
import json,gzip,hashlib,re
R=Path.cwd();C=R/'reports/m5c_pair_capture_20261016/candidate_evidence_20261017';idx=json.loads((C/'TRANSPORT_INDEX.json').read_text());D=C/'direct_review';D.mkdir(exist_ok=True);chosen={}
for x in idx['mappings']:
 n=Path(x['original_path']).name;s=x['scope'];choose=False
 if n in ['normal_setup.rpt','normal_hold.rpt','Ti60_Demo.place.rpt','Ti60_Demo.route.rpt','PAIR_SOFTWARE_ORACLE.json','ACCEPTANCE.json','RESULT.json','SHORT_HANDBACK.json','CURRENT_PLL_SR_BOUNDARY.json','PHYSICAL_RECONCILIATION_HANDOFF.json']:choose=x['bytes']<1500000
 if s.startswith(('short/','manifest/reason20')) and n.endswith('.log') and x['bytes']<60000:choose=True
 if s=='remote/full' and n in ['full.log','compile.log','pair_events.txt','end_events.txt']:choose=True
 if s=='Work/read_only_acceptance':choose=True
 if choose:chosen[x['sha256']]=x
rows=[]
for h,x in sorted(chosen.items()):
 raw=gzip.decompress((C/x['object']).read_bytes());assert hashlib.sha256(raw).hexdigest()==h
 n=re.sub(r'[^A-Za-z0-9_.-]','_',Path(x['original_path']).name);p=D/(h[:12]+'_'+n);p.write_bytes(raw);rows.append(dict(kind='COMPLETE_ORIGINAL_BYTES',scope=x['scope'],original_path=x['original_path'],original_sha256=h,original_bytes=x['bytes'],direct=p.relative_to(C).as_posix(),sha256=h,bytes=len(raw)))
# Exact byte snippets from the large lifecycle ledger: final valid pixel/tails and final release.
x=next(x for x in idx['mappings'] if x['scope']=='remote/full' and x['original_path']=='work/repair_tail_ledger.txt');raw=gzip.decompress((C/x['object']).read_bytes());lines=raw.splitlines(keepends=True);offs=[];n=0
for line in lines:offs.append(n);n+=len(line)
ids=[i for i,l in enumerate(lines) if l.startswith(b'PIX ')];segments=[(max(0,ids[-3]-1),ids[-1]+2),(len(lines)-8,len(lines))]
for k,(a,b) in enumerate(segments):
 start=offs[a];end=offs[b] if b<len(offs) else len(raw);data=raw[start:end];p=D/f'repair_tail_excerpt_{k}.txt';p.write_bytes(data);rows.append(dict(kind='EXACT_ORIGINAL_EXCERPT_NOT_COMPLETE_FILE',original_path=x['original_path'],original_sha256=x['sha256'],original_bytes=x['bytes'],byte_start=start,byte_end_exclusive=end,direct=p.relative_to(C).as_posix(),sha256=hashlib.sha256(data).hexdigest(),bytes=len(data)))
(C/'DIRECT_REVIEW_INDEX.json').write_text(json.dumps(dict(records=rows,limitation='Large allD/allCE/allSR and structural JSON only losslessgzip; B without execution does not independently inspect all of them. Complete small normalreports, actuallogs and exactledger excerpts are direct candidate bytes.'),indent=2));print(len(rows),sum(x['bytes'] for x in rows))
