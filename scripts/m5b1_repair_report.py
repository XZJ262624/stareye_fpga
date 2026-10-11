"""Assemble reviewable excerpts without changing historical simulation evidence."""
import json,re,hashlib,shutil
from m5b1_evidence import R,B,O,F,W,P,BUILD,GROUPS,SUITES,CASES,rec,load,git

def write(name,text):
 (O/name).write_text(text.strip()+'\n',encoding='utf-8')

def main():
 paths=[F/v/'results.json' for v in GROUPS.values()]
 paths += [O/v/'result.json' for v in CASES.values()]
 for v in SUITES.values():paths += [R/c['evidence']['path'] for c in load(F/v)['cases']]
 paths += [O/v/'result.json' for v in ['r1_original','r2_original','r3_capture_original','r3_engine_original','r3_export_original']]
 rows=[]
 for p in paths:
  d=load(p);logs=[]
  if d.get('log'):logs.append(d['log'])
  logs += [v['log'] for v in d.get('cases',d.get('tests',[])) if v.get('log')]
  extracts=[]
  for v in logs:
   text=(R/v['path']).read_text(errors='replace');assert rec(R/v['path'])==v
   lines=[line for line in text.splitlines() if re.search(r'PASS|Fatal|HARDSTOP_|CAPTURE_DESCRIPTOR_|RASTER_ACQUISITION|RECOVERY|REVIEW_R[123]',line)]
   extracts.append(dict(log=v,lines=lines))
  rows.append(dict(receipt=rec(p),status=d['status'],scope='Historical original defect reproduction' if p.parent.name.endswith('_original') else 'Current source-bound final evidence',host=d.get('host'),excerpts=extracts))
 arb='rtl/m5b1_global_canny/m5b1_arbiter.sv';old=git('show',P+':'+arb);assert old==(R/arb).read_bytes()
 tx='rtl/m5b1_global_canny/m5b1_transfer.sv';before=git('show',P+':'+tx).decode();after=(R/tx).read_text()
 gates=['assign wvalid=state==2&&!stop;','assign rready=state==4&&!stop;']
 for s in gates:assert s in before and s in after
 proof=dict(parent=P,arbiter_identical=rec(R/arb),transfer_parent_sha256=hashlib.sha256(before.encode()).hexdigest(),transfer_current=rec(R/tx),unchanged_isolation_expressions=gates,meaning='Baseline source equivalence for isolation, not a claim of AXI stable-VALID compliance after hard stop.')
 (O/'EVIDENCE_SUMMARY.json').write_text(json.dumps(dict(required_parent=P,generator=rec(__file_path()),baseline_hardstop=proof,evidence=rows),indent=2))
 dst=O/'final_build';dst.mkdir(exist_ok=True)
 for name in ['Ti60_Demo.map.rpt','Ti60_Demo.place.rpt','Ti60_Demo.route.rpt','Ti60_Demo.pt.rpt','Ti60_Demo.pinout.rpt']:
  shutil.copyfile(W/'outflow'/name,dst/name)
 write('IMPLEMENTATION.md',r'''
# M5B.1 repair implementation — current review entry

Required direct parent: `264962e0c6af61e751c794c5b5f5252d00edbb6c`. The candidate ID is the Git commit containing this report; it is intentionally not self-embedded. Current acceptance, build, dependencies and scope are in **this `review_fix_264962e0` directory**. The root M5B1 reports bound to parent `c0102ee1` describe the original candidate subsequently rejected by Codex A; they are historical, not this repair's acceptance.

Codex A found three gaps in 264962e0: the real LCD connection shifted pixels, invalid replacement frames could produce classification snapshots, and an unaccepted background transaction could prevent timeout cleanup. The five original HDL reproductions remain `EXPECTED_REPRODUCTION`. `EVIDENCE_SUMMARY.json` preserves the original failure markers and the current final markers with their log hashes. No original review or failed run is overwritten.

## R1: production display connection

The video DMA exposes its current FIFO byte combinationally; the existing LCD driver's register now supplies the intended single sampling delay. The real DMA → actual lcd_driver → M5A bench compares data on the actual receiver sampling edge, before NBA updates, against independent spatial goldens. `connection_capture_v4` checks 6,451,200 LCD, tap and seven-mode samples, with complete 720p frames and both row/frame boundaries. Reintroducing the extra register produces `REVIEW_R1_LCD_SAMPLE` (00 rather than 35). The nonuniform image remains in the principal test; the separate zero test cannot hide byte or beat shifts.

## R2: replay qualification and identity

Actual replay admission travels with the LCD sample and its frame/epoch identity. The M5A frame tag includes qualification; invalid frames still consume raw EOF tags. A midframe loss remains invalid for the rest of that frame. The connection oracle keys delayed samples and successful capture descriptors to the original qualified source frame, timestamp and epoch, rather than the current live frame. `connection_capture_v4` has two successful nonuniform descriptors and covers late offer and receiver occupancy 0/255/256; the receiver boundary is deliberately injected. Actual producer FIFO/offer behavior is separately exercised by the original directed and six-seed full-system tests.

`connection_zero_v4` uses an independent all-zero camera image and asserts a successful zero descriptor (job 1, source 2, frame 0, timestamp 2476648), as well as 1,843,200 zero LCD/tap/mode samples. Black replacement frames remain ineligible. `connection_midloss_v4` demonstrates one failed descriptor, no publication for the damaged job, and a later successful valid source descriptor. All tests drain tags. The tag bench additionally exercises CE stalls and a partial in-flight stream reset with a new epoch. This local tag reset is not encrypted DDR warm restart evidence.

The original M5A raster guard starts in acquisition with bad_frame set until its first real delayed VS edge. The three final connection runs each observe 1,240,818 acquisition fault ticks, zero qualified/tap output during acquisition, and zero later raster faults on every checked cycle. First successful source timestamp 2476648 is after acquisition. These are pixel-domain tick observations, not wall-clock hardware measurements. No first qualified line or later legal raster fault is exempted.

## R3: cancellation and owned transactions

Cancellation can terminate only a request not yet owned by the arbiter, including a simultaneous start/cancel or cancel/READY edge. Accepted transactions, including downstream A-channel backpressure, retain owner and original payload through the real B or last R. A pending cancel prevents the next 4KiB segment. Engine abort retains the active write-source state, and metadata elapsed time is latched before a stalled write. Capture does not consume its FIFO into DRAIN while owned writes still need that payload. Timeout suppresses same-edge capture launch and FREEZE descriptor take; failed descriptors mark the job failed so an old snapshot cannot be exported as the failed job's result.

Final core evidence covers 10 logical transfer cases, seven actual completed DDR commands, four engine write sources and metadata stalls (711 real DDR commands/completions), plus three exact backend same-edge boundaries. Layered force/counter-boundary injection tests are supplemental, not substitutes for real full-frame or default-cycle tests. Accepted capture-drain evidence checks all 32 original class beats and the real B before failure cleanup. Capture, engine and export recovery tests each reach a subsequent successful job with correct identity; export failure preserves the already-published first result and later publishes job 2, with CRC-valid statistics recovered after the partial packet.

The full production limits are exercised for 96,000,000 capture cycles, 96,000,000 engine cycles and 960,000,000 export cycles. Their RT completion counts are 93,754 / 93,753 / 937,503; local cancellation is one and extra BG acceptance is zero. Default export exits 0, emits 712 bytes containing two CRC-valid statistics packets, and explicitly resynchronizes over a truncated payload at bytes 324..388. The 5000-UI cleanup budget uses an accelerated UART and a 100MHz TB clock; it is not a production-baud or exact board wall-clock guarantee. Production 460800-baud waveform and CRC coverage remain independently verified.

Six repair HDL mutations fail the intended oracles: extra LCD register, bypassed qualification (the stronger startup qualification assertion fires), absent local cancellation, zeroed abort payload, live metadata elapsed, and descriptor-take/timeout race. The original ten mutations and all seven original regression groups also pass with current source and runner hashes.

## Explicit irreversible hard-stop limitation

**A protocol watchdog emergency_stop withdraws stalled WVALID. This is an interface-isolation limitation, not universal AXI stable-VALID compliance.** Normal cancellation and ordinary soft_reset retain the strong stalled A/W stability assertions and real B/R drain. On actual protocol deadlock, the frozen fail-stop policy retains owner and transfer busy, makes no synthetic ACK, accepts no new handshake and publishes no new result; recovery requires cold reconfiguration. Work retained this boundary under repair-spec R3 and original SPEC sections 67/69; the new independent reviewers must assess it explicitly.

The final watchdog trace has calibration done/pass both 1 (not a calibration failure), owner 2, arbiter/transfer state 2 and busy 1. Backend states 3→16→7→8→17 cover CAPWAIT, FAULT_REPORT, STATS, STATS_WAIT and FAULT_IDLE. WVALID is withdrawn at the first hard-stop edge; the payload remains identical through this particular capture-fault trace. This does not claim that every inactive WDATA source remains frozen in every hard-stop scenario. Parent/current arbiter bytes and transfer stop gates are proven equal in EVIDENCE_SUMMARY; the original stalled-VALID failure log remains preserved.

DeepSeek B's proposed copy_mem bounds issue does not require a change: copy_next is already a 5-bit wire, so the index is bounded to 0..31. ID validation remains present. Only the XML-selected I3 SDC is active; the unused legacy pt.sdc is not an alternate signoff source.

Hardware performance, valid output rate, DDR warm restart and real multi-PVT testing remain pending. The 4us service model is conditional, 17us is rejected, and 64-pair/1-second processing may safely fail without publication. No fps promise, M5C implementation, Programmer action or hardware operation is included.
''')
 write('BUILD_REPORT.md',r'''
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
''')
 write('REPLAY.md',r'''
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
''')
 current='''## 2026-10-11 M5B.1修复离线验收交回（当前，待固定candidate双审查）

三项264962e0审查缺口已在真实连接与事务验收中关闭；冻结离线总门通过，尚不代表独立复审或硬件PASS。当前报告入口统一为`reports/m5b1_global_canny_i3/review_fix_264962e0/`下的`OFFLINE_ACCEPTANCE.json`、`IMPLEMENTATION.md`、`BUILD_REPORT.md`、`EVIDENCE_SUMMARY.json`、`TECHNICAL_DEPENDENCIES.json`与`PROPOSED_GIT_SCOPE.json`。根目录旧c010验收和旧bit叙述仅保留历史含义。

branch为codex/m5b1-global-canny-prototype；新candidate必须直接parent `264962e0c6af61e751c794c5b5f5252d00edbb6c`。仅精确清单提交，commit后立即停止所有写入交Work；本文件不自嵌commit ID，以Git交回为准。Work核对固定Git快照后盲审DeepSeek B，并停止给用户独立Codex A复审提示词。未做硬件操作。

真实LCD七模式逐像素、有效全零成功descriptor、无效/帧中失效后恢复、CE/标签复位、三阶段未受理取消、已受理A/W/B/R真实排空、metadata背压稳定、同拍边界、六项修复突变、原七组回归与十项突变均有当前源码/runner绑定。默认capture/engine 96M及export 960M周期全部通过；export exit0，712B/两CRC统计，截断包显式重同步。较早default_export_v2原因未知且仍为历史未达到oracle，未改成PASS。

build_20261010_235246完整exit0；45042 XLR/124 RAM10/0 DSP，setup/hold +0.196/+0.027ns，134份路径覆盖报告不是134个PVT角点。940精确pin/457结构CDC分类/413物理数据端点，最大clock-to-Q加数据1.415ns、skew0.825ns，新增内部时序三项0/0/0。新bit2924727B，SHA256 `8bc85b157426cf35e7aab31bc4acd1c8c54b5799c0e7a0424ee555f3927488c4`。96输入/53输出已绑定；1924非规则保护文件及两规则原前缀、2139历史未跟踪资料保持。

显著限制：协议watchdog硬停会撤销stalled WVALID，保留owner/busy、不伪ACK、无新握手/发布，仅冷重新配置；这是既有隔离边界，不能称普遍AXI稳定VALID合规，须交新A/B独立评估。正常取消/普通soft_reset仍强制稳定VALID及真实B/R。默认周期TB使用加速UART，5000UI收尾不是生产波特率上界；本地tag reset不是加密DDR warm restart。4us仅条件模型，不承诺fps；硬件、warm/PVT与真实有效发布率仍PENDING。M5C仅预留未实施。

'''
 for name in ['PROJECT_BRIEF','STATUS','DECISIONS','HANDOFF']:
  p=R/'docs'/f'{name}.md';s=p.read_text(encoding='utf-8');title,body=s.split('\n',1)
  if '## 2026-10-11 M5B.1修复离线验收交回（当前' in body:body=body.split('\n## ',2)[-1];raise AssertionError('Do not regenerate final docs over an existing closure')
  body=body.replace('（当前，修复验证未完成）','（历史续做检查点，已由顶部交回覆盖）').replace('（当前，未完成、未放行）','（历史检查点）').replace('（当前任务）','（历史任务）').replace('（当前）','（历史决定，边界仍有效）')
  p.write_text(title+'\n\n'+current+body.lstrip(),encoding='utf-8')
 print('REPAIR_REPORTS_WRITTEN',len(rows),'evidence receipts')

def __file_path():
 from pathlib import Path
 return Path(__file__)

if __name__=='__main__':main()
