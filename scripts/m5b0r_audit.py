"""Audit immutable diagnostic DB clone under actual I3; bind every report."""
from pathlib import Path
import json,hashlib,shutil,subprocess,datetime
ROOT=Path(__file__).resolve().parents[1];W=ROOT/'efinity/m5b0r_ddr_address_diag_i3';R=ROOT/'reports/m5b0r_ddr_admission/final_audit'
def rec(p):return dict(bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def snap():return {p.relative_to(W).as_posix():rec(p) for d in ('outflow','work_pnr') for p in (W/d).rglob('*') if p.is_file()}
before=snap();C=W/'work'/('audit_'+datetime.datetime.now().strftime('%Y%m%d_%H%M%S'));C.mkdir(parents=True);R.mkdir(parents=True,exist_ok=True)
for d in ('outflow','work_pnr'):shutil.copytree(W/d,C/d)
for n in ('M5B0R_DdrDiag.xml','M5B0R_DdrDiag.peri.xml','M5B0R_DdrDiag.sdc'):shutil.copy2(W/n,C/n)
assert all(rec(C/k)==v for k,v in before.items())
(C/'work_pnr/sdc_file_list').write_text(str(C/'M5B0R_DdrDiag.sdc')+'\n')
tcl='set_timing_model I3\nputs "ACTUAL_MODEL [get_timing_model]"\nreport_timing -setup -npaths 100 -nworst 1 -detail full_path -file diag_setup.rpt\nreport_timing -hold -npaths 100 -nworst 1 -detail full_path -file diag_hold.rpt\ncheck_timing -verbose -file diag_check.rpt\nreport_clocks -file diag_clocks.rpt\nforeach a {tdqss_clk core_clk tac_clk twd_clk clk_sys clk_24m} {\n foreach b {tdqss_clk core_clk tac_clk twd_clk clk_sys clk_24m} {\n  foreach k {setup hold} {\n   report_timing -$k -from_clock $a -to_clock $b -npaths 10 -nworst 1 -detail full_path -file diag_${a}_${b}_${k}.rpt\n  }\n }\n}\nforeach k {setup hold} {\n report_timing -$k -to [get_ports {addr* ba* ras cas we cke odt cs o_dq* o_dm* o_dqs*}] -npaths 200 -nworst 1 -detail full_path -file diag_ddr_output_${k}.rpt\n report_timing -$k -from [get_ports {i_dq* i_dqs*}] -npaths 200 -nworst 1 -detail full_path -file diag_ddr_input_${k}.rpt\n}\nforeach half {hi lo} {\n for {set lane 0} {$lane < 16} {incr lane} {\n  set port [format {i_dq_%s[%d]} $half $lane]\n  foreach k {setup hold} {\n   report_timing -$k -from [get_ports $port] -npaths 1 -nworst 1 -detail full_path -file diag_lane_${half}_${lane}_${k}.rpt\n  }\n }\n}\n'
proof=json.loads((ROOT/'reports/m5b0r_ddr_admission/CONSTRAINT_DERIVATION.json').read_text())
import re
for name in proof['reset_sync_async_SR_pins']:
 pattern='^'+re.escape(name+'|SR')+'$'
 tcl+='set selected [get_pins -regexp {'+pattern+'}]\n'
 tcl+='if {[llength $selected] != 1} {error "reset endpoint selection mismatch"}\n'
 tcl+='puts "VERIFIED_ASYNC_SR $selected"\n'
tcl+='puts "M5B0R_AUDIT_COMPLETE"\n';(C/'audit.tcl').write_text(tcl)
command=['E:/Efinity/2025.1/bin/efx_sta.exe','--prj','M5B0R_DdrDiag','--output_dir','outflow','--tclsh','audit.tcl']
x=subprocess.run(command,cwd=C,capture_output=True);(R/'audit.log').write_bytes(x.stdout+x.stderr)
reports=[]
for p in sorted((C/'outflow').glob('diag_*.rpt')):
 shutil.copy2(p,R/p.name);reports.append(dict(path=p.name,**rec(p)))
after=snap();binding=dict(exit_code=x.returncode,original_unchanged=before==after,original_before=before,original_after=after,clone=str(C),sdc=rec(C/'M5B0R_DdrDiag.sdc'),tcl=rec(C/'audit.tcl'),reports=reports,stdout_complete=b'M5B0R_AUDIT_COMPLETE' in x.stdout)
(R/'binding.json').write_text(json.dumps(binding,indent=2));assert before==after
assert x.returncode==0 and binding['stdout_complete'],(x.returncode,x.stdout[-2000:],x.stderr[-2000:])
# Efinity does not create a report file for a clock pair with no paths.
# Require every DDR lane and global/I/O report; record unconnected clock pairs
# rather than fabricating empty reports or mechanically requiring 144 files.
required=['diag_setup.rpt','diag_hold.rpt','diag_check.rpt','diag_clocks.rpt']
required += ['diag_ddr_'+d+'_'+k+'.rpt' for d in ('input','output') for k in ('setup','hold')]
required += [f'diag_lane_{h}_{i}_{k}.rpt' for h in ('hi','lo') for i in range(16) for k in ('setup','hold')]
actual={x['path'] for x in reports};assert set(required)<=actual
expected_pairs=[f'diag_{a}_{b}_{k}.rpt' for a in ('tdqss_clk','core_clk','tac_clk','twd_clk','clk_sys','clk_24m') for b in ('tdqss_clk','core_clk','tac_clk','twd_clk','clk_sys','clk_24m') for k in ('setup','hold')]
binding['requested_reports']=144;binding['no_path_clock_pair_reports']=sorted(set(expected_pairs)-actual)
(R/'binding.json').write_text(json.dumps(binding,indent=2))
print('M5B0R_AUDIT_PASS',len(reports),'reports; no-path pairs',len(binding['no_path_clock_pair_reports']))
