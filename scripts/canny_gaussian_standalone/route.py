from common import *
W=R/json.loads((O/'ACTIVE_PHYSICAL.json').read_text())['path']
prefix='call E:\\Efinity\\2025.1\\bin\\setup.bat && '
pnr='E:\\Efinity\\2025.1\\python311\\bin\\python.exe -B E:\\Efinity\\2025.1\\scripts\\efx_run_pnr.py Ti60_Demo --prj --family Titanium --device Ti60F225 --timing_model I3 '
for stage,opt,marker in [('place','pack place','Post-placement primitive-level checks is successful'),('route','route','Ending stage final timing analysis')]:
 execute(W/stage,'native',['cmd.exe','/d','/c',prefix+pnr+'--work_dir work_pnr --output_dir outflow --opt '+opt+' timing_analysis=on seed=1 max_threads=32 sdc_file=Ti60_Demo_I3.sdc'],marker,7200,cwd=P)
 text=(W/stage/'native.log').read_text(errors='replace');assert not re.search(r'WARNING.*(?:exact CDC|did not resolve)',text)
 rpt=P/f'outflow/Ti60_Demo.{stage}.rpt';text=rpt.read_text()
 resource={k:int(re.search(v,text)[1]) for k,v in dict(XLR=r'XLRs:\s*(\d+)',RAM=r'Memory Blocks:\s*(\d+)',DSP=r'DSP Blocks:\s*(\d+)').items()}
 save(O/(stage.upper()+'_RESOURCE.json'),dict(passed=resource['XLR']<=51680 and resource['RAM']<=204 and resource['DSP']<=128,resource=resource,report=rec(rpt)))
 assert resource['XLR']<=51680 and resource['RAM']<=204 and resource['DSP']<=128,resource
 print(stage,resource,flush=True)
save(O/'ROUTE_RESULT.json',dict(passed=True,physical=W.relative_to(R).as_posix()))
