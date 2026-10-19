from pathlib import Path
import json,hashlib,difflib,ast
R=Path.cwd();D=Path(__file__).resolve().parent;B=R/'reports/m5c_pair_admission_20261018/remote_v3/package';N=D/'remote_v4';P=N/'package';P.mkdir(parents=True,exist_ok=False)
def rec(p):
 b=p.read_bytes();return dict(size=len(b),sha256=hashlib.sha256(b).hexdigest())
m=json.loads((B/'manifest.json').read_text())
for name,r in m['files'].items():
 assert rec(B/name)==r,name
 q=P/name;q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes((B/name).read_bytes())
q=P/'rtl/m5c_pair_diag/m5c_pair_backend.sv';old=q.read_bytes();q.write_bytes((R/'rtl/m5c_pair_diag/m5c_pair_backend.sv').read_bytes())
assert rec(q)['sha256']=='8a78aa7030d6bdcd27d8e50c1e633e3d9353709c1ae2cfb814606fe37a18c82c'
(P/'provenance/DEADLINE_BACKEND.diff').write_text(''.join(difflib.unified_diff(old.decode().splitlines(True),q.read_bytes().decode().splitlines(True),fromfile='V3',tofile='V4')))
rows=[]
for x in json.loads((B/'provenance/ORIGINAL_63_INPUTS.json').read_text()):
 n=x['path'];rows.append(dict(path=n,parent=rec(B/n),current=rec(P/n),changed=(B/n).read_bytes()!=(P/n).read_bytes()))
assert len(rows)==63 and [x['path'] for x in rows if x['changed']]==['rtl/m5c_pair_diag/m5c_pair_backend.sv']
(P/'provenance/V4_63_INPUT_RELATION.json').write_text(json.dumps(dict(parent_manifest=rec(B/'manifest.json'),records=rows),indent=2))
(P/'portable/current_inputs.py').write_bytes((D/'current_inputs.py').read_bytes())
q=P/'portable/stage.py';s=q.read_text().replace('LATEST_V3','DEADLINE_V4')
s=s.replace('P=Path(__file__).resolve().parents[1]','from current_inputs import capture\nP=Path(__file__).resolve().parents[1]')
s=s.replace("L=P/'portable_logs';L.mkdir(exist_ok=True);start=time.time()","L=P/'portable_logs';L.mkdir(exist_ok=True);start=time.time()\n runtime_tool=tool_identity(tool) if tool else json.loads((P/'COMPILE_RECEIPT.json').read_text())['tool']\n capture(P,label,'pre',runtime_tool)")
s=s.replace("   raise RuntimeError(('NATIVE_TIMEOUT',label,timeout))","   capture(P,label,'post',runtime_tool)\n   raise RuntimeError(('NATIVE_TIMEOUT',label,timeout))")
s=s.replace(" text=(L/(label+'.log')).read_text", " capture(P,label,'post',runtime_tool)\n text=(L/(label+'.log')).read_text")
a="put('INPUTS.json',[dict(path=str(P/x['path']),bytes=x['original']['bytes'],sha256=x['original']['sha256']) for x in inputs])"
b="put('INPUTS.json',[{k:x[k] for k in ['path','bytes','sha256']} for x in json.loads((P/'CURRENT_INPUTS_FULL_POST.json').read_text())['records']])"
assert s.count(a)==1;s=s.replace(a,b)
q.write_text(s)
(P/'provenance/V4_STAGE.diff').write_text(''.join(difflib.unified_diff((B/'portable/stage.py').read_text().splitlines(True),s.splitlines(True),fromfile='V3',tofile='V4')))
q=P/'portable/compat.do';q.write_bytes(q.read_bytes().replace(b'LATEST_V3',b'DEADLINE_V4'))
text='''# 截止门修复 V4：固定WIP仿真包

相对V3，63项RTL/TB/gold执行输入仅backend增加截止门，其余62项原字节不变。版本化host桥接改为每条原生命令前后核实际当前63文件及manifest/tool；INPUTS.json来自实际FULL_POST，不引用历史original哈希。provenance旧LOCAL/REPAIR/V3字段仅为历史来源，不是V4通过证据。

必须在新目录运行本包compatibility，再运行full_video（其内部仍重跑同包同工具compile/compat）；不能覆盖V3或复制其收据。ModelSim2020.4使用+acc。完整运行从time0，无checkpoint迁移。保留96M/service384/blank478667/seed50708、4s模拟、14400s墙钟、全部7健康模式、921600当前像素/gold/BFS、1152currentB+1metaB、CRC/身份/释放/下一发布/end。仅100us启动兼容不证明完整功能；本机10.1c不替代远端2020.4。

导出全部CURRENT_INPUTS_*、INPUTS、实际命令/工具/原日志/软件收据。历史V3 INPUTS有旧backend哈希错误，原件保留；本包重新测量，不补造旧记录。不得修改源码/断言/负载/预算，不运行硬件/Git/串口。物理资格另行建立。
'''
(P/'README_CN.md').write_text(text,encoding='utf-8');(P/'REMOTE_CODEX_PROMPT_CN.md').write_text(text,encoding='utf-8')
m=json.loads(json.dumps(m).replace('LATEST_V3','DEADLINE_V4'));m['version']='pack5_deadline_20261018_v4'
for case,labels in [('compatibility',['vlib','compile','compat']),('full_video',['vlib','compile','compat','full','software'])]:
 m['cases'][case]['required_outputs'] += ['CURRENT_INPUTS_'+label.upper()+'_'+phase+'.json' for label in labels for phase in ['PRE','POST']]
m['cases']['full_video']['required_outputs']+=['INPUTS.json']
m['files']={p.relative_to(P).as_posix():rec(p) for p in sorted(P.rglob('*')) if p.is_file()}
(P/'manifest.json').write_text(json.dumps(m,indent=2))
for p in P.rglob('*.py'):ast.parse(p.read_text(encoding='utf-8-sig'))
s=(R/'reports/m5c_pair_admission_20261018/remote_v3/validate_local.py').read_text().replace('LATEST_V3','DEADLINE_V4')
(N/'validate_local.py').write_text(s)
(N/'PREPARATION.json').write_text(json.dumps(dict(status='PREPARED_NOT_VALIDATED',files=len(m['files']),manifest=rec(P/'manifest.json'),execution_inputs=63,changed=1,unchanged=62),indent=2))
print(P)
