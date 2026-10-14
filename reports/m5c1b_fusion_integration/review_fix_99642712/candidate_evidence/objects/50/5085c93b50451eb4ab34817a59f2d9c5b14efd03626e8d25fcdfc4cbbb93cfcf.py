from pathlib import Path
import json,re,hashlib,difflib
A=Path(__file__).resolve().parent;R=A.parents[3];P=A/'mirror/efinity/m5c_fusion_i3';O=A/'root_adoption_proposal';O.mkdir(exist_ok=False)
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
records=[]
for name in ['Ti60_Demo_I3.sdc','Ti60_Demo.xml']:
 root=R/'efinity/m5c_fusion_i3'/name; mirror=P/name;b=root.read_bytes();m=mirror.read_bytes()
 if name.endswith('.sdc'):
  old=br'{^u_m5b1/video/camera_fifo/rg\[9\]\~FF\|CLK$}';new=br'{^u_m5b1/video/camera_fifo/rp\[9\]\~FF\|CLK$}'
  assert b.count(old)==1 and b.count(new)==0;c=b.replace(old,new);assert c==m and c.replace(new,old)==b
  metadata=None
 else:
  old=b'<efx:param name="mode" value="speed"';new=b'<efx:param name="mode" value="area"';assert b.count(old)==1;c=b.replace(old,new);assert c.replace(new,old)==b
  norm=lambda v:re.sub(br'last_change="[0-9]+"',b'last_change="NORMALIZED_METADATA"',v)
  assert norm(c)==norm(m)
  metadata=dict(root_last_change=re.search(br'last_change="([0-9]+)"',b)[1].decode(),mirror_last_change=re.search(br'last_change="([0-9]+)"',m)[1].decode(),proposal_preserves_root_metadata=True,xml_path_rebase_required=False)
 q=O/name;q.write_bytes(c);offset=b.index(old)
 records.append(dict(root_before=rec(root),measured_mirror=rec(mirror),proposed=rec(q),old_literal=old.decode(),new_literal=new.decode(),offset=offset,inverse_byte_exact=True,metadata=metadata,diff=''.join(difflib.unified_diff(b.decode().splitlines(True),c.decode().splitlines(True),fromfile='root/'+name,tofile='proposed/'+name))))
source=json.loads((R/'reports/m5c1b_fusion_integration/review_fix_99642712/regression/SOURCE101.json').read_text())
assert all(rec(R/x['path'])==x for x in source['records'])
out=dict(status='PROPOSAL_ONLY_NOT_APPLIED_PENDING_COMPLETE_STA_AND_WORK_APPROVAL',records=records,source101=rec(R/'reports/m5c1b_fusion_integration/review_fix_99642712/regression/SOURCE101.json'),source101_unchanged=True,version_boundary='Long/focused/legacy simulation inputs remain their original frozen records. Root SDC/XML are observed protection inputs, not compiled RTL in those simulations. Isolated physical area map/route/STA use their own current SDC/XML inputs. Proposed adoption creates a new configuration version; never rewrite old SOURCE101 or historical receipts.',settings_boundary='Root project XML has relative design paths: no XML path rebase is needed. Eleven isolated settings.json base_path rebases remain mirror-only provenance; root settings are not proposed for change.',literal_boundary='The earlier 64 source aliases cancel exactly against the area inverse mapping; final root-to-measured SDC differs by this one camera Gray-MSB canonical CLK literal only. No timing value, exception, count or other clock target changes.',generator=rec(Path(__file__)))
(O/'PROPOSAL.json').write_text(json.dumps(out,indent=2));print(rec(O/'PROPOSAL.json'))
