from pathlib import Path
import json,hashlib,subprocess,datetime,time,zlib,sys
R=Path.cwd();O=R/'reports/m5c_pair_capture_20261016';W=O/('default_pin_'+datetime.datetime.now().strftime('%H%M%S'));W.mkdir();M=Path('E:/Modelsim_10.1c/win64')
def rec(p):
 b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
S=[R/'rtl/m5c_fusion/m5b1_uart.sv',R/'tb/m5c_pair_diag/tb_pair_default_uart.sv'];inputs=[rec(p) for p in S+[Path(__file__).resolve()]];(W/'INPUTS.json').write_text(json.dumps(inputs,indent=2));(W/'snapshots').mkdir()
for x in inputs:(W/'snapshots'/Path(x['path']).name).write_bytes(Path(x['path']).read_bytes())
commands=[[str(M/'vlib.exe'),'work'],[str(M/'vlog.exe'),'-sv','-work','work']+[str(p) for p in S],[str(M/'vsim.exe'),'-c','-novopt','-l',str(W/'native.log'),'-wlf',str(W/'native.wlf'),'work.tb_pair_default_uart','+OUT='+str(W/'pin.hex'),'+ACCEPT='+str(W/'accepted.hex'),'-do','run -all; quit -f']]
steps=[]
for i,c in enumerate(commands):
 with (W/f'{i}.log').open('wb') as f:
  p=subprocess.Popen(c,cwd=W,stdout=f,stderr=subprocess.STDOUT);(W/f'OWNER{i}.json').write_text(json.dumps(dict(pid=p.pid,start=time.time(),command=c)));code=p.wait()
 t=(W/f'{i}.log').read_text(errors='replace');steps.append(dict(exit=code,log=rec(W/f'{i}.log')))
 if code or '** Error' in t or '** Fatal' in t:break
ok=len(steps)==3 and all(x['exit']==0 for x in steps) and 'PAIR_DEFAULT_PIN_UART_PASS' in t and '** Fatal' not in t
(W/'RESULT.json').write_text(json.dumps(dict(status='PASS_SIM_PENDING_SOFTWARE' if ok else 'FAIL',steps=steps),indent=2));assert ok,t[-3000:]
b=bytes.fromhex((W/'pin.hex').read_text());a=bytes.fromhex((W/'accepted.hex').read_text());assert len(b)==324 and b==a
assert b[:4]==b'SM5B' and b[4]==1 and b[5]==10 and int.from_bytes(b[6:8],'little')==64 and int.from_bytes(b[8:12],'little')==256
assert b[64:320]==bytes(i^0x5a for i in range(256));assert zlib.crc32(b[:-4])==int.from_bytes(b[-4:],'little')
assert inputs==[rec(Path(x['path'])) for x in inputs]
(W/'SOFTWARE_ORACLE.json').write_text(json.dumps(dict(status='PASS_DEFAULT_DIVIDER_PIN_AND_FULL_PACKET_CRC',bytes=len(b),inputs_unchanged=True,scope='Real packetizer/UART pins at default96M/460800 parameters,10ns conditional UI model; representative256-byte payload pattern is not semantic successful pair completion. Full1.268MB pair tested separately.',files=[rec(W/'pin.hex'),rec(W/'accepted.hex')]),indent=2));print(W)
