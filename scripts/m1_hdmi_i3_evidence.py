"""Fail-closed parsers shared by archive, validation and negative fixtures."""
from pathlib import Path
import hashlib, math, re
NAME = 'Ti60_HDMI_1080P_Test'
ENDPOINTS = {f'tmds_lvds_tx_data{lane}[{bit}]' for lane in range(3) for bit in range(10)}
NUMBER = r'[-+]?\d+(?:\.\d+)?'
def require(ok, reason):
    if not ok:
        raise ValueError(reason)
def file_record(path):
    return {'path': path.resolve().as_posix(), 'bytes': path.stat().st_size,
            'sha256': hashlib.sha256(path.read_bytes()).hexdigest().upper()}
def verify_record(row):
    require(isinstance(row, dict) and set(('path', 'bytes', 'sha256')) <= row.keys(), 'missing hash record')
    actual = file_record(Path(row['path']))
    require(all(actual[k] == row[k] for k in actual), 'stale hash: ' + row['path'])
def flow_status(text, expected):
    rows = re.findall(r'^\s*(\w+)\s*:\s*(\S+)\s*$', text, re.M)
    result = {}
    for stage in expected:
        values = [status for name, status in rows if name == stage]
        require(values == ['PASS'], 'failed/missing/duplicate flow status: ' + stage)
        result[stage] = {'status': values[0], 'individual_exit_code': None,
                         'individual_exit_code_not_separately_captured': True}
    return result

def path_report(text, kind, serializer=False):
    require(re.search(r'^Timing Model:\s*I3\s*$', text, re.M) and re.search(r'^Version:\s*2025\.1\.110\.5\.9\s*$', text, re.M), 'wrong/missing I3 report header')
    require(re.search(r'User command: report_timing .*-' + kind + r'\b', text), 'wrong timing check type')
    blocks = re.split(r'^\+\+\+\+ Path \d+ \++\s*$', text, flags=re.M)[1:]
    count = 30 if serializer else 10
    require(len(blocks) == count, 'missing timing paths')
    ends, slacks = [], []
    for block in blocks:
        end = re.findall(r'^Path End\s*:\s*(\S+)\s*$', block, re.M)
        slack = re.findall(r'^Slack\s*:\s*(' + NUMBER + r')\s+\(', block, re.M)
        require(len(end) == len(slack) == 1, 'malformed timing path')
        ends.append(end[0]); slacks.append(float(slack[0]))
    require(all(math.isfinite(x) and x > 0 for x in slacks), 'nonpositive slack')
    summary = re.findall(r'^\s*\d+\s*\|\s*(' + NUMBER + r')\s*\|', text.split('++++ Path 1')[0], re.M)
    require([float(x) for x in summary] == slacks, 'missing/inconsistent timing summary')
    if serializer:
        require(set(ends) == ENDPOINTS and len(set(ends)) == 30, 'missing/duplicate TMDS endpoint')
    else:
        require(all('|' in x for x in ends), 'internal path endpoint expected')
    return {'paths': len(blocks), 'minimum_slack_ns': min(slacks)}

def standard_timing(text):
    require(re.search(r'^Timing Model:\s*I3\s*$', text, re.M) and re.search(r'^Version:\s*2025\.1\.110\.5\.9\s*$', text, re.M), 'wrong standard timing report')
    result = {}
    for name, begin, end in [('setup', 'Setup (Max) Clock Relationship', 'Hold (Min) Clock Relationship'),
                              ('hold', 'Hold (Min) Clock Relationship', 'NOTE:')]:
        require(text.count(begin) == 1, 'missing clock relationship')
        section = text.split(begin)[1].split(end)[0]
        rows = re.findall(r'^\s*clk_pixel\s+clk_pixel\s+(' + NUMBER + r')\s+(' + NUMBER + r')\s+\(R-R\)\s*$', section, re.M)
        require(len(rows) == 1 and float(rows[0][1]) > 0, 'negative/missing internal ' + name)
        result[name] = float(rows[0][1])
    return result

