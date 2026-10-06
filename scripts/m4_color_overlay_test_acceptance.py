"""Actual CLI negatives and isolated RTL mutants; production sources stay intact."""
from pathlib import Path
import copy,json,subprocess,sys,re,hashlib,shutil
from m4_color_overlay_validate import collect,R,ROOT,V
O=R/'negative_cases';O.mkdir(parents=True,exist_ok=True);base=collect();v=V[0];cases=[]
def add(n,f):
 b=copy.deepcopy(base);f(b);cases.append((n,b))
add('missing_variant',lambda b:b['variants'].pop(v))
add('sim_status',lambda b:b['sim'].update(status='FAIL'))
add('sim_not_executed',lambda b:b['sim'].update(commands=[]))
add('missing_sim_log',lambda b:b['sim']['commands'][0]['log'].update(path='reports/m4_color_overlay_i3/negative_cases/missing.log'))
add('sim_exit',lambda b:b['sim']['commands'][0].update(exit_code=1))
add('incomplete_720p',lambda b:next(x for x in b['sim']['cases'] if x['name']=='720p').update(pixels=1))
add('wrong_latency',lambda b:next(x for x in b['sim']['cases'] if x['name']=='720p').update(latency=3317))
add('sim_source_changed',lambda b:b['sim']['sources_after'][0].update(sha256='0'*64))
add('build_exit',lambda b:b['variants'][v]['build'].update(exit_code=1))
add('missing_input',lambda b:b['variants'][v]['after'].pop())
add('changed_input',lambda b:b['variants'][v]['after'][0].update(sha256='0'*64))
add('audit_exit',lambda b:b['variants'][v]['audit'].update(exit_code=1))
add('changed_final_database',lambda b:b['variants'][v]['audit'].update(original_unchanged=False))
add('wrong_implementation',lambda b:b['variants'][v]['audit']['clone_initial_hashes'].update({'work_pnr/Ti60_Demo.lbf':'0'*64}))
add('missing_timing_report',lambda b:b['variants'][v]['audit']['reports'].pop())
add('wrong_sdc',lambda b:b['variants'][v]['audit'].update(sdc_sha256='0'*64))
add('wrong_tcl',lambda b:b['variants'][v]['audit'].update(tcl_sha256='0'*64))
add('stale_bitstream',lambda b:next(x for x in b['variants'][v]['build']['outputs'] if x['path'].endswith('/Ti60_Demo.bit')).update(sha256='0'*64))
rows=[]
for name,b in [('positive',base)]+cases:
 p=O/(name+'.json');p.write_text(json.dumps(b));cmd=[sys.executable,'-B',str(ROOT/'scripts/m4_color_overlay_validate.py'),'--bundle',str(p)];x=subprocess.run(cmd,capture_output=True,text=True);expected=0 if name=='positive' else 1
 assert x.returncode==expected and ('M4_ACCEPTANCE_PASS' if expected==0 else 'M4_ACCEPTANCE_FAIL') in x.stdout,(name,x.stdout,x.stderr)
 rows.append(dict(name=name,exit_code=x.returncode,expected_exit=expected,diagnostic=x.stdout.strip(),command=cmd));print('M4_CLI_NEGATIVE',name,x.returncode,flush=True)
text=(R/v/'final_audit/m4_setup.rpt').read_text()
for name,t in [('negative_slack',re.sub(r'(^Slack\s*:\s*)\S+',r'\g<1>-0.001',text,count=1,flags=re.M)),('wrong_timing_model',text.replace('Timing Model: I3','Timing Model: C4')),('empty_timing','')]:
 p=O/(name+'.txt');p.write_text(t);cmd=[sys.executable,'-B','-c',"import pathlib,sys;from m3_sobel_core_validate import parse_timing;parse_timing(pathlib.Path(sys.argv[1]).read_text(),'setup')",str(p)];x=subprocess.run(cmd,cwd=ROOT/'scripts',capture_output=True,text=True);assert x.returncode!=0,name;rows.append(dict(name=name,exit_code=x.returncode,expected_exit=1,diagnostic=x.stderr.strip().splitlines()[-1]))
