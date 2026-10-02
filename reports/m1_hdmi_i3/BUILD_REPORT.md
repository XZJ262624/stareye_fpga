# M1 HDMI I3 build report (historical offline build + current acceptance)

Current status (2026-10-02): **M1 independent HDMI baseline PASS**. User-reported JTAG test patterns worked for several minutes without anomalies; monitor resolution/refresh pending. Reset robustness remains open. See [ACCEPTANCE_REPORT.md](ACCEPTANCE_REPORT.md) and [FINAL_IMPLEMENTATION_AUDIT.md](FINAL_IMPLEMENTATION_AUDIT.md). The following 2026-10-01 offline-stage statements are historical. Current audit only uses isolated final STA; no P&R/pgm rebuild.

Date: 2026-10-01. Implementer: delegated GPT-6 Astra / Medium; root independently reviewed final I3 timing, endpoint coverage, warnings, source integrity, bit hash, board drawings and Git scope. Offline acceptance PASS; hardware and reset functional acceptance remain open. See root_review.json.

## Result and limits

PASS: official project/API migration, interface generation, synthesis, placement/routing, I3 setup/hold analysis, and offline bitstream generation. All six compiled vendor RTL files are byte-identical. This is an offline vendor-example build baseline, **not HDMI hardware acceptance, reset/CDC functional signoff, or electrical HDMI compliance certification**. No Programmer, hardware programming, JTAG transfer, SPI Active, Flash write, AR0135 integration, or Sobel work occurred.

Project: `F:/Projects/stareye_fpga/efinity/m1_hdmi_i3/Ti60_HDMI_1080P_Test.xml`.
Top: `Ti60_HDMI_1080P_Test`; Titanium / Ti60F225 / FBGA225 / I3 final.
Tool installation: `E:/Efinity/2025.1`; actual map/interface/P&R/STA/pgm reports identify **2025.1.110.5.9**.

## Migration and reproducibility

The source is the HDK archive's `06-FPGA_HDL_Basic-2023.2/07_Ti60_HDMI_1080P_Lvds_Test`, not a newly validated board revision. The original project declares C4, software 2023.1.150.3.11, and a historical D:/SVN_Path location. Necessary copy: six declared RTL files plus project XML, peri XML, and old SDC. Unused lcd_display_char.v, ip/, old outflow/, work directories and old bitstreams were not copied.

`scripts/m1_hdmi_i3_configure.py` uses official `projectdb.EfxProjectDatabase` to select Titanium/Ti60F225/I3, update software version, keep automatic debug insertion off and clear profile, then `DesignAPI.load/check_design/save/generate`. The official loader applied its PLL reference-clock migration patch (20241006) and saved db 20252006. No manual PLL/pin/RTL edits. Official `.pt.sdc` was copied to the project's `Ti60_HDMI_1080P_Test_I3.sdc`; projectdb selects this actual SDC. `VIP_System.sdc` is retained only as historical evidence and is not used.

Run, from repository root, the configure and compile .bat scripts; they call Efinity setup.bat and official flows. Configure recreates the authoritative SDC. The timing_audit .bat explicitly selects I3 inside Tcl, emits separate named coverage/serializer reports, and then restores standard I3 P&R and pgm output. The STA Tcl entry first loads its default C4; that initial diagnostic is excluded from acceptance. The final standard timing report and serializer audits explicitly identify I3.

## Validation evidence

| Check | Result | Evidence |
| --- | --- | --- |
| Configure + official interface API | exit 0 | configure.log |
| Full compile | exit 0; map/interface/pnr/pgm PASS | compile.log; stage_exitcodes.json |
| Explicit I3 audit and final I3 P&R/pgm restoration | exit 0 | timing_audit.log |
| Internal pixel-domain worst setup / hold | **+1.656 ns / +0.098 ns** | Ti60_HDMI_1080P_Test.timing.rpt |
| Core-to-LVDS data handoff | **30/30 endpoints**, worst setup **+4.029 ns**, hold **+0.245 ns** | m1_hdmi_i3_serializer_setup.rpt / serializer_hold.rpt |
| No clock / unconstrained internal endpoints / multiple clock | **0 / 0 / 0** | m1_hdmi_i3_check_timing.rpt |
| Unconstrained status inputs | 2: both PLL LOCKED signals | same report |
| Unconstrained outputs | 7: six LEDs and sys_pll_RSTN | same report |
| Vendor source integrity | six RTL identical; full source before/after inventory | rtl_integrity.json; original_diff.json |

