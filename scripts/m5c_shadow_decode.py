"""Strict type5 schemas1/2. No serial access or import-time file writes."""
import struct,zlib
import m5b1_uart_decode as legacy
FIELDS=('p0_complete_fail','p0_tag_fail','p0_equal_fail','shadow64_accept','shadow128_accept','p0_strong_loss_row','p0_illegal_row')
def config(v):
 return dict(generation=v>>96,schema=(v>>88)&255,algorithm=(v>>80)&255,width=(v>>68)&4095,height=(v>>56)&4095,high=(v>>48)&255,low=(v>>40)&255,median=(v>>39)&1,support=(v>>36)&7,nms=(v>>28)&255,reserved=v&((1<<28)-1))
def decode(packet):
 assert len(packet)==324,'TYPE5_LENGTH'
 h,p=packet[:64],packet[64:320]
 assert struct.unpack('<4sBBHII',h[:16])==(b'SM5B',1,5,64,256,0),'TYPE5_HEADER'
 assert h[56:64]==bytes(8),'TYPE5_HEADER_RESERVED'
 assert int.from_bytes(packet[-4:],'little')==zlib.crc32(packet[:-4]),'TYPE5_CRC'
 q=struct.unpack('<32Q',p);u=lambda o:struct.unpack_from('<I',p,o)[0]
 schema=u(0);f=u(4);d=legacy.descriptor(h[16:56]);c=config(int.from_bytes(p[112:132],'little'))
 assert schema in (1,2) and f&1 and f&~0xef==0,'TYPE5_SCHEMA_FLAGS'
 assert ((f>>5)&7)<=6,'TYPE5_MODE'
 assert p[164:168]==bytes(4) and p[204:208]==bytes(4),'TYPE5_COMMON_RESERVED'
 if schema==1:assert p[208:]==bytes(48),'TYPE5_SCHEMA1_RESERVED'
 else:assert p[236:]==bytes(20),'TYPE5_SCHEMA2_RESERVED'
 assert q[2]==q[6] and q[4]>=q[3],'TYPE5_SESSION_TIME'
 assert (q[8],q[9],q[10],q[12])==(d['epoch'],d['job_id'],d['frame_id'],d['source_sof_pixel_ticks']),'TYPE5_HEADER_IDENTITY'
 assert (c['high'],c['low'],c['median'],c['support'],c['nms'],c['width'],c['height'])==tuple(d[k] for k in ['high','low','median','support_radius','nms_version','width','height']),'TYPE5_CONFIG_HEADER'
 assert c['schema']==c['algorithm']==c['nms']==1 and not c['reserved'],'TYPE5_CONFIG_VERSION'
 assert (c['width'],c['height'])==(1280,720),'TYPE5_PRODUCTION_GEOMETRY'
 assert q[16]>>32==74400000 and q[17]>>32==96000000 and (q[17]&0xffffffff)<=1,'TYPE5_CLOCK_SLOT'
 first=q[21];fv=bool(f&4)
 if fv:
  assert q[22]==q[23]==q[2] and first>>58==0,'TYPE5_FIRST_IDENTITY'
  assert (first&4095)==((first>>24)&4095)<1280 and ((first>>12)&4095)==((first>>36)&4095)<720,'TYPE5_FIRST_COORDINATES'
  assert ((first>>53)&3)==3 and ((first>>48)&3)!=((first>>50)&3),'TYPE5_FIRST_QUALIFICATION'
 else:assert first==q[22]==q[23]==0,'TYPE5_EMPTY_FIRST'
 out=dict(schema=schema,flags=f,mode=(f>>5)&7,session=q[6],token=q[7],record_sequence=q[1],source_config=c,counts=[u(144+4*i) for i in range(5)],extensions_status='absent' if schema==1 else 'provided')
 if schema==2:out['shadow']=dict(zip(FIELDS,[u(208+4*i) for i in range(7)]))
 return out
