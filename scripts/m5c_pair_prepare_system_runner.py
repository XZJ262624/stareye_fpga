from pathlib import Path
import json,hashlib
R=Path.cwd();P=R/'reports/m5c_shadow_stats_20261016/system_134939/run_system_persistent.py';F=R/'reports/m5c_pair_capture_20261016/system_fixture_v4';s=P.read_text().replace("R=Path(__file__).resolve().parents[3];D=Path(__file__).resolve().parent/'run';D.mkdir()", "R=Path(__file__).resolve().parents[3];D=Path(sys.argv[1]).resolve();D.mkdir(exist_ok=False)")
a=s.index('sources=');z=s.index('\ndef rec',a)
s=s[:a]+'''sources=sorted((R/'rtl/m5c_fusion').glob('*.sv'))+sorted((R/'rtl/m5c_fusion/m5a_copy').glob('*.v'))+sorted((R/'rtl/m5c_pair_diag').glob('*.sv'))+[R/'reports/m5c_pair_capture_20261016/system_fixture_v4/tb_pair_system.sv',R/'tb/m5c_fusion/m5c1b_ddr_service_model.sv',R/'efinity/m5c_fusion_i3/src/lcd_driver.v',R/'reports/m5c1b_fusion_integration/osd_reference/m5a_osd_baseline_reference.v']
'''+s[z:]
s=s.replace('m5c_shadow_check_system.py','m5c_pair_check_system.py').replace("R/'scripts/m5c_shadow_finish_system.py',", "R/'scripts/m5c_pair_decode.py',R/'scripts/m5b1_uart_decode.py',")
s=s.replace('reports/m5c_shadow_stats_20261016/system_fixture','reports/m5c_pair_capture_20261016/system_fixture_v4').replace('tb_shadow_system','tb_pair_system').replace('-gBG_REQUEST_CYCLES=1000000','-gBG_REQUEST_CYCLES=96000000').replace('assert len(sys.argv)==1, "No parameter overrides"','assert len(sys.argv)==3, "run-directory and qualified-resource-RESULT required"\ngate=json.loads(Path(sys.argv[2]).read_text());assert gate["status"]=="PASS_STAGE" and gate["resources"]["pass"], "G1 resource gate required"')
s=s.replace("'M5C1B_PASS' in text", "'PAIR_FULL_VIDEO_PASS' in text")
a=s.index(" state('STRICT_SOFTWARE_RUNNING')");z=s.index('\nexcept BaseException:',a)
s=s[:a]+''' state('STRICT_SOFTWARE_RUNNING')
 with (D/'completion_worker.log').open('wb') as f:
  q=subprocess.run([sys.executable,'-B',str(R/'scripts/m5c_pair_check_system.py'),str(D)],stdout=f,stderr=subprocess.STDOUT)
 assert q.returncode==0,'Completion software failure'
 end=json.loads((D/'PAIR_SOFTWARE_ORACLE.json').read_text());assert end['status']=='PASS_ACTUAL_FULL_VIDEO_PAIR_AND_ORIGINAL_END'
 state('PASS_SYSTEM_NATIVE_AND_INDEPENDENT_SOFTWARE',completion=end)
'''+s[z:]
# No normal elapsed-time kill; 4s DUT watchdog remains authoritative. User waiting threshold is not kill permission.
a=s.index('    if time.time()>deadline:');z=s.index('    time.sleep(5)',a);s=s[:a]+s[z:]
(F/'run_system_persistent.py').write_text(s)
import ast
ast.parse(s);ast.parse((R/'scripts/m5c_pair_check_system.py').read_text())
(F/'EXECUTION_PLAN.json').write_text(json.dumps(dict(status='PREPARED_NOT_RUN',G1_required=True,BG_REQUEST_CYCLES=96000000,HEALTHY_FRAMES=2,all7healthy_modes_required=True,SERVICE_CYCLES=384,CAMERA_BLANK_CYCLES=478667,seed=50708,UART_CLOCK_HZ=960000,actual_DUT_watchdog_sim_seconds=4,wall_policy='No normal elapsed kill;120min user handoff threshold not native timeout',remaining='Bind final source and resource result at launch; current map/place not passed yet',runner_sha256=hashlib.sha256((F/'run_system_persistent.py').read_bytes()).hexdigest()),indent=2));print('PREPARED_ONLY')
