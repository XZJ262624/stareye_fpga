"""Additional full-system repair oracles, each with immutable named evidence."""
from pathlib import Path
import argparse,subprocess,json,hashlib,struct
from m5b1_uart_decode import parse
R=Path(__file__).resolve().parents[1];M=Path('E:/Modelsim_10.1c/win64')
def rec(p):return dict(path=p.relative_to(R).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--name',required=True);ap.add_argument('--test',choices=['cancel_recovery','capture_drain'],required=True);ap.add_argument('--mode',type=int,default=0);a=ap.parse_args()
 o=R/'reports/m5b1_global_canny_i3/review_fix_264962e0'/a.name;assert not o.exists();o.mkdir(parents=True);lib=o/'work'
 src=sorted((R/'rtl/m5b1_global_canny').glob('*.sv'))+[R/f'tb/m5b1_global_canny/tb_m5b1_{a.test}.sv'];bound=src+[Path(__file__),R/'scripts/m5b1_uart_decode.py'];before=[rec(p) for p in bound]
 subprocess.run([str(M/'vlib.exe'),str(lib)],check=True,capture_output=True)
 x=subprocess.run([str(M/'vlog.exe'),'-sv','-work',str(lib),*map(str,src)],cwd=o,capture_output=True);(o/'compile.log').write_bytes(x.stdout+x.stderr);assert x.returncode==0,x.stdout
 log=o/'simulation.log';x=subprocess.run([str(M/'vsim.exe'),'-c','-novopt','-onfinish','exit','-lib',str(lib),'tb_m5b1_'+a.test,f'-gCHECK={a.mode}','-do','run -all; quit -f','-l',str(log)],cwd=o,capture_output=True,timeout=3600)
 out=x.stdout.decode(errors='replace');summary=next((s for s in out.splitlines() if 'REVIEW_PASS' in s),None);print(out[-4000:],flush=True)
 assert summary and '** Fatal' not in out and '** Error' not in out
 raw=bytes.fromhex((o/'system_uart.hex').read_text());diagnostics=[];packets=parse(raw,resync=True,diagnostics=diagnostics)
 assert all(p['type']==1 for p in packets)
 stats=[dict(descriptor=p['descriptor'],words=list(struct.unpack('<64I',p['payload']))) for p in packets]
 assert len(stats)==(3 if a.mode==2 else 2)
 failure=stats[-2];success=stats[-1]
 assert failure['words'][22]&8 and failure['words'][33]==1 and not success['words'][22]&8 and success['words'][33]==1
 assert success['descriptor']['job_id']>failure['descriptor']['job_id'] and success['descriptor']['capture_success']
 assert success['words'][4]==failure['words'][4]+1
 assert before==[rec(p) for p in bound]
 (o/'result.json').write_text(json.dumps(dict(status='PASS',case=a.test,mode=a.mode,summary=summary,sources=before,log=rec(log),uart_bytes=len(raw),uart_sha256=hashlib.sha256(raw).hexdigest(),statistics=stats,resync=diagnostics,scope='Actual full system; wall counter boundary injected for cleanup/recovery. Separate default_timeout cases count the complete production limits. UART serializer accelerated; full byte/CRC parsed.'),indent=2))
if __name__=='__main__':main()
