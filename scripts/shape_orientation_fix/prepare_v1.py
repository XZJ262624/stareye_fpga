from pathlib import Path
import json, hashlib, subprocess, time
R=Path(__file__).resolve().parents[2]; O=R/'reports/shape_orientation_fix_20261022'; D=Path(__file__).parent
OLD=R/'reports/shape_standalone_20261021'; P=R/'efinity/shape_orientation_fix_i3'
def rec(p): return dict(path=p.relative_to(R).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def save(p,d): p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(d,indent=2),encoding='utf8')
head=subprocess.check_output(['git','-c','safe.directory=F:/Projects/stareye_fpga','rev-parse','HEAD'],cwd=R,text=True).strip();assert head=='973f6cc2bd997a2f375d1bdb4834ffef8435369c'
old=json.loads((OLD/'SOURCE_MANIFEST.json').read_text());assert len(old)==91
for x in old: assert rec(R/x['path'])==x,x['path']
assert not P.exists();rows=[]
for x in old:
 if not x['path'].startswith('efinity/shape_standalone_i3/'):continue
 src=R/x['path'];dst=P/src.relative_to(R/'efinity/shape_standalone_i3');dst.parent.mkdir(parents=True,exist_ok=True);dst.write_bytes(src.read_bytes());rows.append(dict(before=x,after=rec(dst)))
sensor=P/'src/cmos_i2c/I2C_AR0135_1280720_Config.v';s=sensor.read_bytes();a=b"{16'h3040, 16'h8000}";assert s.count(a)==1;sensor.write_bytes(s.replace(a,b"{16'h3040, 16'hC000}"))
save(O/'PARENT_SOURCE_MANIFEST.json',old);save(O/'PROJECT_DERIVATION.json',dict(parent=head,copies=rows,one_bit_change=dict(path=rec(sensor),index=18,address='3040',old='8000',new='C000',xor='4000'),unchanged_rtl_references=[x for x in old if x['path'].startswith('rtl/')],project_relative_paths_unchanged=True))
for n in ['COMPILE_SOURCE_FILES.json','STANDALONE_EXACT_GROUPS.json']:
 s=(OLD/n).read_text().replace('efinity/shape_standalone_i3/','efinity/shape_orientation_fix_i3/');(O/n).write_text(s)
# Reuse tested tools, explicitly relocating output/project paths. No old source/report is modified.
names=['common.py','standalone_physical_runtime.py','build_physical_v1.py','build_physical_v2.py','prepare_query_v1.py','prepare_query_v2.py','native_sta_v2.py','run_full_sta_manager_v1.py','final_audit_manager_v1.py','audit_metadata_fields_v1.py','audit_external_v1.py','audit_shape_ram_addresses_v1.py','audit_contract_sta_v1.py','pixel_mapped_cones_v2_derived.py','audit_native_clocks_v1.py','audit_native_clocks_v2.py','audit_native_clocks_v3.py','generate_offline_image_v1.py']
tools=[]
for n in names:
 src=R/'scripts/shape_standalone'/n;s=src.read_text().replace('reports/shape_standalone_20261021','reports/shape_orientation_fix_20261022').replace('efinity/shape_standalone_i3','efinity/shape_orientation_fix_i3')
 if n=='build_physical_v1.py':
  line="for n in ['CORE_GATE_RECEIPT.json','COMPONENT_GATE_RECEIPT.json','CONTROLS_OSD_GATE_RECEIPT.json','SYSTEM_PROBE_RECEIPT.json']:assert json.loads((O/n).read_text())['passed'],n"
  assert line in s;s=s.replace(line,"assert json.loads((O/'I2C_GATE_RECEIPT.json').read_text())['passed']\nverify(json.loads((O/'PARENT_SOURCE_MANIFEST.json').read_text()))")
 if n=='common.py':
  s=s.replace("save(O/'HEARTBEAT.json',dict(status='RUNNING',running=True,phase=phase,updated_unix=time.time(),Codex_observed_active=True,hardware_next=False,**kw))","save(O/'HEARTBEAT.json',dict(status='RUNNING',running=True,phase=phase,updated_unix=time.time(),hardware_next=False,**kw))")
 if n=='final_audit_manager_v1.py':
  s=s.replace("'RECOVERY_IMPORT_PROVENANCE.json',",'')
  s=s.replace('documented exact dead-diagnostic/procedure API recovery','unchanged parent constraints and fresh endpoint binding')
 if n=='audit_native_clocks_v3.py':
  s=s.replace("earlier_errors='v1 assumed everyRAM has physicalWCLK; v2 additionally assumed everyDSP has physicalCLK. Neither produced a PASS.","earlier_errors='Historical parent tool development only: v1 assumed everyRAM has physicalWCLK; v2 assumed everyDSP has physicalCLK.")
 dst=D/n;assert not dst.exists();dst.write_text(s,encoding='utf8');compile(s,str(dst),'exec');tools.append(dict(before=rec(src),after=rec(dst)))
save(O/'TOOL_DERIVATION.json',dict(records=tools,relocations=['reports/shape_standalone_20261021 -> reports/shape_orientation_fix_20261022','efinity/shape_standalone_i3 -> efinity/shape_orientation_fix_i3'],build_prerequisite='New actual I2C gate + exact 91 parent source hashes; prior video suite remains parent evidence, not rerun/new PASS.'))
T=R/'tb/shape_orientation_fix';T.mkdir(parents=True,exist_ok=True)
src=R/'efinity/shape_standalone_i3/src/cmos_i2c/I2C_AR0135_1280720_Config.v'
(T/'reference_lut.v').write_bytes(src.read_bytes().replace(b'module\tI2C_AR0135_1280720_Config',b'module\treference_lut'))
save(O/'HEARTBEAT.json',dict(status='RUNNING',running=True,phase='I2C_TEST_PREPARE',updated_unix=time.time(),hardware_next=False))
print('PREPARED_NEW_PROJECT_ONE_BIT_ONLY',len(rows),len(old))
