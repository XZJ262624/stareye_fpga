"""Audit an isolated copy of the M5B1 implementation database under actual I3.

The I3 device model supplies its characterized setup/hold timing bounds. Report
counts are clock-pair and endpoint coverage, not independent PVT corner counts.
"""
from pathlib import Path
import json,hashlib,shutil,subprocess,datetime,argparse,re
R=Path(__file__).resolve().parents[1];W=R/'efinity/m5b1_global_canny_i3'
def digest(p):return dict(bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def snap():return {p.relative_to(W).as_posix():digest(p) for d in ('outflow','work_pnr') for p in (W/d).rglob('*') if p.is_file()}
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--preflight',action='store_true');a=ap.parse_args()
 stamp=datetime.datetime.now().strftime('%Y%m%d_%H%M%S');before=snap();C=W/'work'/('sta_'+stamp);C.mkdir(parents=True)
 O=R/'reports/m5b1_global_canny_i3/review_fix_264962e0/final'/('sta_preflight_'+stamp if a.preflight else 'final_sta');O.mkdir(parents=True,exist_ok=True)
 for d in ('outflow','work_pnr'):shutil.copytree(W/d,C/d)
 for n in ('Ti60_Demo.xml','Ti60_Demo.peri.xml','Ti60_Demo_I3.sdc'):shutil.copy2(W/n,C/n)
 assert all(digest(C/p)==v for p,v in before.items())
 (C/'work_pnr/sdc_file_list').write_text(str(C/'Ti60_Demo_I3.sdc')+'\n')
 tcl='''set_timing_model I3
puts "M5B1_ACTUAL_MODEL [get_timing_model]"
report_timing -setup -npaths 100 -nworst 1 -detail full_path -file m5b1_setup.rpt
report_timing -hold -npaths 100 -nworst 1 -detail full_path -file m5b1_hold.rpt
check_timing -verbose -file m5b1_check.rpt
report_clocks -file m5b1_clocks.rpt
foreach a [get_clocks {*} ] {
 foreach b [get_clocks {*} ] {
  foreach k {setup hold} {
   puts "M5B1_REQUEST_CLOCK_PAIR $a $b $k"
   report_timing -$k -from_clock $a -to_clock $b -npaths 10 -nworst 1 -detail full_path -file m5b1_${a}_${b}_${k}.rpt
  }
 }
}
foreach k {setup hold} {
 report_timing -$k -to [get_ports {addr* ba* ras cas we cke odt cs o_dq* o_dm* o_dqs*}] -npaths 200 -nworst 1 -detail full_path -file m5b1_ddr_output_${k}.rpt
 report_timing -$k -from [get_ports {i_dq* i_dqs*}] -npaths 200 -nworst 1 -detail full_path -file m5b1_ddr_input_${k}.rpt
 report_timing -$k -to [get_ports {hdmi_txd* hdmi_txc*}] -npaths 100 -nworst 1 -detail full_path -file m5b1_hdmi_${k}.rpt
}
foreach half {hi lo} {
 for {set lane 0} {$lane < 16} {incr lane} {
  set port [format {i_dq_%s[%d]} $half $lane]
  foreach k {setup hold} {report_timing -$k -from [get_ports $port] -npaths 1 -nworst 1 -detail full_path -file m5b1_lane_${half}_${lane}_${k}.rpt}
 }
}
'''
 # Query the same exact pin whitelist; the installed grouped-regexp path
 # lookup was independently observed to fail while exact names succeed.
 manifest=json.loads((R/'reports/m5b1_global_canny_i3/review_fix_264962e0/final/CDC_PIN_MANIFEST.json').read_text())
 assert digest(W/'outflow/Ti60_Demo.map.v')['sha256']==manifest['map_sha256'],'Regenerate and re-audit exact pins against final map'
 tcl+='proc audit_exact {selectors} {set r {}; foreach s $selectors {set p [get_pins -regexp $s]; if {[llength $p]!=1} {error "audit pin mismatch $s"}; set r [concat $r $p]}; return $r}\n'
 for key,pins in manifest['groups'].items():
  tcl+=f'set audit_{key} [audit_exact {{\n'+''.join(' {'+'^'+re.escape(pin)+'$'+'}\n' for pin in pins)+'}]\n'
 for src,dst in manifest['gray_pairs']+manifest['mailbox_pairs']:
  count=len(manifest['groups'][dst])
  tcl+=f'report_timing -setup -from $audit_{src} -to $audit_{dst} -npaths {count} -nworst 1 -detail full_path -file m5b1_cdc_{dst}.rpt\n'
 for chain in ('ds','ps','fs','rs'):
  source='^'+re.escape(f'u_m5b1/bridge/{chain}[0]~FF|CLK')+'$';dest='^'+re.escape(f'u_m5b1/bridge/{chain}[1]~FF|D')+'$'
  for kind in ('setup','hold'):
   tcl+=f'report_timing -{kind} -from [audit_exact {{{{{source}}}}}] -to [audit_exact {{{{{dest}}}}}] -npaths 1 -detail full_path -file m5b1_bridge_{chain}_{kind}.rpt\n'
 tcl+='puts "M5B1_STA_COMPLETE"\n'
 if a.preflight:
  cdc=(C/'Ti60_Demo_I3.sdc').read_text().split('# M5B1 explicit CDC endpoints.',1)[1]
  (C/'cdc_only.tcl').write_text('# M5B1 explicit CDC endpoints.'+cdc)
  tcl='source cdc_only.tcl\n'+tcl
 (C/'audit.tcl').write_text(tcl)
 cmd=['E:/Efinity/2025.1/bin/efx_sta.exe','--prj','Ti60_Demo','--output_dir','outflow','--tclsh','audit.tcl']
 (C/'audit.bat').write_text('@echo off\ncall E:\\Efinity\\2025.1\\bin\\setup.bat\nE:\\Efinity\\2025.1\\bin\\efx_sta.exe --prj Ti60_Demo --output_dir outflow --tclsh audit.tcl\nexit /b %errorlevel%\n')
 x=subprocess.run(['cmd','/c',str(C/'audit.bat')],cwd=C,capture_output=True);(O/'audit.log').write_bytes(x.stdout+x.stderr)
 reports=[]
 for p in sorted((C/'outflow').glob('m5b1_*.rpt')):shutil.copy2(p,O/p.name);reports.append(dict(path=p.name,**digest(p)))
 after=snap();(O/'audit.tcl').write_text(tcl)
 result=dict(preflight=a.preflight,command=cmd,exit_code=x.returncode,complete=b'M5B1_STA_COMPLETE' in x.stdout,original_unchanged=before==after,original_before=before,original_after=after,clone=str(C),sdc=digest(C/'Ti60_Demo_I3.sdc'),reports=reports)
 slacks=[]
 for p in O.glob('m5b1_*.rpt'):slacks += [float(v) for v in re.findall(r'Slack\s*:\s*(-?\d+(?:\.\d+)?)',p.read_text(errors='replace'))]
 result['minimum_reported_slack_ns']=min(slacks) if slacks else None
 cdc=[]
 for src,dst in manifest['gray_pairs']+manifest['mailbox_pairs']:
  report=(O/f'm5b1_cdc_{dst}.rpt').read_text();paths=[]
  for block in re.split(r'\+\+\+\+ Path \d+ \++',report)[1:]:
   def number(pattern):return float(re.search(pattern,block).group(1))
   paths.append(dict(endpoint=re.search(r'Path End\s*:\s*(\S+)',block).group(1),data_ns=number(r'Clock To Q \+ Data Path Delay\s*:\s*([\d.]+)'),launch_ns=number(r'Launch Clock Path Delay\s*:\s*([\d.]+)'),slack_ns=number(r'Slack\s*:\s*(-?[\d.]+)')))
  assert sorted(p['endpoint'] for p in paths)==sorted(manifest['groups'][dst]),(dst,'missing/duplicate CDC timing endpoint')
  arrivals=[p['launch_ns']+p['data_ns'] for p in paths];data=[p['data_ns'] for p in paths]
  row=dict(group=dst,paths=len(paths),max_clock_to_Q_plus_data_ns=max(data),data_span_ns=max(data)-min(data),arrival_skew_ns=max(arrivals)-min(arrivals),minimum_slack_ns=min(p['slack_ns'] for p in paths),budget_ns=5.0,fastest_source_period_ns=10.0)
  assert max(data)<5 and row['arrival_skew_ns']<5 and row['minimum_slack_ns']>=0,row
  cdc.append(row)
 check=(O/'m5b1_check.rpt').read_text();counts={k:int(re.search(r'checking '+k+r' \((\d+)\)',check).group(1)) for k in ('no_clock','unconstrained_internal_endpoints','multiple_clock','no_input_delay','no_output_delay')}
 assert all(counts[k]==0 for k in ('no_clock','unconstrained_internal_endpoints','multiple_clock')),counts
 result['cdc_physical_groups']=cdc;result['check_timing']=counts
 (O/'binding.json').write_text(json.dumps(result,indent=2));print('M5B1_STA',O,'exit',x.returncode,'reports',len(reports),'min_slack',result['minimum_reported_slack_ns'],flush=True)
 assert before==after and x.returncode==0 and result['complete']
 if not a.preflight:assert slacks and min(slacks)>=0
if __name__=='__main__':main()
