"""Compare detailed warnings with frozen M4 without adding summary counts twice."""
from pathlib import Path
import collections,json,re,hashlib
R=Path(__file__).resolve().parents[1];O=R/'reports/m5a_streaming_canny_i3';W=R/'efinity/m5a_streaming_canny_i3'
old=R/'efinity/m4_color_overlay_i3/outflow/Ti60_Demo.map.out';new=W/'outflow/Ti60_Demo.map.out'
def normalized(s):
 s=s.replace('m5a_streaming_canny_i3','STAGE').replace('m4_color_overlay_i3','STAGE')
 s=re.sub(r'\(\d+\):', '(LINE):',s)
 return s
def extract(p):
 rows=[s for s in p.read_text(errors='replace').splitlines() if s.startswith('WARNING')]
 summaries=[s for s in rows if re.search(r'post.synthesis.*warning|warnings? found|warnings? reported',s,re.I)]
 # The Efinity post-synthesis summary says "N warnings ..." rather than a code.
 summaries+=[s for s in rows if re.search(r'\b\d+ warnings?\b',s,re.I) and s not in summaries]
 details=[s for s in rows if s not in summaries]
 return rows,summaries,details
a,asum,ad=extract(old);b,bsum,bd=extract(new);ac=collections.Counter(map(normalized,ad));bc=collections.Counter(map(normalized,bd))
added=dict(bc-ac);removed=dict(ac-bc)
codes=collections.Counter(re.search(r'\[([^\]]+)\]\s*$',s).group(1) if re.search(r'\[([^\]]+)\]\s*$',s) else 'UNCODED' for s in bd)
stages={}
for p in sorted((W/'outflow').glob('*')):
 if p.suffix not in ('.log','.rpt','.out') or p.name in ('Ti60_Demo.map.out','Ti60_Demo.log','Ti60_Demo.warn.log','Ti60_Demo.info.log'):continue
 lines=[s.strip() for s in p.read_text(errors='replace').splitlines() if re.match(r'^\s*(?:WARNING|Warning|WARN)\b',s)]
 if lines:stages[p.name]=lines
result=dict(m4_detail_records=len(ad),m5a_detail_records=len(bd),summary_lines=bsum,summary_count=len(bsum),normalized_added=added,normalized_removed=removed,by_code=dict(codes),new_canny_source_warnings=[s for s in bd if 'rtl' in s.lower() and 'm5a' in s.lower()],stage_warning_lines=stages,records=bd,counting_rule='Count each detailed WARNING record once. Summary lines are disclosed separately and are never added to detailed records. Map warning copies in aggregate logs are not added again.',m4_sha256=hashlib.sha256(old.read_bytes()).hexdigest(),m5a_sha256=hashlib.sha256(new.read_bytes()).hexdigest())
(O/'WARNING_REVIEW.json').write_text(json.dumps(result,indent=2));print(json.dumps({k:v for k,v in result.items() if k not in ('records','stage_warning_lines')},indent=2))
