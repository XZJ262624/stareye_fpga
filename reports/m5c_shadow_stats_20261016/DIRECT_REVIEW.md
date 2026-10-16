# Passive matching statistics: review entry (pre-candidate)

This is development evidence, not an independent A/B review or final release gate. Technical baseline is1786858c. This entry was prepared before candidate creation; Work's fixed review receipt supplies the actual candidate identity, parent and exact scope. User M3 migration, root management documents, original hardware captures and unknown working files are outside the technical candidate. Root documentation inherited in a future isolated checkout describes its historical stage; this technical entry and the frozen review gate define the shadow-statistics change.

## Implementation

`m5c_row_fusion.sv` adds a separate passive bank of20 exact64-column flags and two row risk flags per bank. The128-column result is the AND of adjacent64-column flags. The original full-width row_y/cookie/complete state qualifies these flags. Row0-pixel initializes all flags; subsequent mismatches clear the corresponding tile. Original promotion, RGB, frame control and row lifecycle expressions are unchanged. Current map identifies88 additional shadow FFs (80tile+8risk),264 ordinary PIX D/CE/SR pins. No new shadow flag drives the production decision.

`m5c_fusion_display.sv` forwards five read-only signals. `example_top.v` wires these signals into the new observer_v3. The XML changes the observer source entry only; old observer_v2 remains byte-identical. Current SDC was not changed for this implementation; all60 exact groups were rechecked against the fresh map and native physical RAM pins.

`m5c_diag_observer_v3.sv` retains the same record lifecycle, descriptor/identity sampling, single BRAM write port, P0–P4, first difference, and DONE-to-TAKE ownership. Seven u32 saturating counters occupy payload208..235. Word29 upper32 and words30/31 remain zero. New counters contribute to the existing saturation flag. Header64+payload256+CRC4 remains324 bytes. `SHADOW_VALID_MISSING` is a simulation assertion, not a replacement for row-lifetime testing.

Schema1 is still decoded with208..255 strictly reserved and extensions absent. Schema2 reserves236..255. The production decoder requires legal0..6 mode,1280×720, coherent header/config/full identity, clock metadata and CRC. Saturated/aborted records are not forced into normal-frame inclusion relations.

## Interpretation

All seven fields count accepted P0 candidate events, not rows. Complete/tag/equality failures may overlap. Strong-loss and illegal-row are risk clues, not measured false positives. Finer shadow gates do not alter the original whole-row gate or prove current-frame global connectivity. No claim of improved visible hardware enhancement is made.

Only for complete, non-aborted, non-saturated records with P0>0 can differences such as `(shadow64_accept-P1)/P0` describe a retained-candidate opportunity. They are not false-positive rates or image-quality improvements. Strong-loss/illegal flags describe whole-row risks weighted by candidate events; this record does not contain the joint distribution of shadow-pass and risk. It therefore cannot estimate how many newly admitted candidates would be wrong. No policy benefit is scored when P0=0.

Production CE is currently constant1. CE-pause fixtures qualify observer final events explicitly. They prove bank/delay freezing and the qualified interface; they do not make arbitrary held-DE feeding safe. Complete metadata is retained at admission; OSD tail events are counted before seal.

## Evidence navigation and exceptions

`COVERAGE_PROGRESS.md` separates newly executed native tests, host-only checks, inherited unchanged modules and pending gates. `TECHNICAL_BASELINE.json` and `BASELINE_FIXED_BLOB_PROOF.json` bind six original technical files to fixed178 commit bytes. Full `BASELINE.json` stays local because it also records unrelated worktree changes. `IMPLEMENTATION_DERIVATION.json` records the implementation changes. New source/runner/checker inputs are bound per run.

