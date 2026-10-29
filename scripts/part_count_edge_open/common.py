from pathlib import Path
import sys,json,hashlib
sys.dont_write_bytecode=True
R=Path(__file__).resolve().parents[2];O=R/'reports/part_count_edge_open_20261027';O.mkdir(exist_ok=True)
sys.path.insert(0,str(R/'scripts/part_count_edge'))
import assess as edge_parent
holes=edge_parent.holes;rle_labels=edge_parent.rle_labels;closing=edge_parent.closing;frontend=edge_parent.frontend;combine=edge_parent.combine
def rec(p):return dict(path=p.relative_to(R).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def save(n,x):(O/n).write_text(json.dumps(x,indent=2,ensure_ascii=False)+'\n',encoding='utf8')