def coverage(text):
    for name, count in [('no_clock', 0), ('unconstrained_internal_endpoints', 0), ('multiple_clock', 0),
                        ('no_input_delay', 2), ('no_output_delay', 7)]:
        values = re.findall(r'checking ' + name + r' \((\d+)\)', text)
        require(values == [str(count), str(count)], 'unexpected timing coverage: ' + name)
    for name in ['pll_27m_LOCKED', 'sys_pll_LOCKED', 'sys_pll_RSTN'] + [f'led_o[{i}]' for i in range(6)]:
        require(re.search(r'^' + re.escape(name) + r'\s*$', text, re.M), 'missing documented I/O exception')
    return True

def binding(data, root):
    require(data.get('schema') == 1 and type(data.get('exit_code')) is int and data['exit_code'] == 0, 'STA failed/missing exit')
    require(data.get('project_api_timing_model') == 'I3', 'missing project API I3')
    before, after = data['original_before'], data['original_after']
    require(before and before == after and data.get('original_unchanged') is True, 'changed/missing implementation snapshots')
    work = root / 'efinity/m1_hdmi_i3'
    expected = {p.resolve().as_posix() for folder in ('outflow', 'work_pnr') for p in (work / folder).rglob('*') if p.is_file()}
    expected |= {(work / (NAME + suffix)).resolve().as_posix() for suffix in ('.xml', '.peri.xml', '_I3.sdc')}
    require({r['path'] for r in before} == expected and len(before) == len(expected), 'incomplete implementation snapshot')
    for row in before:
        verify_record(row)
        require(Path(row['path']).stat().st_mtime_ns == row['mtime_ns'], 'implementation timestamp changed')
    pairs = data['clone_initial_pairs']
    require(len(pairs) == len(before) and {p['original']['path'] for p in pairs} == expected, 'incomplete clone inputs')
    regenerated = {NAME + s for s in ('.pnr.rpt', '.sta.out', '.timing.rpt', '.prevpr.vdb')}
    regenerated |= {'m1_hdmi_i3_' + n + '.rpt' for n in ('check_timing','clocks','serializer_setup','serializer_hold')}
    regenerated.add('sdc_file_list')
    for pair in pairs:
        verify_record(pair['original'])
        require(Path(pair['copy']['path']).resolve() == Path(data['cwd']).resolve() / Path(pair['original']['path']).relative_to(work), 'wrong clone path')
        require(pair['original']['sha256'] == pair['copy']['sha256'] and pair['original']['bytes'] == pair['copy']['bytes'], 'clone differs')
        if Path(pair['copy']['path']).name not in regenerated:
            verify_record(pair['copy'])
    clone = Path(data['cwd']).resolve()
    require(clone.is_relative_to((work/'work').resolve()), 'audit is not isolated')
    require(Path(data['redirected_sdc_list']['path']).read_text().strip() == str(clone / (NAME + '_I3.sdc')), 'wrong redirected SDC')
    require(file_record(clone/(NAME+'_I3.sdc'))['sha256'] == file_record(work/(NAME+'_I3.sdc'))['sha256'], 'SDC copy differs')
    reports = data['reports']
    expected_reports = {str((root / 'reports/m1_hdmi_i3' / ('m1_hdmi_i3_' + n + '.rpt')).resolve().as_posix()) for n in ('internal_setup', 'internal_hold', 'serializer_setup', 'serializer_hold', 'check_timing', 'clocks')}
    require(len(reports) == 6 and {r['path'] for r in reports} == expected_reports, 'missing bound report')
    for row in reports + [data[k] for k in ('redirected_sdc_list', 'audit_tcl', 'copied_audit_tcl', 'log', 'bitstream')]:
        verify_record(row)
    require(data['audit_tcl']['sha256'] == data['copied_audit_tcl']['sha256'], 'audit Tcl differs')
    log = Path(data['log']['path']).read_text()
    require('ACTUAL_TIMING_MODEL I3' in log and 'M1_I3_AUDIT_COMPLETE' in log and 'Successfully reloaded trace' in log, 'incomplete STA log')
    require(data['bitstream']['bytes'] == 1626948 and data['bitstream']['sha256'] == 'D96068C5D88EE861FD70F1FF4C82221DAE5582E5C1642366A631B053EA7B3E89', 'wrong approved bit')
    return True
