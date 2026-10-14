from pathlib import Path
import json,hashlib,shutil,difflib
F=Path(__file__).resolve().parent;R=F.parents[2];A=F/'resource_area_bound';O=F/'offline_area_artifact';C=O/'mirror';P=C/'efinity/m5c_fusion_i3';OLD=R/'reports/m5c1b_fusion_integration/offline_artifact_retry_20261014'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix() if p.is_relative_to(R) else str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
assert not O.exists();O.mkdir()
plan=json.loads((A/'NEXT_OFFLINE_AREA_CONVERSION_PLAN.json').read_text());rows=[];settings=[]
for x in plan['sources101']:
 p=R/x['path'];assert rec(p)==x;q=C/p.relative_to(A/'mirror');q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,q)
 if q.name=='settings.json':
  data=json.loads(p.read_text());new=json.loads(p.read_text());i=new['args'].index('--base_path')+1;previous=new['args'][i];new['args'][i]=str(P/'ip');q.write_text(json.dumps(new,indent=4)+'\n');check=json.loads(q.read_text());check['args'][i]=previous;assert check==data;settings.append(dict(original=x,copy=rec(q),before=previous,after=new['args'][i],inverse_normalized_exact=True))
 rows.append(dict(original=x,copy=rec(q)))
assert len(rows)==101 and len(settings)==11
db=[]
for x in plan['database8']:
 p=R/x['current']['path'];assert rec(p)==x['current'];assert rec(R/x['route_archive']['path'])==x['route_archive'];q=P/p.relative_to(A/'mirror/efinity/m5c_fusion_i3');q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,q);db.append(dict(original=x['current'],copy=rec(q),route_archive=x['route_archive']))
tools=[rec(Path('E:/Efinity/2025.1')/n) for n in ['scripts/efx_run.py','scripts/efx_run_pgm.py','pgm/bin/efx_pgm/export_bitstream.py','bin/efx_pgm.exe','scripts/sw_version.txt','bin/efx_run.bat','bin/setup.bat']]
(O/'INPUT_WHITELIST.json').write_text(json.dumps(dict(source=rows,settings=settings,database=db,tools=tools,plan=rec(A/'NEXT_OFFLINE_AREA_CONVERSION_PLAN.json'),freeze=rec(F/'WORK_AREA_OFFLINE_BIT_AND_ADOPTION_FREEZE.md')),indent=2))
changes=[]
for name in ['run_conversion.py','options_preflight.py']:
 s=(OLD/name).read_text();t=s.replace('R=F.parents[2]','R=F.parents[3]')
 if name=='options_preflight.py':
  t=t.replace('import sys,json','import sys,json,ast,types,hashlib')
  t=t.replace("out=Path(__file__).resolve().parent/'ACTUAL_GENERATED_OPTIONS.json'",'''tool=Path('E:/Efinity/2025.1/scripts/efx_run_pgm.py');raw=tool.read_text();tree=ast.parse(raw);fn=next(x for x in tree.body if isinstance(x,ast.FunctionDef) and x.name=='run_efx_pgm')
assign=next(x for x in fn.body if isinstance(x,ast.Assign) and any(isinstance(t,ast.Name) and t.id=='run_usbif' for t in x.targets))
loop=fn.body[fn.body.index(assign)+1];assert isinstance(loop,ast.For)
scope={'args':types.SimpleNamespace(opts=args.pgm_opts)};exec(compile(ast.Module(body=[assign,loop],type_ignores=[]),str(tool),'exec'),scope)
assert scope['run_usbif'] is False
out=Path(__file__).resolve().parent/'ACTUAL_GENERATED_OPTIONS.json' ''')
  t=t.replace('flags={k:v',"run_usbif=scope['run_usbif'],run_usbif_actual_installed_code=ast.get_source_segment(raw,assign)+'\\n'+ast.get_source_segment(raw,loop),run_usbif_tool_sha256=hashlib.sha256(tool.read_bytes()).hexdigest(),flags={k:v")
 q=O/name;q.write_text(t);changes.append(dict(parent=rec(OLD/name),derived=rec(q),diff=''.join(difflib.unified_diff(s.splitlines(True),t.splitlines(True)))))
(O/'.gitignore').write_text(''.join('mirror/efinity/m5c_fusion_i3/outflow/Ti60_Demo'+s+'\n' for s in ['.bit','.bit.bin','.hex','.hex.bin']))
(O/'DERIVATION.json').write_text(json.dumps(dict(generator=rec(Path(__file__)),helpers=changes,root_source101_before=rec(F/'regression/SOURCE101.json'),boundary='No native yet. Parent conversion exit-before-postprocess ordering unchanged. New options preflight additionally executes only installed run_usbif assignment/loop AST using actual generated pgm_opts, never run_efx_pgm or hardware.'),indent=2))
print('OFFLINE_AREA_PREPARED',len(rows),len(db),len(settings))
