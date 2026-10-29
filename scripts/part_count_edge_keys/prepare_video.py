from pathlib import Path
import sys,json,re,hashlib,importlib.util
sys.dont_write_bytecode=True
R=Path(__file__).resolve().parents[2];O=R/'reports/part_count_edge_keys_20261028';T=R/'tb/part_count_edge_keys'
def load(n,p):
 s=importlib.util.spec_from_file_location(n,R/p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
ev=load('keys_gold','scripts/canny_split_thresholds/evaluate.py')
sys.path.insert(0,str(R/'scripts/part_count_edge_open'));model=load('keys_model','scripts/part_count_edge_open/model.py');base=load('keys_edge','scripts/part_count_edge/assess.py')
def rec(p):return dict(path=p.relative_to(R).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
w,h=1280,720;raw=bytearray(int(v,16)&255 for v in (R/'tb/part_count_edge_open/video5_noise.hex').read_text().split());bg=raw[0]
# Two weak long lines outside counting ROI test actual threshold behavior,
# retaining the accepted five-part raw scene inside ROI unchanged.
for y in range(110,610):
 for x in range(36,54):raw[y*w+x]=bg-12
 for x in range(88,106):raw[y*w+x]=bg-15
nm=ev.frontend(raw,w,h);edges=[];records=[]
for hi in (48,40,32):
 edge=base.closing(ev.local(ev.classify(nm,hi),w,h),w,h);edges.append(edge)
 roi=bytearray(v for y in range(90,630) for v in edge[y*w+160:y*w+1120]);q=model.classify(roi,960,540);assert q['status']=='VALID' and q['count']==5,q
 records.append(dict(high=hi,low=hi//2,edges=sum(edge),weak_line_edges=sum(edge[y*w+x] for y in range(100,620) for x in range(25,120)),count_model=q))
assert records[0]['weak_line_edges']<records[1]['weak_line_edges']<records[2]['weak_line_edges'],records
p=T/'video.hex';p.write_text(''.join(f'{raw[i]|(edges[0][i]<<8)|(edges[1][i]<<9)|(edges[2][i]<<10):03x}\n' for i in range(w*h)))
# The glyph bits are the established font asset; glyph placement, text,
# H/L formatting, and view selection are independently rendered here.
font={c:[int(x,2) for x in re.findall("5'b([01]{5})",bits)] for c,bits in re.findall(r'"(.)":font=\{([^}]+)\}',(R/'rtl/part_count_edge_open/part_open_font.svh').read_text())}
osd=[]
for view in (0,1):
 for hi in (48,40,32):
  line=f'{"MSK" if view else "RAW"} H{hi:03d} L{hi//2:03d} CLOSE 3X3'.ljust(48)
  for yy in range(14):
   for xx in range(396):
    slot,col=divmod(xx,12);col//=2;bits=font.get(line[slot],[0]*7);osd.append(int(col<5 and bool(bits[yy//2]&(1<<(4-col)))))
q=T/'osd.hex';q.write_text(''.join(str(x)+'\n' for x in osd))
(O/'VIDEO_ORACLE.json').write_text(json.dumps(dict(passed=True,width=w,height=h,fixture='Parent five objects and noise unchanged within ROI; two weak synthetic lines at gray background-12/background-15 outside ROI. Not sensor RAW/DDR verification.',records=records,vector=rec(p),osd=rec(q),software_sources=[rec(R/'scripts/canny_split_thresholds/evaluate.py'),rec(R/'scripts/part_count_edge/assess.py'),rec(R/'scripts/part_count_edge_open/model.py')]),indent=2)+'\n')
print('VIDEO_ORACLE_READY',[(v['high'],v['edges'],v['weak_line_edges']) for v in records])
