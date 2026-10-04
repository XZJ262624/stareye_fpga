"""List a reviewable M3 commit candidate set; does not invoke Git or stage files."""
from pathlib import Path
import json,hashlib
ROOT=Path(__file__).resolve().parents[1];R=ROOT/'reports/m3_sobel_core_i3'
paths=[ROOT/p for p in ('.gitignore','.gitattributes','README.md','docs/PROJECT_BRIEF.md','docs/STATUS.md','docs/HANDOFF.md','docs/MILESTONES.md','docs/DECISIONS.md')]
seed=json.loads((R/'seed_manifest.json').read_text())
paths += [ROOT/'efinity/m3_sobel_core_i3'/x['path'] for x in seed]
paths += list((ROOT/'rtl/m3_sobel_core').glob('*.v'))+list((ROOT/'tb/m3_sobel_core').glob('*.sv'))
paths += list((ROOT/'scripts').glob('m3_sobel_core_*'))
paths += [p for p in R.rglob('*') if p.is_file() and not any(part in ('negative_cases','__pycache__') for part in p.relative_to(R).parts) and p.suffix not in ('.vcd','.wlf','.fst') and p.name not in ('transcript','CHANGE_SCOPE.json','CHANGE_SCOPE.md')]
paths=sorted(set(paths));rows=[]
for p in paths:
    assert p.is_file(),p
    rel=p.relative_to(ROOT).as_posix()
    assert not any(part in ('outflow','work','work_syn','work_pnr','work_pt','ipm','cache','document','reference','tools') for part in p.relative_to(ROOT).parts),rel
    rows.append({'path':rel,'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
groups={}
for row in rows:
    category='/'.join(row['path'].split('/')[:2]) if row['path'].startswith(('efinity/','reports/','rtl/','tb/')) else row['path'].split('/')[0]
    entry=groups.setdefault(category,{'files':0,'bytes':0});entry['files']+=1;entry['bytes']+=row['bytes']
result={'scope':'Review candidate only, no git add/commit; scope files exclude their own self-reference and must be reviewed separately. Regenerate after any candidate file changes.','files':len(rows),'bytes':sum(x['bytes'] for x in rows),'groups':groups,'largest':sorted(rows,key=lambda x:x['bytes'],reverse=True)[:10],'entries':rows}
(R/'CHANGE_SCOPE.json').write_text(json.dumps(result,indent=2))
lines=['# M3拟提交范围','',f'候选 {len(rows)} 文件，共 {result["bytes"]:,} 字节；没有暂存或提交。范围清单自身两个文件另外审阅，避免自引用哈希；已包含主会话ROOT_REVIEW；任何候选文件改变后应重新生成清单。','','| 类别 | 文件 | 字节 |','| --- | ---: | ---: |']
for name,v in groups.items():lines.append(f'| {name} | {v["files"]} | {v["bytes"]:,} |')
lines+=['','仅新增M3工程输入、五RTL、三个TB、M3脚本/文本证据及必要文档。排除bit/outflow/work/cache/IPM/波形、negative_cases临时损坏文件、document/reference/tools。M2没有拟提交变更。详细逐项路径/大小/SHA见CHANGE_SCOPE.json。']
(R/'CHANGE_SCOPE.md').write_text('\n'.join(lines)+'\n',encoding='utf-8')
print('M3_SCOPE',len(rows),result['bytes'])