The first identity mutant had a compilation error and is never counted as a sensitivity pass. The first differential fixture had declaration/unused-output binding errors and is retained; v2 compiles and compares all43 original display outputs and independent OSD on14 simultaneous baseline/current pairs. The old partial-header coupled fixture passes its exact formatter but fails the stricter production config/header check; a new legal-header fixture passes the complete real324-byte schema2 packet. The row-end mutant originally expected the64-tile failure after the earlier128-tile failure; a separate reconciliation retains that original FAIL and identifies the same omitted1279 sample. The original bridge mutant reached only a watchdog because earlyACK suppressed byte_valid; v2 adds an independent DONE ledger and rejects the actual premature TAKE by name.

Field mutant names supplied by TB plusargs are expected-word oracle failures, not independent RTL assertions for each field. `OBSERVER_NEGATIVE_ACTUAL_WORDS.json` binds the actual failing word/log and compile/native exits. ModelSim may return0 after Fatal; sensitivity acceptance requires compile success and the unique expected causal Fatal, never raw exit alone.

## Physical and system gates

Fresh placement:51321 XLR including2150routing,196RAM,1DSP;51680/204/128 hard limits,359XLR margin. Fresh route completed with the same resource counts. These are physical resource facts, not timing or hardware acceptance. Current actual-I3 queries cover25 held groups/1552 destinations, normal setup/hold, every sequential input class, RAM/native pin mapping, DSP through-paths,14-clock Cartesian pairs, backend/diagnostic controls and the88 shadow FFs. All nine actual query stages and final reconciliation completed; FULL_PHYSICAL_QUALIFICATION.json is PASS_CURRENT_I3_PHYSICAL_ONLY. Exact exceptions, current typed connections and internal0/0/0 were checked, including full8073 backend/diagnostic FF controls and88 row-shadow FFs.

Current normal I3 worst setup is+0.122ns and hold is+0.008ns. The narrow hold path is `u_m5b1/background/capture/pack_data[43]` Q to `push_data[43]` D, both on `clk_pixel`; it is not attributed to encrypted DDR or to the new shadow FFs. This is one actual I3 timing model, not cross-PVT qualification. External7 input/135 output delay boundaries remain explicit; internal no-clock/unconstrained/multiple-clock must be0/0/0. Warm reset/hot recovery and hardware behavior remain unproven in this change.

The executed TB and its parent both use a 4-second simulated watchdog (`1ns` time unit and `#4000000000.0`), with a separate 14400-second wall budget. The frozen preparation metadata incorrectly said 2 seconds; `SYSTEM_WATCHDOG_METADATA_RECONCILIATION.json` records that text-only discrepancy without altering active inputs.

The enabled system uses the existing explicit conditional1M cadence/accelerated UART model, retains all7 healthy modes, at least2 type5 records, original type1–4/BFS checks and source/UI/start/done/take/end drain. It does not prove default full-frame export startup latency or hardware behavior. Default UART packet transport is tested separately. No test or physical run is labeled complete solely because a native process exited.

At default460800 baud8N1, the first345600-byte class+mask export has a payload-only7.5s lower bound, longer than the approximately2s source TTL. Later fresh publication may be needed before useful fusion; this is a source/parameter arithmetic boundary, not a measured startup-time guarantee. No new default-rate full-frame throughput or visible-cyan hardware claim follows from accelerated simulation. Historical schema1 compatibility packets come from the prior355456-byte simulation, not user hardware captures.

Do not include work libraries, tool binaries, bit/outflow databases or user captures in the review source package. Large map/route databases can remain an explicit hashed local reproduction boundary; compact pin inventories are not substitutes for complete map logic. Offline bit conversion, final manifests and candidate scope are only valid after their own actual completion receipts.

Offline conversion completed in `offline_shadow_20261016_150745`: native exit0, no timeout, do_program/run_usbif false. Bit size3025194 bytes, SHA256 `97bd27ab0fbd6e0fbd991735f29ff3b905106e44610a0085a5c879df0339770f`. The bit is kept outside the candidate source/evidence payload; conversion does not prove hardware operation. Enabled system final seal now passes independently:355456 wire bytes, types9/1/1/18/3,18 complete original telemetry chains and3 schema2 DONE→TAKE chains. Diagnostic modes3/0/1 only; mode6 nonzero diagnostic proof remains the separate720p coupled test.
