# Deadline fix: bounded gate handback

Canonical change is exactly `!pair_wait_expired&&` in backend pair_selected. Current backend SHA256 is 8a78aa7030d6bdcd27d8e50c1e633e3d9353709c1ae2cfb814606fe37a18c82c. Parent is 99ea359c6a5f5432296e992ec76495e441c9d1a0. No other RTL change, Git write, hardware operation, or new long local video test.

| Evidence directory | Actual result and scope |
|---|---|
| old_repro_v2_230344 | Actual parent backend, unique DEADLINE_NEW_SELECT_AFTER_EXPIRY; same-acquire-edge expired input. |
| fixed_repro_230536 | Same-edge expired refuses selection; zero attempts; reason23; normal lease releases. |
| early_deadline_230731 | Expiry latched eight UI cycles before releasing queued acquire; refuses new selection. |
| windows_231101 | Both actual telemetry states23/24; real producer and packet DONE/TAKE. Raw request0/cache valid1/full SID match/fresh1/expired1/select0. Explicit external fusion client, not whole display pipeline. |
| system_deadline_v2_231423 | Actual system 7200-SOF budget after COV wait starts and actual 2FF UI transfer. No full video traffic. |
| inflight_deadline_v3_231239 case0 ONLY | Selected before expiry, late ACK/arm/capture/export/release succeeds; next publication. Overall directory remains NOT_PASS because its original case1 assertion was stale. |
| inflight_deadline_v5_232054 case1 | Real capture kill; W delivery held33 cycles; currentB1/metaB0; actual first completion reason3 followed by expiry termination reason23, attempts remains1; real release then next publication. |
| deadline_backpressure_v2_232428 case0 | Real current B and export final R delivery each delayed32 cycles; owner remains held; currentB2/metaB1; release after lastB; complete pair and next publication. This delays R delivery, not an RVALID-held/RREADY-low test. |
| multisof_v3_231954 | Actual display_session, both request mailboxes and fusion_display: stale SID1 vs current12 refuses selection without consuming fresh/attempt; next real SOF13 selects same publication and reaches real display admission/arm. Prefilled1/ref_ready0 are environment inputs; stops at control admission, not full pixel/DDR-prefill or release coverage. |
| deadline_mutant_232212 | One exact gate removal, inverse equals parent backend; compile0, unique DEADLINE_NEW_SELECT_AFTER_EXPIRY. |
| metadata_test_232304 | Pure host current-input pre/post helper test, including changed input rejection. Not yet a V4 package execution receipt. |

SHORT_WIRE_CHECK.json independently decodes seven actual emitted UART streams with unchanged trusted pack5 decoder in explicit reduced-plane mode (1600/512/512). Success cases have one complete pair; deadline cases have reason23; kill case contains exact ordered reasons3 then23. No production-size pixel/BFS claim follows from these short streams.

Original failures remain intact: declaration/compile/load fixture failures; old prompt-ACK classification; v3/v4 cancellation assertion incorrectly reading mutable failure after the first failure packet. The latter raw first completion is reason3, while the subsequent legitimate terminal expiry changes live failure to23. New v5 checks both real packet completions and drain/recovery. No failed receipt is rewritten as PASS.

Capture SEPARATE_ELIGIBILITY=1 is explicit in the current inflight/queue-derived tests. Unconnected reset_done/fifo_faults/read_permission monitor outputs are disclosed; they are not safety inputs. No new eight-complete-attempt video run was done: controller attempt bound is unchanged, and these tests exercise post-selection completion and deadline terminal behavior at attempt0/1. High-level exhaustive arbitration or all physical clock phases is not claimed.

Next internal gate: Work approval to fresh-map the frozen one-gate source and prepare V4. V4 will retain V3 workload/oracles but produce actual current63 input records from current manifest plus pre/post file bytes; original V3 metadata remains unchanged. New physical timing/CDC/resource and remote full video must be separately established. Old physical/bit results do not qualify this edit.
