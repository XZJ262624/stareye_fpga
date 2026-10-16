from pathlib import Path
import json,hashlib,datetime,shutil
R=Path(__file__).resolve().parents[1];B=R/'reports/m5c_shadow_stats_20261016';F=B/'system_fixture';F.mkdir(exist_ok=True);assert not list(F.iterdir());P=R/'reports/m5c_diagnostics/stage2_system_fixture_v2'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
s=(P/'tb_diag_system.sv').read_text().replace('tb_diag_system','tb_shadow_system').replace('m5c_diag_observer_v2','m5c_diag_observer_v3')
s=s.replace('    wire diag_ctx,','    wire shvalid,sh64,sh128,shstrong,shillegal;\n    wire diag_ctx,')
s=s.replace('.diag_tag_good(diag_tag)', '.diag_shadow_valid(shvalid),.diag_shadow64(sh64),.diag_shadow128(sh128),.diag_strong_loss(shstrong),.diag_illegal(shillegal),.diag_tag_good(diag_tag)')
s=s.replace('        .mode(out_mode),.admit_mode', '        .shadow_valid(shvalid),.shadow64(sh64),.shadow128(sh128),.strong_loss_row(shstrong),.illegal_row(shillegal),\n        .mode(out_mode),.admit_mode')
assert '.shadow_valid(shvalid)' in s
(F/'tb_shadow_system.sv').write_text(s)
for n in ['end_declarations.svh','end_protocol.svh']:shutil.copyfile(P/n,F/n)
(F/'DERIVATION.json').write_text(json.dumps(dict(parents=[rec(P/n) for n in ['tb_diag_system.sv','end_declarations.svh','end_protocol.svh']],derived=[rec(F/n) for n in ['tb_shadow_system.sv','end_declarations.svh','end_protocol.svh']],changes='Only new diagnostic wires/schema2observer/module symbol. All7healthy modes,2normaldiagnostics,realDDR/BFS/originalwire/end/drain gates retained.'),indent=2))
p=R/'scripts/m5c_diag_check_system.py';s=p.read_text().replace('payload[0]&0xffffffff==1','payload[0]&0xffffffff==2').replace('all(x==0 for x in payload[26:])','payload[29]>>32==0 and payload[30:]==[0,0]')
s=s.replace('  assert payload[25]==0;normal+=1', '  extension=[payload[26]&0xffffffff,payload[26]>>32,payload[27]&0xffffffff,payload[27]>>32,payload[28]&0xffffffff,payload[28]>>32,payload[29]&0xffffffff]\n  assert extension==[0,0,0,7,7,0,0],(seq,extension)\n  assert payload[25]==0;normal+=1')
s=s.replace('mode=mode,flags=flags,counts=counts','mode=mode,flags=flags,counts=counts,shadow_fields=payload[26:30]')
(R/'scripts/m5c_shadow_check_system.py').write_text(s)
p=R/'scripts/m5c_diag_finish_system.py';s=p.read_text().replace('m5c_diag_check_system.py','m5c_shadow_check_system.py')
s=s.replace("['STATE.json','MANIFEST.json']","['STATE.json','MANIFEST.json','HEARTBEAT.json','HEARTBEAT.tmp','completion_worker.log']")
s=s.replace("dict(records=[rec(p) for p in sorted(files)])","dict(records=[rec(p) for p in sorted(files)],excluded_live_epilogue=['HEARTBEAT.json','completion_worker.log'],scope='Stable completed-native/raw/software/input files; manager epilogue separately post-exit.')")
(R/'scripts/m5c_shadow_finish_system.py').write_text(s)
O=B/('system_'+datetime.datetime.now().strftime('%H%M%S'));O.mkdir()
parent=R/'reports/m5c_diagnostics/stage2_system_persistent_20261015_201619/run_system_persistent.py';s=parent.read_text()
s=s.replace('reports/m5c_diagnostics/stage2_ram_20261015_161311/observer_single_write.sv','rtl/m5c_diagnostics/m5c_diag_observer_v3.sv').replace('reports/m5c_diagnostics/stage2_system_fixture_v2','reports/m5c_shadow_stats_20261016/system_fixture').replace('tb_diag_system','tb_shadow_system').replace('m5c_diag_check_system.py','m5c_shadow_check_system.py').replace('m5c_diag_finish_system.py','m5c_shadow_finish_system.py')
(O/'run_system_persistent.py').write_text(s)
(O/'DERIVATION.json').write_text(json.dumps(dict(parent=rec(parent),runner=rec(O/'run_system_persistent.py'),fixture=rec(F/'DERIVATION.json'),scope='Same modelparameters/2simsecondDUTwatchdog/14400wall/all7modes. New schema2 binding; persistent heartbeat and isolated output. No native result inherited.',inputs=[rec(R/n) for n in ['scripts/m5c_shadow_check_system.py','scripts/m5c_shadow_finish_system.py']]),indent=2));print(O)
