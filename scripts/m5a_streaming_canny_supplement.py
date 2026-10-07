"""Recovery and unchanged real HDMI encoder channel checks, isolated test library."""
from pathlib import Path
import json,subprocess,hashlib,re
R=Path(__file__).resolve().parents[1];T=R/'tb/m5a_streaming_canny';O=R/'reports/m5a_streaming_canny_i3/supplement';O.mkdir(exist_ok=True)
M=Path('E:/Modelsim_10.1c/win64');commands=[]
def rec(p):return dict(path=p.relative_to(R).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def run(cmd,name):
 p=O/(name+'.log')
 with p.open('wb') as f:r=subprocess.run(list(map(str,cmd)),cwd=O,stdout=f,stderr=subprocess.STDOUT,timeout=600)
 s=p.read_text(errors='replace');commands.append(dict(command=list(map(str,cmd)),exit_code=r.returncode,log=rec(p)))
 assert r.returncode==0 and not re.search(r'\*\* (Error|Fatal):',s),s[-3000:]
 return s
src=list((R/'rtl/m5a_streaming_canny').glob('*.v'))+[R/'efinity/m5a_streaming_canny_i3/src/hdmi_ip'/n for n in ('rgb2dvi.v','tmds_channel.v')]+[T/'tb_m5a_recovery.sv',T/'tb_m5a_hdmi_channels.sv',T/'run.do',Path(__file__)]
before=[rec(p) for p in src]
if not(O/'work').exists():run([M/'vlib.exe','work'],'vlib')
run([M/'vlog.exe','-sv','-work','work',*[p for p in src if p.suffix in ('.v','.sv')]],'compile')
cases=[]
for top in ('tb_m5a_recovery','tb_m5a_hdmi_channels'):
 s=run([M/'vsim.exe','-c','-novopt','-onfinish','stop','work.'+top,'-do',T/'run.do'],top)
 marker=top.removeprefix('tb_').upper()+'_PASS';assert marker in s
 cases.append(dict(name=top,summary=next(x for x in s.splitlines() if marker in x)))
assert before==[rec(p) for p in src]
(O/'binding.json').write_text(json.dumps(dict(status='PASS',sources_before=before,sources_after=before,commands=commands,cases=cases),indent=2));print('M5A_SUPPLEMENT_PASS')
