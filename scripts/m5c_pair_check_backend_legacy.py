from pathlib import Path
import importlib.util,json,sys,hashlib
R=Path.cwd();W=Path(sys.argv[1]).resolve();p=R/'scripts/m5b1_uart_decode.py';spec=importlib.util.spec_from_file_location('legacy',p);d=importlib.util.module_from_spec(spec);spec.loader.exec_module(d)
rawfile=W/'system_uart.hex';raw=bytes.fromhex(rawfile.read_text());packets=d.parse(raw);r=d.verify(packets);r.update(wire_bytes=len(raw),types=[x['type'] for x in packets],wire_sha256=hashlib.sha256(raw).hexdigest(),hex_file_sha256=hashlib.sha256(rawfile.read_bytes()).hexdigest(),decoder_sha256=hashlib.sha256(p.read_bytes()).hexdigest(),scope='Actual new-backend legacy type2/3 export, byte acceptance model, full class/mask BFS. Not pair current-plane fullvideo or UART pin/default-speed qualification.')
assert r['types']==[1,2,3,1] and r['pixels']==921600
(W/'SOFTWARE_ORACLE.json').write_text(json.dumps(r,indent=2));print(r['status'],len(raw))
