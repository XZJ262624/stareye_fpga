from pathlib import Path
import json,hashlib,zlib,subprocess,sys
O=Path(__file__).resolve().parent

def decode(wire,expected):
 pos=0; index=0; locations=[]
 while pos<len(wire):
  assert wire[pos:pos+4]==b'SM5B','TYPE1_FRAMING'
  assert len(wire)-pos>=68,'TYPE1_TRUNCATED_HEADER'
  typ=wire[pos+5]; length=int.from_bytes(wire[pos+8:pos+12],'little');end=pos+68+length
  assert end<=len(wire),'TYPE1_TRUNCATED_PACKET'
  assert int.from_bytes(wire[end-4:end],'little')==zlib.crc32(wire[pos:end-4]),'TYPE1_CRC'
  if typ==1:
   assert length==256 and index<len(expected),'TYPE1_RECORD_COUNT'
   actual=wire[pos+64:end-4];want=expected[index]
   differences=[i for i in range(256) if actual[i]!=want[i]]
   assert not differences,('TYPE1_INDEPENDENT_SCALAR_MISMATCH',index,differences)
   locations.append((pos,end));index+=1
  pos=end
 assert index==len(expected) and index>0,'TYPE1_MISSING_RECORD'
 return locations

def main():
 w=Path(sys.argv[1]);wire=bytes(int(x,16) for x in (w/'serial.hex').read_text().split())
 records=[x.split() for x in (w/'type1_expected.txt').read_text().splitlines()]
 assert all(x[0]=='TYPE1' and int(x[1])==i+1 for i,x in enumerate(records))
 expected=[int(x[-1],16).to_bytes(256,'little') for x in records]
 locations=decode(wire,expected)
 # First validate entire original stream against retained independent golden and type4 events.
 subprocess.run([sys.executable,'-B',str(O.parent/'check_smoke_uart.py'),str(w)],check=True)
 negatives=[]
 for offset,name in [(56,'pairs'),(60,'elapsed'),(0,'requests')]:
  altered=bytearray(wire);start,end=locations[0];altered[start+64+offset]^=1
  altered[end-4:end]=zlib.crc32(altered[start:end-4]).to_bytes(4,'little')
  path=w/('type1_crc_valid_mutation_'+name+'.bin');assert not path.exists();path.write_bytes(altered)
  try:decode(altered,expected)
  except AssertionError as error:
   assert isinstance(error.args[0],tuple) and error.args[0][0]=='TYPE1_INDEPENDENT_SCALAR_MISMATCH',str(error)
   negatives.append(dict(field=name,offset=offset,status='EXPECTED_SCALAR_REJECTION_WITH_VALID_CRC',reason=repr(error.args[0]),path=str(path),sha256=hashlib.sha256(altered).hexdigest()))
  else:raise AssertionError('TYPE1_MUTANT_ESCAPED')
 result=dict(status='PASS_TYPE1_ALL256_INDEPENDENT_EVENT_BYTES_AND_FULL_MIXED_WIRE',records=len(records),wire_bytes=len(wire),negative=negatives,scope='Normal complete publications; declared status/FIFO inputs are serialization only. Software CRC-valid mutations do not replace RTL mutants.')
 (w/'TYPE1_SOFTWARE_ORACLE.json').write_text(json.dumps(result,indent=2));print(result['status'],len(records))
if __name__=='__main__':main()
