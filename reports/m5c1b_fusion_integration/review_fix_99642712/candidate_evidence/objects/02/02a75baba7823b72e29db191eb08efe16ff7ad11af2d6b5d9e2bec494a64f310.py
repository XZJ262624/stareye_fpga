import sys,json,ast,types,hashlib
from pathlib import Path
sys.path.insert(0,'E:/Efinity/2025.1/scripts')
import efx_run
sys.argv=['efx_run.py','Ti60_Demo.xml','--flow','pgm']
args=efx_run.parse_cmdline_options()
assert args.do_pgm and args.do_export_bitstream and not args.do_program and not args.do_map and not args.do_pnr
assert not args.do_security
flat=[y for x in args.pgm_opts for y in x]
assert not any(x.split('=')[0] in ['program','source','dest','settings_file','usb','jtag','flash'] for x in flat)
assert not Path('efx_pgm_settings.ini').exists()
tool=Path('E:/Efinity/2025.1/scripts/efx_run_pgm.py');raw=tool.read_text();tree=ast.parse(raw);fn=next(x for x in tree.body if isinstance(x,ast.FunctionDef) and x.name=='run_efx_pgm')
assign=next(x for x in fn.body if isinstance(x,ast.Assign) and any(isinstance(t,ast.Name) and t.id=='run_usbif' for t in x.targets))
loop=fn.body[fn.body.index(assign)+1];assert isinstance(loop,ast.For)
scope={'args':types.SimpleNamespace(opts=args.pgm_opts)};exec(compile(ast.Module(body=[assign,loop],type_ignores=[]),str(tool),'exec'),scope)
assert scope['run_usbif'] is False
out=Path(__file__).resolve().parent/'ACTUAL_GENERATED_OPTIONS.json' ;assert not out.exists();out.write_text(json.dumps(dict(run_usbif=scope['run_usbif'],run_usbif_actual_installed_code=ast.get_source_segment(raw,assign)+'\n'+ast.get_source_segment(raw,loop),run_usbif_tool_sha256=hashlib.sha256(tool.read_bytes()).hexdigest(),flags={k:v for k,v in vars(args).items() if k.startswith('do_')},pgm_opts=args.pgm_opts,export_opts=args.export_bitstream_opts,security_opts=args.security_opts,device=args.device,family=args.family,status='PASS_CONVERSION_ONLY_NO_NATIVE_EXECUTED'),indent=2))
print('OPTIONS_CONVERSION_ONLY_PASS')
