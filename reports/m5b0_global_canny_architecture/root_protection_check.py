"""Read-only baseline/Git inspection, writing only this phase's AFTER evidence."""
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import subprocess

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]


def git(*args):
    return subprocess.check_output(['git', '-c', 'safe.directory=F:/Projects/stareye_fpga',
                                    *args], cwd=ROOT).decode('utf-8').strip()


def execute():
    before = HERE/'PROTECTED_BASELINES_BEFORE.json'
    s = json.loads(before.read_text(encoding='utf-8'))
    mismatches = []
    for r in s['files']:
        p = ROOT/r['path']
        if not p.is_file():
            mismatches.append([r['path'], 'missing'])
            continue
        st, h = p.stat(), hashlib.sha256()
        with p.open('rb') as f:
            while chunk := f.read(1024*1024):
                h.update(chunk)
        if st.st_size != r['bytes'] or st.st_mtime_ns != r['mtime_ns'] or h.hexdigest() != r['sha256']:
            mismatches.append([r['path'], 'size/mtime/SHA mismatch'])
    for r in s['locked_unreadable']:
        p = ROOT/r['path']
        st = p.stat()
        if st.st_size != r['bytes'] or st.st_mtime_ns != r['mtime_ns']:
            mismatches.append([r['path'], 'locked metadata mismatch'])
    known = {r['path'] for r in s['files']+s['locked_unreadable']}
    actual = set(s['scripts'])
    for base in s['bases']:
        actual.update(p.relative_to(ROOT).as_posix() for p in (ROOT/base).rglob('*') if p.is_file())
    missing_untracked = [p for p in s['untracked_files'] if not (ROOT/p).is_file()]
    current_untracked = [p for p in git('ls-files', '--others', '--exclude-standard', '-z').split('\0') if p]
    changed = [p for p in git('diff', '--name-only', '-z').split('\0') if p]
    cached = [p for p in git('diff', '--cached', '--name-only', '-z').split('\0') if p]
    branch, head = git('branch','--show-current'), git('rev-parse','HEAD')
    allowed_docs = {'docs/STATUS.md','docs/HANDOFF.md','docs/MILESTONES.md',
                    'docs/DECISIONS.md','docs/PROJECT_BRIEF.md'}
    new_untracked = sorted(set(current_untracked)-set(s['untracked_files']))
    unexpected = [p for p in changed if p not in allowed_docs]
    unexpected += [p for p in new_untracked if not p.startswith('reports/m5b0_global_canny_architecture/')]
    result = dict(date=datetime.now(timezone.utc).isoformat(),
                  status='PASS' if not mismatches and actual==known and not missing_untracked
                  and not cached and not unexpected and head==s['head']
                  and branch=='codex/m5b0-global-canny-architecture' else 'FAIL',
                  before_sha256=hashlib.sha256(before.read_bytes()).hexdigest(),
                  hashed_files=len(s['files']),hashed_bytes=sum(r['bytes'] for r in s['files']),
                  metadata_only_locked=s['locked_unreadable'],mismatch=mismatches,
                  new_protected_files=sorted(actual-known),missing_protected_files=sorted(known-actual),
                  historical_untracked=len(s['untracked_files']),missing_historical_untracked=missing_untracked,
                  branch=branch,head=head,index_empty=not cached,tracked_modified=changed,
                  current_untracked_count=len(current_untracked),new_untracked=new_untracked,
                  unexpected_changes=unexpected)
    (HERE/'PROTECTED_BASELINES_AFTER.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
    print(json.dumps({k:v for k,v in result.items() if k!='new_untracked'},indent=2))
    assert result['status']=='PASS', 'protection/Git scope check failed'


if __name__ == '__main__':
    execute()
