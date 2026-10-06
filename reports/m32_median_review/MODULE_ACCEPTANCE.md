# M3.2 median module independent acceptance

Verdict: **PASS** for standalone module; integration is now authorized. No hardware acceptance claimed.

## Integrity and scope
ZIP 58,427,385 bytes, SHA-256 b0a6a8ae3319fef26ba2c9d75d21837b8219f6b04ed295d0d4f2ce87f8200d48. 79 files / 75,382,662 expanded bytes. All under task_workspace; no traversal, absolute names, symlinks, executable or unknown binary. 77 CSV rows and 78 SHA rows verified; CSV excludes both index files and SHA includes CSV but excludes itself. Complete inventory: FILE_INVENTORY.csv. Extracted inputs rechecked after testing. All 1,412 protected original files retain contents, sizes and mtimes.

## RTL and latency
Exact unsigned median of nine: nine alternating odd/even registered compare-exchange stages, 36 comparisons, sorted lane 4. No mean or approximate selection. 8-bit unsigned comparisons handle 0,255 and duplicates. Core n->n+8 (9 sampling stages). Stream n->n+10 (11 samples), including original two-row buffers and row-major p00..p22 window. Filter request commits only on SOF rising edge; RAW, mode, DE/HS/VS/SOF match both paths. Center=(x-1,y-1), first two rows/columns window-invalid, no zero-padding and no full-frame cache. Asynchronous reset asserts immediately and release uses two synchronizing stages, then waits for SOF. Stream supports valid pauses, no cross-row windows. The stream out_gray retains the original raster slot; a full-system wrapper MUST reanchor median center before feeding Sobel. This wrapper requirement is not an RTL failure.

## Independent dynamic evidence
All six delivered test cases re-run in a clean source-only clone: 3,239,333 checked cycles, 2,090,089 valid outputs including two full 720p frames. Nine deliberately corrupted/truncated negative tests returned nonzero and their expected diagnostics.
ROOT independent Python sorted()[4] model: 362,880 permutations of 1..9, 512 binary windows, 20,000 additional random windows, extrema/duplicates/impulses, pauses and reset. Core 387,013 cycles / 380,486 valid outputs. Independent 13x9 stream: 22 frames, 4,503 cycles / 1,696 valid windows, salt/pepper, frame mode changes, matched bypass delay and reset/restart. One additional deliberately incorrect median golden returned nonzero. No teammate golden was imported by this independent model. An initial ROOT vector-format error (True/False instead of integer) was fixed in ROOT test script only; the failed run is retained.

## Resource/timing and limits
Delivery contains no actual Efinity synthesis or STA, so standalone mapped resource, slack and critical path are NOT VERIFIED. Exact sorting and two-line storage are synthesizable by static review; actual mapping must be measured by upcoming full I3 integration. No Efinity project was opened or changed for this acceptance. Default-bypass synthesis may optimize median logic; enabled build is also mandatory. Final integration mapping actually retains the median RAM in both variants under the inherited synthesis settings, as measured separately. Fixed-raster integration must be tested separately, including a full 5x5 median+Sobel boundary policy. M3.1 current XML differs in GUI/runtime attributes and explicit default ooc=false; full repeated-node canonical comparison is separately recorded. No inferred board safety or noise cause; old Flash camera-pin cold-start risk remains.

## Decision
No module blocker found by Astra/Ultra or independent ROOT review. Permit new branch/new-copy integration only, never replace M2/M3/M3.1. Stop after offline simulation and complete I3 build/STA. No Programmer, download, Flash or automatic Git commit. ROOT_MODULE_EVIDENCE.json binds fresh sources, commands and outputs; raw delivery PASS reports are not used as current execution proof.
