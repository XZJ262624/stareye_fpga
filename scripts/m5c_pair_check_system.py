"""Post-run only. Actual complete UART, pair plane and retained original end oracles."""
from pathlib import Path
import sys,json,hashlib,importlib.util,subprocess,shutil
R=Path(__file__).resolve().parents[1];W=Path(sys.argv[1]).resolve()
def load(name,path):
 s=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
def rec(p):b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
result=json.loads((W/'RESULT.json').read_text());assert result['status']=='PASS_SIM_PENDING_SOFTWARE' and result['inputs_unchanged']
d=load('pairdecode',R/'scripts/m5c_pair_decode.py');legacy=load('legacydecode',R/'scripts/m5b1_uart_decode.py');raw=bytes.fromhex((W/'serial.hex').read_text());pk=d.packets(raw);report=d.decode_pair(raw);assert report['pair_count']==1 and not report['failures']
metadata=[s.split() for s in (W/'uart_meta.txt').read_text().splitlines()];declared=[s for s in metadata if s[0]=='PACKET'];assert len(declared)==len(pk)
for x,z in zip(pk,declared):assert (x['type'],len(x['payload']),int.from_bytes(x['header'][16:56],'little'))==(int(z[1]),int(z[2]),int(z[3],16))
planes={x['type']:x for x in pk if x['type']>=6};current=planes[9]['payload'][24:];expected=bytes.fromhex((W/'pair_current_oracle.hex').read_text());assert len(current)==len(expected)==921600 and current==expected,'PAIR_REAL_VIDEO_CURRENT_BYTE_MISMATCH'
classes=legacy.unpack(planes[7]['payload'][24:],921600,2);mask=bytes(legacy.unpack(planes[8]['payload'][24:],921600,1));assert legacy.bfs(classes,1280,720)==mask,'PAIR_REFERENCE_FULL_GRAPH_MISMATCH'
gold=[int(x,16) for x in (R/'reports/m5c1b_fusion_integration/golden_v2/pixels.hex').read_text().split()];assert len(gold)==921600
assert all(c==(g>>30)&3 for c,g in zip(classes,gold)),'REFERENCE_CLASS_GOLD'
assert all((c&15)==(((g>>30)&3)|(((g>>27)&1)<<2)|(((g>>29)&1)<<3)) for c,g in zip(current,gold)),'CURRENT_CLASS_SUPPORT_LOCAL_GOLD'
events=(W/'pair_events.txt').read_text().splitlines();assert sum(x.startswith('SELECT ') for x in events)==1 and 'PAIR_DONE pixels=921600 currentB=1800 metadataB=1' in events
view=W/'original_types_view';view.mkdir();original=b''.join(raw[x['offset']:x['offset']+x['bytes']] for x in pk if x['type']<=4);(view/'serial.hex').write_text(''.join(f'{b:02x}\n' for b in original));(view/'uart_meta.txt').write_text('\n'.join(' '.join(x) for x in metadata if x[0]!='PACKET' or int(x[1])<=4)+'\n');shutil.copyfile(W/'end_events.txt',view/'end_events.txt')
old=R/'reports/m5c1b_fusion_integration/selected_final_matrix_20261013_071300/replay_end_v2/common/check_end_protocol.py'
p=subprocess.run([sys.executable,'-B',str(old),str(view)],capture_output=True);(view/'checker.log').write_bytes(p.stdout+p.stderr);assert p.returncode==0,p.stderr.decode(errors='replace')[-2000:]
report.update(status='PASS_ACTUAL_FULL_VIDEO_PAIR_AND_ORIGINAL_END',reference_graph_pixels=921600,current_exact_pixels=921600,current_B=1800,metadata_B=1,wire_sha256=hashlib.sha256(raw).hexdigest(),scope='Actual videoDMA/LCD/M5A/fusion/OSD and real accepted DDR service conditional model; class/support/local independent golden. accepted-domain bit compares actual qualified control and is not independently inferred. Accelerated UART is not default-speed or hardware.',bindings=[rec(W/n) for n in ['RESULT.json','INPUTS.json','serial.hex','uart_meta.txt','end_events.txt','pair_events.txt','pair_current_oracle.hex']]+[rec(Path(__file__)),rec(R/'scripts/m5c_pair_decode.py'),rec(old)]);(W/'PAIR_SOFTWARE_ORACLE.json').write_text(json.dumps(report,indent=2));print(report['status'])
