from common import *
import difflib,xml.etree.ElementTree as ET
BASE=R/'efinity/shape_orientation_fix_i3';S=R/'rtl/shape_standalone/shape';Q=R/'rtl/shape_wide_roi'
assert not P.exists() and not Q.exists();P.mkdir();Q.mkdir()
old=json.loads((R/'reports/shape_orientation_fix_20261022/SOURCE_MANIFEST.json').read_text());verify(old);save(O/'PARENT_SOURCE_MANIFEST.json',old)
copies=[]
for x in old:
 if not x['path'].startswith('efinity/shape_orientation_fix_i3/'):continue
 src=R/x['path'];dst=P/src.relative_to(BASE);dst.parent.mkdir(parents=True,exist_ok=True);dst.write_bytes(src.read_bytes());copies.append(dict(before=x,after=rec(dst)))
s=(S/'shape_recognizer_epoch.sv').read_text();oldtext=s
replacements=[
 ('ROI 384..895 x 168..551','ROI 160..1119 x 90..629'),
 ('24 bits:','26 bits:'),('reg [23:0] rows[0:383]','reg [25:0] rows[0:539]'),('reg [23:0] row_q','reg [25:0] row_q'),
 ('reg [8:0] scan','reg [9:0] scan'),('reg [8:0] ey','reg [9:0] ey'),
 ('reg [8:0] left_x,right_x','reg [9:0] left_x,right_x'),('reg [8:0] minx,maxx,miny,maxy','reg [9:0] minx,maxx,miny,maxy'),
 ('reg [2:0] cap_fragment_rows','reg [3:0] cap_fragment_rows'),
 ('x>=384 && x<=895 && y>=168 && y<=551','x>=160 && x<=1119 && y>=90 && y<=629'),
 ('wire [8:0] rx=x-384','wire [9:0] rx=x-160'),('wire [8:0] ry=y-168','wire [9:0] ry=y-90'),
 ('wire [8:0] next_left','wire [9:0] next_left'),('wire [8:0] next_right','wire [9:0] next_right'),
 ("{1'b0,next_right}-{1'b0,next_left}","next_right-next_left"),
 ("{1'b0,row_q[17:9]}-{1'b0,row_q[8:0]}","row_q[19:10]-row_q[9:0]"),
 ("{2'b0,row_q[17:9]}+{2'b0,row_q[8:0]}","{1'b0,row_q[19:10]}+{1'b0,row_q[9:0]}"),
 ("{2'b0,minx}+{2'b0,maxx}","{1'b0,minx}+{1'b0,maxx}"),
 ('row_q[22:20]','row_q[24:22]'),('row_q[19:18]','row_q[21:20]'),('row_q[23]','row_q[25]'),
 ('all 384 rows','all 540 rows'),('x==895','x==1119'),
 ('minx<=511','minx<=959'),('miny<=383','miny<=539'),
 ('196608','518400'),('196609','518401'),('ey<383','ey<539'),
 ('maxx>495','maxx>943'),('maxy>367','maxy>523'),(':383',':539'),
 ('cap_fragment_rows!=7','cap_fragment_rows!=15'),('width<=280','width<=440'),('height<=280','height<=440')]
for a,b in replacements:
 assert a in s,a;s=s.replace(a,b)
s=s.replace('// 26 bits: present, rounded eighth-density, saturated segments, right, left.','// 26 bits: present[25], density[24:22], segments[21:20], right[19:10], left[9:0].')
(Q/'shape_recognizer_epoch.sv').write_text(s,encoding='utf8')
osd=(S/'shape_osd.sv').read_text();newosd=osd.replace('x==384||x==895','x==160||x==1119').replace('y>=168&&y<=551','y>=90&&y<=629').replace('y==168||y==551','y==90||y==629').replace('x>=384&&x<=895','x>=160&&x<=1119');assert newosd!=osd
(Q/'shape_osd.sv').write_text(newosd,encoding='utf8')
xml=P/'Ti60_Demo.xml';a=xml.read_text();b=a.replace('../../rtl/shape_standalone/shape/shape_recognizer_epoch.sv','../../rtl/shape_wide_roi/shape_recognizer_epoch.sv').replace('../../rtl/shape_standalone/shape/shape_osd.sv','../../rtl/shape_wide_roi/shape_osd.sv');assert a!=b;xml.write_text(b,encoding='utf8')
sources=[]
for x in old:
 src=R/x['path'];dst=P/src.relative_to(BASE) if src.is_relative_to(BASE) else Q/src.name if src in [S/'shape_recognizer_epoch.sv',S/'shape_osd.sv'] else src
 sources.append(rec(dst))
save(O/'SOURCE_MANIFEST.json',sources)
compiled=[(P/n.attrib['name']).resolve().relative_to(R).as_posix() for n in ET.parse(xml).getroot().iter() if n.tag.endswith('}design_file')];save(O/'COMPILE_SOURCE_FILES.json',compiled)
assert compiled.count('rtl/shape_wide_roi/shape_recognizer_epoch.sv')==1 and 'rtl/shape_standalone/shape/shape_recognizer_epoch.sv' not in compiled
assert compiled.count('rtl/shape_wide_roi/shape_osd.sv')==1 and 'rtl/shape_standalone/shape/shape_osd.sv' not in compiled
diff=''.join(difflib.unified_diff(oldtext.splitlines(True),s.splitlines(True),fromfile='baseline/shape_recognizer_epoch.sv',tofile='new/shape_recognizer_epoch.sv'))+'\n'+''.join(difflib.unified_diff(osd.splitlines(True),newosd.splitlines(True),fromfile='baseline/shape_osd.sv',tofile='new/shape_osd.sv'))+'\n'+''.join(difflib.unified_diff(a.splitlines(True),b.splitlines(True),fromfile='baseline/Ti60_Demo.xml',tofile='new/Ti60_Demo.xml'))
(O/'SOURCE_DIFF.patch').write_text(diff,encoding='utf8')
save(O/'DERIVATION.json',dict(baseline='9dea12d9f0d29f57aa6d3acb75695da9e0d53d2c',project_copies=copies,changed_logical_files=['shape_recognizer_epoch.sv','shape_osd.sv','Ti60_Demo.xml'],unchanged_core='adapter/system/GAU/DDR/clock/pins/camera/readmode/defaults',SOURCE_DIFF=rec(O/'SOURCE_DIFF.patch')))
verify(old);heartbeat('MINIMAL_CHILD_SOURCE_READY');print('MINIMAL_CHILD_READY',len(sources),len(compiled))
