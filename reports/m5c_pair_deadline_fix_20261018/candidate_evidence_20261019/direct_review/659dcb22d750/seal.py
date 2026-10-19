from pathlib import Path
import json,hashlib,subprocess
R=Path('F:/Projects/stareye_fpga');F=Path(__file__).resolve().parent
def rec(p):
    h=hashlib.sha256();n=0
    with p.open('rb') as s:
        for b in iter(lambda:s.read(1048576),b''):h.update(b);n+=len(b)
    return dict(path=p.relative_to(R).as_posix(),bytes=n,sha256=h.hexdigest())
def put(n,x):
    p=F/n;assert not p.exists();p.write_text(json.dumps(x,indent=2)+'\n')
result=json.loads((F/'RESULT.json').read_text());inp=json.loads((F/'INPUT_WHITELIST.json').read_text());opts=json.loads((F/'ACTUAL_GENERATED_OPTIONS.json').read_text())
assert result['status']=='PASS_OFFLINE_CONVERSION_ONLY' and not opts['run_usbif'] and not opts['flags']['do_program'] and not opts['flags']['do_security']
ignored=[]
for x in result['artifacts']:
    assert rec(R/x['path'])==x
    a=subprocess.run(['git','-c','safe.directory=F:/Projects/stareye_fpga','check-ignore','-v','--',x['path']],cwd=R,capture_output=True,text=True);assert a.returncode==0,a.stderr
    b=subprocess.run(['git','-c','safe.directory=F:/Projects/stareye_fpga','ls-files','--error-unmatch','--',x['path']],cwd=R,capture_output=True,text=True);assert b.returncode==1
    ignored.append(dict(artifact=x,check_ignore=a.stdout.strip(),tracked=False))
put('ARTIFACT_IGNORE_RECEIPT.json',dict(status='PASS_EXACT_FOUR_IGNORED_UNTRACKED',records=ignored))
put('HANDBACK.json',dict(status='PASS_OFFLINE_DEADLINE_CONVERSION_ONLY',result=rec(F/'RESULT.json'),options=rec(F/'ACTUAL_GENERATED_OPTIONS.json'),sources=107,route_database=8,settings_rebase=11,artifacts=result['artifacts'],scope='Offline file conversion only, no hardware. Work separately accepted finite remote V4.1 and current I3 qualification. Three legacy PLL SR endpoints remain untimed (six setup/hold records); no whole-design all-timed/PVT/hardware PASS.',candidate_stage_commit_authorized=False,preparation='Exact approved proposal inputs. XML starts from frozen original pre-native COPY_MANIFEST archive; current qualified route databases are independently bound. No old bit reused.'))
rows=[rec(p) for p in sorted(F.rglob('*')) if p.is_file() and p.name!='HANDBACK_MANIFEST.json']
put('HANDBACK_MANIFEST.json',dict(records=rows))
print(json.dumps(dict(records=len(rows),bytes=sum(x['bytes'] for x in rows),manifest=rec(F/'HANDBACK_MANIFEST.json'),artifacts=result['artifacts'],xml_metadata_changes=result['xml_metadata_changes'])))
