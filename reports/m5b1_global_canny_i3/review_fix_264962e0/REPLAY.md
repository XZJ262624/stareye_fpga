# Repair evidence and replay

Required parent: `264962e0c6af61e751c794c5b5f5252d00edbb6c`.

Current entries are OFFLINE_ACCEPTANCE.json, IMPLEMENTATION.md, BUILD_REPORT.md, EVIDENCE_SUMMARY.json, TECHNICAL_DEPENDENCIES.json and PROPOSED_GIT_SCOPE.json in this directory. The latter separates actual `changed_paths` from full technical `files`. File byte/SHA fields describe normalized Git blobs; working-byte fields separately bind the Windows files. Its own path is excluded from its self-hash. Work verifies the fixed candidate and parent, then snapshots only committed technical files. BASELINE_PROTECTION and raw historical/private untracked data must not be sent externally.

Tools: Efinity 2025.1.110.5.9, ModelSim SE-64 10.1c and Python with NumPy. The local Python is `C:/Users/kqojp/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`; tools reside under E:/Efinity/2025.1 and E:/Modelsim_10.1c. No installation, hardware or network operation is needed. ModelSim may require normal approved process escalation because the desktop sandbox's DLL relocation failed; no approval bypass is part of replay.

From repository root, substitute the real Python for `python`:

```text
python -B scripts/m5b1_review_suite.py core --run reviewer1
python -B scripts/m5b1_review_suite.py negative --run reviewer1
python -B scripts/m5b1_review_suite.py recovery --run reviewer1
python -B scripts/m5b1_review_repro.py --case connection --mode 1 --name reviewer_connection
python -B scripts/m5b1_review_repro.py --case connection --mode 2 --name reviewer_midloss
python -B scripts/m5b1_review_repro.py --case connection --mode 3 --name reviewer_zero
python -B scripts/m5b1_review_repro.py --case default_timeout --mode 0 --name reviewer_default_capture
python -B scripts/m5b1_review_repro.py --case default_timeout --mode 1 --name reviewer_default_engine
python -B scripts/m5b1_review_repro.py --case default_timeout --mode 2 --name reviewer_default_export
```

Choose unused output names; these runners refuse to overwrite existing case receipts. The default export really simulates 960M UI cycles and is long. The original seven groups are selected by m5b1_replay.py; run them only in a disposable checkout or after preserving their fixed output directories. Historical untracked bootstrap/patch helpers are excluded and are not replay dependencies. Build/STA tools are m5b1_build.py, m5b1_sta.py, m5b1_cdc_audit.py and m5b1_static.py. The compile/map .bat wrappers contain the original absolute F:/Projects/stareye_fpga path: launching them unchanged from a different checkout still targets that original workspace. A reviewer must inspect and relocate those paths only in their disposable copy before a fresh isolated build, or run within the explicitly authorized original workspace. The existing receipts bind the original wrappers unchanged. The encrypted IP and unchanged reference RTL/golden scripts required by a complete checkout are listed in TECHNICAL_DEPENDENCIES.

The current local aggregate validator intentionally checks all original raw log/build hashes and HEAD=required_parent before candidate creation; it is not a raw-artifact-free snapshot command. In a fixed candidate, use `m5b1_scope.py --candidate <full-commit>` to verify Git scope and blobs (Windows working-newline metadata is separately checked). Independent fresh simulations create their own receipt/source/log/exit bindings. Full stdout/stderr and exit receipts distinguish a launched simulator from a successful oracle; a zero exit alone is insufficient.

Final current groups: final/global, system_v4, system_faults_v3, directed, mutations, qos_negative, tap; suite receipts final/review_core_v6, review_negative_v6, review_recovery_v6; connection_capture_v4, connection_midloss_v4, connection_zero_v4; default_capture_v4, default_engine_v4, default_export_v3. Earlier v1..v5 receipts, absent receipts, interrupted runs and checkpoint source mismatches remain historical. In particular default_export_v2 never reached its oracle and lacks a diagnostic exit record: its cause is unknown, not retroactively PASS. The complete v3 run exits 0 and meets the default-cycle/host-CRC oracle. Failed startup raster assumptions and the original hard-stop stable-VALID failure are preserved and explained in IMPLEMENTATION.
