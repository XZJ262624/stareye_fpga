from common import *
import xml.etree.ElementTree as ET
verify(json.loads((O/'PROTECTED_PARENTS.json').read_text()))
copies=[]
for f in ('m5b1_async_fifo.sv','m5b1_mailbox.sv','m5b1_failstop.sv','replay_video_dma.sv','replay_arbiter.sv','replay_frontend.sv'):
 a=R/'rtl/canny_replay'/f;b=T/f;assert a.read_bytes()==b.read_bytes();copies.append(dict(source=rec(a),destination=rec(b)))
for d in ('gaussian_m5a','filter'):
 for a in sorted((R/'rtl/shape_standalone'/d).glob('*')):
  if a.is_file():b=T/d/a.name;assert a.read_bytes()==b.read_bytes();copies.append(dict(source=rec(a),destination=rec(b)))
for a,b in [(R/'rtl/shape_wide_roi/shape_recognizer_epoch.sv',T/'shape_recognizer_epoch.sv'),(R/'rtl/shape_standalone/shape/shape_stream_adapter_contract_v2.sv',T/'shape_stream_adapter_contract_v2.sv')]:
 assert a.read_bytes()==b.read_bytes();copies.append(dict(source=rec(a),destination=rec(b)))
# Every generated payload burst is unique and stays in configured capacity.
payload=1280*720;bases=[i*0x400000 for i in range(4)]+[0x02000000+i*0x100000 for i in range(32)]
spans=[(a,a+payload) for a in bases];bursts=[]
for i,(a,e) in enumerate(spans):
 assert e<=512*1024*1024
 for j,(b,f) in enumerate(spans):assert i==j or e<=b or f<=a
 for address in range(a,e,2048):
  assert address%2048==0 and address+2048<=e and address//4096==(address+2047)//4096
  bursts.append(address)
assert len(bursts)==len(set(bursts))==16200
canaries=[a+p for a in bases for p in (0,16,2048,payload-16)]
alias=[]
for bit in range(4,26):
 # Only claim sensitivity where the set contains an address pair differing
 # in this bit; do not pretend a partial test proves all512MiB.
 mapped=[a&~(1<<bit) for a in canaries]
 if len(set(mapped))<len(set(canaries)):alias.append(bit)
assert all(b in alias for b in range(20,26)),alias
save(O/'ADDRESS_AND_COPY_CHECK.json',dict(passed=True,payload_bytes=32*payload,slots=[dict(index=i,base=hex(a),end_exclusive=hex(e)) for i,(a,e) in enumerate(spans)],bursts=len(bursts),last_clip_burst=hex(bursts[-1]),disjoint=True,configured_bytes=512*1024*1024,alias_bitdrop_detected=alias,limits='Arithmetic/model evidence only. Internal DDR core encrypted; 512MiB full capacity and clip32..64MiB physical qualification remain untested in this combined BIT.',copies=copies))
# Same peripheral/pin/clock files and camera mirror bytes.
io=[]
for f in ('Ti60_Demo.peri.xml','src/cmos_i2c/I2C_AR0135_1280720_Config.v'):
 a=R/'efinity/canny_replay_i3'/f;b=P/f;assert a.read_bytes()==b.read_bytes();io.append(dict(source=rec(a),destination=rec(b)))
assert "16'h3040, 16'hC000" in (P/'src/cmos_i2c/I2C_AR0135_1280720_Config.v').read_text()
xml=ET.parse(P/'Ti60_Demo.xml').getroot();paths=[]
for elem in xml.iter():
 if elem.tag.endswith('design_file'):
  p=Path(elem.attrib['name']);p=p if p.is_absolute() else P/p;assert p.is_file();paths.append(p.resolve())
assert len(paths)==len(set(paths))
modules={}
for p in paths:
 for n in re.findall(r'^\s*module\s+(\w+)',p.read_text(errors='replace'),re.M):assert n not in modules,(n,p,modules.get(n));modules[n]=str(p)
save(O/'SOURCE_CLOSURE_CHECK.json',dict(passed=True,design_files=[str(p) for p in paths],modules=modules,io_unchanged=io))
print('STATIC_PASS',len(copies),len(paths),len(modules))
