from pathlib import Path
import re
R=Path(__file__).resolve().parents[2]
font={c:[int(x,2) for x in re.findall("5'b([01]{5})",bits)] for c,bits in re.findall(r'"(.)":font=\{([^}]+)\}',(R/'rtl/part_count_edge_open/part_open_font.svh').read_text())}
pixels=[]
for view in (0,1):
 for hi in (8,128):
  line=f'{"MSK" if view else "RAW"} H{hi:03d} L{hi//2:03d} CLOSE 3X3'.ljust(48)
  for yy in range(14):
   for xx in range(396):
    slot,col=divmod(xx,12);col//=2;bits=font.get(line[slot],[0]*7);pixels.append(int(col<5 and bool(bits[yy//2]&(1<<(4-col)))))
(R/'tb/part_count_edge_keys/osd_ext.mem').write_text(''.join(str(x)+'\n' for x in pixels))
