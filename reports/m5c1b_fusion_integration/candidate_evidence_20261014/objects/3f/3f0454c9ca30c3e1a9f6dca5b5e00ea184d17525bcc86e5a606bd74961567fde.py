from pathlib import Path
import sys,json,zlib
from check_trace import packet128
def uart_check(w):
 z=(w/'uart_meta.txt').read_text().splitlines()[0].split();p,d,t,sl=int(z[1],16),int(z[2],16),int(z[3],16),int(z[4]);payload=b''.join(v.to_bytes(16,'little') for v in packet128(p,d,t,sl,0xfeed000000000003,0xbeef000000000004))
 header=b'SM5B'+bytes([1,4])+int(64).to_bytes(2,'little')+int(256).to_bytes(4,'little')+bytes(4)+(d&((1<<320)-1)).to_bytes(40,'little')+bytes(8)
 gold=header+payload;gold+=zlib.crc32(gold).to_bytes(4,'little');actual=bytes(int(x,16) for x in (w/'serial.hex').read_text().split());assert actual==gold,('SERIAL_PACKET_CRC',len(actual),next((i for i,(a,b) in enumerate(zip(actual,gold)) if a!=b),None))
 return dict(wire_bytes=len(actual),payload=256,CRC='PASS',type=4,reserved_and_header='PASS')

if __name__=='__main__':
 w=Path(sys.argv[1]);result=uart_check(w);(w/'SOFTWARE_UART_ORACLE.json').write_text(json.dumps(result,indent=2));print(result)
