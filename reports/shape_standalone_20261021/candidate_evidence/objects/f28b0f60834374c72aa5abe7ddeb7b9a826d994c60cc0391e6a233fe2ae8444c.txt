from pathlib import Path
import sys,json,re,hashlib
R=Path(__file__).resolve().parents[2];F=Path(sys.argv[1]);P=F/'mirror/efinity/shape_standalone_i3';old=R/'reports/m5c_pair_deadline_fix_20261018/physical_deadline_233017/mirror/efinity/m5c_pair_diag_i3/outflow/selected_check.rpt';current=P/'outflow/selected_check.rpt'
def rec(p):return dict(path=p.relative_to(R).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def names(p,index,label,nextindex):
 text=p.read_text();matches=re.findall(r'^'+str(index)+r'\. checking '+label+r' \(\d+\)\s*$'+'(.*?)'+r'^'+str(nextindex)+r'\. checking',text,re.S|re.M);assert len(matches)==2
 return re.findall(r'^[A-Za-z_][A-Za-z0-9_\[\].]*$',matches[-1],re.M)
rows=[]
for index,label,nextindex,count in [(3,'no_input_delay',4,7),(4,'no_output_delay',5,135)]:
 a=names(old,index,label,nextindex);b=names(current,index,label,nextindex);assert len(a)==len(b)==count and a==b
 rows.append(dict(boundary=label,count=count,current_ports=b,previous_ports=a,equal=True))
out=dict(status='CURRENT_EXTERNAL_BOUNDARIES_IDENTICAL_NOT_EXTERNAL_TIMING_PASS',records=rows,bindings=[rec(old),rec(current)],limitation='The seven inputs include two existing exact-cut key inputs. These inherited external timing boundaries are not expanded to internal recognition control or claimed as board-level timing qualification.')
q=F/'EXTERNAL_BOUNDARY_CONTINUITY.json';assert not q.exists();q.write_text(json.dumps(out,indent=2));print(out['status'])
