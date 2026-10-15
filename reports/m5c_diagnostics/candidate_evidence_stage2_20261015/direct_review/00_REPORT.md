# Stage1 handback: standalone diagnostic observer

Result: PASS_FOCUSED_STANDALONE_ONLY. Nine positive cases passed actual ModelSim compilation/simulation and independent complete40-word oracle; four independently compiled fault variants each hit their own unique named Fatal. Native ModelSim exit0 for expected Fatal is disclosed, not treated as positive simulation success. All command lines, owner PID/time, exit/no-timeout, input snapshots and logs are retained. No active owned native remains after synchronous runner exit. No production integration, synthesis, placement, timing, UART wire simulation or hardware is claimed.

Branch codex/m5c-fusion-prototype; existing fixed candidate3b49a1f701798a817fed42b8097f724cbc9d6160 unchanged. No candidate created. Four tracked management documents changed by Work; no production tracked source change or staged file. Exact check receipt is PROTECTION.json, not a replacement for historical protection seals.

## Actual evidence
Main positives and row negative: stage1_20261015_143117. Remaining preOSD/mode/identity negatives: stage1_20261015_143652, with explicit parent result/hash resume receipt. Additional invalid qualification case: stage1_20261015_143838. Earlier failed compile, inverse-generator assertion and mistyped recovery path remain in HISTORY.json and original directories. The recovery path failure was pre-native, not a DUT failure. All successful RTL/TB/OSD/oracle inputs remained unchanged through each run.

| Case | Independently checked P0,P1,P2,P3,P4 |
|---|---|
|0|[233, 150, 150, 150, 88]|
|1|[233, 150, 150, 0, 0]|
|2|[1, 1, 1, 1, 1]|
|3|[31, 19, 19, 19, 19]|
|4|[4294967295, 4294967295, 4294967295, 4294967295, 4294967295]|
|5|[233, 150, 150, 150, 88]; [233, 150, 150, 150, 88]|
|6|[233, 150, 150, 150, 88]|
|7|[0, 0, 0, 0, 0]|

Case0 includes row gating and actual existing production m5a_osd overlay. Case1 mode2 feeds cyan RGB deliberately but expects zero P3/P4. Case2 only last pixel contributes, proving registered OSD EOF tail inclusion. Case3 abort preserves partial counts and excludes kill edge. Case4 explicitly seeds five counter flops at max-1 in the isolated TB to check saturation (not a real multi-billion-pixel frame). Case5 includes missing-context periodic drop, busy drop, ready/ACK, next full64SID and second periodic record. Case6 resets an active partial observation and verifies no stale ready/data escapes. Case7 zero/no-difference. The extra invalid case changes every supplied predicate qualification and rejects the first unqualified class mismatch before recording a later qualified one. These are finite tests, not exhaustive reset-phase or formal equivalence proofs.

The four mutation names are DIAG_ROW_GATE_REMOVED, DIAG_PRE_OSD_USED, DIAG_MODE_IGNORED and DIAG_IDENTITY_EARLY_OVERWRITE. Original observer vs each fault is recorded in DERIVATION JSON with exact inverse scope; preOSD changes each use of the same counting source error, not unrelated behavior. Identity mutation rereads live descriptor while READY; test poisons live descriptor/epoch/token after capture and catches storage corruption. This does not prove the production source can satisfy PREP stability; that remains an explicit adapter contract.

The oracle reconstructs all counters from stimulus event trace independently of observer state/counters, constructs complete metadata/header/reserved words from known full-width stimuli, compares every RAM word and repeats after40clocks READY to verify immutability. It formats the actual RAM bytes into324B host packets with CRC32. This is neither actual UART serialization nor a production source/DDR capture test; source/class/qualification events are synthetic, with real existing OSD module coupled. No pixel reference from DUT output is used for P0/P1 expectation. P2 in this harness comes from an independently wired fully qualified producer expression; actual production P2 binding remains future work.

## Scope and next gate
STAGE1_FIELD_EDGE_SPEC.md is the exact proposed type5/schema1 byte/edge contract and binding proposal. Metadata is pre-copied21clocks into RAM, then locked to matching full64 frame SID at admit; live metadata is never read at EOF. Stable complete source tuple during PREP must be proven on the production connection. The full160bit config, full64frame/source/session/token/slot generation fields remain intact. P4 is actual registered OSD RGB with matched previous accepted event, including last pixel. CE qualification and real signal alignment require production-coupled validation before adoption.

Approximate551 declared sequential bits plus2560RAM bits is NOT a resource result. With only633XLR margin, added logic/routing/CDC/storage may exceed the limit even if RAM inference succeeds. No2048FF snapshot is used, but production RAM/CDC/packet bridge design is not yet frozen. Do not integrate or build on an assumed fit; preserve all widths and return to Work if budget cannot close.

Work next needs to approve the exact schema and independent-event bindings, genuine stable tuple preparation, actual CE/tail/kill behavior, observer-only drop policy and RAM/CDC/UART packet ownership. Then freeze specific production port/top/transport edits and new coupled tests/resource gate. Existing visible enhancement acceptance, default UART startup/TTL boundary, cold-only reset, external interfaces/PVT and hardware gates are unchanged. No algorithm/row-match/TTL/support guard was relaxed. This package stops at internal Stage1 review.
