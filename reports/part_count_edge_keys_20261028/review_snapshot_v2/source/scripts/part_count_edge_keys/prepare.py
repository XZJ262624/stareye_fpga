"""Create only the authorized independent key fork from the verified open snapshot."""
from pathlib import Path
import hashlib,json,re,subprocess,difflib
R=Path(__file__).resolve().parents[2];O=R/'reports/part_count_edge_keys_20261028';O.mkdir(exist_ok=True)
D=R/'rtl/part_count_edge_keys';P=R/'efinity/part_count_edge_keys_i3';T=R/'tb/part_count_edge_keys'
def rec(p):return dict(path=p.relative_to(R).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def save(n,v):(O/n).write_text(json.dumps(v,indent=2,ensure_ascii=False)+'\n',encoding='utf8')
parent=R/'reports/part_count_edge_open_20261027';m=parent/'review_snapshot/MANIFEST.json'
assert rec(m)['sha256']=='3f566c51b323be799bc71e67cb3aeed252945471361f025db29b39576d2aca9f'
rows=json.loads(m.read_text())['records'];assert len(rows)==423
for row in rows:
 for k in ('original','snapshot'):assert rec(R/row[k]['path'])==row[k],row[k]['path']
bit=parent/'artifacts/StarEye_CountEdgeOpen.bit';assert rec(bit)['sha256']=='baa517a0d9cc742e488e4aee2137acc2c3b18992ffb1ff9d36fbf998a7a90f8c'
assert not D.exists() and not P.exists();D.mkdir();P.mkdir();T.mkdir()
sources=json.loads((parent/'PRODUCTION_MANIFEST.json').read_text());copies=[]
for row in sources:
 src=R/row['path'];assert rec(src)==row
 if src.is_relative_to(R/'efinity/part_count_edge_open_i3'):
  dst=P/src.relative_to(R/'efinity/part_count_edge_open_i3');dst.parent.mkdir(parents=True,exist_ok=True);dst.write_bytes(src.read_bytes());copies.append(dict(parent=rec(src),new=rec(dst)))
for n in ('system','core','confirm','osd'):
 src=R/f'rtl/part_count_edge_open/part_open_{n}.sv';dst=D/f'part_keys_{n}.sv';s=src.read_text().replace(f'module part_open_{n}',f'module part_keys_{n}')
 for child in ('system','core','confirm','osd'):s=s.replace('part_open_'+child,'part_keys_'+child)
 dst.write_text(s);copies.append(dict(parent=rec(src),new=rec(dst)))
for orig,name in [('part_count_controls','part_keys_controls'),('part_count_stream_adapter','part_keys_adapter')]:
 src=R/f'rtl/part_count/{orig}.sv';dst=D/f'{name}.sv';dst.write_text(src.read_text().replace(orig,name));copies.append(dict(parent=rec(src),new=rec(dst)))
p=P/'example_top.v';p.write_bytes(p.read_bytes().replace(b'part_open_system',b'part_keys_system'))
p=P/'Ti60_Demo.xml';s=p.read_text().replace('part_count_edge_open_i3','part_count_edge_keys_i3')
for n in ('system','core','confirm','osd'):s=s.replace(f'../../rtl/part_count_edge_open/part_open_{n}.sv',f'../../rtl/part_count_edge_keys/part_keys_{n}.sv')
s=s.replace('../../rtl/part_count/part_count_controls.sv','../../rtl/part_count_edge_keys/part_keys_controls.sv').replace('../../rtl/part_count/part_count_stream_adapter.sv','../../rtl/part_count_edge_keys/part_keys_adapter.sv')
s=s.replace('</efx:design_info>', '<efx:design_file name="../../rtl/part_count_edge_keys/part_keys_config.sv" version="system_verilog" library="default"/>\n</efx:design_info>')
p.write_text(s)
save('INITIAL_PARENT_PROTECTION.json',dict(passed=True,checks=846,manifest=rec(m),bit=rec(bit)))
save('PARENT_PRODUCTION_MANIFEST.json',sources);save('FORK_RECORD.json',copies)
for n in ('physical_common.py','build_physical_v1.py'):
 s=(R/'scripts/part_count_edge_open'/n).read_text(encoding='utf8').replace('part_count_edge_open','part_count_edge_keys').replace('20261027','20261028').replace('StarEye_CountEdgeOpen','StarEye_CountEdgeKeys')
 (R/'scripts/part_count_edge_keys'/n).write_text(s,encoding='utf8')
print('KEYS_FORK_READY',len(copies))
