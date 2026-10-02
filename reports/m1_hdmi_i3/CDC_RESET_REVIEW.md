# M1 reset and CDC review

Date: 2026-10-01. Scope: preserved vendor RTL and regenerated I3 native interface. This is static/code/STA review; no functional simulation, formal CDC proof, lock-loss simulation or hardware video measurement was performed.

## Clock domains and handoff

All mapped user FFs and the multiplier use clk_pixel. clk27m is routed to the native sys_pll reference, while clk_pixel_5x is the native serializer fast clock. The 10-bit TMDS words are registered/retimed pixel-domain results captured by the four HSIO serializers' slow clock. There is no fabric FIFO or arbitrary asynchronous multi-bit user-data crossing in this example. Generated I3 capture constraints plus 30-bit setup/hold reports substantiate the parallel handoff; they do not validate the internal analog PLL behavior or serial connector phase.

`Ti60_HDMI_1080P_Test.cdc.rpt` says no synchronizer warnings. This tool message does **not** certify asynchronous reset release, PLL lock sequencing, or that all potential CDC mechanisms were recognized. It must not be summarized as 'CDC safe'.

## Reset/lock findings

| Path | Source behavior | Proven and remaining boundary |
| --- | --- | --- |
| Physical24 MHz to pll_27m | no user RSTN port configured | Official design check passes, but reference stability and startup hold sequencing were not simulated/measured |
| pll_27m_LOCKED to sys_pll_RSTN | direct assign | Correct polarity: native RSTN is active low; unlocked0 holds second PLL reset, locked1 releases it. Official guidance supports holding cascaded PLL until upstream lock. Minimum10 ns assertion and lock pulse quality not proven |
| sys_pll_LOCKED to lcd_driver/lcd_display | direct active-low async reset release | Code sensitivity is posedge clk or negedge rst_n despite comments saying sync. No release synchronizer; recovery/removal and lock-glitch response not demonstrated |
| rgb2dvi reset ports | w_rst computed but unused | Three tmds_channel instances have no reset input. acc and tmds have RTL initial values; acc resets through normal control/blanking operation. This is not an explicit PLL-loss/reset sequence |
| Serializer reset/OE | four reset outputs tied0, OE tied1 | Reset available but never actively sequenced; startup phase/alignment and lock-loss recovery are not proven by constant timing paths |
| LOCKED to LEDs, SYS_RSTN | combinational status/control | 2 no_input_delay, 7 no_output_delay (6LED+SYS_RSTN) remain. No invented delays or false paths to hide them |

Official local Titanium PLL manual explicitly says LOCKED is not synchronized to any clock and pulses may be shorter than CLKOUT's period. Thus combinational assignment to sys_pll_RSTN proves the intended gating/polarity only, not a guaranteed valid reset pulse. All unknown recovery/removal and startup issues remain real verification boundaries even though regular data setup/hold passes.

## Acceptance boundary and follow-up

The requested independent I3 migration and offline build passed root's evidence review; see root_review.json. **Clock/reset robustness signoff remains open.** The 2026-10-02 user-reported independent HDMI test-pattern acceptance is PASS (several minutes without anomalies); monitor-reported mode remains pending. See ACCEPTANCE_REPORT.md. Preserving the six source files allowed clean migration evidence; no unsupported reset patch, clock inversion, pin swap, fabricated I/O budget or false path was introduced.

A separately scoped improvement can synchronize pixel reset release, qualify lock/reset duration against the official PLL requirements, provide serializer reset sequencing, and validate loss/relock with a meaningful testbench. Such changes should include their own simulation and complete I3 recompile and must preserve the already checked physical clock/pin interface. A future user-confirmed board test must first establish PCB revision and clock-pair mapping, then verify monitor mode, all four images, startup and repeated relock. No such physical action was executed in this task.

Evidence: rtl_integrity.json; generated pt.rpt/pt.sdc; final I3 timing.rpt; m1_hdmi_i3_check_timing.rpt; serializer setup/hold audits; source top/lcd_driver/lcd_display/rgb2dvi/tmds_channel; local E:/Efinity/2025.1/pt/doc/topics/titanium-pll.html.

2026-10-02 更新：用户报告独立 HDMI JTAG 图案循环正常，数分钟无异常；本文件对复位释放、启动/失锁恢复的专项未验收结论仍成立。最终 DB 的隔离 I3 数据时序复核及证据边界见 [FINAL_IMPLEMENTATION_AUDIT.md](FINAL_IMPLEMENTATION_AUDIT.md)。
