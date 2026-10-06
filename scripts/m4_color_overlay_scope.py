"""Explicit M4 proposal only. No staging, committing, cleanup or broad add."""
from pathlib import Path
import hashlib,json,subprocess
R=Path(__file__).resolve().parents[1];O=R/'reports/m4_color_overlay_i3';W=R/'efinity/m4_color_overlay_i3'
inputs=json.loads((O/'m4_color_overlay_i3/build/input_after.json').read_text());names={x['path'] for x in inputs if x['path'].startswith('efinity/m4_color_overlay_i3/')}
for base in (R/'rtl/m4_color_overlay',R/'tb/m4_color_overlay',O):
 for p in base.rglob('*'):
  parts=p.relative_to(base).parts
  if not p.is_file() or any(x in parts for x in ('work','__pycache__','generated','negative_cases')):continue
  if p.suffix.lower() not in ('.v','.sv','.do','.md','.json','.rpt','.csv'):continue
  if p.name in ('PROPOSED_GIT_SCOPE.json',):continue
  names.add(p.relative_to(R).as_posix())
names.update(p.relative_to(R).as_posix() for p in (R/'scripts').glob('m4_color_overlay_*') if p.suffix in ('.py','.bat','.tcl'))
names.update(['.gitignore','.gitattributes','README.md']+['docs/'+n+'.md' for n in ('PROJECT_BRIEF','STATUS','HANDOFF','MILESTONES','DECISIONS')])
rows=[]
for n in sorted(names):
 assert not n.startswith(('reference/','tools/','handoff/','document/')) and '/outflow/' not in n and '/work/' not in n
 assert not n.endswith(('.bit','.log','.db','.lbf','.lpf','.zip','.lock','.fst','.vcd','.wlf'))
 p=R/n;b=p.read_bytes();assert len(b)<2_000_000,(n,len(b))
 if n.endswith('.bin'):assert n.endswith('/DdrCtrl/ddr3_controller.bin') and all(c in b'0123456789abcdefABCDEF\r\n' for c in b)
 rows.append(dict(path=n,bytes=len(b),sha256=hashlib.sha256(b).hexdigest()))
g=['git','-c','safe.directory=F:/Projects/stareye_fpga'];check=subprocess.run(g+['check-ignore','-z','--stdin'],cwd=R,input=('\0'.join(sorted(names))+'\0').encode(),capture_output=True);assert check.returncode in (0,1) and not check.stdout,check.stdout
result=dict(staged=False,committed=False,branch=subprocess.check_output(g+['branch','--show-current'],cwd=R).decode().strip(),parent=subprocess.check_output(g+['rev-parse','HEAD'],cwd=R).decode().strip(),count_excluding_manifest=len(rows),bytes_excluding_manifest=sum(x['bytes'] for x in rows),manifest_self_hash_excluded=True,files=rows,source_ROM_exception='Required 7600-byte ASCII DDR firmware initialization, not a build database.',excluded='bit/outflow/work/databases/cache/locks/waves/raw logs/generated golden vectors/reference/tools/vendor materials/old engineering directories',shared_dependencies='Existing M3 five cores and M32 four modules are already in parent commit, unchanged; not included as M4 modifications.')
(O/'PROPOSED_GIT_SCOPE.json').write_text(json.dumps(result,indent=2),encoding='utf-8');print('M4_PROPOSED_SCOPE',len(rows)+1,'files',result['bytes_excluding_manifest']+(O/'PROPOSED_GIT_SCOPE.json').stat().st_size,'bytes, index untouched')
