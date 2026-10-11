# M5B.1 repair build and timing — current

Required parent `264962e0c6af61e751c794c5b5f5252d00edbb6c`. Current machine gate: `OFFLINE_ACCEPTANCE.json` in this directory. Root older reports/bit metadata remain historical evidence for the rejected first candidate.

`build_20261010_235246` completes map, interface, P&R, programming-file generation and bit export with exit 0. Programming-file generation is an offline compiler phase, not Programmer/download. Resources: **45042 XLR / 124 RAM10 / 0 DSP**, within 48640 / 204 / 128. All 96 final inputs and 53 outputs are byte/hash bound. The saved project-before and project-after XML differ only in tool `last_change`/`last_run_flow`; exact inverse substitution restores the before bytes. Production RTL/SDC have not changed after the build. The archived previous bit is preserved.

New bit: `efinity/m5b1_global_canny_i3/outflow/Ti60_Demo.bit`, **2924727 bytes**, SHA-256 **8bc85b157426cf35e7aab31bc4acd1c8c54b5799c0e7a0424ee555f3927488c4**. It is generated locally and deliberately excluded from Git; the build receipt binds it.

I3 full STA completes with 134 coverage reports. These are path/check reports, **not 134 independent PVT corners**. The tool's final t16ff grade-3 model is labelled typical process, characterized −40..100°C and 0.95V ±30mV. Setup minimum **+0.196ns**, hold minimum **+0.027ns**; HDMI setup/hold +10.553/+0.095ns. This signoff model coverage is not an on-board PVT sweep.

New internal no-clock / unconstrained / multiple-clock counts are **0 / 0 / 0**. Seven external no-input and 135 no-output-delay endpoints are explicit legacy/asynchronous I/O boundaries, not hidden internal exceptions; UART is asynchronous serial. The XML-selected `Ti60_Demo_I3.sdc` matches the actual STA clone SDC list and exact file bytes. Whole clock-domain false paths are absent.

The mapped primitive audit covers FF D/CE/SR, SRL and RAM port clocks: **457 classified crossings**, zero unapproved crossings and zero unknown internal crossings; no new SRL synchronizers (the historical 576 same-domain SRLs remain). External camera/unclocked input and encrypted PLL/IP boundaries remain explicit UNKNOWN categories, not a claim of zero risk. Three true dual-clock FIFO RAM banks are approved asynchronous storage; engine copy/export RAM is UI synchronous.

The mapped-netlist-bound selector manifest checks **940 exact pins in 25 groups**. Physical checks cover **413 destination data endpoints in ten Gray/mailbox groups**; maximum clock-to-Q plus data delay **1.415ns**, maximum arrival skew **0.825ns**, against a 5ns data budget and 10ns fastest source period. The 457 structural crossings, 413 timed data endpoints and 940 selected pins count different objects. Mailbox stable sampling windows and first-stage-only control cuts are retained; downstream synchronizer stages remain timed.

`final/final_sta/binding.json`, `final/CDC_STRUCTURAL_AUDIT.json`, `final/CDC_PIN_MANIFEST.json` and `final_build/*.rpt` provide fixed evidence. Static protection verifies 1924 original non-rule tracked files plus the two original append-only rule baselines (1926 records), all 2139 historical untracked paths present, and copied source provenance. .gitignore/.gitattributes are unchanged from parent 264962e0. Full technical dependencies and actual repair Git changes are distinguished in TECHNICAL_DEPENDENCIES and PROPOSED_GIT_SCOPE.

The explicit watchdog hard-stop VALID withdrawal and cold-reconfiguration restriction in IMPLEMENTATION remain material limitations. Independent A/B review and user hardware validation are still required.
