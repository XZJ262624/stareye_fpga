from pathlib import Path
import sys,json,re,zlib,struct,hashlib
D=Path(sys.argv[1]);raw=bytes.fromhex((D/'wire.hex').read_text());log=(D/'sim.log').read_text(errors='replace')
assert len(raw)==324 and zlib.crc32(raw[:-4])==int.from_bytes(raw[-4:],'little')
assert '** Fatal:' not in log and '** Error:' not in log and 'CACHE_CONTEXT_PASS' in log
m=re.findall(r'DIAG_ADMIT tick=(\d+) sid=(\d+) token=(\d+) slot=(\d+) desc=([0-9a-fA-F]+)',log);e=re.findall(r'DIAG_EOF tick=(\d+) seq=(\d+)',log);assert len(m)==len(e)==1
admit,sid,token,slot=map(int,m[0][:4]);desc=int(m[0][4],16);end,seq=map(int,e[0]);assert (sid,token,slot,seq)==(1,1,0,1)
cfg=(1<<96)|(1<<88)|(1<<80)|(1280<<68)|(720<<56)|(64<<48)|(32<<40)|(1<<39)|(3<<36)|(1<<28)
expected_desc=1|(1<<128)|(1<<384)|(1<<448)|(cfg<<576)|(1<<736)|(1<<744)|(1<<272)
assert desc==expected_desc,'SOURCE_DESCRIPTOR_CONTRACT'
pm=re.search(r'DIAG_PARAMS mode=(\d+) pause=(\d+) readstall=(\d+)',log);mode=int(pm[1]) if pm else 6
p0=p1=p4=0;s64=s128=0
for y in range(720):
 for x in range(1280):
  candidate=3<=x<1277 and 3<=y<717 and (x+y)%3==1 and (x+2*y)%2==1
  p0+=candidate;p1+=candidate and y!=110
  s64+=candidate and not(y==110 and x//64==163//64)
  s128+=candidate and not(y==110 and x//128==163//128)
  p4+=candidate and y!=110 and not(12<=y<34 and(12<=x<228 or 244<=x<412))
W=[0]*32;W[0]=2|((5|(mode<<5))<<32);W[1]=1;W[2]=sid;W[3]=admit;W[4]=end
W[5:14]=[1,1,1,1,1,0,0,0,1]
W[14:18]=[cfg&((1<<64)-1),(cfg>>64)&((1<<64)-1),(74400000<<32)|(cfg>>128),(96000000<<32)]
W[18]=p0|(p1<<32);W[19]=p1|((p1 if mode==6 else 0)<<32);W[20]=p4 if mode==6 else 0
W[21]=163|(110<<12)|(163<<24)|(110<<36)|(1<<50)|(1<<52)|(1<<53)|(1<<54)|(mode<<55);W[22]=W[23]=1
W[26]=0;W[27]=(p0-p1)|(s64<<32);W[28]=s128;W[29]=0
payload=struct.pack('<32Q',*W);header=b'SM5B'+bytes([1,5,64,0])+struct.pack('<II',256,0)+(desc&((1<<320)-1)).to_bytes(40,'little')+bytes(8)
expected=header+payload;expected+=zlib.crc32(expected).to_bytes(4,'little')
diff=[dict(offset=i,expected=a,actual=b) for i,(a,b) in enumerate(zip(expected,raw)) if a!=b]
result=dict(status='PASS_COMPLETE_324B_COUPLED' if not diff else 'FAIL',differences=diff,counts=[p0,p1,p1,p1 if mode==6 else 0,p4 if mode==6 else 0],first_difference=dict(x=163,y=110,current_class=0,reference_class=1,reference_mask=1),admit_tick=admit,eof_tick=end,wire_sha256=hashlib.sha256(raw).hexdigest(),scope='Production reader/cache/display/rowfusion/OSD plus observer/bridge/default UART. Lease ACK is modeled; production backend arbitration is a separate pending gate.')
(D/'SOFTWARE_ORACLE.json').write_text(json.dumps(result,indent=2));assert not diff,diff
print(json.dumps(result))