(R/'negative_acceptance.json').write_text(json.dumps(rows,indent=2))
M=Path('E:/Modelsim_10.1c/win64');prod=[p for d in ['rtl/m3_sobel_core','rtl/m32_median_integration','rtl/m4_color_overlay'] for p in (ROOT/d).glob('*.v')]+[ROOT/'rtl/m31_sobel_controls/m31_osd.v']+[ROOT/'efinity/m4_color_overlay_i3/src/hdmi_ip'/n for n in ('rgb2dvi.v','tmds_channel.v')]+list((ROOT/'tb/m4_color_overlay').glob('*.sv'))
def rec(p):return dict(path=p.relative_to(ROOT).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
before=[rec(p) for p in prod];mutants=[
 ('raw_delay_minus_one','m4_stream_top.v','.DELAY(H_TOTAL)','.DELAY(H_TOTAL-1)','tb_m4_stream'),
 ('raw_delay_plus_one','m4_stream_top.v','.DELAY(H_TOTAL)','.DELAY(H_TOTAL+1)','tb_m4_stream'),
 ('rgb_channel_swap','m4_colorize.v',"24'hff0000","24'h0000ff",'tb_m4_colorize'),
 ('invalid_window_red','m4_colorize.v','(edge_valid && edge_binary)','(edge_binary)','tb_m4_colorize'),
 ('median_background','m4_stream_top.v','.aligned_raw(out_raw)','.aligned_raw(u_m32.median_gray)','tb_m4_stream'),
 ('mag_corrupted','m4_colorize.v','{3{legacy_gray}}',"((mode==1)?24'd0:{3{legacy_gray}})",'tb_m4_colorize'),
 ('mag_depends_threshold','m4_stream_top.v','.legacy_gray(out_legacy)',".legacy_gray((out_mode==1 && out_threshold!=0)?8'd0:out_legacy)",'tb_m4_stream'),
 ('midframe_settings','m4_controls.v','if(frame_start) begin threshold<=pending_threshold;mode<=pending_mode;end','begin threshold<=pending_threshold;mode<=pending_mode;end','tb_m4_controls'),
 ('osd_hidden','m4_osd.v',"ink?24'hffffff:24'h000000",'rgb','tb_m4_stream')]
mutants.append(('hdmi_wrong_red_lane','rgb2dvi.v','vid_pData[23:16]','vid_pData[7:0]','tb_m4_hdmi_channels'))
results=[]
for name,file,old,new,top in mutants:
 d=O/name;d.mkdir(exist_ok=True);src=d/'sources';src.mkdir(exist_ok=True)
 copied=[]
 for p in prod:
  s=p.read_text();
  if p.name==file:assert old in s,(name,old);s=s.replace(old,new,1)
  q=src/p.name;q.write_text(s);copied.append(q)
 def tool(cmd,log):
  with (d/log).open('wb') as f:p=subprocess.run(list(map(str,cmd)),cwd=d,stdout=f,stderr=subprocess.STDOUT,timeout=300)
  return p.returncode,(d/log).read_text(errors='replace')
 if not (d/'work').exists():assert tool([M/'vlib.exe','work'],'vlib.log')[0]==0
 assert tool([M/'vlog.exe','-sv','-work','work',*copied],'compile.log')[0]==0,name
 cmd=[M/'vsim.exe','-c','-novopt','-onfinish','stop','work.'+top]
 if top=='tb_m4_stream':cmd+=['-gFRAMES=31','+DIR='+str(R/'sim/generated/small')]
 cmd+=['-do',ROOT/'tb/m4_color_overlay/run.do'];code,log=tool(cmd,'run.log');assert code!=0 and ('Fatal:' in log or '** Error:' in log),(name,code,log[-2000:])
 results.append(dict(name=name,exit_code=code,rejected=True,command=list(map(str,cmd)),mutation=dict(file=file,old=old,new=new),sources=[rec(p) for p in copied],log=rec(d/'run.log')));print('M4_RTL_MUTANT_REJECTED',name,flush=True)
assert before==[rec(p) for p in prod]
(R/'rtl_negative_acceptance.json').write_text(json.dumps(results,indent=2))
(R/'negative_binding.json').write_text(json.dumps(dict(sources=[rec(Path(__file__)),rec(ROOT/'scripts/m4_color_overlay_validate.py'),rec(ROOT/'scripts/m3_sobel_core_validate.py')],artifacts=[rec(R/'negative_acceptance.json'),rec(R/'rtl_negative_acceptance.json')],production_sources_before=before,production_sources_after=before),indent=2))
print('M4_NEGATIVES_PASS cli='+str(len(rows)-1)+' rtl='+str(len(results)),flush=True)
