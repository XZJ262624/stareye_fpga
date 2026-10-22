from common import *
import subprocess,datetime,xml.etree.ElementTree as ET
# Preserve the exact first-STA source manifest before refreshing final SDC.
old=O/'physical_20261022_171508/STA_FAILURE_PRESERVED';f=json.loads((old/'FAILURE.json').read_text())
backup=old/'ORIGINAL_SOURCE_MANIFEST.json'
if not backup.exists():
 assert rec(O/'SOURCE_MANIFEST.json')==f['source_manifest']
 backup.write_bytes((O/'SOURCE_MANIFEST.json').read_bytes())
exec(compile((R/'scripts/canny_gaussian_standalone/describe_scope.py').read_text(),'describe_scope.py','exec'))
before=json.loads((O/'physical_20261022_171508/INPUTS_BEFORE_MAP.json').read_text())
drift=[dict(before=x,after=rec(R/x['path'])) for x in before if rec(R/x['path'])!=x]
assert all(x['before']['path'] in [(P/n).relative_to(R).as_posix() for n in ('Ti60_Demo_I3.sdc','Ti60_Demo.xml')] for x in drift),drift
ns={};code=(R/'scripts/canny_gaussian_standalone/fix_xml.py').read_text().replace("(P/'Ti60_Demo.xml').write_text(s,encoding='utf8')",'');exec(compile(code,'reconstruct_original_xml','exec'),ns)
original=ns['s'];original_bytes=original.replace('\n','\r\n').encode('utf8')
xml_before=next(x for x in before if x['path'].endswith('/Ti60_Demo.xml'))
assert hashlib.sha256(original_bytes).hexdigest()==xml_before['sha256'] and len(original_bytes)==xml_before['bytes']
a=ET.fromstring(original);b=ET.parse(P/'Ti60_Demo.xml').getroot()
assert len(a)==len(b) and all(ET.tostring(x)==ET.tostring(y) for x,y in zip(a,b))
attributes={k:dict(before=a.attrib.get(k),after=b.attrib.get(k)) for k in set(a.attrib)|set(b.attrib) if a.attrib.get(k)!=b.attrib.get(k)}
assert set(attributes)<=set('last_change last_run_state last_run_flow config_result_in_sync design_ood place_ood route_ood'.split()),attributes
save(O/'XML_METADATA_DRIFT.json',dict(passed=True,reconstructed_original_exact_hash=xml_before,root_metadata_only=attributes,all_child_elements_equal=True))
save(O/'MAP_SOURCE_BINDING.json',dict(passed=True,inputs=rec(O/'physical_20261022_171508/INPUTS_BEFORE_MAP.json'),production_sources_unchanged_since_map=True,allowed_constraint_and_native_xml_metadata_change=drift,xml_proof=rec(O/'XML_METADATA_DRIFT.json'),final_sources=rec(O/'SOURCE_MANIFEST.json')))
git=['git','-c','safe.directory=F:/Projects/stareye_fpga']
branch=subprocess.check_output(git+['branch','--show-current'],cwd=R,text=True).strip()
head,parent=subprocess.check_output(git+['rev-parse','HEAD','HEAD^'],cwd=R,text=True).split()
assert head=='b5f36414035193ab9c7aa8393732a93e10fe141e' and parent=='9dea12d9f0d29f57aa6d3acb75695da9e0d53d2c'
scope=['rtl/canny_gaussian_standalone','efinity/canny_gaussian_standalone_i3','tb/canny_gaussian_standalone','scripts/canny_gaussian_standalone','reports/canny_gaussian_standalone_fast_20261022']
assert not subprocess.check_output(git+['ls-tree','-r','--name-only',head,'--',*scope],cwd=R,text=True).strip()
save(O/'BASELINE_IDENTITY.json',dict(branch=branch,baseline_head=head,parent=parent,candidate_commit=None,uncommitted=True,scope=scope,baseline_scope='All five new directories absent from baseline HEAD; entire new scope is an addition. FOCUSED_TECHNICAL_DIFF compares separately frozen gaussian working-tree origins, not a committed parent.',git_mutation=False,hardware=False))
net=(P/'outflow/Ti60_Demo.map.v').read_text()
removed=['shadow_tiles','pair_capture','pair_controller','shape_feature','shape_class','shape_detector','telemetry']
assert all(x not in net for x in removed);assert "assign uart_tx_o = 1'b1" in net
save(O/'TRIM_SCOPE_CHECK.json',dict(passed=True,map=rec(P/'outflow/Ti60_Demo.map.v'),absent_synthesized_names=removed,uart='External pin retained; constant idle1; no UART export state machine',retained_safety='m5c_pair_diag_lease and m5c_pair_arbiter retained byte-identically for real slot lease/outstanding B/R ownership. Name alone does not indicate retained pair collection.',source_tieoffs='Display session telemetry_pending=0 because removed consumer; no fake transaction ACK.'))
ctx=json.loads((O/'NOTIFICATION_CONTEXT.json').read_text(encoding='utf-8-sig'));ctx.update(codex_checked_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),codex_observation='Astra已核全系统及逐坐标融合PASS，正在STA/BIT与最小冻结交付');save(O/'NOTIFICATION_CONTEXT.json',ctx)
save(O/'PHASE_RESULT.json',dict(status='RUNNING',phase='FINAL_STA_BIT_AND_FREEZE',running=True,hardware_next=False,updated_utc=datetime.datetime.now(datetime.timezone.utc).isoformat()))
print('DELIVERY_SOURCE_PRECHECK_PASS',len(before),'drift',len(drift))
