from pathlib import Path
import json,hashlib
R=Path.cwd();F=R/'reports/m5c_pair_capture_20261016/current_qualification_revision';F.mkdir();paths=['rtl/m5c_pair_diag/m5c_pair_capture.sv','rtl/m5c_pair_diag/m5c_pair_system.sv','efinity/m5c_pair_diag_i3/example_top.v'];rows=[]
def rec(p):b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
for i,rel in enumerate(paths):
 p=R/rel;b=p.read_bytes();before=F/(str(i)+'_'+p.name);before.write_bytes(b);s=p.read_text()
 if i==0:
  s=s.replace(' input ce,frame_sof,',' input source_tap_valid,source_tap_qualified,\n input ce,frame_sof,')
  needle=' wire prst=release_pix[1];';assert needle in s;s=s.replace(needle,needle+'''
 // Raw tap qualification is frame-sticky and retained through the delayed final tail.
 reg source_frame_qualified;
 always @(posedge pix_clk or negedge prst)
  if(!prst)source_frame_qualified<=0;
  else if(ce&&frame_sof)source_frame_qualified<=source_tap_valid&&source_tap_qualified;
  else if(ce&&source_tap_valid&&!source_tap_qualified)source_frame_qualified<=0;
 wire current_source_qualified=frame_sof?(source_tap_valid&&source_tap_qualified):source_frame_qualified;
''')
  s=s.replace('frame_admit&&mode_cov&&fusion_enabled&&!kill&&identity_ok&&','frame_admit&&mode_cov&&fusion_enabled&&!kill&&identity_ok&&current_source_qualified&&')
  s=s.replace('if(cancel_sync[1]||kill||!identity_ok||!ce||','if(frame_sof||!current_source_qualified||cancel_sync[1]||kill||!identity_ok||!ce||')
  s=s.replace('if(cancel_sync[1]||kill||!identity_ok)begin reason<=6','if(frame_sof||!current_source_qualified||cancel_sync[1]||kill||!identity_ok)begin reason<=6')
 elif i==1:
  s=s.replace(' input pair_cov,',' input pair_source_tap_valid,pair_source_tap_qualified,\n input pair_cov,');s=s.replace('.ce(fusion_ce),.frame_sof(pair_sof)', '.source_tap_valid(pair_source_tap_valid),.source_tap_qualified(pair_source_tap_qualified),.ce(fusion_ce),.frame_sof(pair_sof)')
 else:s=s.replace('u_m5b1(.pair_cov(', 'u_m5b1(.pair_source_tap_valid(fusion_tap_valid),.pair_source_tap_qualified(fusion_tap_qualified),.pair_cov(')
 p.write_text(s);rows.append(dict(before=rec(before),after=rec(p)))
(F/'DERIVATION.json').write_text(json.dumps(dict(status='IMPLEMENTED_PENDING_TEST',rows=rows,contract='Only real qualified current replay can succeed; validtap qualified loss sticky through finaltail; livequalified during invalidtap ignored; support/domain0 allowed; newfirst beforeoldEOF rejects. OldM5A/rowunchanged.'),indent=2));print('UPDATED3')
