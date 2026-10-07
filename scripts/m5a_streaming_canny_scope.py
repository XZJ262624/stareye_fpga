"""Produce an explicit review manifest; never stage, commit, or delete files."""
from pathlib import Path
import csv, hashlib, io, json, subprocess

ROOT = Path(__file__).resolve().parents[1]
REPORT = ROOT / 'reports/m5a_streaming_canny_i3'
GIT = ['git', '-c', 'safe.directory=F:/Projects/stareye_fpga']


def git(*args):
    return subprocess.check_output(GIT + list(args), cwd=ROOT).decode().strip()


def main():
    assert git('branch', '--show-current') == 'codex/m5a-streaming-canny'
    assert git('rev-parse', 'HEAD') == '95bf83f7172ecdf11ee9b8deb3e2c1bba535a56d'
    assert not git('diff', '--cached', '--name-only'), 'Do not change existing index'
    names = {'.gitattributes', '.gitignore', 'README.md', 'docs/PROJECT_BRIEF.md', 'docs/STATUS.md', 'docs/HANDOFF.md',
             'docs/MILESTONES.md', 'docs/DECISIONS.md'}
    baseline = json.loads((REPORT / 'M4_COMMITTED_COPY.json').read_text())
    names.update(row['path'] for row in baseline['files'])
    for directory in ('rtl/m5a_streaming_canny', 'tb/m5a_streaming_canny'):
        names.update(p.relative_to(ROOT).as_posix() for p in (ROOT / directory).iterdir()
                     if p.is_file() and p.suffix in ('.v', '.sv', '.do'))
    names.update(p.relative_to(ROOT).as_posix() for p in (ROOT / 'scripts').glob('m5a_streaming_canny_*')
                 if p.is_file() and p.suffix in ('.py', '.bat', '.tcl'))
    manifests = ['reports/m5a_streaming_canny_i3/PROPOSED_GIT_SCOPE.json',
                 'reports/m5a_streaming_canny_i3/PROPOSED_GIT_SCOPE.csv']
    for p in REPORT.rglob('*'):
        if not p.is_file() or p.suffix not in ('.md', '.json', '.rpt', '.xml', '.txt'):
            continue
        name = p.relative_to(ROOT).as_posix()
        if name in manifests or any(q in name for q in ('/negative_', '/generated/',
                '/work/', '/outflow/', '/build_failed_', '/build_before_comment_', '/audit_before_comment_')):
            continue
        if subprocess.run(GIT + ['check-ignore', '-q', '--', name], cwd=ROOT).returncode == 0:
            continue
        names.add(name)
    files = []
    for name in sorted(names):
        p = ROOT / name
        assert p.is_file(), name
        assert not set(p.parts) & {'outflow', 'work', '.git', 'reference', 'tools', '__pycache__'}
        assert p.suffix.lower() not in ('.bit', '.lbf', '.lpf', '.db', '.wlf', '.vcd', '.fst', '.log', '.lock', '.exe', '.msi', '.zip')
        if p.suffix == '.bin':
            assert name == 'efinity/m5a_streaming_canny_i3/ip/DdrCtrl/ddr3_controller.bin'
            p.read_text(encoding='ascii')  # Necessary source ROM, not a bitstream.
        assert subprocess.run(GIT + ['check-ignore', '-q', '--', name], cwd=ROOT).returncode != 0, name
        data = p.read_bytes()
        category = name.split('/')[0] if '/' in name else 'root'
        files.append(dict(path=name, bytes=len(data), sha256=hashlib.sha256(data).hexdigest(), category=category))
    allowed = {'root', 'docs', 'efinity', 'rtl', 'tb', 'scripts', 'reports'}
    assert all(x['category'] in allowed for x in files)
    output = io.StringIO(newline='')
    writer = csv.DictWriter(output, fieldnames=['path', 'bytes', 'sha256', 'category'])
    writer.writeheader(); writer.writerows(files)
    csv_path = ROOT / manifests[1]
    csv_path.write_text(output.getvalue(), encoding='utf-8', newline='')
    result = dict(branch=git('branch', '--show-current'), head=git('rev-parse', 'HEAD'),
        index_empty=True, staged=False, committed=False, files=files,
        hashed_payload_count=len(files), hashed_payload_bytes=sum(x['bytes'] for x in files),
        manifest_files=manifests, manifest_hash_note='Manifests excluded from their own hashes to avoid circular self-reference.',
        total_file_count=len(files)+2, total_bytes=0,
        source_rom_exception='DDR ASCII initialization ROM is necessary source input, not generated bitstream.',
        excluded='bit/outflow/work/databases/cache/locks/waves/logs/reference/tools/old untracked files',
        largest_file=max(files, key=lambda x: x['bytes']))
    json_path = ROOT / manifests[0]
    for _ in range(10):
        data = (json.dumps(result, ensure_ascii=False, indent=2) + '\n').encode('utf-8')
        total = result['hashed_payload_bytes'] + csv_path.stat().st_size + len(data)
        if total == result['total_bytes']:
            json_path.write_bytes(data)
            break
        result['total_bytes'] = total
    else:
        raise AssertionError('Manifest size failed to converge')
    assert sum((ROOT/x).stat().st_size for x in names | set(manifests)) == result['total_bytes']
    print(json.dumps({k: result[k] for k in ('total_file_count', 'total_bytes', 'hashed_payload_count', 'hashed_payload_bytes', 'largest_file')}, indent=2))


if __name__ == '__main__':
    main()
