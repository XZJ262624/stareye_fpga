"""Emit the exact candidate path list; no Git mutations are performed here."""
from pathlib import Path
import json,hashlib,subprocess,shutil
R=Path(__file__).resolve().parents[1];O=R/'reports/m5b1_global_canny_i3';W=R/'efinity/m5b1_global_canny_i3';P='c0102ee1c9a0a8aa802c398755d4a7b3139c7ffd'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def git(*args):return subprocess.check_output(['git','-c','safe.directory='+R.as_posix(),*args],cwd=R)
def main():
 assert git('rev-parse','HEAD').decode().strip()==P and not git('diff','--cached','--name-only')
 receipt=json.loads((O/'OFFLINE_ACCEPTANCE.json').read_text());assert receipt['status']=='PASS_OFFLINE_PENDING_INDEPENDENT_REVIEWS_AND_HARDWARE'
 copies=json.loads((O/'M5A_INPUT_COPY.json').read_text());paths={row['copy']['path'] for row in copies['files']}
 paths.update(p.relative_to(R).as_posix() for p in (R/'rtl/m5b1_global_canny').glob('*.sv'))
 paths.update(p.relative_to(R).as_posix() for p in (R/'tb/m5b1_global_canny').glob('*.sv'))
 scripts=['build.py','compile.bat','map.bat','constraints.py','sta.py','cdc_audit.py','static.py','validate.py','checkpoint.py','scope.py','directed_sim.py','global_sim.py','system_sim.py','system_faults.py','mutations.py','qos_negative.py','tap_sim.py','uart_decode.py','replay.py']
 paths.update('scripts/m5b1_'+s for s in scripts)
 paths.update(['.gitattributes','.gitignore',*('docs/'+s+'.md' for s in ('STATUS','HANDOFF','PROJECT_BRIEF','DECISIONS'))])
 F=O/'final_build';F.mkdir(exist_ok=True)
 for name in ('Ti60_Demo.map.rpt','Ti60_Demo.place.rpt','Ti60_Demo.route.rpt','Ti60_Demo.pt.rpt'):
  shutil.copy2(W/'outflow'/name,F/name);paths.add((F/name).relative_to(R).as_posix())
 old={}
 for name in ('tap','global_final','system','system_faults','directed','mutations','qos_negative'):
  data=json.loads((O/name/'results.json').read_text())
  for row in data['sources']:
   if not row['path'].startswith(('rtl/m5b1_global_canny/','tb/m5b1_global_canny/','scripts/m5b1_','reports/m5b1_global_canny_i3/')):old[row['path']]=row
 deps=dict(required_parent=P,unchanged_test_reference_files=sorted(old.values(),key=lambda r:r['path']),provenance_source_files=[r['source'] for r in copies['files']],frozen_spec=rec(O/'SPEC_FREEZE.md'),external_tools=['Efinity 2025.1.110.5.9','ModelSim 10.1c','Python 3 with NumPy for tap'],privacy='BASELINE_PROTECTION historical untracked names are repository protection metadata; Work excludes them and all raw personal/history material from external review snapshots.')
 (O/'TECHNICAL_DEPENDENCIES.json').write_text(json.dumps(deps,indent=2))
 rootreports=['BASELINE_PROTECTION.json','M5A_INPUT_COPY.json','CDC_PIN_MANIFEST.json','CDC_STRUCTURAL_AUDIT.json','STATIC_AUDIT.json','OFFLINE_ACCEPTANCE.json','DEVELOPMENT_CHECKPOINT.json','TECHNICAL_DEPENDENCIES.json','BUILD_REPORT.md','IMPLEMENTATION.md','REPLAY.md']
 paths.update((O/p).relative_to(R).as_posix() for p in rootreports)
 for name in ('tap','global_final','system','system_faults','directed','mutations','qos_negative'):paths.add((O/name/'results.json').relative_to(R).as_posix())
 for p in (O/'final_sta').glob('*.rpt'):paths.add(p.relative_to(R).as_posix())
 for name in ('binding.json','audit.tcl'):paths.add((O/'final_sta'/name).relative_to(R).as_posix())
 for name in ('inputs_before.json','inputs_after.json','result.json','XML_METADATA_ONLY.json'):paths.add((O/receipt['build_directory']/name).relative_to(R).as_posix())
 for p in (O/'blocked_build_evidence').glob('*.rpt'):paths.add(p.relative_to(R).as_posix())
 paths.add((O/'patterns/snake_vertical_1280x720.hex').relative_to(R).as_posix())
 for name in paths:
  assert (R/name).is_file() and not any(v in Path(name).parts for v in ('work','outflow','work_pnr','work_syn','ipm','cache'))
  assert Path(name).suffix.lower() not in ('.log','.out','.bit','.vcd','.wlf','.exe','.dll','.zip')
  if Path(name).suffix.lower()=='.bin':assert name in {r['copy']['path'] for r in copies['files']},name
 rows=[rec(R/p) for p in sorted(paths)];manifest=O/'PROPOSED_GIT_SCOPE.json'
 manifest.write_text(json.dumps(dict(branch='codex/m5b1-global-canny-prototype',required_parent=P,files=rows,self_not_hashed=manifest.relative_to(R).as_posix(),ROM_exception='Copied DDR ASCII initialization .bin is a required source, not a generated bitstream.',excluded='Raw logs, work/outflow/databases, waveforms, tool packages, unrelated untracked files and historical personal materials'),indent=2))
 selected=sorted(paths|{manifest.relative_to(R).as_posix()});scratch=O/'work';scratch.mkdir(exist_ok=True);(scratch/'stage_paths.nul').write_bytes(b'\0'.join(p.encode() for p in selected)+b'\0')
 print('CANDIDATE_SCOPE',len(selected),'files',sum((R/p).stat().st_size for p in selected),'bytes','reference dependencies',len(old))
if __name__=='__main__':main()
