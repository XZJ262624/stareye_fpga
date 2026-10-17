from pathlib import Path
import json,hashlib,re,zlib,datetime
R=Path(__file__).resolve().parents[1];F=R/'reports/m5c_pair_capture_20261016';W=F/'selection_real_telemetry_235111';O=F/'selection_real_telemetry_handback';O.mkdir(exist_ok=True)
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
result=json.loads((W/'RESULT.json').read_text());assert result['status']=='PASS_REAL_TELEMETRY_SELECTION_BOUNDARY'
inputs=json.loads((W/'INPUTS.json').read_text());assert all(rec(Path(x['path']))['sha256']==x['sha256'] and rec(Path(x['path']))['bytes']==x['bytes'] for x in inputs)
rows=[]
for case in range(5):
 d=W/f'case{case}';log=(d/'native.log').read_text();assert '** Fatal' not in log and '** Error' not in log and 'REAL_TELEMETRY_SELECTION_PASS' in log
 raw=bytes.fromhex((d/'system_uart.hex').read_text());packets=[];pos=0
 while pos<len(raw):
  h=raw[pos:pos+64];assert len(h)==64 and h[:4]==b'SM5B' and h[4]==1 and int.from_bytes(h[6:8],'little')==64 and h[12:16]==bytes(4) and h[56:]==bytes(8)
  n=int.from_bytes(h[8:12],'little');assert n==256 and h[5] in (1,4);end=pos+64+n;assert end+4<=len(raw) and int.from_bytes(raw[end:end+4],'little')==zlib.crc32(raw[pos:end])
  payload=raw[pos+64:end];packets.append(h[5])
  if h[5]==4:
   expected=bytearray(256)
   for offset,value,size in [(0,1,4),(8,6,8),(32,2000000,8),(96,(1<<64)-1,8),(104,(1<<64)-1,8)]:expected[offset:offset+size]=value.to_bytes(size,'little')
   assert payload==expected and h[16:56]==bytes(40)
  pos=end+4
 assert packets==([1] if case==0 else [1,4])
 lines=(d/'events.txt').read_text().splitlines();uis=[];telem=[]
 for line in lines:
  if line.startswith('UI '):uis.append(dict(re.findall(r'(\w+)=([^ ]+)',line)))
  if line.startswith('TELEM '):telem.append(dict(re.findall(r'(\w+)=([^ ]+)',line)))
 acq=[x for x in uis if x['acq']=='1'];ack=[x for x in uis if x['ack']=='1'];assert len(acq)==1 and len(ack)==1
 a=acq[0];assert a['pairSID']==a['activeSID'] and a['fresh']=='1' and a['eq']=='1' and int(ack[0]['cyc'])==int(a['cyc'])+1
 if case in (2,3):assert a['state']=='24' and a['packet']=='1' and a['pending']=='0' and a['selected']=='0' and a['take']=='1'
 if case in (0,4):assert a['state']=='0' and a['packet']=='0' and a['selected']=='1' and a['take']=='1'
 chain={}
 if case:
  starts=[x for x in telem if x['start']=='1' and x['type']=='4'];done=[x for x in telem if x['done']=='1' and x['type']=='4'];takes=[x for x in telem if x['take']=='1'];assert len(starts)==len(done)==len(takes)==1
  busy0=[x for x in telem if x['pending']=='0' and x['packetbusy']=='1' and x['type']=='4'];assert busy0
  chain=dict(start=int(starts[0]['cyc']),pending_clear_while_busy=int(busy0[0]['cyc']),done=int(done[0]['cyc']),take=int(takes[0]['cyc']))
  assert chain['start']<chain['pending_clear_while_busy']<chain['done'] and chain['take']==chain['done']+1
 rows.append(dict(case=case,wire_bytes=len(raw),packet_types=packets,crc_and_exact_no_source_type4_payload=True,acquire=a,ack=ack[0],telemetry_chain=chain))
active=json.loads((F/'system_qualified_resume_2103/INPUTS.json').read_text());assert len(active)==63 and all(rec(Path(x['path']))['sha256']==x['sha256'] and rec(Path(x['path']))['bytes']==x['bytes'] for x in active)
summary=dict(status='PASS_REAL_MODULE_REPRODUCTION_OF_SELECTION_BUSY_WINDOW',time=datetime.datetime.now().astimezone().isoformat(),cases=rows,active_inputs_checked=63,active_input_differences=0,original_longrun_exact_cause='NOT_OBSERVED_INTERNAL_PREDICATES',scope='Actual telemetry producer, actual frame_done sampled snapshot, real RAM formatting and packet DONE/TAKE, parallel mailboxes, real backend publication/B and lease ACK. Synthetic completed no-source frame; no video raster/reader acceptance/capture-export success claim.',no_rtl_change=True)
(O/'SUMMARY.json').write_text(json.dumps(summary,indent=2)+'\n')
files=[p for p in W.rglob('*') if p.is_file() and 'work' not in p.relative_to(W).parts and p.suffix in ['.json','.log','.txt','.hex','.sv','.py']]+[O/'SUMMARY.json',O/'REPORT.md',Path(__file__)]
(O/'MANIFEST.json').write_text(json.dumps([rec(p) for p in files],indent=2)+'\n');print(O,len(files))
