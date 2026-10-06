"""Review-only whitelist inventory. Never stages or commits anything."""
from pathlib import Path
import json,hashlib,subprocess
R=Path(__file__).resolve().parents[1];O=R/'reports/m32_median_integration_i3';variants=('m32_median_integration_i3','m32_median_integration_enabled_i3')
bases=[R/'efinity'/v for v in variants]+[R/'rtl/m32_median_integration',R/'rtl/m31_sobel_controls',R/'tb/m32_median_integration',O,R/'reports/m32_median_review'];files=set()
for base in bases:
 for p in base.rglob('*'):
  if p.is_file() and not any(x in ('outflow','work','work_syn','work_pnr','work_pt','ipm','cache','replay') for x in p.relative_to(base).parts) and p.suffix.lower() in ('.v','.sv','.sdc','.tcl','.xml','.json','.csv','.md','.txt','.do','.log','.py','.bat','.ve','.vh','.vhd','.vhdl','.rpt') and p.name!='PROPOSED_GIT_SCOPE.json':files.add(p)
files.update((R/'scripts').glob('*m32*'));files.update(R/'docs'/n for n in ('STATUS.md','HANDOFF.md','MILESTONES.md','DECISIONS.md'));files.add(R/'.gitignore');names=sorted(p.relative_to(R).as_posix() for p in files)
proc=subprocess.run(['git','-c','safe.directory=F:/Projects/stareye_fpga','check-ignore','-z','--stdin'],input='\0'.join(names)+'\0',capture_output=True,text=True);assert proc.returncode in (0,1);ignored=set(proc.stdout.split('\0'));rows=[]
for name in names:
 if name in ignored:continue
 p=R/name;rows.append(dict(path=name,bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest(),scope='M31 uncommitted prerequisite' if name.startswith('rtl/m31_sobel_controls/') else 'M32 proposed'))
assert not any(x['path'].startswith(('reference/','tools/','handoff/','document/')) or '/outflow/' in x['path'] or '/work' in x['path'] or x['path'].endswith('.bit') for x in rows)
result=dict(staged=False,committed=False,branch='codex/m32-median-integration',parent='7a9b448080fd6f1624c2ef37ee2eb267fed49c82',m31_status='Verified uncommitted M31 tree. Two required shared RTL files explicitly included; original M31 engineering directory excluded.',file_count=len(rows),total_bytes=sum(x['bytes'] for x in rows),largest_files=sorted(rows,key=lambda x:x['bytes'],reverse=True)[:5],files=rows,git_ignore_check='NUL-separated git check-ignore -z --stdin; ignores checked, not staged',ignored_candidates_removed=sorted(x for x in ignored if x))
(O/'PROPOSED_GIT_SCOPE.json').write_text(json.dumps(result,indent=2));print('M32_SCOPE',result['file_count'],result['total_bytes'],'bytes; staged=false')
