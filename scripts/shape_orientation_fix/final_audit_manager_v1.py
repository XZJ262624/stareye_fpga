from standalone_physical_runtime import *
F,P=active();start=time.time();W=F/'final_audit_manager';W.mkdir()
try:
 while not(F/'STA_CHAIN_COMPLETE.json').exists():
  if(O/'FULL_NATIVE_STA_EXECUTION_RECEIPT.json').exists():assert json.loads((O/'FULL_NATIVE_STA_EXECUTION_RECEIPT.json').read_text()).get('execution_passed',False)
  assert time.time()-start<10800;save(F/'FINAL_AUDIT_HEARTBEAT.json',dict(status='WAIT_FRESH_ALL_NATIVE_STA',pid=os.getpid(),time=time.time()));time.sleep(10)
 verify(json.loads((O/'SOURCE_MANIFEST.json').read_text()));verify(json.loads((F/'CURRENT_ROUTED_DB_V2.json').read_text())['records'])
 for name,args in[('audit_metadata_fields_v1.py',[]),('audit_external_v1.py',[str(F)]),('audit_shape_ram_addresses_v1.py',[str(F)]),('audit_contract_sta_v1.py',[])]:
  execute(W,name.removesuffix('.py'),[str(E/'python311/bin/python.exe'),'-B',str(Path(__file__).parent/name),*args],timeout=600)
 recon=json.loads((F/'CONTRACT_STA_RECONCILIATION.json').read_text());ram=json.loads((F/'SHAPE_RAM_ADDRESS_MAPPING.json').read_text());resolved=set(ram['resolves_pins']);unknown=[r for r in recon['unknown']if not(r['kind']=='RAM'and r['pin']in resolved and r['native_net']=='gnd')];assert not unknown and not recon['negative'] and len(recon['legacy_untimed_not_pass'])==6,(unknown,recon['negative'],recon['legacy_untimed_not_pass'])
 native=json.loads((F/'NATIVE_ALL_FF_COVERAGE.json').read_text());plan=json.loads((F/'BATCHED_ENDPOINT_PLAN.json').read_text());assert all(len(plan['groups'][k])==native['native_FF_count']for k in['D','CE','SR']);assert len(recon['bundles'])==6
 idx=json.loads((F/'TIMING_REPORT_INDEX.json').read_text())['reports'];timed={}
 for name,report in idx.items():
  kind,mode=re.match(r'batch_(D|CE|SR|RAM|DSP)_(setup|hold)_',name).groups()
  for row in report['rows']:timed[kind,mode,row['end']]=row
 missing={(s['kind'],s['mode'],r['pin']):r for s in recon['scopes']for r in s['missing']};metadata=json.loads((F/'METADATA_FIELD_MAPPING.json').read_text());mcells={r['cell']for r in metadata['fifo']+metadata['current_tag']};assert len(mcells)==579;cov=[]
 for cell in sorted(mcells):
  for kind in['D','CE','SR']:
   pin=cell+'|'+kind;assert pin in plan['groups'][kind]
   for mode in['setup','hold']:
    k=kind,mode,pin
    if k in timed:assert timed[k]['slack']>=0;cov.append(dict(pin=pin,mode=mode,classification='CURRENT_NATIVE_TIMED',slack=timed[k]['slack']))
    else:
     row=missing[k];assert row['classification']in['NATIVE_CONSTANT_EXISTING','NATIVE_CONSTANT_MAP_AGREEMENT']and row['native_net']in['gnd','vcc'];cov.append(row)
 save(F/'METADATA_TIMING_COVERAGE.json',dict(passed=True,cells=579,records=cov,unknown=[],negative=[]));verify(metadata['source_bindings']);verify(metadata['bindings']);verify(json.loads((O/'SOURCE_MANIFEST.json').read_text()));verify(json.loads((F/'CURRENT_ROUTED_DB_V2.json').read_text())['records'])
 resource=json.loads((F/'FINAL_ROUTE_RESOURCE_GATE.json').read_text());initial=json.loads((F/'INITIAL_TIMING_GATE.json').read_text());external=json.loads((F/'EXTERNAL_BOUNDARY_CONTINUITY.json').read_text());assert not list(F.rglob('*.bit'))
 receipt=dict(status='PASS_STANDALONE_FRESH_NATIVE_PHYSICAL_WITH_EXPLICIT_INHERITED_BOUNDARIES_NOT_HARDWARE',passed=True,source_count=len(json.loads((O/'SOURCE_MANIFEST.json').read_text())),source_manifest=rec(O/'SOURCE_MANIFEST.json'),physical=F.relative_to(R).as_posix(),resource=resource,normal=initial,all_native_FFs=native['native_FF_count'],encrypted_DDR_FFs=native['encrypted_partition_FF_count'],endpoint_counts={k:len(v)for k,v in plan['groups'].items()},metadata_FFs=579,metadata_modes_records=len(cov),unknown=[],negative=[],legacy_PLL_async_SR_UNTIMED_NOT_PASS=recon['legacy_untimed_not_pass'],external_boundary=external,retained_MED_logic=True,no_bitstream=True,hardware_next=False,candidate=None,scope='Fresh standalone only: final91inputs + unchanged parent constraints and fresh endpoint binding; full6731actualnativeFF D/CE/SR including encryptedDDR +RAM/DSP setup/hold,6live5ns bundles/current clockmatrix/DSPthrough, full579metadata; unchanged original external7/135 and6PLLasyncSR are explicit limitations, not timing PASS.',bindings=[rec(F/n)for n in['STA_CHAIN_COMPLETE.json','CONTRACT_STA_RECONCILIATION.json','METADATA_FIELD_MAPPING.json','METADATA_TIMING_COVERAGE.json','SHAPE_RAM_ADDRESS_MAPPING.json','EXTERNAL_BOUNDARY_CONTINUITY.json','STANDALONE_PIXEL_MAPPED_CONES_V2.json','NATIVE_ALL_FF_COVERAGE.json','route/NEW_CDC_CONSTRAINT_APPLICATION_AUDIT.json']])
 save(F/'FINAL_PHYSICAL_RECEIPT.json',receipt);save(O/'PHYSICAL_FINAL_RECEIPT.json',dict(status=receipt['status'],passed=True,final=rec(F/'FINAL_PHYSICAL_RECEIPT.json'),hardware_next=False));print('STANDALONE_FRESH_FULL_PHYSICAL_AUDIT_COMPLETE_RETURN_TO_WORK',flush=True)
except Exception as err:
 save(O/'PHYSICAL_FINAL_RECEIPT.json',dict(status='FAIL_STANDALONE_PHYSICAL_AUDIT_REQUIRES_WORK',passed=False,error=repr(err),physical=F.relative_to(R).as_posix(),hardware_next=False));raise
