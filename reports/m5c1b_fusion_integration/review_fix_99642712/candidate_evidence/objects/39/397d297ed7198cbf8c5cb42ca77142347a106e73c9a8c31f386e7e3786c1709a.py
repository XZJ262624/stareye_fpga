from pathlib import Path
import hashlib,json,subprocess,os
O=Path(__file__).resolve().parent;F=O.parent;A=F/'resource_area_bound';R=F.parents[2]
def rec(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b)
 return dict(path=p.relative_to(R).as_posix(),bytes=p.stat().st_size,sha256=h.hexdigest())
result=json.loads((O/'RESULT.json').read_text());native=json.loads((O/'NATIVE_EXIT_RECEIPT.json').read_text());opt=json.loads((O/'ACTUAL_GENERATED_OPTIONS.json').read_text());assert result['status']=='PASS_OFFLINE_CONVERSION_ONLY' and native['exit']==0 and not native['timeout'];assert opt['flags']['do_program'] is False and opt['run_usbif'] is False
assert json.loads((O/'EXIT_NATIVE_CIM.json').read_text(encoding='utf-8-sig'))==[]
checks=0
for x in json.loads((O/'QUALIFIED_INPUTS_PRECONVERSION.json').read_text())['records']:assert rec(R/x['path'])==x;checks+=1
for x in json.loads((F/'regression/SOURCE101.json').read_text())['records']:assert rec(R/x['path'])==x;checks+=1
for label in ['PRE_NATIVE_ARCHIVE','POST_NATIVE_ARCHIVE']:
 for x in json.loads((O/(label+'.json')).read_text())['records']:
  assert rec(R/x['archive']['path'])==x['archive'] and x['archive']['sha256']==x['original']['sha256'];checks+=1
for x in result['artifacts']:assert rec(R/x['path'])==x;checks+=1
os.environ['GIT_OPTIONAL_LOCKS']='0';git=['git','-c','safe.directory=F:/Projects/stareye_fpga'];ignored=subprocess.run(git+['check-ignore','-v','--']+[x['path'] for x in result['artifacts']],cwd=R,capture_output=True,text=True);assert ignored.returncode==0 and len(ignored.stdout.splitlines())==4
assert not subprocess.check_output(git+['diff','--cached','--name-only'],cwd=R,text=True).strip();head=subprocess.check_output(git+['rev-parse','HEAD'],cwd=R,text=True).strip();assert head=='99642712cfb912f484006f4cd74aba4bdaa8d57b'
(O/'IGNORE_RECEIPT.json').write_text(json.dumps(dict(command=ignored.args,exit=ignored.returncode,stdout=ignored.stdout,ignore=rec(O/'.gitignore')),indent=2))
p=O/'FINAL_HANDBACK.json';assert not p.exists();p.write_text(json.dumps(dict(status='PASS_OFFLINE_AREA_ARTIFACT_SEALED_BEFORE_ROOT_ADOPTION',head=head,candidate=None,checks=checks,artifacts=result['artifacts'],native=rec(O/'NATIVE_EXIT_RECEIPT.json'),options=rec(O/'ACTUAL_GENERATED_OPTIONS.json'),qualified_physical_manifest=rec(A/'PHYSICAL_HANDBACK_MANIFEST.json'),management2337_delta=rec(F/'work_management_2337/MANAGEMENT_DELTA.json'),source101_unchanged=True,owned_native_exited=True,resource=dict(XLR=48007,RAM10=192,DSP=1),setup_ns=.191,hold_ns=.026,boundary='Offline file conversion only; no hardware or cross-PVT claim. Root SDC/XML not yet adopted at this seal. Original candidate remains FAIL, index empty, no Git mutation. Exact ignored artifacts not proposed for Git. Disabled security IV warning preserved; no key change.'),indent=2))
p=O/'HANDBACK_MANIFEST.json';assert not p.exists();records=[rec(x) for x in sorted(O.rglob('*')) if x.is_file()];p.write_text(json.dumps(dict(records=records),indent=2));print('OFFLINE_AREA_SEALED',len(records),checks,rec(p))
