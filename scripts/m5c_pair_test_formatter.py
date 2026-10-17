from pathlib import Path
import subprocess,json,hashlib,datetime,time,re
R=Path.cwd();W=R/'reports/m5c_pair_capture_20261016'/('formatter_short_'+datetime.datetime.now().strftime('%H%M%S'));W.mkdir();M=Path('E:/Modelsim_10.1c/win64')
S=[R/'tb/m5c_pair_diag/tb_pair_formatter_equivalence.sv',R/'rtl/m5c_pair_diag/m5c_pair_controller.sv'];rows=[]
old_source=R/'reports/m5c_pair_capture_20261016/formatter_revision/controller_before.sv'
def fn(s,name):return re.sub(r'\s+','',re.search(r'function \[127:0\] '+name+r'.*?endfunction',s,re.S)[0].replace(name,'WORD'))
tb=S[0].read_text();assert fn(tb,'old_word')==fn(old_source.read_text(),'meta_word');assert fn(tb,'new_word')==fn(S[1].read_text(),'meta_word')
S.append(old_source)
for p in S:
 b=p.read_bytes();q=W/p.name;q.write_bytes(b);rows.append(dict(path=str(p),snapshot=str(q),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b)))
(W/'INPUTS.json').write_text(json.dumps(rows,indent=2));(W/'RUNNER.py').write_bytes(Path(__file__).read_bytes())
for n,args in [('lib',[str(M/'vlib.exe'),'work']),('compile',[str(M/'vlog.exe'),'-sv',rows[0]['snapshot']]),('sim',[str(M/'vsim.exe'),'-c','-novopt','-l',str(W/'native.log'),'-wlf',str(W/'native.wlf'),'work.tb_pair_formatter_equivalence','-do','run -all;quit -f'])]:
 with (W/(n+'.log')).open('w') as f:
  p=subprocess.Popen(args,cwd=W,stdout=f,stderr=subprocess.STDOUT);(W/(n+'_OWNER.json')).write_text(json.dumps(dict(pid=p.pid,command=args,time=time.time())));c=p.wait()
 t=(W/(n+'.log')).read_text();assert c==0 and '** Error' not in t and '** Fatal' not in t,t
assert 'PAIR_FORMATTER_EQ_PASS 64000_words' in t
assert all(hashlib.sha256(Path(x['path']).read_bytes()).hexdigest()==x['sha256'] for x in rows)
(W/'RESULT.json').write_text(json.dumps(dict(status='PASS_REACHABLE_WORD_FUNCTION_EQUIVALENCE',words=64000,scope='All word0..31 both completion modes over1000 deterministic randomized fullwidth inputs; completion actual reachable0..15. word32..63 unreachable by 0..31 FORMAT /0..15 COMP_FORMAT; old variable select is out-of-range X there, new default0; not claimed equivalent outside reachable domain.',native_exit=c,inputs_unchanged=True),indent=2));print(W)
