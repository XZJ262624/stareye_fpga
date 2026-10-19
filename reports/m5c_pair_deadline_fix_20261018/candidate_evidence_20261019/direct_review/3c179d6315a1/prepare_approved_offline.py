from pathlib import Path
import json, hashlib, difflib
R=Path('F:/Projects/stareye_fpga'); B=Path(__file__).resolve().parent
F=B/'offline_deadline_20261019'
O=R/'reports/m5c_pair_admission_20261018/offline_v3_20261018_current'
def rec(p):
    b=p.read_bytes(); return dict(path=p.relative_to(R).as_posix() if p.is_relative_to(R) else p.as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def check(x):
    p=Path(x['path']); p=p if p.is_absolute() else R/p
    z=rec(p); assert (z['bytes'],z['sha256'])==(x['bytes'],x['sha256']),p
    return p
def put(n,x):
    p=F/n; assert not p.exists(); p.write_text(json.dumps(x,indent=2)+'\n')
p=B/'OFFLINE_DEADLINE_PROPOSAL.json'
assert rec(p)['sha256']=='6ca10b52439e2aa32174469777ebb9b655f3809466a3aced7964f8884cc05190'
plan=json.loads(p.read_text()); check(plan['physical_manifest'])
assert not F.exists(); F.mkdir()
source=[]; changes=[]
for x in plan['source']:
    check(x['canonical']); p=check(x['qualified']); q=R/x['destination']; raw=p.read_bytes(); new=raw
    if p.name=='settings.json':
        a=json.loads(raw)['args']; old=a[a.index('--base_path')+1]
        newbase=old.replace(str(B/'physical_deadline_233017/mirror').replace('\\','/'),str(F/'mirror').replace('\\','/'))
        assert old!=newbase
        t=json.dumps(old).encode(); u=json.dumps(newbase).encode(); assert raw.count(t)==1
        new=raw.replace(t,u); assert new.replace(u,t)==raw
        changes.append(dict(original=rec(p),old_base=old,new_base=newbase,inverse_byte_exact=True))
    q.parent.mkdir(parents=True,exist_ok=True); q.write_bytes(new)
    source.append(dict(original=rec(p),canonical=x['canonical'],copy=rec(q),initial_copy=x['original_copy']))
db=[]
for x in plan['database']:
    p=check(x['current']); check(x['route_archive']); q=R/x['destination']; q.parent.mkdir(parents=True,exist_ok=True); q.write_bytes(p.read_bytes())
    db.append(dict(original=rec(p),copy=rec(q),route_archive=x['route_archive']))
for x in plan['tools']: check(x)
assert (len(source),len(changes),len(db),len(plan['tools']))==(107,11,8,7)
put('INPUT_WHITELIST.json',dict(source=source,database=db,tools=plan['tools'],settings_rebase=changes,approved_proposal=rec(B/'OFFLINE_DEADLINE_PROPOSAL.json')))
der=[]
for name in ['options_preflight.py','run_conversion.py']:
    p=O/name; old=p.read_bytes(); q=F/name; q.write_bytes(old)
    der.append(dict(parent=rec(p),derived=rec(q),transform='exact bytes; run root is explicit and script-local directory selects fresh destination'))
put('DERIVATION.json',der)
(F/'.gitignore').write_text(''.join('mirror/efinity/m5c_pair_diag_i3/outflow/Ti60_Demo'+s+'\n' for s in ['.bit','.bit.bin','.hex','.hex.bin']))
print('PREPARED_EXACT_APPROVED_107_SOURCE_8_DB_7_TOOLS_11_SETTINGS')
