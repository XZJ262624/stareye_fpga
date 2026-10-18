from pathlib import Path
R=Path.cwd();D=R/'reports/m5c_pair_admission_20261018/implementation'
s=(R/'tb/m5c_pair_diag/tb_pair_selection_lifecycle_pack5.sv').read_text()
s=s.replace('module tb_pair_selection_lifecycle;','module tb_pair_latest_lifecycle;')
a='''   else $fatal(1,"DIAG_UNCLASSIFIED_CONSUMPTION");''';assert s.count(a)==1
s=s.replace(a,'''   else begin /* Prompt mailbox ACK precedes acquisition under the new contract. */ end''')
s=s.replace('if(CASE==1&&(backend.pair_failure==0||','if(CASE==1&&(backend.pair_failure!=3||')
p=R/'tb/m5c_pair_diag/tb_pair_latest_lifecycle.sv';assert not p.exists();p.write_text(s)
src=(R/'scripts/m5c_pair_selection_lifecycle_pack5.py').read_text();tail=src[src.index('sources='):]
tail=tail.replace('sources+[base,Path(__file__)]','sources+[base,Path(__file__)]')
tail=tail.replace("work.tb_pair_selection_lifecycle","work.tb_pair_latest_lifecycle")
tail=tail.replace("[str(p) for p in sources]","[str(W/'snapshots'/f'{i}_{p.name}') for i,p in enumerate(sources)]")
tail=tail.replace("code=p.wait()","code=p.wait(timeout=600)")
header='''from pathlib import Path
import datetime,hashlib,json,subprocess,time
R=Path(__file__).resolve().parents[1];F=R/'reports/m5c_pair_admission_20261018/implementation';M=Path('E:/Modelsim_10.1c/win64');W=F/('lifecycle_'+datetime.datetime.now().strftime('%H%M%S'));W.mkdir()
def rec(p):
 b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
base=R/'tb/m5c_pair_diag/tb_pair_selection_lifecycle_pack5.sv'
tb=R/'tb/m5c_pair_diag/tb_pair_latest_lifecycle.sv'
(W/'TOOLS.json').write_text(json.dumps([rec(M/n) for n in ['vlib.exe','vlog.exe','vsim.exe']],indent=2))
'''
p=R/'scripts/m5c_pair_latest_lifecycle.py';assert not p.exists();p.write_text(header+tail)