The full compile log preserves official substage PASS statuses. Individual substage numeric exit codes were not separately captured; do not invent them. The outer command exit codes are captured. The audit wrapper stops on any failed stage.

Resource result: **551/60800 XLR (0.91%), 172 FF, 436 LUT4, 103 ADD, 1/160 DSP, 0/256 RAM, 2/4 PLL, 4 HSIO LVDS lanes, 3 global clocks**. FF/LUT/ADD are synthesis counts; XLR/DSP/RAM are final route counts.

## Warnings reviewed

- Interface: clk_25M at R13 is configured as pll_clkin but no PLL uses it. Current source uses C5/24 MHz. Kept unchanged, warning remains visible. This unused input does not supply sys_pll.
- Three `data_island_data(0)` 32-to-4 truncations; constants remain zero. Three 4-to-3 `mode({3'b0,DE})` truncations remove a leading zero, leaving video/control mode unchanged. oe_i(1) is 32-to-1 and remains one.
- Legacy rgb2dvi TMDS_Clk_p output and SerialClk input are unused: this design exports 10-bit encoded words to native HSIO serializers, not a fabric serializer in rgb2dvi. Grounding the unused SerialClk is not grounding the actual `clk_pixel_5x` interface clock.
- Loop variable i[31:12] removed as redundant by synthesis (20 lines).
- clk27m is unused by RTL logic, but remains an interface global clock for the second PLL's core reference. The interface/route reports prove the cascade; this warning is not a lost PLL reference.
- DSP CE permanently disabled warning: archived `dsp_warning_evidence.txt` shows CE=0, **P_REG=1 and P_REG_USE_CE=0**, while A/B/C/OP/W/O registers are disabled. Thus the sole enabled pipeline register ignores CE; this warning does not establish that the multiplication image is frozen. No RTL/netlist functional simulation was run.
- `Found 2 warnings in the post-synthesis netlist` is a summary of the clk27m/DSP warnings. Complete logs retained, no warning was suppressed.

## Bitstream

`F:/Projects/stareye_fpga/efinity/m1_hdmi_i3/outflow/Ti60_HDMI_1080P_Test.bit`

- Size: **1,626,948 bytes**.
- SHA256: **D96068C5D88EE861FD70F1FF4C82221DAE5582E5C1642366A631B053EA7B3E89**.
- Offline generation preserves vendor mode=active(x1), bit and hex options; these are file generation parameters, not a Flash operation.
- Downloaded: **no**. PCB revision, HDMI cable/monitor behavior, clock polarity at the connector, startup/lock-loss robustness and picture remain unverified.

See PIN_CLOCK_CHECK.md and CDC_RESET_REVIEW.md for clock, physical-interface, constraint and reset boundaries. No Git add/commit. Generated heavy files remain in ignored outflow/work directories; Git state evidence is archived separately.

## 2026-10-02 验收更新

上文 2026-10-01 未下载/未实物验收属于历史离线阶段。用户现已报告 JTAG 后独立 HDMI 测试图循环正常，数分钟无异常；显示器识别模式、下载文件精确哈希和原始日志仍待补充。整改后的真实流程状态解析、内部与 30 路 TMDS 正裕量检查及最终实现隔离 STA 绑定见 [FINAL_IMPLEMENTATION_AUDIT.md](FINAL_IMPLEMENTATION_AUDIT.md)。原始 bit 与完整 outflow 保持不变，未重跑 P&R/pgm。摄像头直通未验收。
