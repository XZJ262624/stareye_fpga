"""Software-only independent checks; output confined to a new review directory."""
import hashlib
import json
from array import array
from fractions import Fraction
from pathlib import Path
import random
import sys

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import models as m
import run_models
import check_addresses
import protocol_model
import calculate_bandwidth


def component_gold(c, w, h):
    seen, out = set(), bytearray(len(c))
    for origin, value in enumerate(c):
        if not value or origin in seen:
            continue
        stack, group, strong = [origin], [], False
        seen.add(origin)
        while stack:
            i = stack.pop()
            group.append(i)
            strong |= c[i] == 2
            for j, v in enumerate(c):
                if v and j not in seen and max(abs(i % w-j % w), abs(i // w-j // w)) == 1:
                    seen.add(j)
                    stack.append(j)
        if strong:
            for i in group:
                out[i] = 1
    return out


def literal_2d(c, w, h):
    a = [[c[y*w+x] == 2 for x in range(w)] for y in range(h)]
    times, scans = [0 if v == 2 else -1 for v in c], 0
    while True:
        changed = False
        for rev in (False, True):
            scans += 1
            for y in (range(h-1, -1, -1) if rev else range(h)):
                for x in (range(w-1, -1, -1) if rev else range(w)):
                    if c[y*w+x] == 1 and not a[y][x] and any(
                        a[yy][xx] for yy in range(max(0, y-1), min(h, y+2))
                        for xx in range(max(0, x-1), min(w, x+2))
                    ):
                        a[y][x], times[y*w+x], changed = True, scans, True
        if not changed:
            return bytearray(v for row in a for v in row), scans, times


def union_find_gold(c, w, h):
    parent, rank = array('i', range(len(c))), bytearray(len(c))
    def find(i):
        while parent[i] != i:
            parent[i] = parent[parent[i]]
            i = parent[i]
        return i
    def union(a, b):
        a, b = find(a), find(b)
        if a == b:
            return
        if rank[a] < rank[b]:
            a, b = b, a
        parent[b] = a
        if rank[a] == rank[b]:
            rank[a] += 1
    for y in range(h):
        for x in range(w):
            i = y*w+x
            if not c[i]:
                continue
            if x and c[i-1]:
                union(i, i-1)
            if y:
                for xx in range(max(0, x-1), min(w, x+2)):
                    j = (y-1)*w+xx
                    if c[j]:
                        union(i, j)
    roots = {find(i) for i, v in enumerate(c) if v == 2}
    return bytearray(bool(v) and find(i) in roots for i, v in enumerate(c))


def execute():
    out = HERE / 'root_replay'
    out.mkdir(exist_ok=True)
    source_names = ('models.py', 'run_models.py', 'check_addresses.py',
                    'protocol_model.py', 'calculate_bandwidth.py')
    hashes = {n: hashlib.sha256((HERE/n).read_bytes()).hexdigest() for n in source_names}
    rng, cases, pixels = random.Random(50707), 0, 0
    for w, h in ((1,1), (1,7), (7,1), (2,2), (3,3), (5,4), (9,7)):
        for _ in range(90):
            c = rng.choices((0,1,2), weights=(6,10,1), k=w*h)
            gold = component_gold(c, w, h)
            literal, scans, times = literal_2d(c, w, h)
            event, es, et = m.raster_event(c, w, h)
            assert gold == literal == event == m.bfs_gold(c,w,h)[0] == m.jacobi_literal(c,w,h)[0]
            assert scans == es and times == list(et)
            cases, pixels = cases+1, pixels+w*h
    for c,w,h in (([1,2],2,1), ([2,0,0,1],2,2)):
        assert component_gold(c,w,h) == m.raster_event(c,w,h)[0]
    # A deliberately corrupted mask must fail the same equality check.
    gold = component_gold([2,1],2,1)
    bad = bytearray(gold)
    bad[1] ^= 1
    try:
        assert bad == gold
    except AssertionError:
        mutation_rejected = True
    else:
        raise AssertionError('corrupted result was accepted')
    w,h = 1280,720
    c = bytearray(w*h)
    for x in range(0,w,2):
        for y in range(h):
            c[y*w+x] = 1
        if x+2 < w:
            c[(h-1 if (x//2)%2 == 0 else 0)*w+x+1] = 1
    c[0] = 2
    gold = union_find_gold(c,w,h)
    event, scans, _ = m.raster_event(c,w,h)
    bfs, distance, _, _ = m.bfs_gold(c,w,h)
    assert event == bfs == gold and scans == 642
    full = dict(pixels=w*h, retained=sum(gold), scans=scans, pairs=scans//2,
                jacobi_scans=distance+1, input_sha256=hashlib.sha256(c).hexdigest(),
                mask_sha256=hashlib.sha256(gold).hexdigest())
    results = run_models.execute(out)
    existing = json.loads((HERE/'MODEL_RESULTS.json').read_text(encoding='utf-8'))
    for got, ref in zip(results['cases'], existing['cases']):
        assert {k:v for k,v in got.items() if k!='cpu_seconds'} == {k:v for k,v in ref.items() if k!='cpu_seconds'}
    assert len(results['cases']) == len(existing['cases']) == 30
    check_addresses.execute(out)
    protocol_model.execute(out)
    calculate_bandwidth.execute(out, out/'MODEL_RESULTS.json', 60)
    b = calculate_bandwidth.calculate(60)
    assert b['clock_based_video_Bps'] == float(Fraction(74400000,1650*750)*921600+60*921600)
    assert b['job_fixed_bytes'] == 807424 and b['per_scan_total_bytes'] == 460800
    assert 807424+642*460800 == 296641024
    for fps in (-1, float('nan'), float('inf')):
        try:
            calculate_bandwidth.calculate(fps)
        except ValueError:
            pass
        else:
            raise AssertionError('invalid camera fps accepted')
    address = json.loads((out/'DDR_ADDRESS_MAP.json').read_text())
    ranges = sorted(address['ranges'], key=lambda r:r['start'])
    assert ranges[0]['start'] == 0 and ranges[-1]['end'] == 2**32
    assert all(r['end']-r['start'] == r['bytes'] for r in ranges)
    assert all(a['end'] == b['start'] for a,b in zip(ranges,ranges[1:]))
    assert hashes == {n:hashlib.sha256((HERE/n).read_bytes()).hexdigest() for n in hashes}
    summary = dict(status='PASS_SOFTWARE_AND_STATIC_REVIEW_ONLY', random_cases=cases,
                   random_pixels=pixels, deterministic_extra_cases=2,
                   independent_gold='DFS components / full-frame union-find',
                   independent_scan_model='2D literal forward/back',
                   negative_mask_rejected=mutation_rejected, full_frame=full,
                   exhaustive_3x3=results['exhaustive_3x3'], model_cases=30,
                   full_frame_cases=results['full_frame_cases'], address_negative_cases=6,
                   protocol_cases=json.loads((out/'PROTOCOL_RESULTS.json').read_text())['case_count'],
                   camera_fps_negative_cases=3, source_sha256=hashes,
                   hardware_verified=False, production_rtl_verified=False)
    (out/'ROOT_TEST_RESULTS.json').write_text(json.dumps(summary,indent=2),encoding='utf-8')
    print(json.dumps(summary,indent=2))


if __name__ == '__main__':
    execute()
