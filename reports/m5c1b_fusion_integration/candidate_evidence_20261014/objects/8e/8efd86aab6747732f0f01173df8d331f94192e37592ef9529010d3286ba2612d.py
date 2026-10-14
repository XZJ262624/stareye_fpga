from pathlib import Path
import json,hashlib,shutil,subprocess,xml.etree.ElementTree as ET
F=Path(__file__).resolve().parent;R=F.parents[2];M=R/'reports/m5c1b_fusion_integration/selected_final_matrix_20261013_071300';O=M/'replay_end_v2';C=F/'mirror'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def chk(xs):
 for x in xs:assert rec(R/x['path'])==x,x['path']
 return len(xs)
identity=R/'reports/m5c1b_fusion_integration/final_source_selection_20261013_063600/SELECTED_SOURCE_IDENTITY.json';sel=json.loads(identity.read_text())['records'];assert chk([x['adopted'] for x in sel])==101
protection=R/'reports/m5c1b_fusion_integration/SOURCE_PROTECTION.json';assert chk(json.loads(protection.read_text()))==4465
proofs=list((O/'runs').glob('*/GATE_MANIFEST.json'));assert len(proofs)==17
for n in ['focused_replay','legacy_current','legacy_default_timeout','legacy37_handback_0955','nonzero_negative_handback_0957','end_protocol_handback_1007']:proofs+=list((M/n).glob('*MANIFEST*.json'))
assert len(proofs)==23
counts=[]
for p in proofs:counts.append(dict(manifest=rec(p),checked=chk(json.loads(p.read_text())['records'])))
def git(*a):return subprocess.check_output(['git','-c','safe.directory=F:/Projects/stareye_fpga',*a],cwd=R,text=True).strip()
head=git('rev-parse','HEAD');parent=git('rev-parse','HEAD^');branch=git('branch','--show-current');assert head=='f8bc4492f7247b5c242c80b76d9ca4a76347f30d' and parent=='8976a276f03b4cd146c451aa081b04f71637fcf2' and branch=='codex/m5c-fusion-prototype';assert not git('diff','--cached','--name-only')
rows=[];settings=[]
for x in sel:
 p=R/x['adopted']['path'];q=C/x['target'];assert q.resolve().is_relative_to(C);q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,q)
 if q.name=='settings.json':
  a=json.loads(p.read_text());b=json.loads(p.read_text());i=b['args'].index('--base_path')+1;old=b['args'][i];b['args'][i]=str(C/'efinity/m5c_fusion_i3/ip');q.write_text(json.dumps(b,indent=4)+'\n');z=json.loads(q.read_text());z['args'][i]=old;assert z==a;settings.append(dict(source=rec(p),copy=rec(q),old=old,new=b['args'][i],normalization='Only args value following --base_path'))
 rows.append(dict(source=rec(p),copy=rec(q)))
assert len(settings)==11 and len(list(C.rglob('*.*')))==101
P=C/'efinity/m5c_fusion_i3';refs=[]
for e in ET.parse(P/'Ti60_Demo.xml').iter():
 if e.tag.endswith('design_file'):
  p=(P/e.attrib['name']).resolve();assert p.is_relative_to(C) and p.is_file(),p;refs.append(rec(p))
assert not (P/'outflow').exists() and not (P/'work_pnr').exists()
(F/'COPY_MANIFEST.json').write_text(json.dumps(dict(records=rows,settings=settings,xml_design_files=refs,identity=rec(identity),source_constraints_unchanged=True,no_inherited_database=True),indent=2))
(F/'PREFLIGHT.json').write_text(json.dumps(dict(status='PASS_INPUT_ADMISSION_ONLY',selected=101,protected=4465,proofs=counts,proof_record_checks=sum(x['checked'] for x in counts),head=head,parent=parent,branch=branch,index_empty=True,freeze=rec(F.parent/'FRESH_I3_BUILD_EXECUTION_FREEZE_20261014.md'),draft=rec(M/'FUTURE_BUILD_PLAN_DRAFT_091000.json'),copy=rec(F/'COPY_MANIFEST.json')),indent=2));print('PREFLIGHT PASS',len(rows),len(settings),sum(x['checked'] for x in counts),flush=True)
