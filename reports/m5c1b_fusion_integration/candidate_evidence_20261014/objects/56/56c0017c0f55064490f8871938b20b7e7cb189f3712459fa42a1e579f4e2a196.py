import sys,json
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
out=Path(__file__).resolve().parent/'ACTUAL_GENERATED_OPTIONS.json';assert not out.exists();out.write_text(json.dumps(dict(flags={k:v for k,v in vars(args).items() if k.startswith('do_')},pgm_opts=args.pgm_opts,export_opts=args.export_bitstream_opts,security_opts=args.security_opts,device=args.device,family=args.family,status='PASS_CONVERSION_ONLY_NO_NATIVE_EXECUTED'),indent=2))
print('OPTIONS_CONVERSION_ONLY_PASS')
