"""M5B.0 software-only models. Python stdlib; never touches hardware or old inputs."""
from array import array
from collections import deque
import heapq


def validate(c, w, h):
    if not isinstance(w, int) or not isinstance(h, int) or len(c) != w * h or min(w, h) < 1 or any(not isinstance(v, int) or not 0 <= v <= 2 for v in c):
        raise ValueError('classification shape or reserved code 11')


def bfs_gold(c, w, h):
    """Independent coordinate BFS, initialized with ALL strong pixels."""
    validate(c, w, h)
    out = bytearray(len(c))
    distance = array('i', [-1]) * len(c)
    q = deque()
    for i, v in enumerate(c):
        if v == 2:
            out[i] = 1
            distance[i] = 0
            q.append((i % w, i // w))
    peak = len(q)
    visited = 0
    while q:
        x, y = q.popleft()
        visited += 1
        for dy in (-1, 0, 1):
            for dx in (-1, 0, 1):
                if dx == dy == 0:
                    continue
                xx, yy = x + dx, y + dy
                if 0 <= xx < w and 0 <= yy < h:
                    j = yy * w + xx
                    if c[j] == 1 and not out[j]:
                        out[j] = 1
                        distance[j] = distance[y * w + x] + 1
                        q.append((xx, yy))
        peak = max(peak, len(q))
    return out, max(distance, default=-1), visited, peak


def neighbors(i, w, h):
    x, y = i % w, i // w
    lo, hi = max(0, x - 1), min(w, x + 2)
    for yy in range(max(0, y - 1), min(h, y + 2)):
        for xx in range(lo, hi):
            j = yy * w + xx
            if j != i:
                yield j


def jacobi_literal(c, w, h):
    """Whole old image read before next image write, includes zero-change scan."""
    validate(c, w, h)
    cur = bytearray(v == 2 for v in c)
    scans = 0
    while True:
        nxt = bytearray(cur)
        for i, v in enumerate(c):
            if v == 1:
                nxt[i] = any(cur[j] for j in neighbors(i, w, h))
        scans += 1
        if nxt == cur:
            return nxt, scans
        cur = nxt


def raster_literal(c, w, h):
    """Gauss-Seidel all 8 neighbors; forward then reverse; pair changed reduction."""
    validate(c, w, h)
    cur = bytearray(v == 2 for v in c)
    activation = array('i', [0 if v == 2 else -1 for v in c])
    scans, changes = 0, []
    while True:
        pair_changed = False
        for order in (range(len(c)), range(len(c)-1, -1, -1)):
            scans += 1
            changed = 0
            for i in order:
                if c[i] == 1 and not cur[i] and any(cur[j] for j in neighbors(i, w, h)):
                    cur[i] = 1
                    activation[i] = scans
                    changed += 1
            changes.append(changed)
            pair_changed |= bool(changed)
        if not pair_changed:
            return cur, scans, activation, changes


def raster_event(c, w, h):
    """Exact scan-arrival solver, NOT cycle-accurate hardware simulation.

    A seed is present before scan 1. A weak activated at scan s is visible later
    in that scan, or in scan s+1 after reversal. Nonnegative FIFO arrival edges
    permit heap shortest-arrival relaxation. Small tests compare EVERY arrival.
    """
    validate(c, w, h)
    inf = len(c) + 2
    times = array('i', [0 if v == 2 else inf for v in c])
    queue = []
    # Strong pixels need no queue storage. Their weak neighbors start at scan 1.
    for i, v in enumerate(c):
        if v == 1 and any(c[j] == 2 for j in neighbors(i, w, h)):
            times[i] = 1
            queue.append((1, i))
    heapq.heapify(queue)
    while queue:
        s, i = heapq.heappop(queue)
        if times[i] != s:
            continue
        for j in neighbors(i, w, h):
            if c[j] != 1:
                continue
            same_scan = (j > i) if s & 1 else (j < i)
            arrival = s if same_scan else s + 1
            if arrival < times[j]:
                times[j] = arrival
                heapq.heappush(queue, (arrival, j))
    out = bytearray(t != inf for t in times)
    last = max((t for t in times if t != inf), default=0)
    scans = 2 * ((last + 1) // 2 + 1)
    activation = array('i', [-1 if t == inf else t for t in times])
    return out, scans, activation


def pack(c, bits):
    per = 8 // bits
    out = bytearray((len(c) + per - 1) // per)
    for i, v in enumerate(c):
        if v >= 1 << bits:
            raise ValueError('packing overflow')
        out[i // per] |= v << (bits * (i % per))
    return out


def unpack(buf, n, bits):
    per = 8 // bits
    return bytearray((buf[i // per] >> (bits * (i % per))) & ((1 << bits) - 1) for i in range(n))


def burst_plan(start, size, max_beats=128):
    """16-byte beats, INCR, no burst crossing 4KiB. Payload must be beat-aligned."""
    if start < 0 or start % 16 or size % 16 or size <= 0:
        raise ValueError('alignment')
    ans = []
    while size:
        n = min(size, max_beats * 16, 4096 - start % 4096)
        ans.append((start, n))
        start += n
        size -= n
    return ans
