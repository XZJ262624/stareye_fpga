"""STA only: audit a final implementation copy; never calls P&R/pgm/Programmer."""
from pathlib import Path
from datetime import datetime, timezone
import hashlib, json, os, shutil, subprocess, tempfile
ROOT = Path(__file__).resolve().parents[1]
WORK = ROOT / 'efinity/m1_hdmi_i3'
REP = ROOT / 'reports/m1_hdmi_i3'
NAME = 'Ti60_HDMI_1080P_Test'
BIT_SHA = 'D96068C5D88EE861FD70F1FF4C82221DAE5582E5C1642366A631B053EA7B3E89'
def record(path):
    return {'path': path.resolve().as_posix(), 'bytes': path.stat().st_size,
            'sha256': hashlib.sha256(path.read_bytes()).hexdigest().upper()}
def snapshot():
    files = sorted(p for folder in ('outflow', 'work_pnr') for p in (WORK / folder).rglob('*') if p.is_file())
    files += [WORK / (NAME + suffix) for suffix in ('.xml', '.peri.xml', '_I3.sdc')]
    return [dict(record(p), mtime_ns=p.stat().st_mtime_ns) for p in files]
def main():
    before = snapshot()
    bit = record(WORK / 'outflow' / (NAME + '.bit'))
    if bit['bytes'] != 1626948 or bit['sha256'] != BIT_SHA:
        raise ValueError('Approved bitstream changed; refusing audit')
    (WORK / 'work').mkdir(exist_ok=True)
    clone = Path(tempfile.mkdtemp(prefix='sta_i3_', dir=WORK / 'work'))
    pairs = []
    for folder in ('outflow', 'work_pnr'):
        shutil.copytree(WORK / folder, clone / folder)
    for suffix in ('.xml', '.peri.xml', '_I3.sdc'):
        shutil.copy2(WORK / (NAME + suffix), clone / (NAME + suffix))
    for row in before:
        original = Path(row['path'])
        copied = clone / original.relative_to(WORK)
        pairs.append({'original': record(original), 'copy': record(copied)})
    sdc_list = clone / 'work_pnr/sdc_file_list'
    sdc_list.write_text(str(clone / (NAME + '_I3.sdc')) + '\n')
    tcl = ROOT / 'scripts/m1_hdmi_i3_timing_audit.tcl'
    shutil.copy2(tcl, clone / 'audit.tcl')
    for old in (clone / 'outflow').glob('m1_hdmi_i3_*.rpt'):
        old.unlink()
    os.chdir(clone)
    from projectdb.db import EfxProjectDatabase
    project = EfxProjectDatabase()
    if not project.load(NAME + '.xml') or project.device_timing_model != 'I3':
        raise ValueError('Official project API did not confirm I3')
    command = [str(Path(os.environ['EFINITY_HOME']) / 'bin/efx_sta.exe'), '--prj', NAME,
               '--output_dir', 'outflow', '--tclsh', 'audit.tcl']
    result = subprocess.run(command, capture_output=True)
    log = REP / 'isolated_sta.log'
    log.write_bytes(result.stdout + result.stderr)
    after = snapshot()
    evidence = {'schema': 1, 'utc': datetime.now(timezone.utc).isoformat(),
                'command': command, 'cwd': clone.as_posix(), 'exit_code': result.returncode,
                'project_api_timing_model': project.device_timing_model,
                'original_before': before, 'original_after': after,
                'original_unchanged': before == after, 'clone_initial_pairs': pairs,
                'redirected_sdc_list': record(sdc_list), 'audit_tcl': record(tcl),
                'copied_audit_tcl': record(clone / 'audit.tcl'), 'log': record(log),
                'bitstream': bit, 'reports': [],
                'limitation': 'Current final implementation and bit are co-snapshotted. Original build did not capture route/bit input hashes; this is not retrospective cryptographic proof that this DB generated the bit or that this exact file was downloaded.'}
    for kind in ('internal_setup', 'internal_hold', 'serializer_setup', 'serializer_hold', 'check_timing', 'clocks'):
        source = clone / 'outflow' / ('m1_hdmi_i3_' + kind + '.rpt')
        if source.exists():
            target = REP / source.name
            shutil.copy2(source, target)
            evidence['reports'].append(record(target))
    (REP / 'final_implementation_binding.json').write_text(json.dumps(evidence, indent=2))
    if result.returncode or before != after or b'M1_I3_AUDIT_COMPLETE' not in result.stdout or len(evidence['reports']) != 6:
        raise RuntimeError('STA audit failed; see binding/log')
    print('PASS isolated STA; final implementation and outflow unchanged; ' + clone.as_posix())
if __name__ == '__main__':
    main()
