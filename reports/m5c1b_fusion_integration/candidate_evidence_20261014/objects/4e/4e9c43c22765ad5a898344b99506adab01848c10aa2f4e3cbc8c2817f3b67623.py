from pathlib import Path
import json,sys
MASK=(1<<64)-1
def bits(n,lo,w=64):return (n>>lo)&((1<<w)-1)
def packet128(p,d,token,slot,jobs,faults):
 has=bits(p,128)!=0;d=d if has else 0
 return [bits(p,0)<<64|bits(p,288,32)<<32|1,bits(d,512)<<64|bits(d,320),bits(d,0)<<64|bits(p,64),bits(d,64)<<64|bits(d,128),bits(d,448)<<64|bits(d,384),bits(p,128)<<64|(token if has else 0),(((bits(p,64)-bits(d,512))&MASK)<<64|((bits(p,0)-bits(d,320))&MASK)) if has else (1<<128)-1,bits(p,320,32)<<96|bits(p,256,32)<<64|bits(p,224,32)<<32|bits(p,192,32),bits(p,352)<<64|bits(p,416),faults<<64|jobs,int(has and slot),0,0,0,0,0]
def check(path):
 sources={};accepted={};memory={};complete={};bytecounts={};writes=0
 for line in Path(path).read_text().splitlines():
  z=line.split();kind=z[0]
  if kind=='S':sources[int(z[1])]=int(z[2],16)
  elif kind=='A':
   n=int(z[1]);accepted[n]=(int(z[2]),int(z[3],16),int(z[4],16),int(z[5],16));memory[n]={}
  elif kind=='W':
   n,c,k=int(z[1]),int(z[2]),int(z[3]);got=int(z[4],16);d,t,sl=int(z[5],16),int(z[6],16),int(z[7]);a,ad,j,f=accepted[n]
   assert k==len(memory[n]) and c==a+k+1,('ORDER',n,k,c,a)
   expected=bits(packet128(sources[n],d,t,sl,j,f)[k//2],64*(k%2))
   assert got==expected,('WORD_VALUE',n,k,hex(got),hex(expected))
   memory[n][k]=expected;writes+=1
  elif kind=='P':
   n,c=int(z[1]),int(z[2]);a,d,_,_=accepted[n];assert c==a+32 and len(memory[n])==32,('COMPLETE',n)
   assert int(z[3],16)==(d&((1<<320)-1) if bits(sources[n],128) else 0),('HEADER',n)
   complete[n]=b''.join(memory[n][k].to_bytes(8,'little') for k in range(32));bytecounts[n]=0
  elif kind=='B':
   n,k,g=int(z[1]),int(z[2]),int(z[3],16);assert k==bytecounts[n] and complete[n][k]==g,('BYTE_VALUE',n,k,g);bytecounts[n]+=1
  elif kind!='R':raise AssertionError(('UNKNOWN_TRACE',line))
 assert len(complete)==17 and all(v==256 for v in bytecounts.values()),('COVERAGE',bytecounts)
 return dict(status='PASS_SOFTWARE_FORMATTER',packets=len(complete),bytes=sum(bytecounts.values()),partial_and_complete_writes=writes)
if __name__=='__main__':print(json.dumps(check(sys.argv[1]),indent=2))
