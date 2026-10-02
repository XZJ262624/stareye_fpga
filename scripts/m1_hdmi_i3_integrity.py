from pathlib import Path
import json
r=Path('F:/Projects/stareye_fpga/reports/m1_hdmi_i3')
a=json.loads((r/'original_before.json').read_text(encoding='utf-8-sig')); b=json.loads((r/'original_after.json').read_text(encoding='utf-8-sig'))
diff=[{'before':x,'after':y} for x,y in zip(a,b) if x!=y]
result={'before_files':len(a),'after_files':len(b),'all_sha256_readable':all(x['sha256'] for x in a+b),'same_full_manifest':a==b,'differences':diff}
(r/'original_diff.json').write_text(json.dumps(result,indent=2)); print(json.dumps(result)); assert a==b
